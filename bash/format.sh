#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "No argument provided. Usage: ./format.sh [-app]"
    exit 1
fi

# Parse the argument
case "$1" in
    -app)
        echo "Running command for -app"
        echo "Format App"
        swiftformat [path/app] --config [path/config]
        ;;
    *)
        echo "Invalid argument. Usage: ./format.sh [-app]"
        exit 1
        ;;
esac
