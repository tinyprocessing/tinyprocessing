#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [-info] [-list] [-connect SSID] [-on] [-off]"
    exit 1
}

# Function to get current Wi-Fi connection info
get_info() {
    networksetup -getinfo Wi-Fi
    networksetup -getairportnetwork en0
}

# Function to list available Wi-Fi SSIDs
list_wifi() {
    /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s
}

# Function to connect to a specified Wi-Fi SSID
connect_wifi() {
    if [ -z "$1" ]; then
        echo "Error: SSID not provided."
        usage
    fi
    networksetup -setairportnetwork en0 "$1"
}

# Function to turn on Wi-Fi
turn_on_wifi() {
    networksetup -setairportpower Wi-Fi on
}

# Function to turn off Wi-Fi
turn_off_wifi() {
    networksetup -setairportpower Wi-Fi off
}

# Check the number of arguments
if [ "$#" -eq 0 ]; then
    usage
fi

# Parse command line options
while [ "$#" -gt 0 ]; do
    case "$1" in
        -info)
            get_info
            ;;
        -list)
            list_wifi
            ;;
        -connect)
            shift
            connect_wifi "$1"
            ;;
        -on)
            turn_on_wifi
            ;;
        -off)
            turn_off_wifi
            ;;
        *)
            echo "Invalid option: $1"
            usage
            ;;
    esac
    shift
done

exit 0
