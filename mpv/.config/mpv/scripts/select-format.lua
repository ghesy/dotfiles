-- diplay a menu that lets you switch to different youtube-dl format.
-- source: https://github.com/jgreco/mpv-youtube-quality
--
-- I improved this version based on some of the open pull requests on this plugin's github page:
-- Improved to support extractors other than YouTube (ex. PeerTube),
-- Automatically fetch formats on video start,
-- Added ESC key for closing,
-- Improved font scaling and visibility,
-- Other minor improvements.

local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'
local assdraw = require 'mp.assdraw'

local opts = {
    --key bindings
    toggle_menu_binding = "ctrl+f",
    close_menu_binding = "ESC",
    up_binding = "k",
    down_binding = "j",
    pgup_binding = "ctrl+u",
    pgdown_binding = "ctrl+d",
    top_binding = "g",
    bottom_binding = "G",
    select_binding = "ENTER",

    --formatting / cursors ○●▷▶
    selected_and_active     = "● ",
    selected_and_inactive   = "● ",
    unselected_and_active   = "○ ",
    unselected_and_inactive = ". ",

    --font size scales by window, if false requires larger font and padding sizes
    scale_playlist_by_window=true,

    --playlist ass style overrides inside curly brackets, \keyvalue is one field, extra \ for escape in lua
    --example {\\fnUbuntu\\fs10\\b0\\bord1} equals: font=Ubuntu, size=10, bold=no, border=1
    --read http://docs.aegisub.org/3.2/ASS_Tags/ for reference of tags
    --undeclared tags will use default osd settings
    --these styles will be used for the whole playlist. More specific styling will need to be hacked in
    --
    --(a monospaced font is recommended but not required)
    style_ass_tags = "{\\fnmonospace\\fs9}",

    --paddings for top left corner
    text_padding_x = 5,
    text_padding_y = 5,

    --other
    menu_timeout = 10,

    --use youtube-dl to fetch a list of available formats (overrides quality_strings)
    fetch_formats = true,

    --default menu entries
    quality_strings=[[ [
    { "4320p" : "bestvideo[height<=?4320p]+bestaudio/best" },
    { "2160p" : "bestvideo[height<=?2160]+bestaudio/best" },
    { "1440p" : "bestvideo[height<=?1440]+bestaudio/best" },
    { "1080p" : "bestvideo[height<=?1080]+bestaudio/best" },
    { "720p"  : "bestvideo[height<=?720]+bestaudio/best" },
    { "480p"  : "bestvideo[height<=?480]+bestaudio[abr<=?70]/best" },
    { "360p"  : "bestvideo[height<=?360]+bestaudio[abr<=?70]/best" },
    { "240p"  : "bestvideo[height<=?240]+bestaudio[abr<=?70]/best" },
    { "144p"  : "bestvideo[height<=?144]+bestaudio[abr<=?70]/best" }
    ] ]],
}
(require 'mp.options').read_options(opts, "ytdl-quality")
opts.quality_strings = utils.parse_json(opts.quality_strings)

local destroyer = nil

