#!/bin/sh
# setup neomutt's folders and ask for an account to open

dir=~/.local/share/neomutt
acc=$dir/accounts
umask 077

command -v abook >/dev/null ||
    notify-send NeoMutt 'Please install "abook" to get addressbook functionality'

command -v lynx >/dev/null  ||
    notify-send NeoMutt 'Please install "lynx" to be able to read HTML mails'

[ ! -d "$acc" ] && cat << 'eof' | { mkdir -p "$acc"; cat > "$acc"/EXAMPLE ;}
# vim:filetype=neomuttrc
set realname  = 'Real Name'
set imap_user = username
set my_pass   = "`pass account`"
set from      = $imap_user@host.com
set folder    = imaps://$imap_user@imap.host.com:993
set smtp_url  = smtps://$imap_user@smtp.host.com:465
set smtp_pass = $my_pass
set imap_pass = $my_pass
set spoolfile = +INBOX
set postponed = +Draft # For Gmail: "+[Gmail]/Drafts"
set record    = +Sent  # For Gmail: "+[Gmail]/Sent Mail"
set trash     = +Trash # For Gmail: "+[Gmail]/Trash"
set my_spam_folder +Spam # For Gmail: "+[Gmail]/Spam"
# uncomment this if inbox is not showing up
#mailboxes +INBOX
# uncomment these lines to disable tls:
#set ssl_starttls = no
#set ssl_force_tls = no
eof

mkdir -p ~/.cache/neomutt $dir/mailbook 2>/dev/null
! sel=$(basename -a "$acc"/* | dmenu -w $WINDOWID -l 10 -p 'Choose an email account') ||
    [ ! -r "$acc/$sel" ] && { pkill -xg0 neomutt && exit ;}
echo source "$acc/$sel"
