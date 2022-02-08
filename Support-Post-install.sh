#!/bin/sh

####################################################################################################
#
#	Support Post-install
#
#	Purpose: Configures Support to company standards post-install
#	https://github.com/root3nl/SupportApp/blob/master/LaunchAgent%20Sample/nl.root3.support.plist
#
####################################################################################################
#
# HISTORY
#
# 	Version 0.0.1, 30-Jun-2021, Dan K. Snelson (@dan-snelson)
#		Original version
#
#	Version 0.0.2, 14-Jul-2021, Dan K. Snelson (@dan-snelson)
#		Leveraged Jamf Pro Self Service "brandingimage.png" for custom logo
#
####################################################################################################



####################################################################################################
#
# Variables
#
####################################################################################################

scriptVersion="0.0.2"
scriptResult=""
loggedInUser=$( /bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/ { print $3 }' )
loggedInUserID=$( /usr/bin/id -u "${loggedInUser}" )
authorizationKey="${4}"				# Authorization Key to prevent unauthorized execution via Jamf Remote
plistDomain="${5}"				# Reverse Domain Name Notation (i.e., "org.churchofjesuschrist")
resetConfiguration="${6}"			# Configuration Files to Reset (None (blank) | All | LaunchAgent)
launchAgentPath="/Library/LaunchAgents/${plistDomain}.Support.plist"
defaultLaunchAgentPath="/Library/LaunchAgents/nl.root3.support.plist"



####################################################################################################
#
# Functions
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Check for a specified value in Parameter 4 to prevent unauthorized script execution
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function authorizationCheck() {

	if [[ "${authorizationKey}" != "PurpleMonkeyDishwasher" ]]; then

		scriptResult+="Error: Incorrect Authorization Key; exiting."
		echo "${scriptResult}"
		exit 1

	else

		scriptResult+="Correct Authorization Key, proceeding; "

	fi

}



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Reset Configuration
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function resetConfiguration() {

	echo "Reset Configuration: ${1}"
	scriptResult+="Reset Configuration: ${1}; "

	case ${1} in

		"All" )
			# Reset All Configuration Files
			echo "Reset All Configuration Files"

			# Delete Default LaunchAgent
			echo "Unload ${defaultLaunchAgentPath} …"
			/bin/launchctl asuser "${loggedInUserID}" /bin/launchctl unload -w "${defaultLaunchAgentPath}"
			echo "Remove ${defaultLaunchAgentPath} …"
			/bin/rm -fv ${defaultLaunchAgentPath}
			scriptResult+="Removed ${defaultLaunchAgentPath}; "
			
			# Reset LaunchAgent
			echo "Unload ${launchAgentPath} …"
			/bin/launchctl asuser "${loggedInUserID}" /bin/launchctl unload -w "${launchAgentPath}"
			echo "Remove ${launchAgentPath} …"
			/bin/rm -fv ${launchAgentPath}
			scriptResult+="Removed ${launchAgentPath}; "

			# Hide Support in Finder
			echo "Hide Support in Finder …"
			/usr/bin/chflags hidden "/Applications/Support.app" 
			scriptResult+="Hid Support in Finder; "

			# Hide Support in Launchpad
			echo "Hide Support in Launchpad …"
			/usr/bin/sqlite3 $(/usr/bin/sudo find /private/var/folders \( -name com.apple.dock.launchpad -a -user ${loggedInUser} \) 2> /dev/null)/db/db "DELETE FROM apps WHERE title='Support';"
			/usr/bin/killall Dock
			scriptResult+="Hid Support in Launchpad; "

			# Support custom logo
			echo "Support custom logo …"
			/bin/mkdir -pv /Library/Application\ Support/${plistDomain}
			/bin/cp -v /Users/${loggedInUser}/Library/Application\ Support/com.jamfsoftware.selfservice.mac/Documents/Images/brandingimage.png /Library/Application\ Support/${plistDomain}/brandingimage.png
			scriptResult+="Copied Support custom logo; "

			scriptResult+="All Configuration Files; "
			;;

		"LaunchAgent" )
			# Reset LaunchAgent
			echo "Unload ${launchAgentPath} …"
			/bin/launchctl asuser "${loggedInUserID}" /bin/launchctl unload -w "${launchAgentPath}"
			echo "Remove ${launchAgentPath} …"
			/bin/rm -fv ${launchAgentPath}
			scriptResult+="Removed ${launchAgentPath}; "
			;;

		* )
			# None of the expected options was entered; don't reset anything
			echo "None of the expected reset options was entered; don't reset anything"
			scriptResult+="None of the expected reset options was entered; don't reset anything; "
			;;

	esac

}



####################################################################################################
#
# Program
#
####################################################################################################

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Logging preamble
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

echo " "
echo "###"
echo "# Support Post-install (${scriptVersion})"
echo "###"
echo " "



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Confirm Authorization
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

authorizationCheck



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Reset Configuration
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

resetConfiguration "${resetConfiguration}"



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Support LaunchAgent
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if [[ ! -f ${launchAgentPath} ]]; then

	echo "Create ${launchAgentPath} …"

	cat <<EOF > ${launchAgentPath}
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>${plistDomain}.Support.plist</string>
<key>ProgramArguments</key>
	<array>
		<string>/Applications/Support.app/Contents/MacOS/Support</string>
	</array>
	<key>KeepAlive</key>
	<true/>
	<key>ProcessType</key>
	<string>Interactive</string>
</dict>
</plist>
EOF

	scriptResult+="Created ${launchAgentPath}; "

	echo "Set ${launchAgentPath} file permissions ..."
	/usr/sbin/chown root:wheel ${launchAgentPath}
	/bin/chmod 644 ${launchAgentPath}
	/bin/chmod +x ${launchAgentPath}
	scriptResult+="Set ${launchAgentPath} file permissions; "

else

	echo "${launchAgentPath} exists"
	scriptResult+="${launchAgentPath} exists; "

fi


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Load Support LaunchAgent
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# https://github.com/macadmins/nudge/blob/main/build_assets/postinstall-launchagent
# Only enable the LaunchAgent if there is a user logged in, otherwise rely on built in LaunchAgent behavior
if [[ -z "$loggedInUser" ]]; then
	echo "Did not detect user"
elif [[ "$loggedInUser" == "loginwindow" ]]; then
	echo "Detected Loginwindow Environment"
elif [[ "$loggedInUser" == "_mbsetupuser" ]]; then
	echo "Detect SetupAssistant Environment"
elif [[ "$loggedInUser" == "root" ]]; then
	echo "Detect root as currently logged-in user"
else
	# Unload the LaunchAgent so it can be triggered on re-install
	/bin/launchctl asuser "${loggedInUserID}" /bin/launchctl unload -w "${launchAgentPath}"
	# Kill Support just in case (say someone manually opens it and not launched via LaunchAgent
	/usr/bin/killall Support
	# Load the LaunchAgent
	/bin/launchctl asuser "${loggedInUserID}" /bin/launchctl load -w "${launchAgentPath}"
fi



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Exit
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

scriptResult+="Goodbye!"

echo "${scriptResult}"

exit 0
