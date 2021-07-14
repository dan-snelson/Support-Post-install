# Support-Post-install
## Jamf Pro Post-install script to configure Support

On the off-chance this may help other Jamf Pro admins, we’re currently testing a [Support post-install script](https://github.com/dan-snelson/Support-Post-install/blob/main/Support-Post-install.bash), which we’ve added to a Jamf Pro policy as a Script payload, specifying the following:

### Jamf Pro Script Parameter Labels

- Parameter 4: Authorization Key
- Parameter 5: Reverse Domain Name Notation (i.e., "org.churchofjesuschrist")
- Parameter 6: Configuration Files to Reset (i.e., None (blank) | All | LaunchAgent)

![Jamf Pro Script Parameter Labels](images/Screen%20Shot%202021-07-14%20at%204.59.54%20AM.png)

