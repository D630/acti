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

_status() {
    case "$1" in

        01)
                mes='App File is unset!'
                ;;
        02)
                mes='There is no App File!'
                ;;
        03)
                mes='Empty App File exists!'
                ;;
        04)
                mes='Bye, Bye! No App has been chosen.'
                ;;
        05)
                mes="App '$app' is blocked!"
                ;;
        06)
                mes='Could not activate Window!'
                ;;
        07)
                mes='Could not run App!'
                ;;
        08)
                mes="Command '${app##* }' does not exist!"
                ;;
        10)
                mes="Could not run command "edit"!"
                ;;
        11)
                mes='Could not print App File!'
                ;;
        12)
                mes='Could not print formatted App File!'
                ;;
        13)
                mes="Command '${0##*/} $*' is unknown!"
                ;;
        14)
                mes='Could not create Backup File!'
                ;;
        15)
                mes='Could not write App File!'
                ;;
        16)
                mes='Backup File is unset!'
                ;;
        19)
                mes='You need to switch to another desktop first!'
                ;;
        25)
                mes='App Dir is unset!'
                ;;
        26)
                mes='App Dir has been created!'
                ;;
        27)
                mes='Invalid syntax!'
                ;;
        28)
                mes="App '$app' is an ignore case!"
                ;;
        29)
                mes="App '$app' is not in list!"
                ;;
        30)
                mes='Could not write History File!'
                ;;
        31)
                mes='App has no Desktop File!'
                ;;
        32)
                mes="App '$a' has been deleted!"
                ;;
        33)
                mes="Added App '$a' is blocked now!"
                ;;
        34)
                mes="Added App '$a' is ignored now!"
                ;;
        35)
                mes="App '$a' has been added!"
                ;;
        36)
                mes='Could not create Backup Dir!'
                ;;
        37)
                mes="Command '${0##*/} $app' is unknown!"
                ;;
        38)
                mes='App File has been build!'
                ;;
        39)
                mes='Could not build App File!'
                ;;
        40)
                mes='New App Dir has been build!'
                ;;
        41)
                mes='Could not build new App Dir!'
                ;;
        42)
                mes='App Dir has been rebuild!'
                ;;
        43)
                mes='Could not rebuild App Dir!'
                ;;
        44)
                mes="$l has been set!"
                ;;
        45)
                mes="Could not set $l!"
                ;;
        46)
                mes="History File is unset!"
                ;;
        *)
            return 0
            ;;
    esac

    case "$2" in

        1)
                _config_status_1 "$1"
                ;;
        2)
                _config_status_2 "$1"
                ;;
        3)
                _config_status_3 "$1"
                ;;
        4)
                _config_status_4 "$1"
                ;;
        5)
                _config_status_5 "$1"
                ;;
        6)
                _config_status_6 "$1"
                ;;
        *)
                return 0
                ;;
    esac
}
