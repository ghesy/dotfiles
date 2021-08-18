#!/bin/sh
# install hblock's header file.

main()
{
    header=/etc/hblock/header
    [ "$(header | sha256sum)" = "$(sha256sum < $header)" ] && return 1
    header > $header && echo Updated $header.
}

header()
{
    localhost
    redirects
}

redirects()
{
    cat <<- eof
		# Force google's safesearch
		216.239.38.120 google.com
		216.239.38.120 google.co.uk
		216.239.38.120 www.google.com
		216.239.38.120 www.google.co.uk
	eof
}

localhost()
{
    hostname="$(uname -n)"
    cat <<- eof
		127.0.0.1  localhost
		::1        localhost
		127.0.1.1  $hostname.localdomain $hostname
	eof
}

main "$@"
