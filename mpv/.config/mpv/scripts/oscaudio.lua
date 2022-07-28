-- don't auto-hide mpv's osc on audio-only files

mp.register_event("file-loaded", function()
	mp.commandv("script-message-to", "osc", "osc-visibility",
		(mp.get_property("video") == "no" and "always" or "auto"), "true")
end)
