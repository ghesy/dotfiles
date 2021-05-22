# mkinitcpio

These are a bunch of kernel settings and hooks.
The 'consolefont' hook in 'mkinitcpio.conf' also changes the tty font,
which is specified in the 'vconsole.conf' file.

The available fonts are at /usr/share/kbd/consolefonts .

Run the following command after updating the files:

    mkinit -P
