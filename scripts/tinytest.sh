#!/bin/bash

# Configuration
PROJECT_DIR=""
PROJECT_NAME=""
SCHEME_NAME=""
CONFIGURATION="Debug"
SIMULATOR_PLATFORM="iOS Simulator"
DEVICE_NAME="iPhone 15 Pro"
RUNTIME_OS="17.2"

# Build and test the project
echo -e "\033[1;36mFinding and Booting Simulator\033[0m"
echo "Runtime OS will be this: ${RUNTIME_OS}"
echo "Device name: ${DEVICE_NAME}"

echo -e "\033[1;36mBoot...\033[0m"
echo -e "\033[1;36mTarget Simulator: ${SIMULATOR_PLATFORM} ${DEVICE_NAME} (${RUNTIME_OS})\033[0m"

# Start timer
start_time=$(date +%s)

# Clean, build, and test the project with caching and parallel builds
xcodebuild \
-project "${PROJECT_DIR}/${PROJECT_NAME}" \
-scheme "${SCHEME_NAME}" \
-configuration "${CONFIGURATION}" \
-destination "platform=${SIMULATOR_PLATFORM},name=${DEVICE_NAME},OS=${RUNTIME_OS}" \
-jobs 8 \
-enableCodeCoverage "YES" \
build-for-testing \
test \
| tee build/xcodebuild.log | xcpretty --color

# End timer
end_time=$(date +%s)
elapsed_time=$((end_time - start_time))

# Check for errors
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mBuild failed. Check the output above for details.\033[0m"
    exit 1
fi

echo -e "\033[1;36mBuild completed in ${elapsed_time} seconds.\033[0m"

