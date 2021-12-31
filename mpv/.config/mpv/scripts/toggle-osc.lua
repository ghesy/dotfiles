-- this script binds "b" to toggle OSC between "auto" and "always" mode.
-- source: https://github.com/mpv-player/mpv/issues/4896#issuecomment-330458533

local isauto = true  -- we can't read the osc mode, so we assume it starts in auto mode.
mp.add_key_binding("b", "osc-toggle", function()
    isauto = not isauto
    mp.command("script-message osc-visibility " .. (isauto and "auto" or "always"))
end)
