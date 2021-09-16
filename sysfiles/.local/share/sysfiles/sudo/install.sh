#!/bin/sh
# install sudo-related configs
install -DCvm644 faillock.conf /etc/security/faillock.conf
install -DCvm644 config.sudo /etc/sudoers.d/config
install -DCvm644 programs.sudo /etc/sudoers.d/programs
