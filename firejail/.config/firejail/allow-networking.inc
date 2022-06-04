# allow networking

ignore net none
protocol unix,inet,inet6,netlink
ignore protocol
private-etc ca-certificates,ssl,localtime

# vim:ft=firejail
