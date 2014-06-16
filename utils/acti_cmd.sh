#!/usr/bin/env bash

_cmd_help() {
printf "acti <options> <subcommand> <APP>

OPTIONS:
--------
--gui                       Start acti in interactive GUI mode with
                            Dmenus.

-e X,Y,W,H , -E X,Y,W,H     Activate single window of an App with sizing.
-gh        , -GH            Arrange horizontaly all windows of an App on
                            current desktop in a grid of equal sizes.
-gv        , -GV            Arrange verticaly all windows of an App on
                            current desktop in a grid of equal sizes.
-m         , -M             Maximize all windows of an App on current
                            desktop. In GUI mode the last window is set
                            on top. This option in CLI mode is like the
                            w_action=activate_all, which is default in
                            both modes.

SUBCOMMANDS:
------------
gui APP                     Execute APP with own options without
                            checking its listing in the App File.
term APP                    Execute APP with own options in a Terminal
                            without checking its listing in the App File.

block APP ...               Ban Acti from activating and executing APP.
del APP ...                 Delete APP from the App File.
ign APP ...                 Ban Acti from activating APP, but enable
                            executing APP.
reg APP ...                 Insert APP into App File and enable Acti to
                            activate APP.

config set PATTERN ... -- APP ...
                            Set PATTERN in Desktop File with name of APP.
                            PATTERN can be: Encoding, Version, Type,
                            Name, Exec, Terminal (true|false), Path, Geo
                            (X,Y,W,H), W_action (activate_all|maximize|
                            grid_horizontal|grid_vertical).
config set PATTERN ... -- xargs COMMAND
                            Set PATTERN in all Desktop Files, where
                            COMMAND finds PATTERN. COMMAND could be:
                            egrep -l -e 'PATTERN' ...
edit apps APP               Execute an Editor and initiate reading the
                            Desktop File of APP.
edit apps file              Execute an Editor and initiate reading the
                            App File.

print [-bl|-fm]             Print the App File, but edit the status name.
                            Option '-fm' invokes a tabspaced format with
                            header; the option '-bl' invokes a block by
                            block format.

show apps                   Print all raw Desktop Files.
show apps APP ...           Print raw Desktop File with name of APP.
show apps -- xargs COMMAND  Print all Desktop Files, where COMMAND finds
                            PATTERN. See: 'config set'.
show apps dir               Tree App Dir.
show apps file              Print raw App File.
show history                Print raw History File.
show log                    Print raw Log File.

build dir [--new|--re]      Read App File and create App Dir on the basis
                            of it. Option '--new' create fully new Desktop
                            Files; the option '--re' only rebuilds the App
                            Dir, so modified Desktop Files are preserved
                            and left over Files will be deleted.
build file                  Read App Dir and map its order in App File
                            (directional).

wins close APP              Close all windows of APP on current desktop.
wins move DESKTOP APP       Move all windows of APP on current desktop
                            to DESKTOP.
wins switch DESKTOP APP     Move all windows of APP on current desktop
                            to DESKTOP and switch to DESKTOP.

info apps                   Count status of Apps in App File and give an
                            output.
info version                Print version of Acti.

dpath                       Invoke 'dmenu_path'.
list                        List all the windows being managed by the
                            window manager on all desktops.
help, -h , --help           Display this help.

GUI-Mode:
---------
acti                        Prompt a second Dmenu, where commands can be
                            selected.
history                     Like 'show history', but interactive with a
                            Dmenu.
list                        Comannd 'list', but interactive.
dpath                       Command 'dpath', but interactive.

GRID_HORIZONTAL             Arrange all windows of an App on current
                            desktop in a grid of equal sizes. Acti begins
                            to tile horizontaly.
GRID_VERTICAL               Arrange all windows of an App on current
                            desktop in a grid of equal sizes. Acti begins
                            to tile verticaly.
MAXIMIZE                    Maximize all windows of an App on current
                            desktop and set then the last activated on
                            top.
CLOSE_ALL                   Close all windows of an App on current desktop.
MV_TO_DESKTOP               Prompts a  Dmenu,  where  MV_AND_SWITCH_TO DESKTOP
                            moves  all  windows  of  an  App  on  current
                            desktop  to  another  desktop  and  switches
                            to  that  desktop. MV_TO_BUT_STAY DESKTOP does
                            the same, but without switching to that desktop.
CYCLE                       Reorders window listing. The cycle continues
                            clockwisely.
"
}

