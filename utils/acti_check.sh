#!/usr/bin/env bash

# Copyright 2014 D630
# https://github.com/D630/acti

# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.

# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
# for more details.

# You should have received a copy of the GNU General
# Public License along with this program. If not, see
# <http://www.gnu.org/licenses/gpl-3.0.html>.

_check_files() {
    if [ -z "$app_file" ]
    then
        _status 01 3
    elif [ ! -f "$app_file" ]
    then
        _status 02 3
    elif [ "$(stat -c %s "$app_file" 2>/dev/null)" -lt 2 ]
    then
        _status 03 3
    fi

    [ -z "$backup_file" ] && _status 16 3
    [ -z "$history_file" ] && _status 46 3
}

_check_dirs() {
    [ -z "$app_dir" ] && _status 25 3
    [ -d "$app_dir" ] || { mkdir -p ${app_dir}/{block,ign,reg} && _status 26 2 ; }
    [ -d "$app_dir/block" ] || { mkdir ${app_dir}/block && _status 26 2 ; }
    [ -d "$app_dir/ign" ] || { mkdir ${app_dir}/ign && _status 26 2 ; }
    [ -d "$app_dir/reg" ] || { mkdir ${app_dir}/reg && _status 26 2 ; }
}

_check_status_apps() {
    app_status="$(egrep -xo -e "(block|ign|reg).+${app##* }" "$app_file")"
    case "${app_status% *}" in

        block)
                _status 05 4
                ;;
        ign)
                _status 28 5
                ;;
        reg)
                # list all APP-windows on all desktops
                w_l="$(wmctrl -lpx | sed -rn "/( "$app"\.|\."$app" )/I p" 2>/dev/null)"

                # if there is no window of App, do function _exec_app()
                [ -z "$w_l" ] && _exec_app

                # get number of all APP-windows on all desktops
                w_n_all="$(sed -n '$=' <<< "$w_l")"
                case "$w_n_all" in

                    1)
                            # if only one window of App, activate that window
                            w_id="$(sed -n "s/ .*//p" <<< "$w_l")"
                            _check_wins_geo
                            { wmctrl -i -a "$w_id" && exit 0 ; } || _status 06 3
                            ;;
                    *)
                            # if more than one window of App, do function _check_wins()
                            if [ "$modus" = gui ]
                            then
                                _check_wins && _check_wins_action && _cmd_wins_cli && _cmd_wins_gui
                            else
                                _check_wins && _check_wins_action && _cmd_wins_cli && exit 0
                            fi
                            ;;
                esac
                ;;
        *)
                # if command 'list', then activate single window, else error status
                if [ "$list" = true ]
                then
                    { wmctrl -i -a "$app" && exit 0 ; } || _status 06 3
                else
                    _status 29 4
                fi
                ;;
    esac
}

_check_wins() {
    # get current screen geo
    screen=( $(xwininfo -root | sed -n -e "/Height: / s/.* //p" -e "/Width: / s/.* //p" | sed 'N;s/\n/ /') )

    # get current desktop
    curr_desk="$(wmctrl -d | sed -n "/ \*/ s/ .*//p")"

    # get total number of APP-windows on current desktop
    w_n="$(sed -rn "/[[:alnum:]]  \<"$curr_desk"\> [[:digit:]]/ p" <<< "$w_l" | sed -n '$=')"

    [ -z "$w_n" ] && _status 19 3

    # then get numeric window identities
    _w_ids=( $(sed -rn "/[[:alnum:]]  \<"$curr_desk"\> [[:digit:]]/ s/ .*//p" <<< "$w_l") )
}

_check_wins_geo() {
    if [ -z "$geo" ]
    then
        while read a
        do
            [[ "$a" =~ Geo=.+ ]] && geo="${a##*=}"
        done < <(find ${app_dir}/*/${app}.desktop -exec sed -n p {} \; 2>/dev/null || _status 31 3)
    fi

    if [ -n "$geo" ]
    then
        wmctrl -i -r "$w_id" -b remove,maximized_vert,maximized_horz
        wmctrl -i -r "$w_id" -e "0,$geo"
    else
        echo
    fi
}

_check_wins_action() {
    if [ -z "$w_action" ]
    then
        while read a
        do
            [[ "$a" =~ W_action=.+ ]] && w_action="${a##*=}"
        done < <(find ${app_dir}/*/${app}.desktop -exec sed -n p {} \; 2>/dev/null || _status 31 3)
    fi

    { [ -z "$w_action" ] && w_action="activate_all" ; } || echo
}
