-- config
DESCRIPTION_KEY = 'ctrl+d'
COMMENTS_KEY = 'ctrl+c'
COMMENTS_PREFIX = "│"
WRAPCOL = 75
---

local mp = require 'mp'
local utils = require 'mp.utils'

-- local shell = {}
-- function shell.escape(args)
--     local ret = {}
--     for _,a in pairs(args) do
--         s = tostring(a)
--         if s:match("[^A-Za-z0-9_/:=-]") then
--             s = "'"..s:gsub("'", "'\\''").."'"
--         end
--         table.insert(ret,s)
--     end
--     return table.concat(ret, " ")
-- end

-- function shell.exec(args)
--     return os.execute(shell.escape(args))
-- end

local function exec(args)
    local r = mp.command_native({name = "subprocess", args = args,
        capture_stdout = true, capture_stderr = true})
    return r.status == 0, r.stdout
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
    local s = string.gsub(s, "\r", "")
    for line in getlines(s) do
        local len = ulen(line)
        if len == nil then len = #line end
        if len <= WRAPCOL then
            w[#w + 1] = line
        else
            -- find the position of the first space character before the WRAPCOLth column
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

-- -- https://github.com/philanc/plc/blob/master/plc/checksum.lua
-- local function crc32(s)
--     local b, crc, mask
--     crc = 0xffffffff
--     for i = 1, #s do
--         b = string.byte(s, i)
--         crc = crc ~ b
--         for _ = 1, 8 do
--             mask = -(crc & 1)
--             crc = (crc >> 1) ~ (0xedb88320 & mask)
--         end
--     end
--     return (~crc) & 0xffffffff
-- end

function isfile(path)
   local f = io.open(path, "r")
   if f ~= nil then io.close(f) return true else return false end
end

desc = {}
function get_comm_desc()
    local url = string.gsub(mp.get_property("path"), "ytdl://", "")
    if isfile(url) then return end

    local status, json = exec{"yt-dlp", "--no-playlist", "-j", "--write-comments",
        "--extractor-args", "youtube:comment_sort=top;max_comments=100", url}
    if not status then return end
    local json = utils.parse_json(json)
    if not json then return end

    dir = (os.getenv("XDG_CACHE_HOME") or os.getenv("HOME").."/.cache").."/comments"
    if not exec{"mkdir", "-pm700", dir} then return end

    -- local id = crc32(url)
    local id = json.id
    comm = dir.."/"..id..".comm"
    desc = dir.."/"..id..".desc"

    if (not isfile(desc)) and json.description then
        local f = assert(io.open(desc, "w"))
        f:write(wrap(json.description))
        f:close()
    end

    if isfile(comm) or (not json.comments) then return end
    local f = assert(io.open(comm, "w"))
    for i,v in ipairs(json.comments) do
        local op = "" local fav = "" local indent = ""
        if v.author_is_uploader then op = " " end
        if v.is_favorited then fav = " " end
        if v.parent ~= "root" then indent = "   " end
        f:write(v.author, op, fav, " • ", v.likes, " Likes", " • ",
            v.time_text, "\n", COMMENTS_PREFIX,
            string.gsub(wrap(v.text), "\n", indent..COMMENTS_PREFIX.."\n"), "\n")
    end
    f:close()
end

function page(file)
    term = os.getenv("TERMINAL")
    if term then
        exec{"setsid", "-f", term, "-e", os.getenv("PAGER") or "less", file}
    else
        exec{"setsid", "-f", "xdg-open", file}
    end
end

mp.add_forced_key_binding(COMMENTS_KEY, "show_comments", function() page(comm) end)
mp.add_forced_key_binding(DESCRIPTION_KEY, "show_description", function() page(desc) end)
mp.register_event("start-file", get_comm_desc)
