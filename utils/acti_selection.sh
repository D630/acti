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

_selection_modus_cli() {
    [ -z "$app" ] && app=$@

    while [ $# -ne 0 ]
    do
        case "$1" in

            help|HELP|-h|--help)
                    _cmd_help && return 0
                    ;;
            build|BUILD)
                    _cmd_build $* && return 0
                    ;;
            dpath|DPATH)
                    _cmd_dpath && return 0
                    ;;
            print|PRINT)
                    _cmd_print $* && return 0
                    ;;
            show|SHOW)
                    _cmd_show $* && return 0
                    ;;
            config|CONFIG)
                    _cmd_config "$@" && return 0
                    ;;
            info|INFO)
                    _cmd_info $* && return 0
                    ;;
            list|LIST)
                    _cmd_list && return 0
                    ;;
            edit|EDIT)
                    _cmd_edit_app_editor $* && return 0
                    ;;
            term|TERM)
                    _cmd_term $* && return 0
                    ;;
            gui|GUI)
                    _cmd_gui $* && return 0
                    ;;
            del|DEL|block|BLOCK|ign|IGN|reg|REG)
                    _cmd_edit_app_pre && _cmd_edit_app $* && _cmd_edit_app_post && _cmd_build_dir_build_rebuild && return 0
                    ;;
            wins|WINS)
                    _cmd_wins $*
                    ;;
            *)
                    _check_status_apps
                    ;;
        esac
    done
}

_selection_modus_gui() {

    case ${app%% *} in

        acti|ACTI)
                _selection_modus_gui_sel_2
                ;;
        history|HISTORY)
                _selection_modus_gui_sel_5
                ;;
        dpath|DPATH)
                _selection_modus_gui_sel_6
                ;;
        list|LIST)
                _selection_modus_gui_sel_7
                ;;
        *)
                _custom_selection_modus_gui $app
                ;;
    esac
}

_selection_modus_gui_sel_1() {
    app=$(\
        sed -r -e "/^\<block\> /d" -e "s/^\<ign\> //g" -e "s/^\<reg\> //g" < "$app_file" |
        sort -fg |
        sed "1 i "${menu_1:-"ACTI"}"" |
        _config_dmenu)
}

_selection_modus_gui_sel_2() {
    while true
    do
        app=$(_config_dmenu < <(echo -e ${menu_2:-"BLOCK X Y\nBUILD DIR --NEW\nBUILD DIR --RE\nBUILD FILE\nDEL X Y\nDPATH\nEDIT APPS X\nEDIT APPS FILE\nGUI X\nHISTORY\nIGN X Y\nLIST\nREG X Y\nTERM X"} | sort))
        { [ -n "$app" ] && _selection_modus_gui $app ; } || return 0
    done
}

_selection_modus_gui_sel_3() {
    w_action=$(sed "1 i "${menu_3:-"CYCLE\nGRID_HORIZONTAL\nGRID_VERTICAL\nMAXIMIZE\nCLOSE_ALL\nMV_TO_DESKTOP"}"" <<< "$w_l" | _config_dmenu | awk '{print $1}')
}

_selection_modus_gui_sel_4() {
    mv_action=$(_config_dmenu < <(echo -e ${menu_4:-"MV_AND_SWITCH_TO\nMV_TO_BUT_STAY"}))
}

_selection_modus_gui_sel_5() {
    app="$(_cmd_show_history | _config_dmenu)"
    { [ -z "$app" ] && return 0 ; } || _exec_app
}

_selection_modus_gui_sel_6() {
    app="$(_cmd_dpath | _config_dmenu)"
    { [ -z "$app" ] && return 0 ; } || _check_status_apps
}

_selection_modus_gui_sel_7() {
    app=$(wmctrl -lpx | _config_dmenu | awk '{print $1}')
    list=true
    { [ -z "$app" ] && return 0 ; } || _check_status_apps
}
