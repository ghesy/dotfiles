#!/bin/bash
# build a pacman repository from a directory of PKGBUILDs.
# requires pacman, pacman-contrib and bindfs.

# config
repo_dir=/var/lib/repo/nebula
repo_name=nebula

# global variables
repo=''
repo_bind_dir=''
rebuilt_pkgs=()
tmpdir=''
force=false
declare -A target_pkgs

# setup options and traps to catch errors
set -eEu -o pipefail
shopt -s nullglob
trap 'echo ${0##*/}: failed @ line $LINENO: $BASH_COMMAND' ERR

main()
{
    # cd to the script's directory
    cd "$(dirname "$(readlink -f "${0:?}")")"

    [[ $* = -f ]] && force=true

    # bind the repo-dir as rw to a temporary location
    bind_repo_dir
    repo_dir=$repo_bind_dir
    repo=$repo_dir/$repo_name.db.tar.zst

    build_updated_pkgs
    cleanup_removed_pkgs
    add_rebuilt_pkgs_to_db
}

# loop over all target packages and build them if necessary
build_updated_pkgs()
{
    local pkg_dir pkg_name ret must_touch=false
    for pkg_dir in */; do
        pkg_name=$(get_pkg_name "$pkg_dir")
        target_pkgs[$pkg_name]=exists
        needs_rebuild "$pkg_dir" || continue
        must_touch=true
        echo building "$pkg_name"...
        pushd "$pkg_dir" >/dev/null
        PKGDEST=$repo_dir makepkg -csr && ret=$? || ret=$?
        popd >/dev/null
        [[ $ret -ne 13 ]] && [[ $ret -ne 0 ]] && exit 1
        [[ $ret -eq  0 ]] && rebuilt_pkgs+=("$pkg_name")
    done
    [[ $must_touch = true ]] && touch "$repo" || :
}

# add the rebuilt packages to the database
add_rebuilt_pkgs_to_db()
{
    local pkg
    pushd "$repo_dir" >/dev/null
    set +u
    if [[ $force = true ]]; then
        printf '%s\n' *.pkg.tar.zst |
            pacsort -f | xargs -rd'\n' repo-add -n -R "$repo"
    else
        for pkg in "${rebuilt_pkgs[@]}"; do
            printf '%s\n' "$pkg"-*.pkg.tar.zst |
                pacsort -f | xargs -rd'\n' repo-add -n -R "$repo"
        done
    fi
    set -u
    popd >/dev/null
}

# if a target package is removed but still exists in repo dir,
# remove it from the database and repo dir as well.
cleanup_removed_pkgs()
{
    local pkg pkg_name
    [[ ! -s $repo ]] && return
    pushd "$repo_dir" >/dev/null
    set +u
    for pkg in $(tar -tf "$repo" | grep -Po '^[^/]+(?=/$)'); do
        pkg_name=${pkg%-*}
        pkg_name=${pkg_name%-*}
        if [[ ${target_pkgs[$pkg_name]} != exists ]]; then
            repo-remove "$repo" "$pkg_name"
            rm -fv "$pkg"-*.pkg.tar.zst
        fi
    done
    set -u
    popd >/dev/null
}

# parse the PKGBUILD residing in the given directory and get it's $pkgname
get_pkg_name()
{
    local line pkg_name
    while IFS= read -r line; do
        case $line in
            pkgname=*)
                pkg_name=${line#*=}
                pkg_name=${pkg_name#\'}; pkg_name=${pkg_name#\"}
                pkg_name=${pkg_name%\'}; pkg_name=${pkg_name%\"}
                if [[ -n $pkg_name ]]; then
                    echo "$pkg_name"
                    return
                fi
            ;;
        esac
    done < "$1"/PKGBUILD
    echo "${0##*/}: failed getting pkgname from ${1%/}/PKGBUILD" >&2
    return 1
}

# if any file in the target package directory is newer than
# the package database, it means that it needs to be rebuilt
needs_rebuild()
{
    [[ ! -e $repo ]] && return 0
    for f in "$1"/*; do
        [[ $f -nt $repo ]] && return 0
    done
    return 1
}

# if the given repodir isn't writable by the user,
# bind-mount it as a writable dir to a temporary location.
bind_repo_dir()
{
    sudo -v
    trap cleanup EXIT
    tmpdir=$(mktemp -d)
    repo_bind_dir=$tmpdir/binddir
    mkdir "$repo_bind_dir"
    sudo mkdir -p "$repo_dir"
    sudo bindfs -u "$USER" -g "$(id -gn)" \
        --create-as-mounter "$repo_dir" "$repo_bind_dir"
}

cleanup()
{
    # if we're in the mount-bind, unmount will fail;
    # so cd to some other place
    cd "$tmpdir"

    # unmount the mount-bind and remove the temporary directories
    mountpoint -q "$repo_dir" && sudo umount "$repo_dir"
    rmdir "$repo_dir"
    rmdir "$tmpdir"
}

main "$@"