_cmd_dpath() {
    dmenu_path
}

_cmd_gui() {
    _exec_app $app
}

_cmd_term() {
    _exec_app $app
}

_cmd_print() {
    pf_ext=$(sed -r -e "s#^\<block\>#&ed#g" -e "s#^\<ign\>#&ored#g" -e "s#^\<reg\>#&ular#g"  < "$app_file")

    case "$2" in

    -fm|-FM)
            _cmd_print_fm
            ;;
    -bl|-BL)
            _cmd_print_bl
            ;;
    *)
            _cmd_print_
            ;;
    esac
}

_cmd_print_() {
    sed -n 'p' <<< "$pf_ext" || _status 11 2
}

_cmd_print_fm() {
    {
    pf_width=$(($(wc -L "$app_file" | sed 's/ .*//')+9)) &&
    column -t <<< "${pf_head:-"K1 K2"}" &&
    printf '%*s\n' "${pf_width:-$(tput cols)}" '' | tr ' ' - &&
    column -t <<< "$pf_ext"
    } || _status 12 2
}

_cmd_print_bl() {
    set $(echo "${pf_head:-"K1 K2"}")
    awk -v K1="$1" -v K2="$2" -F" " '{print K1":",$1;print K2":",$2"\n"}' <<< "$pf_ext" || _status 12 2
}

_cmd_show() {
    case "$2" in

        apps|APPS)
                case "$3" in

                    file|FILE)
                            _cmd_show_apps_file
                            ;;
                    dir|DIR)
                            _cmd_show_apps_dir
                            ;;
                    *)
                            _cmd_show_apps_ $*
                            ;;
                esac
                ;;
        history|HISTORY)
                _cmd_show_history
                ;;
        log|LOG)
                _cmd_show_log
                ;;
        *)
                _cmd_show_ $*
                ;;
    esac
}

_cmd_show_apps_file() {
    sed -n 'p' "$app_file"
}

_cmd_show_apps_dir() {
    tree "$app_dir"
}

_cmd_show_apps_() {
    cd "$app_dir"

    if [[ "$*" =~ = ]]
    then
        shift 3
        find . -type f -name "*.desktop" | $* | xargs sed -s '$ a\ '
    else
        shift 2
        find . -type f -name "*.desktop" | fgrep "$(tr ' ' '\n' <<< "$*" | sed 's/$/.desktop/')" | xargs sed -s '$ a\ '
    fi
}

_cmd_show_history() {
    sed -n 'p' "$history_file"
}

_cmd_show_log() {
    sed -n 'p' "$log_file"
}

_cmd_show_() {
    _status 13 2
}

_cmd_config() {
    case "$2" in

        set|SET)
                _cmd_config_set "$@"
                ;;
        *)
                _cmd_config_ $*
                ;;
    esac
}

_cmd_config_set() {
    shift 2

    cd "$app_dir"

    for a in "$@"
    do
        [[ "$a" == -- ]] && shift 1 && break
        settings+=( "$a" )
        shift 1
    done

    if [[ "$*" =~ = ]]
    then
        search="$(find . -type f -name "*.desktop" | "$@")"
        for l in "${settings[@]}"
        do
            { xargs sed -i -e s/^"${l%%=*}".*/"$l"/g <<< "$search" && _status 44 6 ; } || _status 45 6
        done
    else
        for l in "${settings[@]}"
        do
            { find . -type f -name "*.desktop" | fgrep "$(tr ' ' '\n' <<< "$*" | sed 's/$/.desktop/')" | xargs sed -i "s/^${l%%=*}.*/$l/g" && _status 44 6 ; } || _status 45 6
        done
    fi
}

_cmd_config_() {
    _status 13 4
}

_cmd_info() {
    case "$2" in

        version|VERSION)
                _cmd_info_version
                ;;
        apps|APPS)
                _cmd_info_apps
                ;;
        *)
                _cmd_info_ $*
                ;;
    esac
}

