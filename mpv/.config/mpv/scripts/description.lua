-- get the description and comments of videos.
-- config
DESCRIPTION_KEY = 'ctrl+d'
COMMENTS_KEY = 'ctrl+c'
MAX_COMMENTS = 300 -- set to 0 to fetch all comments
MAX_REPLIES = 10 -- set to 0 to show all replies
COMMENTS_PREFIX = "│"
WRAPCOL = 70
CACHEDIR = (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME").."/.cache").."/description"
---

local mp = require 'mp'
local utils = require 'mp.utils'

-- execute shell commands using mpv's subprocess command
local function exec(args)
    local r = mp.command_native({name = "subprocess", args = args,
        capture_stdout = true, capture_stderr = true})
    return r.status == 0, r.stdout
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

-- separate the given string into lines.
function getlines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

-- test wether the given path is a file
function isfile(path)
   local f = io.open(path, "r")
   if f ~= nil then io.close(f) return true else return false end
end

-- get the path/url of the currently playing video
function geturl()
    return string.gsub(mp.get_property("path"), "ytdl://", "")
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
function page(f)
    local file = descfile[geturl()][f]
    if not isfile(file) then return end
    local term = os.getenv("TERMINAL")
    if term then
        shexec{term, "-e", os.getenv("PAGER") or "less", file}
    else
        shexec{"xdg-open", file}
    end
end

-- download and save description and comments to CACHEDIR
descfile = {}
function savedesc()

    -- if the video is a local file, return
    local url = geturl()
    if isfile(url) then return end

    -- set the path of cache files
    local id = url:gsub(".-%w/", ""):gsub("[^%w%-_]", ""):reverse()
    descfile[url] = {}
    descfile[url].desc = CACHEDIR.."/"..id..".desc"
    descfile[url].comm = CACHEDIR.."/"..id..".comm"
    if isfile(descfile[url].desc) or isfile(descfile[url].comm) then return end

    -- get the video's infojson using yt-dlp
    local maxcomments = ""
    if MAX_COMMENTS > 0 then maxcomments = ";max_comments="..MAX_COMMENTS end
    local status, json = exec{"yt-dlp", "--no-playlist", "-j", "--write-comments",
        "--extractor-args", "youtube:comment_sort=top"..maxcomments,
        "--", url}
    if not status then return end
    local json = utils.parse_json(json)
    if not json then return end

    if not exec{"mkdir", "-pm700", CACHEDIR} then return end

    -- format and write the description to cache
    if json.description then
        local f = assert(io.open(descfile[url].desc, "w"))
        f:write(wrap(json.description))
        f:close()
    end

    -- format and write the comments to cache
    if not json.comments then return end
    local f = assert(io.open(descfile[url].comm, "w"))
    local replies = 0
    for i,v in ipairs(json.comments) do
        local op = "" local fav = "" local indent = COMMENTS_PREFIX
        if v.parent == "root" then
            replies = 0
        else
            if MAX_REPLIES > 0 then
                replies = replies + 1
                if replies > MAX_REPLIES then goto continue end
            end
            indent = "   "..COMMENTS_PREFIX
        end
        if v.author_is_uploader then op = " " end
        if v.is_favorited then fav = " " end
        local text = indent..v.author..op..fav.." • "..v.like_count..
            " Likes".." • "..v.time_text.."\n"..v.text
        text = wrap(text):gsub("\n$", ""):gsub("\n", "\n"..indent)
        f:write(text, "\n\n\n")
        ::continue::
    end
    f:close()
end

mp.register_event("start-file", savedesc)
mp.add_forced_key_binding(DESCRIPTION_KEY, "show_description", function() page("desc") end)
mp.add_forced_key_binding(COMMENTS_KEY, "show_comments", function() page("comm") end)
