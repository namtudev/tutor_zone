#!/bin/sh

# Script to copy the correct GoogleService-Info.plist based on build configuration
# This is called from Xcode build phases

# Determine which config to use based on the configuration name
if [ "${CONFIGURATION}" == "Debug-dev" ] || [ "${CONFIGURATION}" == "Release-dev" ]; then
    echo "Using Dev Firebase configuration"
    cp "${SRCROOT}/config/dev/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
elif [ "${CONFIGURATION}" == "Debug-staging" ] || [ "${CONFIGURATION}" == "Release-staging" ]; then
    echo "Using Staging Firebase configuration"
    cp "${SRCROOT}/config/staging/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
elif [ "${CONFIGURATION}" == "Debug-prod" ] || [ "${CONFIGURATION}" == "Release-prod" ] || [ "${CONFIGURATION}" == "Release" ] || [ "${CONFIGURATION}" == "Debug" ]; then
    echo "Using Production Firebase configuration"
    cp "${SRCROOT}/config/prod/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
else
    echo "Unknown configuration: ${CONFIGURATION}"
    echo "Using Production Firebase configuration as fallback"
    cp "${SRCROOT}/config/prod/GoogleService-Info.plist" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/GoogleService-Info.plist"
fi

echo "Firebase configuration copied successfully"
