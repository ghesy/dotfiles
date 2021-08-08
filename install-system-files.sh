#!/bin/bash

# config
path=~/.local/share/system-files
backup_dir=/etc/system-files-backup

main()
{
    sudo -v || return 1
    install_and_backup_system_files
    run_sysconf_scripts
}

install_and_backup_system_files()
{
    is_laptop && laptop=true || unset laptop

    for dir in "$path"/*/; do
        find -L "$dir" -type f \
            ${laptop:--not -path '*/*.laptop/*'} \
            -not -path '*/OTHER/*'  \
            -not -path '*/MANUAL/*' \
            -not -name '*.ignore'   \
            -not -name '*.sysconf.sh' |
            while IFS= read -r file; do
                install_file "$file" "/${file#$dir*}"
            done
    done
}

run_sysconf_scripts()
{
    sudo find -L "$path" -type f -executable -name '*.sysconf.sh' -exec '{}' ';'
}

install_file()
{
    src="$1"
    dest="$2"
    [ ! -r "$src" ] && return 1
    are_identical "$src" "$dest" && return 0
    backup_file "$dest"
    sudo mkdir -p "$(dirname "$dest")"
    sudo cp -v "$src" "$dest"
}

backup_file()
{
    backup="$backup_dir$dest"
    if [ -r "$dest" ] && [ ! -r "$backup" ]; then
        sudo mkdir -vp "$(dirname "$backup")"
        sudo cp -v "$dest" "$backup"
    fi
}

are_identical()
{
    [ "$(digest "$1")" = "$(digest "$2")" ]
}

digest()
{
    sudo sha1sum "$1" | cut -d' ' -f1
}

is_laptop()
{
    chassis="$(cat /sys/class/dmi/id/chassis_type 2>/dev/null)" || return 1
    [ -n "$chassis" ] && [ "$chassis" -ge 8 ] && [ "$chassis" -le 14 ] &&
        return 0 || return 1
}

main "$@"
