-- author: Ehsan Ghorbannezhad <ehsan@disroot.org>
--
-- properly set mpv's subtitle and osd fonts to the system's sans-serif font.
--
-- this is a workaround for libass defaulting to NotoSans or some other font
-- for some reason. normally it should use the system's sans-serif font.
--
-- setting the font explicitly by setting sub-font and osd-font mpv's config
-- works as well, but then if you change the system's font in fontconfig,
-- you have to change it here too. not cool.

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
