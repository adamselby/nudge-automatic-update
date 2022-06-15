# Nudge Automatic Update

You can use [Nudge](https://github.com/macadmins/nudge) to enforce macOS updates, but this requires manual work on your part for regular updates to macOS. Nudge is entirely customizable, and allows you the ability to require OS updates be completed by specific set dates, which is what you can automate using *update-nudge.sh*. The customization of Nudge can happen via a Configuration Profile, and *nudge.json* in this repository can manage the `osVersionRequirements` section of Nudge independently of the Configuration Profile. This allows for updates as each new version of macOS releases, without pushing a new profile. 

To do this, the JSON file can be served up at a URL which is then specified as *-json-url* in the LaunchAgent. This LaunchAgent is installed along with Nudge, or can be created and updated via a script, independently of your install. Each time Nudge is launched via this LaunchAgent, it checks the URL for `osVersionRequirements` in *nudge.json*. Because of the difference in OS versions, it would be This information consists of a few key parts, which are detailed below. 

This version of `update-nudge.sh` is for Nudge v1.1.0 or higher only. You can find a legacy version supporting `targetedOSVersions` under previous releases, if needed. 

## update-nudge.sh

This script is intended to be run through a variety of triggers, including a manual trigger, an automated trigger based on a content change from a source such as [Apple Software Lookup Service](https://gdmf.apple.com/v2/pmv), or on a recurring basis. The script updates *nudge.json* file with the latest release information for macOS Big Sur and macOS Monterey. This latest release information is provided by Jamf Patch. 

Each new release is added with a configurable lead time (default: 14 days) from when the latest release is available to when it will be the required version for easy automation of Nudge Events. When a new release is available, the version number becomes the `requiredMinimumOSVersion`, and the `requiredInstallationDate` is set to a future date determined by the configurable lead time.

Currently, this script does not account for or accommodate [deferring software updates](https://support.apple.com/guide/mdm/managing-software-updates-mdm02df57e2a/web#mdmfb8077b62), and assumes that updates are available to your users immediately. A future version of this script will allow for a configurable deferral period. 

### nudgeLatest

`nudgeLatest` uses the generic macOS Jamf Patch item, which always reflects the most recent public version of macOS. This uses the Nudge Event `targetedOSVersionsRule` of **default**, ensuring that users on any version of macOS receive the Nudge Event. 

## nudge.json

Defines multiple values for a major release of macOS, including the about update URL, required installation dates, minimum OS versions, and targeted OS version in a JSON file that is read by Nudge, in order to enforce Software Updates to end users. This JSON file can be served directly from Git, or hosted on a static web server. 

### aboutUpdateURL

This is a URL for the "More information" button in Nudge. This can be used to link to the "What's new in the updates for macOS" Apple Support article, or could be used to link to an internal documentation page.  

### requiredInstallationDate

The required installation date for Nudge to enforce the required operating system version. This is calculated as a future date using the configurable lead time (default: 14 days) and the published date from Jamf Patch. By default, a new release of macOS will be required 14 days after release. 

### requiredMinimumOSVersion

The required minimum operating system version. This is the desired OS version that we are requiring users to update to automatically after it is released. This version is provided by Jamf Patch, along with the release date. 

### targetedOSVersionsRule

The major version of macOS that require a security update. This script automatically targets the correct OS using *major OS match*, meaning updates to macOS Monterey will be required for users on macOS Monterey only, while updates to macOS Big Sur will be required for users on macOS Big Sur only. Users will not be prompted to upgrade to macOS Monterey with these rules. This allows us to maintain separate upgrade paths for users who need to remain on macOS Big Sur and have not upgraded to macOS Monterey. If you are not deferring major versions of macOS, your users may still be prompted by Software Update to install macOS Monterey while on macOS Big Sur. 
