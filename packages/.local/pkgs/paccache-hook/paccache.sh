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
    # but keep the packages specified in the makedepends array
    paccache --verbose --remove --uninstalled --keep 0 --min-mtime '-1month' \
        --ignore "$(joinby ',' "${ignore[@]}")"

    # only keep 2 versions of the other packages in the cache
    paccache --verbose --remove --keep 2
}

joinby()
{
    local IFS=$1
    shift
    echo "$*"
}

main "$@"
