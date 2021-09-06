#!/bin/sh
# setup neomutt's folders and ask for an account to open

dir=~/.local/share/neomutt
acc=$dir/accounts
umask 077

command -v abook >/dev/null ||
    notify-send NeoMutt 'Please install "abook" to get addressbook functionality'

command -v lynx >/dev/null  ||
    notify-send NeoMutt 'Please install "lynx" to be able to read HTML mails'

[ ! -d $acc ] && cat << 'eof' | { mkdir -p $acc; cat > $acc/EXAMPLE ;}
# vim:ft=neomuttrc
set realname  = 'Real Name'
set imap_user = username
set my_pass   = "`pass account`"
set from      = $imap_user@host.com
set folder    = imaps://$imap_user@host.com@imap.host.com:993
set smtp_url  = smtps://$imap_user@host.com@smtp.host.com:465
set smtp_pass = $my_pass
set imap_pass = $my_pass
set spoolfile = +INBOX
set postponed = +Draft # "+[Gmail]/Drafts"
set record    = +Sent  # "+[Gmail]/Sent Mail"
set trash     = +Trash # "+[Gmail]/Trash"
eof

mkdir -p ~/.cache/neomutt $dir/mailbook
! sel="$(basename $acc/* | dmenu -w $WINDOWID -p 'Choose an email account')" &&
    pkill -nx neomutt && exit
echo source $acc/$sel
