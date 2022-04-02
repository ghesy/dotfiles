local opts = {
    youtubedl_path = "yt-dlp",
    prefix_cursor      = "● ",
    prefix_norm_sel    = "○ ",
    prefix_norm        = ". ",
    prefix_header      = "- ",
    menu_timeout_sec = 10,
    menu_padding_x = 5,
    menu_padding_y = 5,
    ass_style = "{\\fnmonospace\\fs8}",
}

local keys = {
    { {"UP",    "k"},       "up",     function() menu_cursor_move(-1) end, {repeatable=true} },
    { {"DOWN",  "j"},       "down",   function() menu_cursor_move( 1) end, {repeatable=true} },
    { {"PGUP",  "ctrl+u"},  "pgup",   function() menu_cursor_move(-5) end, {repeatable=true} },
    { {"PGDWN", "ctrl+d"},  "pgdwn",  function() menu_cursor_move( 5) end, {repeatable=true} },
    { {"g"},                "top",    function() menu_cursor_move("top")    end },
    { {"G"},                "bottom", function() menu_cursor_move("bottom") end },
    { {"ENTER"},            "select", function() menu_select() end },
    { {"ESC"},              "quit",   function() menu_hide()   end },
}

local utils = require "mp.utils"
local assdraw = require "mp.assdraw"
local data = {}
local url = ""

-- fetch the formats using youtube-dl asyncronously and hand them to formats_save()
function formats_fetch()
    if not update_url() then return end
    local args = {opts.youtubedl_path, "--no-playlist", "-j", "--", url}
    execasync(function(a, b, c) formats_save(url, a, b, c) end, args)
end

-- process the formats fetched by fetch_formats()
function formats_save(url, success, result, error)
    if (not success) or (result.status ~= 0) then return end
    local json = utils.parse_json(result.stdout)
    if (not json) or (not json.formats) then return end
    data[url] = {}
    data[url].formats = {}
    for _, fmt in ipairs(json.formats) do
        if is_format_valid(fmt) then
            fmt.label = build_format_label(fmt)
            fmt.ytdl_format = build_ytdl_format_str(fmt)
            table.insert(data[url].formats, fmt)
        end
    end
    table.sort(data[url].formats, format_sort_fn)
end

-- show/hide the menu
function menu_toggle()
    if not update_url() then return end
    if is_menu_active() then menu_hide() else menu_show() end
end

function menu_show()
    if no_formats_available() then return end
    menu_init_vars()
    menu_draw()
    menu_keys("bind")
end

function menu_init_vars()
    if data[url].timer then
        data[url].timer:resume()
    else
        data[url].timer = mp.add_periodic_timer(opts.menu_timeout_sec, menu_hide)
    end
    if not data[url].cursor_pos then data[url].cursor_pos = 1 end
    if not data[url].selected_pos then data[url].selected_pos = 0 end
end