_cmd_info_version() {
    sed -n 'p' <<< "$version"
}

_cmd_info_apps() {
    _cmd_print | sed 's/ .*//g' | sort | uniq -c
}

_cmd_info_() {
    _status 13 2
}

_cmd_list() {
    wmctrl -lpx
}

_cmd_edit_app_editor() {
    case "$2" in

        apps|APPS)
                case "$3" in
                    file|FILE)
                            _cmd_edit_app_editor_file
                            ;;
                    *)
                            _cmd_edit_app_editor_apps $*
                            ;;
                esac
                ;;
        *)
                _cmd_edit_app_editor_
                ;;
    esac
}

_cmd_edit_app_editor_() {
    _status 37 3
}

_cmd_edit_app_editor_file() {
    { exec "$_editor" "$app_file" || exec "$_visual" "$app_file" ; } 2>/dev/null || _status 10 3
}

_cmd_edit_app_editor_apps() {
    { exec "$_editor" ${app_dir}/*/${3}.desktop || exec "$_visual" ${app_dir}/*/${3}.desktop ; } 2>/dev/null || _status 10 3
}

_cmd_edit_app_post() {
    { sort -k2 -f "$app_file" | uniq > "$app_file.$$" && mv "$app_file.$$" "$app_file" ; } || _status 15 3
}

_cmd_edit_app_pre() {
    cp "$app_file" "$backup_file" 2>/dev/null || _status 14 3
}

_cmd_edit_app() {
    while [ $# -ne 0 ]
    do
        case "$1" in

            del|DEL)
                    shift
                    for a in "$@"
                    do
                        [[ "$a" =~ (block|del|ign|reg|BLOCK|DEL|IGN|REG) ]] && break
                        sed -ri -e "/^(\<block\> |\<ign\> |\<reg\> )(\<"$a"\>)$/d" "$app_file" && _status 32 6
                        shift
                    done
                    ;;
            block|BLOCK)
                    shift
                    for a in "$@"
                    do
                        [[ "$a" =~ (block|del|ign|reg|BLOCK|DEL|IGN|REG) ]] && break
                        sed -ri -e "$ i block $a" -e "/^(\<reg\> |\<ign\> )(\<"$a"\>)$/d" "$app_file" && _status 33 6
                        shift
                    done
                    ;;
            ign|IGN)
                    shift
                    for a in "$@"
                    do
                        [[ "$a" =~ (block|del|ign|reg|BLOCK|DEL|IGN|REG) ]] && break
                        sed -ri -e "$ i ign $a" -e "/^(\<block\> |\<reg\> )(\<"$a"\>)$/d" "$app_file" && _status 34 6
                        shift
                    done
                    ;;
            reg|REG)
                    shift
                    for a in "$@"
                    do
                        [[ "$a" =~ (block|del|ign|reg|BLOCK|DEL|IGN|REG) ]] && break
                        sed -ri -e "$ i reg $a" -e "/^(\<block\> |\<ign\> )(\<"$a"\>)$/d" "$app_file" && _status 35 6
                        shift
                    done
                    ;;
        esac
    done
}

_cmd_build() {
    case "$2" in

        file|FILE)
                _cmd_build_file
                ;;
        dir|DIR)
                case "$3" in

                    --re|--RE)
                            { _cmd_build_dir_build_rebuild && _status 42 6 ; } || _status 43 4
                            ;;
                    --new|--NEW)
                            { _cmd_build_dir_build_new && _status 40 6 ; } || _status 41 4
                            ;;
                    *)
                            _cmd_build_dir_ $*
                            ;;
                esac
                ;;
        *)
                _cmd_build_ $*
                ;;
    esac
}

_cmd_build_() {
    _status 13 4
}

