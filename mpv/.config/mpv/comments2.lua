-- config
COMMENTS_KEY = 'ctrl+c'
DESCRIPTION_KEY = 'ctrl+d'
COMMENTS_WRAP = 75
COMMENTS_PREFIX = "│"
---

local mp = require 'mp'
local utils = require 'mp.utils'

local shell = {}
function shell.escape(args)
    local ret = {}
    for _,a in pairs(args) do
        s = tostring(a)
        if s:match("[^A-Za-z0-9_/:=-]") then
            s = "'"..s:gsub("'", "'\\''").."'"
        end
        table.insert(ret,s)
    end
    return table.concat(ret, " ")
end

function shell.exec(args)
    return os.execute(shell.escape(args))
end

local function exec(args)
    local r = mp.command_native({name = "subprocess", args = args,
        capture_stdout = true, capture_stderr = true})
    return r.status, r.stdout
end

-- separate the given string into lines.
function getlines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

-- get the number of bytes that contain n utf8 characters from the string s.
function uchar(s, n)
    return utf8.offset(s, n+1)-1
end

-- wrap lines of the given string to WRAP columns.
function wrap(s)
    local w = {}
    for line in getlines(s) do
        local len = utf8.len(line)
        if len == nil then len = #line end
        if len <= WRAP then
            w[#w + 1] = line
        else
            -- find the position of the first space character before the WRAPth column
            local brk = string.find(string.reverse(string.sub(line, 1, uchar(line, WRAP))), "%s")
            if brk ~= nil then
                brk = uchar(line, WRAP - (brk - 1))
            else
                brk = uchar(line, WRAP)
            end
            w[#w + 1] = string.sub(line, 1, brk) .. "\n"
            w[#w + 1] = wrap(string.sub(line, brk+1, -1))
        end
    end
    return table.concat(w)
end

function t(cond ,T ,F)
    if cond then return T else return F end
end

desc = {}
function get_comments_and_description()
    local path = string.gsub(mp.get_property("path"), "ytdl://", "")
    if (shell.exec{"test", "-f", path} == true) then return end

    -- local status, stdout = exec{"/bin/sh", "-c", "youtube-dl -jq " ..
    --     shell.escape{path} .. " | jq -r .description > /tmp/mpv.description"}
    -- if status < 0 then return end

    -- local status, stdout = exec{"/bin/sh", "-c", "pipe-viewer --no-interactive " ..
    --     "--no-use-colors --comments=" .. shell.escape{path} .. " > /tmp/mpv.comments"}
    -- if status < 0 then return end

    local status, json = exec{"/bin/sh", "-c", "yt-dlp --no-playlist -j --write-comments " ..
        "--extractor-args 'youtube:max_comments=100;comment_sort=top' " ..
        shell.escape{path}}
    if (status < 0) or (json == nil) or (json == "") then return end

    local json = utils.parse_json(json)
    if (json == nil) or (json.formats == nil) then return end

    io.output("/tmp/comments.wat")
    for i,v in ipairs(json.comments) do
        local op = "" local fav = "" local indent = ""
        if v.author_is_uploader then op = " " end
        if v.is_favorited then fav = " " end
        if v.parent ~= "root" then indent = "   " end
        io.write(v.author, op, fav, " • ", v.likes, " Likes", " • ",
            v.time_text, "\n", COMMENTS_PREFIX,
            string.gsub(wrap(v.text), "\n", indent..COMMENTS_PREFIX.."\n"), "\n")
    end

    --proxychains -q youtube-dl -j --write-comments \
    ----extractor-args 'youtube:max_comments=100;comment_sort=top' "${1:?}"

end

function show_comments()
    if (shell.exec{"test", "-f", "/tmp/mpv.comments"} ~= true) then return end
    os.execute("setsid -f $TERMINAL -e less /tmp/mpv.comments")
end

function show_description()
    if (shell.exec{"test", "-f", "/tmp/mpv.description"} ~= true) then return end
    os.execute("setsid -f $TERMINAL -e less /tmp/mpv.description")
end

mp.register_event("start-file", get_comments_and_description)
mp.add_forced_key_binding(COMMENTS_KEY, "show_comments", show_comments)
mp.add_forced_key_binding(DESCRIPTION_KEY, "show_description", show_description)