function show_menu()
    local selected = 1
    local active = 0
    local current_ytdl_format = mp.get_property("ytdl-format")
    msg.verbose("current ytdl-format: "..current_ytdl_format)
    local num_options = 0
    local options = {}

    if opts.fetch_formats then
        options, num_options = download_formats()
    end

    if next(options) == nil then
        for i,v in ipairs(opts.quality_strings) do
            num_options = num_options + 1
            for k,v2 in pairs(v) do
                options[i] = {label = k, format=v2}
                if v2 == current_ytdl_format then
                    active = i
                    selected = active
                end
            end
        end
    end

    --set the cursor to the currently format
    for i,v in ipairs(options) do
        if v.format == current_ytdl_format then
            active = i
            selected = active
            break
        end
    end

    function selected_move(amt)
        selected = selected + amt
        if selected < 1 then selected = num_options
        elseif selected > num_options then selected = 1 end
        timeout:kill()
        timeout:resume()
        draw_menu()
    end
    function selected_top()
        selected = 1
        timeout:kill()
        timeout:resume()
        draw_menu()
    end
    function selected_bottom()
        selected = num_options
        timeout:kill()
        timeout:resume()
        draw_menu()
    end
    function choose_prefix(i)
        if     i == selected and i == active then return opts.selected_and_active
        elseif i == selected then return opts.selected_and_inactive end

        if     i ~= selected and i == active then return opts.unselected_and_active
        elseif i ~= selected then return opts.unselected_and_inactive end
        return "> " --shouldn't get here.
    end

    function draw_menu()
        local ass = assdraw.ass_new()

        ass:pos(opts.text_padding_x, opts.text_padding_y)
        ass:append(opts.style_ass_tags)

        for i,v in ipairs(options) do
            ass:append(choose_prefix(i)..v.label.."\\N")
        end

        local w, h = mp.get_osd_size()
        if opts.scale_playlist_by_window then w,h = 0, 0 end
        mp.set_osd_ass(w, h, ass.text)
    end

    function destroy()
        timeout:kill()
        mp.set_osd_ass(0,0,"")
        mp.remove_key_binding("move_up")
        mp.remove_key_binding("page_up")
        mp.remove_key_binding("move_down")
        mp.remove_key_binding("page_down")
        mp.remove_key_binding("move_top")
        mp.remove_key_binding("move_bottom")
        mp.remove_key_binding("select")
        mp.remove_key_binding("escape")
        mp.remove_key_binding("close")
        destroyer = nil
    end
    timeout = mp.add_periodic_timer(opts.menu_timeout, destroy)
    destroyer = destroy

    mp.add_forced_key_binding(opts.up_binding,     "move_up",     function() selected_move(-1) end, {repeatable=true})
    mp.add_forced_key_binding(opts.pgup_binding,   "page_up",     function() selected_move(-5) end, {repeatable=true})
    mp.add_forced_key_binding(opts.down_binding,   "move_down",   function() selected_move(1)  end, {repeatable=true})
    mp.add_forced_key_binding(opts.pgdown_binding, "page_down",   function() selected_move(5)  end, {repeatable=true})
    mp.add_forced_key_binding(opts.top_binding,    "move_top",    function() selected_top()    end, {repeatable=true})
    mp.add_forced_key_binding(opts.bottom_binding, "move_bottom", function() selected_bottom() end, {repeatable=true})
    mp.add_forced_key_binding(opts.select_binding, "select",
        function()
            destroy()
            mp.set_property("ytdl-format", options[selected].format)
            reload_resume()
        end
    )
    mp.add_forced_key_binding(opts.toggle_menu_binding, "escape", destroy)
    mp.add_forced_key_binding(opts.close_menu_binding, "close", destroy) --close menu using ESC

    draw_menu()
    return
end

local ytdl = {
    path = "youtube-dl",
    searched = false,
    blacklisted = {}
}

-- shorten and format the given number (eg. 4560 -> 4.5K)
function numshorten(n)
    n = tonumber(n)
    if n >= 10^9 then
        return string.format("%.1fG", n/10^9)
    elseif n >= 10^6 then
        return string.format("%.1fM", n/10^6)
    elseif n >= 10^3 then
        return string.format("%.1fK", n/10^3)
    else
        return string.format("%.1f", n)
    end
end

function pri_vcodec(s)
    if not s then return 0 end
    s = s:gsub("%..*", "")
    if s == "av01" then
        return 8
    elseif s == "vp9" then
        return 7
    elseif s == "h265" or s == "hevc" then
        return 6
    elseif s == "h264" or s == "avc1" then
        return 5
    elseif s == "vp8" then
        return 4
    elseif s == "h263" then
        return 3
    elseif s == "theora" then
        return 2
    else
        return 1
    end
end

function pri_acodec(s)
    if not s then return 0 end
    s = s:gsub("%..*", "")
    if s == "flac" or s == "alac" then
        return 11
    elseif s == "wav" or s == "aiff" then
        return 10
    elseif s == "opus" then
        return 9
    elseif s == "vorbis" then
        return 8
    elseif s == "aac" then
        return 7
    elseif s == "mp4a" then
        return 6
    elseif s == "mp3" then
        return 5
    elseif s == "eac3" then
        return 4
    elseif s == "ac3" then
        return 3
    elseif s == "dts" then
        return 2
    else
        return 1
    end
end

