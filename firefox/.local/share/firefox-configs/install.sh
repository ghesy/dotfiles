#!/bin/sh
for profile_dir in ~/.mozilla/firefox/????????.*/; do
    install -vbCDm644 user.js -t "$profile_dir/"
    install -vbCDm644 userChrome.css -t "$profile_dir/chrome/"
    install -vbCDm644 handlers.json -t "$profile_dir/"
done
