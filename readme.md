We use [Nudge](https://github.com/macadmins/nudge) to enforce macOS updates. Nudge is entirely customizable, and allows us to require OS updates be completed by specific set dates. While the customization of Nudge happens in a Configuration Profile on Jamf, *nudge.json* in this repository manages the `osVersionRequirements` section of Nudge. 

This JSON file is specified as *-json-url* in the LaunchAgent which is installed along with Nudge and can be updated via Jamf. Each time Nudge is launched, it checks the URL for `osVersionRequirements` This file consists of a few key parts, which are detailed below. 

**This version of `update-nudge.sh` is available for legacy reasons, where Nudge versions prior to v1.1.0 are in use.**

## update-nudge.sh

This script is intended to be run as a recurring task, and it updates the *nudge.json* file with the latest release as determined by jamf-patch, with a 45 day lead time for when the latest release will be the required version. This can be changed to a shorter window manually by editing `requiredInstallationDate` in *nudge.json*. 

When a new release is detected, the version number defined in `requiredMinimumOSVersion` in *nudge.json* is appended to the end of `targetedOSVersions` and the `requiredMinimumOSVersion` is set to the new release version number. The installation date is set to 45 days in the future, but is configurable for your environment. 

## nudge-*.json

Define required minimum OS versions, required installation dates, and targeted OS versions in a JSON file that is read by Nudge, in order to enforce Software Updates to end users. This JSON file can be served directly from Git, or hosted on a static web server. 

### aboutUpdateURL

This is a URL for the "More information" button in Nudge. This can be used to link to the "What's new in the updates for macOS" Apple Support article, or could be used to link to a CAS documentation page about a specific update, or our update policy in general. 

### requiredInstallationDate

This is the installation date where this version of macOS will be required. Users will be notified of the update prior to this date, and shown the deadline in order to encourage they update at their convenience. If the user has not updated by this date, they will be unable to defer the update further. 

### requiredMinimumOSVersion

This is the desired OS version that we are requiring users to update to. As an example, if the `requiredMinimumOSVersion` is set to 11.4, users who are already on 11.4 will not see the Nudge window notifying them to update. Any users not on 11.4 will be notified, if they are included in `targetedOSVersions`. This version does not have to be the most recent release, and does not have to match the software update available via deferred policy.

### targetedOSVersions

Finally, we have a list of targeted previous versions of macOS that must be updated to the `requiredMinimumOSVersion`. These must be individually specified in order to ensure a match against all potential Macs. 
