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

source ${utils_dir}/acti_check.sh
source ${utils_dir}/acti_cmd.sh
source ${utils_dir}/acti_custom.sh
source ${utils_dir}/acti_exec.sh
source ${utils_dir}/acti_selection.sh
source ${utils_dir}/acti_status.sh

log_echo="| tee -a "$log_file""

[ "$xmessage" = true ] && xm_echo="| tee >(xmessage -title "${xmessage_title:-"xmessage:acti"}" -name "acti" -file -)"

shopt -s execfail

_config_dmenu() {
    dmenu $d_opt $d_name $d_class $d_prompt $d_h $d_w $d_x $d_y $d_o $d_dim $d_dc ${d_color[*]} -fn "${d_fn:='Droid Sans Mono-9'}"
}

_config_status_1() {
    { echo "$1: $mes" >&2 ; exit "$1" ; }
}

_config_status_2() {
    { eval echo "$(date +%Y-%m-%d_%H:%M:%S) $1: $mes" ${log_file:+"$log_echo"} | cut -c21- >&2 ; exit "$1" ; }
}

_config_status_3() {
    { eval echo "$(date +%Y-%m-%d_%H:%M:%S) $1: $mes" ${log_file:+"$log_echo"} | eval cut -c21- "$xm_echo" >&2 ; exit "$1" ; }
}

_config_status_4() {
    eval echo "$(date +%Y-%m-%d_%H:%M:%S) $1: $mes" ${log_file:+"$log_echo"} | eval cut -c21- "$xm_echo" >&2 ; { [ "$modus" = gui ] && _main --gui ; } || exit "$1"
}

_config_status_5() {
    { eval echo "$(date +%Y-%m-%d_%H:%M:%S) $1: $mes" ${log_file:+"$log_echo"} | cut -c21- >&2 ; _exec_app ; }
}

_config_status_6() {
    { eval echo "$(date +%Y-%m-%d_%H:%M:%S) $1: $mes" ${log_file:+"$log_echo"} | cut -c21- >&2 ; }
}
