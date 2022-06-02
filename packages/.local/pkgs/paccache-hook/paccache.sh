#!/bin/bash
# /usr/share/libalpm/scripts/paccache
# clean pacman's package cache.

# specify packages that are often used for builds and shouldn't be
# removed from the cache. useful if you use paru's RemoveMake option.
ignore=(
    go rust cargo make cmake git qt5-base python-setuptools
    python-build python-wheel python-installer
)

main()
{
    # remove uninstalled packages older than a month,
    # excluding the packages specified in the ignore array
    pacman-conf cachedir | while IFS= read -r cachedir; do
        cd "$cachedir" || continue
        get_uninstalled_pkgs | filter_out_newer_than_a_month |
            xargs -rd'\n' rm -fv
    done

    # only keep 2 versions of the other packages in the cache
    paccache --verbose --remove --keep 2
}

get_uninstalled_pkgs()
{
    paccache --verbose --dryrun --uninstalled --keep 0 \
        --ignore "$(joinby ',' "${ignore[@]}")" | grep '^[0-9a-z]'
}

filter_out_newer_than_a_month()
{
    xargs -rd'\n' stat -c '%W	%n' | awk '
        BEGIN { monthago = systime() - (60 * 60 * 24 * 30) }
        $1 < monthago { print $2 }
    '
}

joinby()
{
    local IFS=$1
    shift
    echo "$*"
}

main "$@"
