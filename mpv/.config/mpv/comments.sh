#!/bin/bash
p() { printf '%s\n' "$*" ;}

unset js
jq '.comments[]' "${1:?}" | while IFS= read -r line
do
    [ "$line" != "}" ] && js="$js"$'\n'"$line" && continue

    comment=${js#*'"text": "'}; comment=${comment%%'",'$'\n'*}
    author=${js#*'"author": "'}; author=${author%%'",'$'\n'*}
    likes=${js#*'"like_count": '}; likes=${likes%%','$'\n'*}
    time=${js#*'"time_text": "'}; time=${time%%'",'$'\n'*}
    is_op=${js#*'"author_is_uploader": '}; is_op=${is_op%%false,$'\n'*}
    is_fav=${js#*'"is_favorited": '}; is_fav=${is_fav%%false,$'\n'*}
    parent=${js#*'"parent": "'}; parent=${parent%%'"'*}

    printf '%s\n%s\n' "$author${is_op:+ } • $likes Likes • $time${is_fav:+ • }" "$comment" |
        sed 's/\\n/\n/g;s/\\"/"/g;s/\\\\/\\/g' | fold -sw75 | {
            [ "$parent" = root ] && sed 's/^/│/' || sed 's/^/   │/'
        }
    echo
    unset js
done
