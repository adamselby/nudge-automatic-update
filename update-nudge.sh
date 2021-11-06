#!/bin/bash

requiredInstallationFutureTime="T00:00:00Z"
leadTimeInDays="14"

# Shared functions for each major release

function setAboutUpdate {
	# Set the About Update URL for each major release
	if [[ "${majorVersionNumber}" == "11" ]] ; then 
		aboutUpdateURL="https://support.apple.com/en-us/HT211896" # What's new in the updates for macOS Big Sur
	elif [[ "${majorVersionNumber}" == "12" ]] ; then 
		aboutUpdateURL="https://support.apple.com/en-us/HT212585" # What's new in the updates for macOS Monterey
	else
		aboutUpdateURL="https://support.apple.com/en-us/HT201541" # Update macOS on Mac
	fi
	echo "Setting About Update URL for macOS ${majorVersionName} to ${aboutUpdateURL}…"
}

function getPatchResults {
	# Get the latest release info from Jamf Patch
	jamfPatchResults=$(curl -s "https://jamf-patch.jamfcloud.com/v1/software/${majorVersionPatchID}")
}

function getLatestVersionNumber {
	# Get the latest version's version number, based on the Jamf Patch information
	latestVersionNumber=$( echo "$jamfPatchResults" | grep currentVersion | tr -d '"' | awk '{ print $2 }')
	
	echo "Latest version of macOS ${majorVersionName} is ${latestVersionNumber}…"
}

function setRequiredInstallationDate {
	# Get the latest version's release date, based on the Jamf Patch information
	latestVersionReleaseDate=$( echo "$jamfPatchResults" | grep lastModified | tr -d '"' | awk '{ print $2 }' | cut -c1-10)

	# Calculate the required installation date in the future, based upon the release date
	# …for macOS
	requiredInstallationFutureDate=$(date -j -v +${leadTimeInDays}d -f "%Y-%m-%d" "$latestVersionReleaseDate" +%Y-%m-%d)

	# …for Linux
	# requiredInstallationFutureDate=$(date -d "+$leadTimeInDays days" -I)

	# Combine the date with the time for required installation
	requiredInstallationDate="$requiredInstallationFutureDate$requiredInstallationFutureTime"
	
	echo "Latest release date for macOS ${majorVersionName} is ${latestVersionReleaseDate}, setting required installation date to ${requiredInstallationDate}…"
}

# Create a Nudge Event for each major release, and write them to nudge.json

function defineNudgeEvent {
	setAboutUpdate
	getPatchResults
	getLatestVersionNumber
	setRequiredInstallationDate

	nudgeEventData="
			{	// macOS $majorVersionName
				\"aboutUpdateURL\": \"$aboutUpdateURL\",
				\"requiredInstallationDate\": \"$requiredInstallationDate\",
				\"requiredMinimumOSVersion\": \"$latestVersionNumber\",
				\"targetedOSVersionsRule\": \"$majorVersionNumber\"
			}"
}

function createNudgeFile {
	cat <<-EOF > nudge.json
	{
			"osVersionRequirements": [
	EOF

	echo "${osVersionMonterey},${osVersionBigSur}" >> nudge.json
	scriptResult+="Updated nudge.json! "
	echo $scriptResult

	echo "
			]
	}" >> nudge.json
}

# Define major release

function nudgeMonterey {
	majorVersionName="Monterey"
	majorVersionNumber="12"
	majorVersionPatchID="41F"

	defineNudgeEvent
	
	osVersionMonterey="$nudgeEventData"
}

function nudgeBigSur {
	majorVersionName="Big Sur"
	majorVersionNumber="11"
	majorVersionPatchID="303"

	defineNudgeEvent

	osVersionBigSur="$nudgeEventData"
}

nudgeBigSur
nudgeMonterey

createNudgeFile

exit 0
