-- author: Ehsan Ghorbannezhad <ehsan@disroot.org>
-- set mpv's cache-secs to a different value on network videos.

local opts = {
    cache_secs = 200
}
(require "mp.options").read_options(opts)

local orig_cache_secs = ""

function update_cache_secs()
    local path = mp.get_property("path")
    if isempty(path) then
        return
    elseif isempty(orig_cache_secs) then
        orig_cache_secs = mp.get_property("cache-secs")
    end
    mp.set_property("cache-secs",
        is_network_stream(path) and opts.cache_secs or orig_cache_secs)
end

function is_network_stream(path)
    local proto = path:match("^(%a+)://")
    if not proto then return false end
    for _, p in ipairs{
        "http", "https", "ytdl", "rtmp", "rtmps", "rtmpe", "rtmpt", "rtmpts",
        "rtmpte", "rtsp", "rtsps", "mms", "mmst", "mmsh", "mmshttp", "rtp",
        "srt", "srtp", "gopher", "gophers", "data", "ftp", "ftps", "sftp"} do
        if proto == p then return true end
    end
    return false
end

function isempty(var)
    return var == nil or var == ""
end

mp.register_event("start-file", update_cache_secs)
