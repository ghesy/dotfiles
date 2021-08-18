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
    case $(machine) in
        laptop) exclude=desktop ;;
        desktop) exclude=laptop ;;
    esac
    for dir in "$path"/*/; do
        find -L "$dir" -type f \
            -not -path "*/*.$exclude/*" \
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
    exists "$src" || return 1
    are_identical "$src" "$dest" && return 0
    backup_file "$dest"
    sudo mkdir -p "$(dirname "$dest")"
    sudo cp "$src" "$dest" && echo "$dest" Installed.
}

backup_file()
{
    backup="$backup_dir$dest"
    if exists "$dest" && ! exists "$backup"; then
        sudo mkdir -p "$(dirname "$backup")"
        sudo cp "$dest" "$backup" && echo "$dest" Backed up.
    fi
}

are_identical()
{
    exists "$1" && exists "$2" || return 1
    [ "$(digest "$1")" = "$(digest "$2")" ]
}

digest()
{
    sudo sha256sum "$1" | cut -d' ' -f1
}

machine()
{
    case $(</sys/class/dmi/id/chassis_type) in
        9|10|11|14) echo laptop  ;;
                 *) echo desktop ;;
    esac
}

exists()
{
    sudo [ -r "$1" ]
}

main "$@"