function pri_protocol(s)
    if s == "https" or s == "ftps" then
        return 8
    elseif s == "http" or s == "ftp" then
        return 7
    elseif s == "m3u8_native" or s == "m3u8" then
        return 6
    elseif s == "http_dash_segments" then
        return 5
    elseif s == "websocket_frag" then
        return 4
    elseif s == "mms" or s == "rtsp" then
        return 3
    elseif s == "f4f3" or s == "f4m" then
        return 2
    elseif s == nil then
        return 0
    else
        return 1
    end
end

function pri_hdr(s)
    if s == "DV" then
        return 7
    elseif s == "HDR12" then
        return 6
    elseif s == "HDR10+" then
        return 5
    elseif s == "HDR10" then
        return 4
    elseif s == "HLG" then
        return 3
    elseif s == "SDR" then
        return 2
    elseif s == nil then
        return 0
    else
        return 1
    end
end

format_cache={}
function download_formats()
    local function exec(args)
        local ret = utils.subprocess({capture_stderr = true, args = args})
        return ret.status, ret.stdout, ret
    end

    local function table_size(t)
        s = 0
        for i,v in ipairs(t) do
            s = s+1
        end
        return s
    end

    local url = mp.get_property("path")
    url = string.gsub(url, "ytdl://", "") -- Strip possible ytdl:// prefix.

    -- don't fetch the format list if we already have it
    if format_cache[url] ~= nil then
        local formats = format_cache[url]
        return formats, table_size(formats)
    end
    -- mp.osd_message("Fetching formats...", 60)

    if not (ytdl.searched) then
        local ytdl_mcd = mp.find_config_file("youtube-dl")
        if not (ytdl_mcd == nil) then
            msg.verbose("found youtube-dl at: " .. ytdl_mcd)
            ytdl.path = ytdl_mcd
        end
        ytdl.searched = true
    end

    local command = {ytdl.path, "--no-warnings", "--no-playlist", "-j"}
    table.insert(command, url)
    local es, json, result = exec(command)

    if (es < 0) or (json == nil) or (json == "") then
        -- mp.osd_message("Fetching formats failed...", 1)
        msg.verbose("failed to get format list: " .. es)
        return {}, 0
    end

    local json, err = utils.parse_json(json)

    if (json == nil) or (json.formats == nil) then
        -- mp.osd_message("Fetching formats failed...", 1)
        if (err ~= nil) then msg.warn("failed to parse JSON data: " .. err) end
        return {}, 0
    end

    formats = {}
    msg.verbose("youtube-dl succeeded!")
    for _,f in ipairs(json.formats) do

        if ((f.vcodec == nil or f.vcodec == "none" or f.vcodec == "null") and
            (f.acodec == nil or f.acodec == "none" or f.acodec == "null") and
            (f.width  == nil or f.width  == "none" or f.width  == "null") and
            (f.height == nil or f.height == "none" or f.height == "null") and
            (f.vbr    == nil or f.vbr    == "none" or f.vbr    == "null") and
            (f.abr    == nil or f.abr    == "none" or f.abr    == "null") and
            (f.tbr    == nil or f.tbr    == "none" or f.tbr    == "null")) or
            f.ext == "mhtml" or f.protocol == "mhtml" then
            goto continue
        end

        local res, fps, hdr, codec, br, asr, format, audiofmt, maxpx

        if (f.vcodec == nil or  f.vcodec == "none" or  f.vcodec == "null") and
           (f.acodec ~= nil and f.acodec ~= "none" and f.acodec ~= "null") then
            -- audio-only formats
            res = "audio-only"
            fps = ""
            hdr = ""
            codec = f.acodec or ""
            br = f.abr or f.tbr or ""
            asr = f.asr and "SR="..numshorten(f.asr) or ""
            format = string.format("%s/bestaudio", f.format_id)
        else
            -- video formats
            res = (f.width or "?").."x"..(f.height or "?")
            codec = f.vcodec or ""
            asr = ""
            br = f.vbr or f.tbr or ""
            fps = f.fps and "FPS="..f.fps or ""
            if f.dynamic_range and f.dynamic_range ~= "SDR" then
                hdr = " "..f.dynamic_range.." "
            else
                hdr = ""
            end
            -- if width or height are less than 1000 pixels, set the maximum audio bitrate to 70 kbps.
            maxpx = math.max(tonumber(f.width or "1"), tonumber(f.height or "1"))
            if maxpx < 1000 then
                audiofmt = "bestaudio[abr<=70]"
            else
                audiofmt = "bestaudio"
            end
            format = string.format("%s+%s/%s+bestaudio/%s/best", f.format_id, audiofmt, f.format_id, f.format_id)
        end
        codec = codec:gsub("%..*", ""):gsub("av01", "av1"):gsub("avc1", "h264"):gsub("h265", "hevc")
        if br and tonumber(br) then
            br = "BR="..numshorten(br*10^3)
        else
            br = ""
        end
        local label = string.format("%-11s%-8s%s%-6s%-10s%s", res, fps, hdr, codec, br, asr)
        table.insert(formats,
            { label=label, format=format, width=f.width,
            height=f.height, fps=f.fps, hdr=f.dynamic_range, vcodec=f.vcodec,
            acodec=f.acodec, vbr=f.vbr, abr=f.abr, asr=f.asr, protocol=f.protocol, id=f.format_id }
        )

        ::continue::
    end

    table.sort(formats,
        function(a, b)
            if (a.width or 1) * (a.height or 1) > (b.width or 1) * (b.height or 1) then
                return true
            elseif (a.width or 1) * (a.height or 1) < (b.width or 1) * (b.height or 1) then
                return false
            elseif (a.fps or 0) > (b.fps or 0) then
                return true
            elseif (a.fps or 0) < (b.fps or 0) then
                return false
            elseif pri_hdr(a.hdr) > pri_hdr(b.hdr) then
                return true
            elseif pri_hdr(a.hdr) < pri_hdr(b.hdr) then
                return false
            elseif pri_vcodec(a.vcodec) > pri_vcodec(b.vcodec) then
                return true
            elseif pri_vcodec(a.vcodec) < pri_vcodec(b.vcodec) then
                return false
            elseif pri_acodec(a.acodec) > pri_acodec(b.acodec) then
                return true
            elseif pri_acodec(a.acodec) < pri_acodec(b.acodec) then
                return false
            elseif (a.vbr or 0) > (b.vbr or 0) then
                return true
            elseif (a.vbr or 0) < (b.vbr or 0) then
                return false
            elseif (a.asr or 0) > (b.asr or 0) then
                return true
            elseif (a.asr or 0) < (b.asr or 0) then
                return false
            elseif pri_protocol(a.protocol) > pri_protocol(b.protocol) then
                return true
            elseif pri_protocol(a.protocol) < pri_protocol(b.protocol) then
                return false
            else
                return a.id > b.id
            end
        end
    )

    -- mp.osd_message("", 0)
    format_cache[url] = formats
    return formats, table_size(formats)