_cmd_build_dir_pre() {
    cd "$app_dir"
    tar -cf ${backup_dir}/${app_dir##*/}.tar "block" "ign" "reg" || _status 36 4
}

_cmd_build_dir_() {
    _status 13 4
}

_cmd_build_dir_build_new() {
    _cmd_build_dir_pre

    while read a
    do
        cat > ${app_dir}/${a}.desktop <<EOF
Encoding=UTF-8
Version=1.0
Type=Application
Name=${a##*/}
Exec=${a##*/}
Terminal=
Path=
Geo=
W_action=
EOF
    done < <(_selection_modus_cli show apps file | sed 's/ /\//g')
}

_cmd_build_dir_build_rebuild() {
    _cmd_build_dir_pre

    cd "$app_dir"

    # Write App Dir into Array
    declare -A old
    while read o
    do
        old["$o"]="$o"
    done < <(find . -type f | cut -c3-)

    # Compare App File with App Dir and modify App Dir
    while read new
    do
        if [ -z "${old["$new"]}" ]
        then
            mv "${app_dir}/$(eval echo "${old["{block,ign,reg}/${new##*/}"]}")" "${app_dir}/${new}" 2>/dev/null || cat > "${app_dir}/${new}" <<EOF
Encoding=UTF-8
Version=1.0
Type=Application
Name=$(sed 's/.desktop$//g' <<< "${new##*/}")
Exec=$(sed 's/.desktop$//g' <<< "${new##*/}")
Terminal=
Path=
Geo=
W_action=
EOF
        fi
    done < <(_selection_modus_cli show apps file | sed 's/ /\//g;s/$/.desktop/g')

    # Remove obsolete Apps in App Dir (diff is here much faster than complete iteration loop)
    diff -y --suppress-common-lines <(sed 's/ /\//g;s/$/.desktop/g' "$app_file" | sort) <(for a in "${old[@]}" ; do echo "$a" ; done | sort) | egrep -o -e ">.(reg|block|ign)/.*" | sed 's/>\t//g' | xargs rm -f
}

_cmd_build_file() {
    _cmd_edit_app_pre
    cd "$app_dir"
    { find . -type f | sort | sed -r 's/^(\.\/)//g;s/\// /g;s/.desktop$//g' > "$app_file" && _status 38 6 ; } || _status 39 4
    _cmd_edit_app_post
}

_cmd_wins_gui() {
    while true
    do
        _selection_modus_gui_sel_3

        case "$w_action" in

            mv_to_desktop|MV_TO_DESKTOP)
                    _cmd_wins_move_to_desktop
                    ;;
            close_all|CLOSE_ALL)
                    _cmd_wins_close
                    ;;
            cycle|CYCLE)
                    _cmd_wins_cycle
                    ;;
            maximize|MAXIMIZE)
                    _cmd_wins_maximize
                    ;;
            grid_vertical|GRID_VERTICAL)
                    _cmd_wins_grid_vertical
                    ;;
            grid_horizontal|GRID_HORIZONTAL)
                    _cmd_wins_grid_horizontal
                    ;;
            *)
                    break
                    ;;
        esac
    done

    [ -z "$w_action" ] && _main --gui
}

_cmd_wins() {
    case "$2" in

        close|CLOSE)
                w_action="close_all"
                app=$3
                ;;
        move|MOVE)
                w_action="mv_to_but_stay"
                mv_action="$w_action $3"
                app=$4
                ;;
        switch|SWITCH)
                w_action="mv_and_switch_to"
                mv_action="$w_action $3"
                app=$4
                ;;
    esac
    _check_status_apps
}

_cmd_wins_cli() {
    case "$w_action" in

        mv_to_but_stay|MV_TO_BUT_STAY)
                _cmd_wins_move_to_desktop_stay
                ;;
        mv_and_switch_to|MV_AND_SWITCH_TO)
                _cmd_wins_move_to_desktop_switch
                ;;
        close_all|CLOSE_ALL)
                _cmd_wins_close
                ;;
        cycle|CYCLE)
                _cmd_wins_cycle # not integrated yet
                ;;
        maximize|MAXIMIZE)
                _cmd_wins_maximize
                ;;
        grid_vertical|GRID_VERTICAL)
                _cmd_wins_grid_vertical
                ;;
        grid_horizontal|GRID_HORIZONTAL)
                _cmd_wins_grid_horizontal
                ;;
        activate_all|ACTIVATE_ALL)
                _cmd_wins_activate
                ;;
        *)
                _cmd_wins_activate
                ;;
    esac
}

