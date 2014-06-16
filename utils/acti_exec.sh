#!/usr/bin/env bash

_exec_app() {
    app_a=( $app )

    if [ "${#app_a[@]}" -gt 1 ]
    then
        if command -v "${app_a[1]}" >/dev/null
        then
            { echo "$app" >> "$history_file" && sort -f "$history_file" | uniq > "$history_file.$$" && mv "$history_file.$$" "$history_file" ; } || _status 30 3
            if [[ "${app%% *}" =~ (term|TERM) ]]
            then
                if [ -t 1 ]
                then
                    exec ${app#* } 2>/dev/null || _status 07 3
                else
                    exec $_term "${app#* };${SHELL:-"bash"}" 2>/dev/null || _status 07 3
                fi
            elif [[ "${app%% *}" =~ (gui|GUI) ]]
            then
                exec ${app#* } 2>/dev/null || _status 07 3
            fi
        else
            _status 08 3
        fi
    else
        if command -v "$app" >/dev/null
        then
            while read a
            do
                [[ "$a" =~ Exec=.+ ]] && app="${a##*=}"
                [[ "$a" =~ Terminal=.+ ]] && terminal="${a##*=}"
            done < <(find ${app_dir}/*/${app}.desktop -exec sed -n p {} \; 2>/dev/null || _status 31 3)
            if [ -n "$terminal" ] && [[ "$terminal" == [tT]rue ]]
            then
                if [ -t 1 ]
                then
                    exec $app 2>/dev/null || _status 07 3
                else
                    exec $_term "$app;${SHELL:-"bash"}" 2>/dev/null || _status 07 3
                fi
            else
                exec $app 2>/dev/null || _status 07 3
            fi
        else
            _status 08 3
        fi
    fi
}
