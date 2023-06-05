#!/bin/bash

####################################################################################################
#
# Script to take Survey through JamfPro and Populate Users Feedback as Extension Attribute
#
# Author : Salim Ukani aka Samstar777
#
# Date : 4th June 2023
#
####################################################################################################
#
# HISTORY
#
#   Version 1.0.0, 5-June-2023, Salim Ukani (@samstar777)
#   - This script Survey is focus to Populate Asset Ownership in Jamf Pro
#       - Required `selectitems`
#       - BYOD
#       - CYOD
# 
####################################################################################################



####################################################################################################
#
# Global Variables
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Script Version and Jamf Pro Script Parameters
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

scriptVersion="1.0.0"
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
jssUser="$4" # Parameter 4: Jamf Pro UserName 
jssPass="$5" # Parameter 5: Jamf Pro User Password 
scriptLog="${6:-"/var/log/assetType.log"}" # Parameter 6: Script Log Location [ /var/log/assetType.log ] (i.e., Your organization's default location for client-side logs)
message="${7:-"Select Ownership of your Asset"}" # Parameter 7: PopUp message prompt

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Path to the jamf binary:
jamfBINARY="/usr/local/bin/jamf"

# These parameter getch macOS major version information
macOSMAJOR=$(sw_vers -productVersion | cut -d'.' -f1) # Expected output: 10, 11, 12, 13

# Fetch mac serialnumber
serial=$(system_profiler SPHardwareDataType | awk '/Serial/{print$NF}')


# Validate the connection to a managed computer's Jamf Pro service and set $jamfSERVER accordingly.
#getJamfProServer Information
jamfSTATUS=$("$jamfBINARY" checkJSSConnection -retry 1 2>/dev/null)
	echo "jamfSTATUS is: $jamfSTATUS" >> /var/log/assettype.log
if [[ $(echo "$jamfSTATUS" | grep -c 'available') -gt 0 ]]; then
	jamfSERVER=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)
else
	echo "Warning: Jamf Pro service unavailable."; jamfSERVER="FALSE"; jamfERROR="TRUE" >> /var/log/assettype.log
fi

# Attempt to acquire a Jamf Pro $jamfProTOKEN via $jssUser
##	getJamfProServer
if [[ "$jamfSERVER" != "FALSE" ]]; then
	echo jamfUser is: "$jssUser" >> /var/log/assettype.log
	echo jamfSERVER is: "$jamfSERVER" >> /var/log/assettype.log
	commandRESULT=$(curl -X POST -u "$jssUser:$jssPass" -s "${jamfSERVER}api/v1/auth/token")
	echo commandRESULT is:"$commandRESULT" >> /var/log/assettype.log
	if [[ $(echo "$commandRESULT" | grep -c 'token') -gt 0 ]]; then
		if [[ $macOSMAJOR -ge 12 ]]; then
			jamfProTOKEN=$(echo "$commandRESULT" | plutil -extract token raw -)
		else
			jamfProTOKEN=$(echo "$commandRESULT" | python -c 'import sys, json; print json.load(sys.stdin)["token"]')
		fi
	else
		echo "Error: Response from Jamf Pro API token request did not contain a token."; jamfERROR="TRUE" >> /var/log/assettype.log
	fi
	echo jamfProTOKEN is: \n"$jamfProTOKEN" >> /var/log/assettype.log
fi

#get ID based on serialnumber

jssID=$(curl -s -X GET "$jamfSERVER""JSSResource/computers/serialnumber/$serial" -H "accept: application/xml" -H "Authorization: Bearer $jamfProTOKEN" | xmllint --xpath "/computer/general/id/text()" -)

echo jssID is: $jssID >> /var/log/assettype.log

# Run the script to capture the end user's response
assetType=$(osascript << EOF
set assettypes to {"BYOD", "CYOD"}
set defaultasset to choose from list assettypes with prompt "$message" default items {"BYOD"}
EOF
)

echo assetType is: "$assetType" >> /var/log/assettype.log

#API command to update the end user's response
curl -X PUT -H "Accept: text/xml" -H "Content-type: text/xml" -H "Authorization: Bearer $jamfProTOKEN" -d "<computer><extension_attributes><extension_attribute><name>assetType</name><value>$assetType</value></extension_attribute></extension_attributes></computer>" "$jamfSERVER""JSSResource/computers/id/"${jssID}"/subset/extension_attributes"

# Invalid current token

invalidateTOKEN=$(curl --header "Authorization: Bearer ${jamfProTOKEN}" --write-out "%{http_code}" --silent --output /dev/null --request POST --url "${jamfSERVER}api/v1/auth/invalidate-token")
echo $invalidateTOKEN