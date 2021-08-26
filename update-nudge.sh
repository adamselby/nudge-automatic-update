#!/bin/bash

# Define the current Jamf Patch URL
jamfPatchURL="https://jamf-patch.jamfcloud.com/v1/software/303" # macOS Big Sur

# Get the current contents of nudge-11.json
jsonContents=$(cat nudge-11.json)
requiredMinimumOSVersionCurrent=$(echo $jsonContents | grep requiredMinimumOSVersion | tr -d '"' | tr -d ',' | awk '{print $9;}')
targetedOSVersionsCurrent=$(echo $jsonContents | grep targetedOSVersions | tr -d ']' | tr -d '}' | awk '{$1 = ""; $2 = ""; $3 = ""; $4 = ""; $5 = ""; $6 = ""; $7 = ""; $8 = ""; $9 = ""; $10 = ""; $11 = ""; print $0;}')
echo "Current minimum OS version is $requiredMinimumOSVersionCurrent"

# Add the current minimum OS version to the targeted OS versions list
targetedOSVersions=$(echo $targetedOSVersionsCurrent, \"$requiredMinimumOSVersionCurrent\")

# Get the latest release info from jamf-patch
latestVersionNumber=$(curl -s "$jamfPatchURL" | grep currentVersion | tr -d '"' | awk '{ print $2 }')
latestVersionReleaseDate=$(curl -s "$jamfPatchURL" | grep lastModified | tr -d '"' | awk '{ print $2 }' | cut -c1-10)
echo "Latest OS version is $latestVersionNumber"

# Calculate the required minimum OS version and targeted OS versions
requiredMinimumOSVersion=$(echo $latestVersionNumber)

# Check if the current targetedOSVersions matches latestVersionNumber
if [[ "${requiredMinimumOSVersionCurrent}" == "${latestVersionNumber}" ]] ; then
	echo "Versions match, exiting…"
	exit 0
else
	echo "Versions do not match, updating nudge-11.json…"

	# Set the About Update URL for a release
	latestVersionRelease=$(echo $latestVersionNumber | awk -F. '{ print $1 }')
	if [[ "${latestVersionRelease}" == "11" ]] ; then 
		aboutUpdateURL="https://support.apple.com/en-us/HT211896"
		echo "Setting About Update URL to \"What's new in the updates for macOS Big Sur\""
	elif [[ "${latestVersionRelease}" == "12" ]] ; then 
		aboutUpdateURL="https://support.apple.com/en-us/" # future link for macOS Monterey
		# echo "Setting About Update URL to What's new in the updates for macOS Monterey"
	else
		aboutUpdateURL="https://support.apple.com/en-us/HT201541" # Update macOS on Mac
	fi

	# Calculate the required installation date in the future, based upon the release date

	# …for macOS
	requiredInstallationFutureDate=$(date -j -v +45d -f "%Y-%m-%d" "$latestVersionReleaseDate" +%Y-%m-%d)

	# …for Linux
	# requiredInstallationFutureDate=$(date -d "+45 days" -I)

	requiredInstallationFutureTime="T00:00:00Z"
	requiredInstallationDate="$requiredInstallationFutureDate$requiredInstallationFutureTime"
	echo "Latest OS release date is $latestVersionReleaseDate, setting required installation date to $requiredInstallationFutureDate"

	# Generate new JSON
	cat <<-EOF > nudge-11.json
	{
		"osVersionRequirements": [{
			"aboutUpdateURL": "$aboutUpdateURL",
			"requiredInstallationDate": "$requiredInstallationDate",
			"requiredMinimumOSVersion": "$latestVersionNumber",
			"targetedOSVersions": [ $targetedOSVersions ]
		}]
	}
	EOF

	scriptResult+="Updated nudge-11.json; "
	echo $scriptResult
	exit 0
fi
