# dotfiles

![Screenshot](sc1.jpg)
![Screenshot](sc2.jpg)

## Suckless Builds

- Window Manager: [dwm](https://github.com/ghesy/dwm)
- Status Bar: [dwmBar](https://github.com/ghesy/dwmbar)
- Terminal: [st](https://github.com/ghesy/st)
- Menu: [dmenu](https://github.com/ghesy/dmenu)
- Screen Locker: [slock](https://github.com/ghesy/slock)
- sxiv: [sxiv-flexipatch](https://github.com/ghesy/sxiv-flexipatch)

## Configs

### Base

- [Scripts](scripts/.local/bin)
- [runit User Services](services/.local/runit/sv)
- [zprofile](zsh/.config/zsh/zprofile)
- [xinitrc](X11/.config/X11/xinitrc)
- XDG: [.desktop Files](xdg/.local/share/applications),
[mimeapps.list](xdg/.config)

### Shell

- [Zsh](zsh/.config/zsh)
- [Readline (inputrc)](other/.config/inputrc)

### Media

- Media Player: [mpv](mpv/.config/mpv)
- Image Viewer: [sxiv](sxiv/.config/sxiv)
- PDF Reader: [zathura](zathura/.config/zathura)

### Music

- [MPD](music/.config/mpd)
- [ncmpcpp](music/.config/ncmpcpp)
- [cava](music/.config/cava)

### Appearance

- Notification Daemon: [Dunst](dunst/.config/dunst)
- Compositor: [picom](picom/.config/picom)
- [Fontconfig](fontconfig/.config/fontconfig)
- [GTK](gtk/.config)
- [Xresources](X11/.config/X11/xresources)

### Text

- Editor: [Neovim](nvim/.config/nvim)
- Pager: [Less](less/.config)

### Package Management

- AUR Helper: [Paru](paru/.config/paru)
- [makepkg](makepkg/.config/pacman)

### Security

- [GPG](gnupg/.local/share/gnupg)
- [Sudo and PAM](packages/.local/pkgs/sudo-configs)
- [Firejail](firejail/.config/firejail)

### Other Configs

- [Local Packages](packages/.local/pkgs)
- Email Client: [NeoMutt](neomutt/.config/neomutt)
- RSS Feed Reader: [Newsboat](newsboat/.config/newsboat)
- BitTorrent Client: [Transmission + tremc](transmission/.config)
- Reddit Client: [TUIR](tuir/.config/tuir)
- Download Manager: [aria2c + aria2p](aria2/.config)
- [FireFox Configs](firefox/.local/share/firefox-configs)
- [Git](git/.config/git)
- Mounting USB flash drives: [bashmount](other/.config/bashmount)
- NetworkManager UI: [networkmanager-dmenu](other/.config/networkmanager-dmenu)

### Home Cleanup

- [Environment Variables](zsh/.config/zsh/xdg.profile)
- [wget](other/.config/wget)
- [npm](other/.config/npm)