end

-- register script message to show menu
mp.register_script_message("toggle-quality-menu",
    function()
        if destroyer ~= nil then
            destroyer()
        else
            show_menu()
        end
    end
)

-- keybind to launch menu
mp.add_key_binding(opts.toggle_menu_binding, "quality-menu", show_menu)

-- special thanks to reload.lua (https://github.com/4e6/mpv-reload)
function reload(path, time_pos)
    if time_pos == nil then
        mp.commandv("loadfile", path, "replace")
    else
        mp.commandv("loadfile", path, "replace", "start=+" .. time_pos)
    end
end
function reload_resume()
    local path = mp.get_property("path", property_path)
    local time_pos = mp.get_property("time-pos")
    local reload_duration = mp.get_property_native("duration")
    local playlist_count = mp.get_property_number("playlist/count")
    local playlist_pos = mp.get_property_number("playlist-pos")
    local playlist = {}
    for i = 0, playlist_count-1 do
        playlist[i] = mp.get_property("playlist/" .. i .. "/filename")
    end
    if reload_duration and reload_duration > 0 then
        reload(path, time_pos)
    elseif reload_duration and reload_duration == 0 then
        reload(path, time_pos)
    else
        reload(path, nil)
    end
    for i = 0, playlist_pos-1 do
        mp.commandv("loadfile", playlist[i], "append")
    end
    mp.commandv("playlist-move", 0, playlist_pos+1)
        for i = playlist_pos+1, playlist_count-1 do
    mp.commandv("loadfile", playlist[i], "append")
    end
end

mp.register_event("start-file", download_formats)
