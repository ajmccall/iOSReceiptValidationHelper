#!/bin/bash
set -e

if [ $# -ge 2 ]
	then
		BUNDLE_ID=$1
		ITUNES_SECRET=$2
		PRODUCT_ID=$3
		
		INFO_FILE="./ReceiptHelper/Info.plist"
		CONFIG_FILE="./ReceiptHelper/purchaseController.plist"

		#Replace Values in info.plist
		echo "Replacing "$INFO_FILE" with values <BUNDLE_ID> = "$BUNDLE_ID
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" $INFO_FILE

		#Replace Values in purchaseController.plist
		echo "Replacing "$CONFIG_FILE" with value <iTunesSecret> = "$ITUNES_SECRET
        /usr/libexec/PlistBuddy -c "Set :iTunesSecret $ITUNES_SECRET" $CONFIG_FILE

		#Replace Values in purchaseController.plist
		echo "Replacing "$CONFIG_FILE" with value <productId> = "$PRODUCT_ID
        /usr/libexec/PlistBuddy -c "Set :productId $PRODUCT_ID" $CONFIG_FILE

	else
		echo "At least 2 arguments are required"
		echo "usage config.sh <BUNDLE_ID> <ITUNES_SECRET> [PRODUCT_ID]"
		echo "eg: config.sh <bundle id> <itunes iap secret> [product id]"
		exit 1
fi