_cmd_wins_activate() {
    for id in "${_w_ids[@]}"
    do
        wmctrl -i -a "$id"
    done
}

_cmd_wins_move_to_desktop() {
    while true
    do
        _selection_modus_gui_sel_4
        case ${mv_action%% *} in

            mv_to_but_stay|MV_TO_BUT_STAY)
                    _cmd_wins_move_to_desktop_stay
                    ;;
            mv_and_switch_to|MV_AND_SWITCH_TO)
                    _cmd_wins_move_to_desktop_switch
                    ;;
            *)
                    _cmd_wins_move_to_desktop_
                    ;;
        esac
    done
}

_cmd_wins_move_to_desktop_() {
    { w_l="$(wmctrl -lpx | sed -rn "/( "$app"\.|\."$app" )/I p")" ; break ; }
}

_cmd_wins_move_to_desktop_switch() {
    for id in "${_w_ids[@]}"
    do
        wmctrl -i -r "$id" -t "${mv_action##* }"
    done

    wmctrl -s "${mv_action##* }"
}

_cmd_wins_move_to_desktop_stay() {
    for id in "${_w_ids[@]}"
    do
        wmctrl -i -r "$id" -t "${mv_action##* }"
    done
}

_cmd_wins_close() {
    for id in "${_w_ids[@]}"
    do
        wmctrl -i -c "$id"
    done
}

_cmd_wins_cycle() {
    # reorder Window IDs and overwrite array
    _w_ids=( $(sed -e "s/ /\n/g" <<< "${_w_ids[@]}" | sed -n -e "1,$((w_n-1)){H}" -e "$w_n{x;H;}" -e '${g;s/\n//;p;}') )
}

_cmd_wins_maximize() {
    # Adapted. See for more details http://forum.ubuntuusers.de/topic/wmtiler-fuer-floating-wm-s/
    X=$LEFT_MARGIN
    Y=$TOP_MARGIN
    W=$((screen[0]-LEFT_MARGIN-RIGHT_MARGIN))
    H=$((screen[1]-TOP_MARGIN-BOTTOM_MARGIN))

    if [ "$modus" = gui ]
    then
        # get ID of _NET_ACTIVE_WINDOW
        active_w=$(xprop -root _NET_ACTIVE_WINDOW | sed -n 's/.* //g p')
        i=0
        while [ "$i" -le "$w_n" ]
        do
            if [[ "${_w_ids[$i]}" -ne "$active_w" ]]
            then
                wmctrl -i -r ${_w_ids[$i]} -b remove,maximized_vert,maximized_horz
                wmctrl -i -r ${_w_ids[$i]} -e "0,$X,$Y,$W,$H"
            fi
            i=$((i+1))
        done
        # now that all the windows have been set, set the master on top
        wmctrl -r :ACTIVE: -e "0,$X,$Y,$W,$H"
    else
        i=0
        while [ "$i" -le "$w_n" ]
        do
            wmctrl -i -r ${_w_ids[$i]} -b remove,maximized_vert,maximized_horz
            wmctrl -i -r ${_w_ids[$i]} -e "0,$X,$Y,$W,$H"
            wmctrl -i -a ${_w_ids[$i]} 2>/dev/null
            i=$((i+1))
        done
    fi
}

