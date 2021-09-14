#!/bin/sh
# install sudo-related configs
install -DCvm644 faillock.conf /etc/security/faillock.conf
install -DCvm644 config.sudo programs.sudo -t /etc/sudoers.d
