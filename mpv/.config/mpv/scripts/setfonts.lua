-- author: Ehsan Ghorbannezhad <ehsan@disroot.org>
-- properly set mpv's subtitle and osd fonts to the system's sans-serif font
-- mpv is supposed to set the --sub-font and --osd-font options to sans-serif
-- by default, but for some reason libass defaults to NotoSans or whatever.

local r = mp.command_native{
	name = "subprocess",
	capture_stdout = true,
	capture_stderr = true,
	playback_only = false,
	args = { "fc-match", "-f%{family}", "sans-serif" },
}

if r and r.status == 0 then
	mp.set_property("osd-font", r.stdout)
	mp.set_property("sub-font", r.stdout)
end