_cmd_wins_grid_vertical() {
    # Adapted. See for more details http://forum.ubuntuusers.de/topic/wmtiler-fuer-floating-wm-s/

    columns=2 # columns1=left and columns2=right
    w_column1=$((w_n/columns))
    w_column2=$((w_column1+w_n%columns))
    X=$LEFT_MARGIN
    Y=$TOP_MARGIN
    W=$(((screen[0]-LEFT_MARGIN-RIGHT_MARGIN)/columns))
    H_column1=$(((screen[1]-TOP_MARGIN-BOTTOM_MARGIN)/w_column1-TITLE_BAR_HEIGHT))
    H_column2=$(((screen[1]-TOP_MARGIN-BOTTOM_MARGIN)/w_column2-TITLE_BAR_HEIGHT))

    # start counting from zero
    i=0
    # we have not processed any windows yet
    CURRENT_COLUMN_WINDOWS=0
    # we will be processing the first column
    CURRENT_COLUMN=1

    while [ "$i" -le "$w_n" ]
    do
        if [[ "$CURRENT_COLUMN" -lt "$columns" ]]
        then
            if [[ "$CURRENT_COLUMN_WINDOWS" -eq "$w_column1" ]]
            then
                CURRENT_COLUMN=$((CURRENT_COLUMN+1))
                if [[ "$CURRENT_COLUMN" -eq "$columns" ]]
                then
                    X=$((X+W))
                    Y=$TOP_MARGIN
                    H="$H_column2"
                else
                    CURRENT_COLUMN_WINDOWS=0
                fi
            fi
            if [[ "$CURRENT_COLUMN_WINDOWS" -eq "0" ]]
            then
                Y=$TOP_MARGIN
                H="$H_column1"
                if [[ "$CURRENT_COLUMN" -ne "1" ]]
                then
                    X=$((X+W))
                fi
            fi
        fi

        wmctrl -i -r ${_w_ids[$i]} -b remove,maximized_vert,maximized_horz
        wmctrl -i -r ${_w_ids[$i]} -e "0,$X,$Y,$W,$H"
        wmctrl -i -a ${_w_ids[$i]} 2>/dev/null

        # preselect the next window
        Y=$((Y+H))
        CURRENT_COLUMN_WINDOWS=$((CURRENT_COLUMN_WINDOWS+1))
        i=$((i+1))
    done
}

_cmd_wins_grid_horizontal() {
    # Adapted. See for more details http://forum.ubuntuusers.de/topic/wmtiler-fuer-floating-wm-s/

    rows=2 # row1=top and row2=bottom
    w_row1=$((w_n/rows))
    w_row2=$((w_row1+w_n%rows))
    X=$LEFT_MARGIN
    Y=$TOP_MARGIN
    W_row1=$(((screen[0]-LEFT_MARGIN-RIGHT_MARGIN)/w_row1))
    W_row2=$(((screen[0]-LEFT_MARGIN-RIGHT_MARGIN)/w_row2))
    H=$(((screen[1]-TOP_MARGIN-BOTTOM_MARGIN)/rows-TITLE_BAR_HEIGHT))

    # start counting from zero
    i=0
    # we have not processed any windows yet
    CURRENT_ROW_WINDOWS=0
    # we will be processing the first row
    CURRENT_ROW=1

    while [ "$i" -le "$w_n" ] # Durchlauf aller Fenster ab 0
    do
        if [[ "$CURRENT_ROW" -lt "$rows" ]] # Durchlauf ab 0
        then
            if [[ "$CURRENT_ROW_WINDOWS" -eq "$w_row1" ]] # Ende row1
            then
                CURRENT_ROW=$((CURRENT_ROW+1)) # Beginn row2
                if [[ "$CURRENT_ROW" -eq "$rows" ]]
                then
                    X=$LEFT_MARGIN
                    Y=$((Y+H+TITLE_BAR_HEIGHT)) # Y+H
                    W="$W_row2" # W row2
                else
                    CURRENT_ROW_WINDOWS=0
                fi
            fi
            if [[ "$CURRENT_ROW_WINDOWS" -eq "0" ]] # erster Durchlauf
            then
                X=$LEFT_MARGIN
                W="$W_row1" # W row1
                if [[ "$CURRENT_ROW" -ne "1" ]] # row 2
                then
                    Y=$((Y+H+TITLE_BAR_HEIGHT))
                fi
            fi
        fi

        wmctrl -i -r ${_w_ids[$i]} -b remove,maximized_vert,maximized_horz
        wmctrl -i -r ${_w_ids[$i]} -e "0,$X,$Y,$W,$H"
        wmctrl -i -a ${_w_ids[$i]} 2>/dev/null

        # preselect the next window
        X=$((X+W)) # X+W
        CURRENT_ROW_WINDOWS=$((CURRENT_ROW_WINDOWS+1)) # Fenster +1
        i=$((i+1)) # i +1
    done
}
