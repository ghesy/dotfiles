-- config
COMMENTS_KEY = 'ctrl+c'
DESCRIPTION_KEY = 'ctrl+d'
---

local mp = require 'mp'

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

desc = {}
function get_comments_and_description()
    local path = string.gsub(mp.get_property("path"), "ytdl://", "")
    if (shell.exec{"test", "-f", path} == true) then return end

    local status, stdout = exec{"/bin/sh", "-c", "youtube-dl -jq " ..
        shell.escape{path} .. " | jq -r .description > /tmp/mpv.description"}
    if status < 0 then return end

    local status, stdout = exec{"/bin/sh", "-c", "pipe-viewer --no-interactive " ..
        "--no-use-colors --comments=" .. shell.escape{path} .. " > /tmp/mpv.comments"}
    if status < 0 then return end
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
