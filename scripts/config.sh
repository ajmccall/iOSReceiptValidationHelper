#!/bin/bash
set -e

if [ $# -ge 2 ]
	then
		BUNDLE_ID=$1
		ITUNES_SECRET=$2
		
		INFO_FILE="./ReceiptHelper/Info.plist"
		CONFIG_FILE="./ReceiptHelper/purchaseController.plist"

		#Replace Values in info.plist
		echo "Replacing "$INFO_FILE" with values <BUNDLE_ID> = "$BUNDLE_ID
        /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" $INFO_FILE

		#Replace Values in purchaseController.plist
		echo "Replacing "$CONFIG_FILE" with value <iTunesSecret> = "$ITUNES_SECRET
        /usr/libexec/PlistBuddy -c "Set :iTunesSecret $ITUNES_SECRET" $CONFIG_FILE

	else
		echo "2 arguments are required"
		echo "usage config.sh <BUNDLE_ID> <ITUNES_SECRET>"
		echo "eg: config.sh com.yourcompany.app_id your_itunes_connect_secret_key"
		exit 1
fi
