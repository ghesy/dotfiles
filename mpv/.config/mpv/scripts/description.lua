-- author: Ehsan Ghorbannezhad <ehsan@disroot.org>
-- fetch and show video description, comments, likes, dislikes etc.
-- requires yt-dlp (youtube-dl can't fetch comments) and curl.

-- config
KEY = "ctrl+d" -- binding to open the file containing the description, comments etc.
TRY_PROXYCHAINS = true -- try to use proxychains for connection if normal connection is not possible. requires proxychains.
MAX_COMMENTS = 10 -- limit the number of comments to fetch.
MAX_REPLIES = 5 -- limit the number of replies per comment to fetch.
MAX_WIDTH = 70 -- wrap lines longer that this many characters.
COMMENT_PREFIX = "│" -- the string appearing before each line of the comments
SECTION_SEPARATOR = "\n"..string.rep("=", 75).."\n\n" -- the string appearing between each section (description, comments etc.)
CACHE_DIR = (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME").."/.cache").."/description" -- where to save the files
DISLIKE_API_BASE = "https://returnyoutubedislikeapi.com/votes?videoId=" -- base URL of the returnyoutubedislike API
--

local mp = require 'mp'
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
    for _,a in pairs(args) do
        s = tostring(a)
        if s:match("[^A-Za-z0-9_/:=-]") then
            s = "'"..s:gsub("'", "'\\''").."'"
        end
        table.insert(t, s)
    end
    return os.execute("setsid -f "..table.concat(t, " ").." >/dev/null 2>&1")
end

-- test wether the given path is a file
function isfile(path)
   local f = io.open(path, "r")
   if f ~= nil then io.close(f) return true else return false end
end

-- get the source URL of a downloaded video file from it's metadata
function getfileurl(path)
    local success, url = exec{"ffprobe", "-loglevel", "error",
        "-show_entries", "format_tags=purl", "-of", "default=nk=1:nw=1", path}
    if success == false or url == nil then url = "" end
    return url:gsub("\n", "")
end

-- get the URL of the currently playing video
function geturl()
    local url = string.gsub(mp.get_property("path"), "ytdl://", "")
    if isfile(url) then return getfileurl(url) else return url end
end

-- test wether the given URL belongs to youtube
function isyoutube(url)
    return url:find("://youtu%.be/") ~= nil or url:find("://w*%.?youtube%.com/") ~= nil
end

-- separate the given string into lines.
function getlines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

-- wrap lines of the given string to MAX_WIDTH columns.
function wrap(s)
    local w = {}
    for line in getlines(s) do
        if #line <= MAX_WIDTH then
            w[#w + 1] = line .. "\n"
        else
            -- find the position of the first space character before the MAX_WIDTHth column
            local brk = line:sub(1, MAX_WIDTH):reverse():find("%s")
            if brk ~= nil then
                brk = MAX_WIDTH - (brk - 1)
            else
                brk = MAX_WIDTH
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

    return ">" .. string.rep(phases[#phases], nwhole) .. phasechar ..
        string.rep(' ', nempty) .. "<"
end

-- open description or comments in a pager in a terminal window
function opendesc()
    local file = descfile[geturl()]
    if not isfile(file) then return end
    local term = os.getenv("TERMINAL")
    if term then
        shexec{term, "-e", os.getenv("PAGER") or "less", file}
    else
        shexec{"xdg-open", file}
    end
end

-- save the description and comments fetched by fetchdesc() to CACHE_DIR
function savedesc(success, result, error)
    if (not success) or (result.status ~= 0) then return end
    local json = utils.parse_json(result.stdout)
    if not json then return end
    if not exec{"mkdir", "-pm700", CACHE_DIR} then return end
    local url = geturl()

    -- if no important info is available, do not proceed
    if (not json.description) and (not json.comments) and
       (not json.like_count)  and (not json.dislike_count) then
        return
    end

    -- open the file for writing
    local f = assert(io.open(descfile[url], "w"))

    -- write extractor info
    if json.extractor or json.webpage_url_domain then
        f:write("Source: ")
        if json.extractor then f:write(json.extractor) end
        if json.extractor_key then f:write(" - ", json.extractor_key) end
        if json.webpage_url_domain then f:write(" - ", json.webpage_url_domain) end
        f:write("\n", SECTION_SEPARATOR)
    end

    -- write title, channel name, like and view count etc.
    if json.title      then f:write("Title: ",   json.title,   "\n") end
    if json.channel    then f:write("Channel: ", json.channel, "\n") end
    if json.view_count then f:write(numshorten(json.view_count), " views\n") end

    -- if it's a youtube video, get the dislike count from returnyoutubedislike's API
    if not json.dislike_count and isyoutube(url) then
        local success, stdout = exec{"curl", "-fsL", "--", DISLIKE_API_BASE..json.id}
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

    f:write(SECTION_SEPARATOR)

    -- write description
    if json.description then
        f:write(wrap(json.description), SECTION_SEPARATOR)
    end

    -- format and write the comments to cache
    if json.comments then
        for i,v in ipairs(json.comments) do
            local op = "" local fav = "" local indent = COMMENT_PREFIX
            if v.parent ~= "root" then indent = "   "..COMMENT_PREFIX end
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

-- generate a unique ID for the given URL
function genid(url)
    local id = url:gsub("^.-[^:/]/", "")
    if isyoutube(url) then
        id = id:gsub("^watch%?v=", "")
    end
    return id:gsub("[^%w%-_]", "")
end

-- download description and comments and hand it to savedesc()
function fetchdesc()
    -- return if no URL is associated with the video
    local url = geturl()
    if url == nil or url == "" then return end

    -- set the path of cache files
    local id = genid(url)
    descfile[url] = CACHE_DIR.."/"..id..".txt"
    if isfile(descfile[url]) then return end

    -- get the video's infojson using yt-dlp and send it's result to formatdesc()
    local args = {"yt-dlp", "--no-playlist", "-j", "--write-comments", "--extractor-args",
        "youtube:comment_sort=top;max_comments=all,"..MAX_COMMENTS..",all,"..MAX_REPLIES, "--", url}

    if TRY_PROXYCHAINS then
        local success, stdout = exec{"curl", "-sLIm8", "--", url}
        if success == false or stdout == "" then
            args = {"proxychains", "-q", table.unpack(args)}
        end
    end
    execasync(savedesc, args)
end

mp.add_forced_key_binding(KEY, "show_description", opendesc)
mp.register_event("start-file", fetchdesc)