function no_formats_available()
    return (not data[url]) or (not data[url].formats) or (#data[url].formats < 0)
end

function menu_hide()
    data[url].timer:kill()
    mp.set_osd_ass(0, 0, "")
    menu_keys("unbind")
end

function menu_draw()
    local ass = assdraw.ass_new()
    ass:pos(opts.menu_padding_x, opts.menu_padding_y)
    ass:append(opts.ass_style)
    ass:append(opts.prefix_header..get_menu_header().."\\N")
    for idx, fmt in ipairs(data[url].formats) do
        ass:append(menu_get_prefix(idx))
        ass:append(fmt.label.."\\N")
    end
    mp.set_osd_ass(0, 0, ass.text)
end

function menu_get_prefix(i)
    if i == data[url].cursor_pos then
        return opts.prefix_cursor
    elseif i == data[url].selected_pos then
        return opts.prefix_norm_sel
    else
        return opts.prefix_norm
    end
end

-- bind/unbind the menu movement/action keys
function menu_keys(action)
    for _, i in ipairs(keys) do
        if action == "bind" then
            for _, key in ipairs(i[1]) do
                mp.add_forced_key_binding(key, i[2], i[3], i[4])
            end
        elseif action == "unbind" then
            mp.remove_key_binding(i[2])
        end
    end
end

function menu_cursor_move(i)
    if i == "top" then
        data[url].cursor_pos = 1
    elseif i == "bottom" then
        data[url].cursor_pos = #data[url].formats
    else
        data[url].cursor_pos = data[url].cursor_pos + i
        if data[url].cursor_pos < 1 then
            data[url].cursor_pos = 1
        elseif data[url].cursor_pos > #data[url].formats then
            data[url].cursor_pos = #data[url].formats
        end
    end
    menu_timer_restart()
    menu_draw()
end

function menu_select()
    local sel = data[url].cursor_pos
    data[url].selected_pos = sel
    mp.set_property("ytdl-format", data[url].formats[sel].ytdl_format)
    menu_hide()
    reload_resume()
end

function menu_timer_restart()
    data[url].timer:kill()
    data[url].timer:resume()
end

function is_menu_active()
    return data[url] and data[url].timer and data[url].timer:is_enabled() or false
end

-- build the youtube-dl format option for the given format
function build_ytdl_format_str(fmt)
    if is_format_audioonly(fmt) then
        return string.format("%s/bestaudio", fmt.format_id)
    else
        local audiofmt = "bestaudio"
        maxpx = math.max(tonumber(fmt.width or "1"), tonumber(fmt.height or "1"))
        if maxpx < 1000 then audiofmt = "bestaudio[abr<=70]" end
        return string.format("%s+%s/%s+bestaudio/%s/best",
            fmt.format_id, audiofmt, fmt.format_id, fmt.format_id)
    end
end

-- build the label that represents the format in the UI
function build_format_label(fmt)
    local res, codec, br, formatstr
    if is_format_audioonly(fmt) then
        res = "audio-only"
        codec = fmt.acodec or ""
        br = fmt.abr or fmt.tbr or ""
    else
        res = (fmt.width or "?").."x"..(fmt.height or "?")
        codec = fmt.vcodec or ""
        br = fmt.vbr or fmt.tbr or ""
    end
    if codec ~= "" then
        codec = codec:gsub("%..*", ""):gsub("av01", "av1")
        codec = codec:gsub("avc1", "h264"):gsub("h265", "hevc")
    end
    if br ~= "" and tonumber(br) then
        br = numshorten(br*10^3)
    end
    return label_formatfn(
        res,
        fmt.fps or "",
        codec,
        br,
        fmt.asr and numshorten(fmt.asr) or "",
        fmt.protocol or ""
    )
end

function get_menu_header()
    return label_formatfn("Resolution", "FPS", "Codec", "BR", "ASR", "Proto")
end

function label_formatfn(...)
    return string.format("%-10s %-3s %-5s %-4s %-4s %s", ...)
end

-- function for sorting the formats table
function format_sort_fn(a, b)
    local params = {
        "fps", "dynamic_range", "vcodec",
        "acodec", "tbr", "vbr", "abr", "asr", "protocol"
    }
    a.res = (a.width or 1) * (a.height or 1)
    b.res = (b.width or 1) * (b.height or 1)
    if     a.res > b.res then return true
    elseif a.res < b.res then return false end
    for _, param in ipairs(params) do
        local x = get_param_precedence(param, a[param])
        local y = get_param_precedence(param, b[param])
        if     x > y then return true
        elseif x < y then return false end
    end
    return tostring(a.format_id) > tostring(b.format_id)
end

-- rate the given parameter value based on it's precedence
function get_param_precedence(param, value)
    local order = {
        ["dynamic_range"] = {
            {"sdr"}, {"^$"},  {"hlg"},  {"h?d?r?10$"},  {"h?d?r?10%+"},
            {"h?d?r?12"}, {"dv"}
        },
        ["vcodec"] = {
            {"theora"}, {"mp4v", "h263"}, {"vp0?8"}, {"[hx]264", "avc"},
            {"[hx]265", "he?vc"}, {"vp0?9$"}, {"vp0?9%.2"}, {"av0?1"},
        },
        ["acodec"] = {
            {"dts"}, {"^ac%-?3"}, {"e%-?a?c%-?3"}, {"mp3"}, {"mp?4a?"}, {"avc"},
            {"vorbis", "ogg"}, {"opus"}
        },
        ["protocol"] = {
            {"f4"}, {"ws", "websocket$"}, {"mms", "rtsp"}, {"^$"}, {"rtmpe?"},
            {"websocket_frag"}, {".*dash"}, {"m3u8.*"}, {"http$", "ftp$"},
            {"https", "ftps"},
        },
    }
    if isempty(order[param]) then
        return tonumber(value) or 0
    elseif isempty(value) then
        value = ""
    end
    local n = 1
    for _, patternlist in ipairs(order[param]) do
        for _, pattern in ipairs(patternlist) do
            if value:find(pattern) then
                return n
            end
        end
        n = n + 1
    end
    return 0
end

-- test wether the format contains any usable information
function is_format_valid(fmt)
    if fmt.ext == "mhtml" or fmt.protocol == "mhtml" then
        return false
    end
    local params = {"vcodec", "acodec", "width", "height", "vbr", "abr", "tbr"}
    for _, param in ipairs(params) do
        if is_param_valid(fmt[param]) then
            return true
        end
    end
    return false
end

-- test wether the given format only contains an audio stream
function is_format_audioonly(fmt)
    return is_param_valid(fmt.acodec) and (not is_param_valid(fmt.vcodec))
end

function is_param_valid(p)
    return p and p ~= "none" and p ~= "null"
end

-- update the global url variable with the URL of the currently playing video
function update_url()
    local path = string.gsub(mp.get_property("path"), "ytdl://", "")
    if isfile(path) then
        return false
    else
        url = path
        return true
    end
end

-- shorten and format the given number (eg. 4560 -> 4.5K)
function numshorten(n)
    n = tonumber(n)
    if     n >= 10^9 then return string.format("%dG", n/10^9)
    elseif n >= 10^6 then return string.format("%dM", n/10^6)
    elseif n >= 10^3 then return string.format("%dK", n/10^3)
    else                  return string.format("%d" , n) end
end

-- test wether the given path is a file
function isfile(path)
   local f = io.open(path, "r")
   if f ~= nil then io.close(f) return true else return false end
end

function isempty(var)
    return (not var) or var == ""
end

-- asynchronously execute shell commands using mpv's subprocess command
function execasync(fn, args)
    mp.command_native_async({name = "subprocess", args = args,
        capture_stdout = true, capture_stderr = true}, fn)
end

-- this segment is taken from reload.lua (https://github.com/4e6/mpv-reload, commit c1219b6)
function reload(time_pos)
    if not time_pos then
        mp.commandv("loadfile", url, "replace")
    else
        mp.commandv("loadfile", url, "replace", "start=+" .. time_pos)
    end
end
function reload_resume()
    local time_pos = mp.get_property("time-pos")
    local reload_duration = mp.get_property_native("duration")
    local playlist_count = mp.get_property_number("playlist/count")
    local playlist_pos = mp.get_property_number("playlist-pos")
    local playlist = {}
    for i = 0, playlist_count-1 do
        playlist[i] = mp.get_property("playlist/" .. i .. "/filename")
    end
    if reload_duration and reload_duration >= 0 then
        reload(time_pos)
    else
        reload()
    end
    for i = 0, playlist_pos-1 do
        mp.commandv("loadfile", playlist[i], "append")
    end
    mp.commandv("playlist-move", 0, playlist_pos+1)
    for i = playlist_pos+1, playlist_count-1 do
        mp.commandv("loadfile", playlist[i], "append")
    end
end

mp.register_event("start-file", formats_fetch)
mp.add_key_binding(nil, "menu", menu_toggle)
