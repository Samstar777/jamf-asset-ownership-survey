# jamf-asset-ownership-survey
Script to take Survey through JamfPro and Populate Users Feedback as Extension Attribute

# Survey Script for Jamf Pro

This script automates the process of conducting a survey through Jamf Pro and populating users' feedback as an extension attribute. It allows you to gather information about the ownership type of assets from end users and store their responses in Jamf Pro.

# Usage

To use this script, follow the instructions below:

| Step | Description                                                                                              |
|-----:|----------------------------------------------------------------------------------------------------------|
|     1| Make note of JamfPro API userName and Password                                                           |
|     2| Download script from gitHub Page and upload the same in Jamf Pro                                         |
|     3| Create a Jamf Pro policy and add script to the policy                                                    |         
|     4| Modify the global variables section of the script according to your requirements,refer [Policy Preview](https://github.com/Samstar777/jamf-asset-ownership-survey/blob/b8d5271f42480c67398d7da7fa2df53f6a15daab/Policy%20Preview.png) |
|     5| Scope the policy as SelfService to test devices with ongoing frequency                                   |


The script will perform the following actions:

  * Check the availability of the Jamf Pro service.
  * Acquire a Jamf Pro authentication token.
  * Fetch the Jamf Pro ID for the computer using the serial number.
  * Display a pop-up message to the user, prompting them to select the ownership type of the asset.
  * Update the extension attribute in Jamf Pro with the selected ownership type.
  * The script will log the execution details and any errors encountered to the specified script log location.
  * Lastly script will invalidate the authentication token.
  
# Requirements

Bash shell environment
Jamf Pro account with appropriate privileges to access and update extension attributes.

# Configuration

The script provides several global variables that can be customized according to your needs. Here is an overview of the variables and their purpose:

  * scriptVersion: Specifies the version of the script.
  * jssUser: Jamf Pro username used for authentication.
  * jssPass: Jamf Pro user password.
  * scriptLog: Location of the script log file.
  * message: Prompt message displayed to the user during the survey.
  * Make sure to set these variables correctly before running the script.

# Troubleshooting

If you encounter any issues or errors while using the script, refer to the following troubleshooting steps:

* Ensure that the Jamf Pro service is available and accessible from the machine running the script.
* Verify the correctness of the Jamf Pro username and password specified in the script.
* Check the script log file for any error messages or unexpected behavior.
* Review the script code and comments for any missed configuration steps or syntax errors.

# Contributions

Contributions to this project are welcome. If you find any bugs, have suggestions for improvements, or would like to add new features, please open an issue or submit a pull request.

 # License

This project is licensed under the MIT License.

# Credits

Script Author: Salim Ukani (@samstar777)
