#!/bin/bash

OFFICE_SSID="blizzard"
DEBUG_LOG_FILE="/tmp/sleep-watcher-debug"
SCREEN_ON_CMD="caffeinate -d"
OFFICE_MODE_ON_FILE="/tmp/office_mode_on"

wlan_ssid() {
    local AIRPORT_CMD="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
    local SSID=`$AIRPORT_CMD -I | awk '/ SSID/ {print substr($0, index($0, $2))}'`
    echo $SSID
}

is_in_office() {
    [ "`wlan_ssid`" = $OFFICE_SSID ]
}

debug_log() {
    local MESSAGE=$1
    echo `date` $MESSAGE >> $DEBUG_LOG_FILE
}

office_mode_on_actions() {
    $SCREEN_ON_CMD &
    osascript -e "set Volume 0"
}

turn_on_office_mode() {
    if [ -f $OFFICE_MODE_ON_FILE ]; then
        debug_log "Already on office mode, exiting." && return
    fi
    touch $OFFICE_MODE_ON_FILE

    debug_log "Office mode on"

    office_mode_on_actions
}

office_mode_off_actions() {
    pkill -xf "$SCREEN_ON_CMD"
}

turn_off_office_mode() {
    if [ ! -f $OFFICE_MODE_ON_FILE ]; then
        debug_log "Already off office mode, exiting." && return
    fi
    rm $OFFICE_MODE_ON_FILE

    debug_log "Office mode off"

    office_mode_off_actions
}

main() {
    if is_in_office; then
        turn_on_office_mode
    else
        turn_off_office_mode
    fi
}

main
