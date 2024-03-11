#!/usr/bin/bash -i

#############################################################################
# Author      : Mark Ehab Tawfiq                                            #
# Date        : 8 Mar 2024                                                  #
# Script      : File Organizer                                              #
# description : This script organizes files in a specified directory        #
#               based on their file types into separate subdirectories.     #
#               This can be useful to keep your directories clean and tidy  #
#               by automatically sorting files into appropriate categories. #
#############################################################################

#################################################################################################
#                                           DEPENDANCIES                                        #
#################################################################################################

# Include File_Organizer_Functions.sh for the script to run properly
source ~/Desktop/EmbeddedLinuxDiplomaTasks/ShellScripting/task1/File_Organizer_Functions.sh

#################################################################################################
#                                   GLOBAL VARIABLES DEFINITIONS                                #
#################################################################################################

# Define a global variable to hold passed directory path 
# in which files to be organized
declare GLOBAL_DIRECTORY_PATH=${1}

#################################################################################################
#                                      FUNCTIONS DEFINITIONS                                    #
#################################################################################################

# Define the test function of File Organizer 
function fileOrganizerTest () 
{
    # Local variables definition
    local LOCAL_DIR_PATH=${1}               # Local variable to hold passed directory path

    # Check if passed directory path is valid or not 
    if [ ! -d "${LOCAL_DIR_PATH}" ]; then
        echo "Error: No such file or directory"
    else    

        # Check files availabilty
        checkAvailability "${LOCAL_DIR_PATH}"

        # Create subdirectories 
        subDirectoryCreation "${LOCAL_DIR_PATH}" 

        # Move files to subdirectories
        fileMove "${LOCAL_DIR_PATH}"
    fi
}
#################################################################################################
#                                  FILE ORGANIZER SCRIPT TEST                                   #
#################################################################################################

# Test file organizer 
fileOrganizerTest "${GLOBAL_DIRECTORY_PATH}"