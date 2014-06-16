#!/usr/bin/env bash

_custom_selection_modus_gui(){
    #while true
    #do
        case ${app%% *} in

            *)
                    _selection_modus_cli $app
                    ;;
        esac
    #done
}
