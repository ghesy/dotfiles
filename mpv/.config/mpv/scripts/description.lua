-- author: Ehsan Ghorbannezhad <ehsan@disroot.org>
-- fetch and show video description, comments, likes, dislikes etc.
-- requires yt-dlp (youtube-dl can't fetch comments) and curl.

local opts = {
    try_proxychains = true, -- try to use proxychains for connection if normal connection is not possible. requires proxychains.
    max_comments = 10, -- limit the number of comments to fetch.
    max_replies = 5, -- limit the number of replies per comment to fetch.
    max_width = 70, -- wrap lines longer that this many characters.
    comment_prefix = "│", -- the string appearing before each line of the comments
    section_separator = "\n"..string.rep("=", 75).."\n\n", -- the string appearing between each section (description, comments etc.)
    cache_dir = (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME").."/.cache").."/description", -- where to save the files
    dislike_api_base = "https://returnyoutubedislikeapi.com/votes?videoId=", -- base URL of the returnyoutubedislike API
    ytdlp_path = "yt-dlp"
}
(require 'mp.options').read_options(opts)

local utils = require 'mp.utils'
descfile = {}

-- if table.unpack() isn't available, use unpack() instead
if not table.unpack then
    table.unpack = unpack
end

-- execute shell commands using mpv's subprocess command
function exec(args)
    local r = mp.command_native({name = "subprocess", args = args,
        capture_stdout = true, capture_stderr = true})
    return r.status == 0, r.stdout
end

-- asynchronously execute shell commands using mpv's subprocess command
function execasync(fn, args)
    mp.command_native_async({name = "subprocess", args = args,
        capture_stdout = true, capture_stderr = true}, fn)
end

-- execute shell commands by escaping args and feeding them to os.execute()
function shexec(args)
    local t = {}
    for _, a in pairs(args) do
        local s = tostring(a)
        if s:match("[^A-Za-z0-9_/:=-]") then
            s = "'"..s:gsub("'", "'\\''").."'"
        end
        table.insert(t, s)
    end
    return os.execute("setsid -f "..table.concat(t, " ").." >/dev/null 2>&1")
end

function isnetworkstream(path)
    local proto = path:match("^(%a+)://")
    if not proto then return false end
    for _, p in ipairs{
        "http", "https", "ytdl", "rtmp", "rtmps", "rtmpe", "rtmpt", "rtmpts",
        "rtmpte", "rtsp", "rtsps", "mms", "mmst", "mmsh", "mmshttp", "rtp",
        "srt", "srtp", "gopher", "gophers", "data", "ftp", "ftps", "sftp"} do
        if proto == p then return true end
    end
    return false
end

-- test wether the given path is a file
function isfile(path)
    local f = io.open((path:gsub("^file://", "")), "r")
    if f then io.close(f) return true else return false end
end

-- get the source URL of a downloaded video file from it's metadata
function getfileurl(path)
    local success, url = exec{"ffprobe", "-loglevel", "error",
        "-show_entries", "format_tags=purl", "-of", "default=nk=1:nw=1", "--", path}
    if success == false or (not url) then url = "" end
    return url:gsub("\n", "")
end

-- get the URL of the currently playing video
function geturl()
    local path = mp.get_property("path")
    if (not path) or path:find("^archive://") then
        return false
    elseif isfile(path) then
        return getfileurl(path)
    elseif isnetworkstream(path) then
        return path:gsub("^ytdl://", "")
    end
end

-- test wether the given URL belongs to youtube
function isyoutube(url)
    local patterns = {"w*%.?youtu%.be/", "w*%.?youtube%.com/"}
    for _, pattern in ipairs(patterns) do
        if url:gsub("^https?://", ""):find(pattern) then return true end
    end
    return false
end

-- separate the given string into lines.
function getlines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

-- wrap lines of the given string to opts.max_width columns.
function wrap(s)
    local w = {}
    for line in getlines(s) do
        if #line <= opts.max_width then
            w[#w + 1] = line .. "\n"
        else
            -- find the position of the first space character before the opts.max_width-th column
            local brk = line:sub(1, opts.max_width):reverse():find("%s")
            if brk then
                brk = opts.max_width - (brk - 1)
            else
                brk = opts.max_width
            end
            w[#w + 1] = string.sub(line, 1, brk) .. "\n"
            w[#w + 1] = wrap(string.sub(line, brk+1, -1))
        end
    end
    return table.concat(w)
end

-- shorten and format the given number (eg. 4560 -> 4.5K)
function numshorten(n)
    if n >= 10^6 then
        return string.format("%.1fM", n/10^6)
    elseif n >= 10^3 then
        return string.format("%.1fK", n/10^3)
    else
        return tostring(n)
    end
end

-- round the given number
function round(n)
    return math.floor(n+0.5)
end

-- generate a nice unicode progress bar
function progressbar(percent)
    local step = 5
    local phases = {' ', '▏', '▎', '▍', '▌', '▋', '▊', '▉', '█'}
    local nwhole = math.floor(percent / step)
    local nphase = round(percent % step / (step / (#phases - 1)))
    local nempty = (100 / step) - (nwhole + 1)
    local phasechar = phases[nphase+1]
    if percent == 100 then phasechar = '' end

    return "─" .. string.rep(phases[#phases], nwhole) .. phasechar ..
        string.rep(' ', nempty) .. "─"
end

-- open the description file in a pager inside a terminal window.
function opendesc()
    local url = geturl()
    if (not url) or url == "" then return end
    local file = descfile[url]
    if not isfile(file) then return end
    local term = os.getenv("TERMINAL")
    if term then
        shexec{term, "-e", os.getenv("PAGER") or "less", file}
    else
        shexec{"xdg-open", file}
    end
end

-- save the info fetched by fetchdesc() to opts.cache_dir.
function savedesc(url, success, result, error)
    if (not success) or (result.status ~= 0) then return end
    local json = utils.parse_json(result.stdout)
    if not json then return end
    if not exec{"mkdir", "-pm700", "--", opts.cache_dir} then return end

    -- if none of the important info are available, do not proceed
    if (not json.description) and (not json.comments) and
       (not json.like_count)  and (not json.dislike_count) then
        return
    end

    -- open the file for writing
    local f = assert(io.open(descfile[url], "w"))

    -- write extractor info
    if json.extractor or json.webpage_url_domain then
        f:write("source: ")
        if json.webpage_url then f:write(json.webpage_url) end
        if json.extractor then f:write(" - ", json.extractor) end
        if json.extractor_key then f:write(" - ", json.extractor_key) end
        f:write("\n", opts.section_separator)
    end

    -- write title, channel name, like and view count etc.
    if json.title       then f:write("title:   ", json.title,   "\n") end
    if json.channel     then f:write("channel: ", json.channel, "\n") end
    if json.upload_date then f:write("date:    ", formatdate(json.upload_date), "\n") end
    if json.view_count  then f:write("views:   ", numshorten(json.view_count), "\n") end

    -- if it's a youtube video, get the dislike count from returnyoutubedislike's API
    if (not json.dislike_count) and isyoutube(url) then
        local success, stdout = exec{"curl", "-fsL", "--", opts.dislike_api_base..json.id}
        if success == true and stdout ~= "" then
            json.dislike_count = utils.parse_json(stdout).dislikes
        end
    end

    -- write likes and dislikes
    if json.like_count and json.dislike_count then f:write("\n ") end
    if json.like_count or  json.dislike_count then
        local nlike = "-"
        local ndislike = "-"
        if json.like_count    then nlike    = numshorten(json.like_count)    end
        if json.dislike_count then ndislike = numshorten(json.dislike_count) end
        f:write(string.format("%-9s    %9s\n", "﨓"..nlike, "﨑"..ndislike))
    end
    if json.like_count and json.dislike_count then
        local percent = json.like_count / (json.like_count + json.dislike_count) * 100
        percent = string.format("%.2f", percent)
        f:write("        ", percent, "%\n", progressbar(percent), "\n")
    end

    f:write(opts.section_separator)

    -- write description
    if json.description then
        f:write(wrap(json.description), opts.section_separator)
    end

    -- format and write comments
    if json.comments then
        for i,v in ipairs(json.comments) do
            local op = "" local fav = "" local indent = opts.comment_prefix
            if v.parent ~= "root" then indent = "   "..opts.comment_prefix end
            if v.author_is_uploader then op = " " end
            if v.is_favorited then fav = " " end
            local text = indent .. v.author .. op .. fav .. "   " .. "﨓" ..
                numshorten(v.like_count) .. "   "..v.time_text.."\n"..v.text
            text = wrap(text):gsub("\n$", ""):gsub("\n", "\n"..indent)
            f:write(text, "\n\n\n")
        end
    end
    f:close()
end

function formatdate(date)
    local date = os.time{
        year = date:match("^%d%d%d%d"),
        month = date:match("(%d%d)%d%d$"),
        day = date:match("%d%d$")
    }
    return os.date("%Y-%m-%d", date)
end

-- generate a unique ID for the given URL, suitable for use as a filename
function genid(url)
    return url:gsub("^.-[^:/]/", ""):gsub("^watch%?v=", ""):gsub("[^%w%-_]", "-")
end

-- download the info asyncronously and hand them to savedesc()
function fetchdesc()
    -- return if no URL is associated with the video
    local url = geturl()
    if (not url) or url == "" then return end

    -- set the path of the cache file
    local id = genid(url)
    descfile[url] = opts.cache_dir.."/"..id..".txt"

    -- return if the info is already downloaded and saved
    if isfile(descfile[url]) then return end

    -- get the video's infojson using yt-dlp and send it's result to formatdesc()
    local args = {opts.ytdlp_path, "--no-playlist", "-j", "--write-comments", "--extractor-args",
        "youtube:comment_sort=top;max_comments=all,"..opts.max_comments..",all,"..opts.max_replies, "--", url}

    if opts.try_proxychains then
        local success, stdout = exec{"curl", "-sLIm8", "--", url}
        if success == false or stdout == "" then
            args = {"proxychains", "-q", table.unpack(args)}
        end
    end
    execasync(function(a, b, c) savedesc(url, a, b, c) end, args)
end

mp.register_event("start-file", fetchdesc)
mp.add_key_binding(nil, "show", opendesc)
