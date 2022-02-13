-- fetch and show comments and description of videos.
-- requires yt-dlp (youtube-dl can't fetch comments).
-- author: Ehsan Ghorbannezhad <ehsan@disroot.org>

-- config
DESCRIPTION_KEY = 'ctrl+d' -- binding to open the video description in your pager in a new terminal window.
COMMENTS_KEY = 'ctrl+c' -- same as above but for the comments.
TRY_PROXYCHAINS = true -- try to use proxychains for connection if normal connection is not possible.
MAX_COMMENTS = 10 -- limit the number of comments to fetch.
MAX_REPLIES = 5 -- limit the number of replies per comment to fetch.
WRAPCOL = 70 -- wrap lines longer that this many characters.
COMMENTS_PREFIX = '│'
CACHEDIR = (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME").."/.cache").."/description"
---

local mp = require 'mp'
local utils = require 'mp.utils'
descfile = {}

-- execute shell commands using mpv's subprocess command
local function exec(args)
    local r = mp.command_native({name = "subprocess", args = args,
        capture_stdout = true, capture_stderr = true})
    return r.status == 0, r.stdout
end

-- asynchronously execute shell commands using mpv's subprocess command
local function execasync(fn, args)
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

-- get the source url of a downloaded video file from it's metadata
function getfileurl(path)
    local status, url = exec{"ffprobe", "-loglevel", "error",
        "-show_entries", "format_tags=purl", "-of", "default=nk=1:nw=1", path}
    if status == false or url == nil then url = "" end
    return url:gsub("\n", "")
end

-- get the url of the currently playing video
function geturl()
    local url = string.gsub(mp.get_property("path"), "ytdl://", "")
    if isfile(url) then return getfileurl(url) else return url end
end

-- separate the given string into lines.
function getlines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

-- wrap lines of the given string to WRAPCOL columns.
function wrap(s)
    local w = {}
    for line in getlines(s) do
        if #line <= WRAPCOL then
            w[#w + 1] = line .. "\n"
        else
            -- find the position of the first space character before the WRAPCOLth column
            local brk = line:sub(1, WRAPCOL):reverse():find("%s")
            if brk ~= nil then
                brk = WRAPCOL - (brk - 1)
            else
                brk = WRAPCOL
            end
            w[#w + 1] = string.sub(line, 1, brk) .. "\n"
            w[#w + 1] = wrap(string.sub(line, brk+1, -1))
        end
    end
    return table.concat(w)
end

-- open description or comments in a pager in a terminal window
function pager(f)
    local file = descfile[geturl()][f]
    if not isfile(file) then return end
    local term = os.getenv("TERMINAL")
    if term then
        shexec{term, "-e", os.getenv("PAGER") or "less", file}
    else
        shexec{"xdg-open", file}
    end
end

-- save the description and comments fetch by fetchdesc() to CACHEDIR
function savedesc(success, result, error)
    if (not success) or (result.status ~= 0) then return end
    local json = utils.parse_json(result.stdout)
    if not json then return end
    if not exec{"mkdir", "-pm700", CACHEDIR} then return end
    local url = geturl()

    -- format and write the description to cache
    if json.description then
        local f = assert(io.open(descfile[url].desc, "w"))
        f:write(wrap(json.description))
        f:close()
    end

    -- format and write the comments to cache
    if not json.comments then return end
    local f = assert(io.open(descfile[url].comm, "w"))
    for i,v in ipairs(json.comments) do
        local op = "" local fav = "" local indent = COMMENTS_PREFIX
        if v.parent ~= "root" then indent = "   "..COMMENTS_PREFIX end
        if v.author_is_uploader then op = " " end
        if v.is_favorited then fav = " " end
        local text = indent..v.author..op..fav.." • "..v.like_count..
            " Likes".." • "..v.time_text.."\n"..v.text
        text = wrap(text):gsub("\n$", ""):gsub("\n", "\n"..indent)
        f:write(text, "\n\n\n")
    end
    f:close()
end

-- download description and comments and hand it to savedesc()
function fetchdesc()
    -- if the video is a local file, return
    local url = geturl()
    if url == nil or url == "" then return end

    -- set the path of cache files
    local id = url:gsub(".-%w/", ""):gsub("[^%w%-_]", ""):reverse()
    descfile[url] = {}
    descfile[url].desc = CACHEDIR.."/"..id..".desc"
    descfile[url].comm = CACHEDIR.."/"..id..".comm"
    if isfile(descfile[url].desc) or isfile(descfile[url].comm) then return end

    -- get the video's infojson using yt-dlp and send it's result to formatdesc()
    local args = {"yt-dlp", "--no-playlist", "-j", "--write-comments", "--extractor-args",
        "youtube:comment_sort=top;max_comments=all,"..MAX_COMMENTS..",all,"..MAX_REPLIES, "--", url}

    if TRY_PROXYCHAINS then
        local status, stdout = exec{"curl", "-sLIm8", "--", url}
        if status == false or stdout == "" then
            args = {"proxychains", "-q", unpack(args)}
        end
    end
    execasync(savedesc, args)
end

mp.add_forced_key_binding(DESCRIPTION_KEY, "show_description", function() pager("desc") end)
mp.add_forced_key_binding(COMMENTS_KEY, "show_comments", function() pager("comm") end)
mp.register_event("start-file", fetchdesc)
