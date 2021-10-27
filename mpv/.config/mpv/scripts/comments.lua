-- get the description and comments of videos.
-- config
DESCRIPTION_KEY = 'ctrl+d'
COMMENTS_KEY = 'ctrl+c'
MAX_COMMENTS = 200
COMMENTS_PREFIX = "│"
WRAPCOL = 75
CACHEDIR = (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME").."/.cache").."/description"
---

local mp = require 'mp'
local utils = require 'mp.utils'

local function exec(args)
    local r = mp.command_native({name = "subprocess", args = args,
        capture_stdout = true, capture_stderr = true})
    return r.status == 0, r.stdout
end

function shexec(args)
    local ret = {}
    for _,a in pairs(args) do
        s = tostring(a)
        if s:match("[^A-Za-z0-9_/:=-]") then
            s = "'"..s:gsub("'", "'\\''").."'"
        end
        table.insert(ret,s)
    end
    return os.execute(table.concat(ret, " "))
end

-- separate the given string into lines.
function getlines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

-- get the number of bytes that contain n utf8 characters from the string s.
--function uchar(s, n) return utf8.offset(s, n+1)-1 end
function uchar(s, n) return n end

--function ulen(s) return utf8.len(line) end
function ulen(s) return #s end

-- wrap lines of the given string to WRAPCOL columns.
function wrap(s)
    local w = {}
    for line in getlines(s) do
        local len = ulen(line)
        if len == nil then len = #line end
        if len <= WRAPCOL then
            w[#w + 1] = line .. "\n"
        else
            -- find the position of the first space character before the WRAPCOLth column
            --local brk = line:sub(1, WRAPCOL):reverse():find("%s")
            local brk = string.find(string.reverse(string.sub(line, 1, uchar(line, WRAPCOL))), "%s")
            if brk ~= nil then
                brk = uchar(line, WRAPCOL - (brk - 1))
            else
                brk = uchar(line, WRAPCOL)
            end
            w[#w + 1] = string.sub(line, 1, brk) .. "\n"
            w[#w + 1] = wrap(string.sub(line, brk+1, -1))
        end
    end
    return table.concat(w)
end

function isfile(path)
   local f = io.open(path, "r")
   if f ~= nil then io.close(f) return true else return false end
end

function geturl()
    return string.gsub(mp.get_property("path"), "ytdl://", "")
end

descfile = {}
function savedesc()
    local url = geturl()
    if isfile(url) then return end

    local id = url:gsub(".-%w/", ""):gsub("[^%w%-_]", ""):reverse()
    descfile[url] = {}
    descfile[url].desc = CACHEDIR.."/"..id..".desc"
    descfile[url].comm = CACHEDIR.."/"..id..".comm"
    if isfile(descfile[url].desc) or isfile(descfile[url].comm) then return end

    local status, json = exec{"yt-dlp", "--no-playlist", "-j", "--write-comments",
        "--extractor-args", "youtube:comment_sort=top;max_comments="..MAX_COMMENTS,
        "--", url}
    if not status then return end
    local json = utils.parse_json(json)
    if not json then return end

    if not exec{"mkdir", "-pm700", CACHEDIR} then return end

    if json.description then
        local f = assert(io.open(descfile[url].desc, "w"))
        f:write(wrap(json.description))
        f:close()
    end

    if not json.comments then return end
    local f = assert(io.open(descfile[url].comm, "w"))
    for i,v in ipairs(json.comments) do
        local op = "" local fav = "" local indent = COMMENTS_PREFIX
        if v.author_is_uploader then op = " " end
        if v.is_favorited then fav = " " end
        if v.parent ~= "root" then indent = "   "..COMMENTS_PREFIX end
        local text = indent..v.author..op..fav.." • "..v.like_count..
            " Likes".." • "..v.time_text.."\n"..v.text
        text = wrap(text):gsub("\n$", ""):gsub("\n", "\n"..indent)
        f:write(text, "\n\n")
    end
    f:close()
end

function page(f)
    local file = descfile[geturl()][f]
    if not isfile(file) then return end
    local term = os.getenv("TERMINAL")
    if term then
        shexec{"setsid", "-f", term, "-e", os.getenv("PAGER") or "less", file, ">/dev/null 2>&1"}
    else
        shexec{"setsid", "-f", "xdg-open", file, ">/dev/null 2>&1"}
    end
end

mp.add_forced_key_binding(COMMENTS_KEY, "show_comments", function() page("comm") end)
mp.add_forced_key_binding(DESCRIPTION_KEY, "show_description", function() page("desc") end)
mp.register_event("start-file", savedesc)
