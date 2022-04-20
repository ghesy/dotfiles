-- author: Ehsan Ghorbannezhad <ehsan@disroot.org>
-- set mpv's cache-secs to a different value on network videos.

local opts = {
    cache_secs = 120
}
(require "mp.options").read_options(opts)

local orig_cache_secs = ""

function update_cache_secs()
    local path = mp.get_property("path")
    if isempty(path) then
        return
    elseif isempty(orig_cache_secs) then
        orig_cache_secs = mp.get_property("options/cache-secs")
    end
    mp.commandv("set", "cache-secs",
        is_network_stream(path) and opts.cache_secs or orig_cache_secs
    )
end

function is_network_stream(path)
    local netprotos = mkset{
        "http", "https", "ytdl", "rtmp", "rtmps", "rtmpe", "rtmpt", "rtmpts",
        "rtmpte", "rtsp", "rtsps", "mms", "mmst", "mmsh", "mmshttp", "rtp",
        "srt", "srtp", "gopher", "gophers", "data", "ftp", "ftps", "sftp"}
    local proto = type(path) == "string" and path:match("^(%a+)://") or nil
    return proto and netprotos[proto]
end

function mkset(list)
    local set = {}
    for _, v in ipairs(list) do set[v] = true end
    return set
end

function isempty(var)
    return var == nil or var == ""
end

mp.register_event("start-file", update_cache_secs)
