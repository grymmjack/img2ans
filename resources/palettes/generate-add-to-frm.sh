#!/usr/bin/env bash
for dir in $(echo $(ls . | tr -d ' ' | sed -e "s/\.GPL//ig")); do 
    if [ "./${dir}" != "${0}" ]; then
        echo "    AddItem __UI_NewID, \"$(echo $dir | sed -e 's/(/ (/ig')\""
    fi
done