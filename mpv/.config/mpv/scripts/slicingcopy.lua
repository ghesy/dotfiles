-- cut and save fragments of videos.
-- source: https://github.com/snylonue/mpv_slicing_copy

local opts = {
    ffmpeg_path = "ffmpeg",
    target_dir = "~/Documents/Fragments",
    overwrite = false, -- whether to overwrite existing files
    vcodec = "copy",
    acodec = "copy",
}
(require 'mp.options').read_options(opts)

local msg = require "mp.msg"
local utils = require "mp.utils"

local cut_pos = nil
local command_template = {
    ss = "$shift",
    t = "$duration",
}

Command = {}

function Command:new(name)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    opts.name = ""
    opts.args = { "" }
    if name then
        opts.name = name
        opts.args[1] = name
    end
    return o
end
function Command:arg(...)
    for _, v in ipairs({...}) do
        self.args[#self.args + 1] = v
    end
    return self
end
function Command:as_str()
    return table.concat(self.args, " ")
end
function Command:run()
    local res, err = mp.command_native({
        name = "subprocess",
        args = self.args,
        capture_stdout = true,
        capture_stderr = true,
    })
    return res, err
end

local function file_format()
    local fmt = mp.get_property("file-format")
    if not fmt:find(',') then
        return fmt
    end
    local filename = mp.get_property('filename')
    local name = mp.get_property('filename/no-ext')
    return filename:sub(name:len() + 2)
end

local function timestamp(duration)
    local hours = math.floor(duration / 3600)
    local minutes = math.floor(duration % 3600 / 60)
    local seconds = duration % 60
    return string.format("%02d:%02d:%02.03f", hours, minutes, seconds)
end

local function osd(str)
    return mp.osd_message(str, 3)
end

local function info(s)
    msg.info(s)
    osd(s)
end

local function get_outname(shift, endpos)
    local name = mp.get_property("filename/no-ext")
    local fmt = file_format()
    name = string.format("%s_%s-%s.%s", name, timestamp(shift), timestamp(endpos), fmt)
    return name:gsub(":", "-")
end

local function cut(shift, endpos)
    local inpath = mp.get_property("stream-open-filename")
    local outpath = utils.join_path(
        opts.target_dir,
        get_outname(shift, endpos)
    )
    local ua = mp.get_property('user-agent')
    local referer = mp.get_property('referrer')
    local cmds = Command:new(opts.ffmpeg_path)
        :arg("-v", "warning")
        :arg(opts.overwrite and "-y" or "-n")
        :arg("-stats")
    if ua and ua ~= '' and ua ~= 'libmpv' then
        cmds:arg('-user_agent', ua)
    end
    if referer and referer ~= '' then
        cmds:arg('-referer', referer)
    end
    cmds:arg("-ss", (command_template.ss:gsub("$shift", shift)))
        :arg("-i", inpath)
        :arg("-t", (command_template.t:gsub("$duration", endpos - shift)))
        :arg("-c:v", opts.vcodec)
        :arg("-c:a", opts.acodec)
        :arg(outpath)
    msg.info("Run commands: " .. cmds:as_str())
    local res, err = cmds:run()
    if err then
        msg.error(utils.to_string(err))
    elseif res.stderr ~= "" or res.stdout ~= "" then
        msg.info("stderr: " .. (res.stderr:gsub("^%s*(.-)%s*$", "%1"))) -- trim stderr
        msg.info("stdout: " .. (res.stdout:gsub("^%s*(.-)%s*$", "%1"))) -- trim stdout
    end
end

local function toggle_mark()
    local pos, err = mp.get_property_number("time-pos")
    if not pos then
        osd("Failed to get timestamp")
        msg.error("Failed to get timestamp: " .. err)
        return
    end
    if cut_pos then
        local shift, endpos = cut_pos, pos
        if shift > endpos then
            shift, endpos = endpos, shift
        elseif shift == endpos then
            osd("Cut fragment is empty")
            return
        end
        cut_pos = nil
        info(string.format("Cut fragment: %s-%s", timestamp(shift), timestamp(endpos)))
        cut(shift, endpos)
    else
        cut_pos = pos
        info(string.format("Marked %s as start position", timestamp(pos)))
    end
end

local function clear_toggle_mark()
    cut_pos = nil
    info("Cleared cut fragment")
end

opts.target_dir = opts.target_dir:gsub('"', "")
file, _ = utils.file_info(mp.command_native({ "expand-path", opts.target_dir }))
if not file then
    os.execute("mkdir -p " .. opts.target_dir)
elseif not file.is_dir then
    osd("target_dir is a file")
    msg.warn(string.format("target_dir `%s` is a file", opts.target_dir))
end
opts.target_dir = mp.command_native({ "expand-path", opts.target_dir })
mp.add_key_binding(nil, "slicing-mark", toggle_mark)
mp.add_key_binding(nil, "slicing-mark-clear", clear_toggle_mark)
