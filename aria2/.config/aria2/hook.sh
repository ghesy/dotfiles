#!/bin/sh
notify-send aria2 "Download Failed${3:+:
${3##*/}}"
