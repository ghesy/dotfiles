# allow access to GPU for OpenGL and friends

noblacklist /sys

whitelist /sys/module/amdgpu
read-only /sys/module/amdgpu

whitelist /sys/module/radeon
read-only /sys/module/radeon

# vim:filetype=firejail
