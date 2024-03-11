#!/usr/bin/bash -i

#############################################################################
# Author      : Mark Ehab Tawfiq                                            #
# Date        : 8 Mar 2024                                                  #
# Script      : File Organizer auxillary functions                          #
# description : This file contains auxillay functions on which File         #
#               Organizer script depends to work properly.                  #
#############################################################################

#################################################################################################
#                                   GLOBAL VARIABLES DEFINITIONS                                #
#################################################################################################

# Define must-exist global variable flags for subdirectories to determine 
#if these directories need to be existed or not
declare GLOBAL_TXT_MUST_EXIST_FLAG=0                       # Must-exist global variable flag for txt directory (Initialized with 0)
declare GLOBAL_JPG_MUST_EXIST_FLAG=0                       # Must-exist global variable flag for jpg directory (Initialized with 0)
declare GLOBAL_PDF_MUST_EXIST_FLAG=0                       # Must-exist global variable flag for pdf directory (Initialized with 0)

# Define global variables to hold the count of .txt, .jpg and .pdf files that exist in the passed directory
declare GLOBAL_TXT_FILES_COUNT=0                           # Global variable to hold count of .txt files in the passed directory (Initialized with 0)
declare GLOBAL_JPG_FILES_COUNT=0                           # Global variable to hold count of .jpg files in the passed directory (Initialized with 0)
declare GLOBAL_PDF_FILES_COUNT=0                           # Global variable to hold count of .pdf files in the passed directory (Initialized with 0)

#################################################################################################
#                                      FUNCTIONS DEFINITIONS                                    #
#################################################################################################

# Define a function to check the availability of files in passed directory
function checkAvailability ()
{
    # Local variables definition
    local LOCAL_DIR_PATH=${1}               # Local variable to hold passed directory path

    # Check if there are .txt files exist in passed directory or not
    GLOBAL_TXT_FILES_COUNT=$(ls "${LOCAL_DIR_PATH}"/*.txt 2> /dev/null | wc -l)
    if [ "${GLOBAL_TXT_FILES_COUNT}" -gt 0 ]; then
        GLOBAL_TXT_MUST_EXIST_FLAG=1
    fi

    # Check if there are .jpg files exist in passed directory or not
    GLOBAL_JPG_FILES_COUNT=$(ls "${LOCAL_DIR_PATH}"/*.jpg 2> /dev/null | wc -l)
    if [ "${GLOBAL_JPG_FILES_COUNT}" -gt 0 ]; then
        GLOBAL_JPG_MUST_EXIST_FLAG=1
    fi

    # Check if there are .pdf files exist in passed directory or not
    GLOBAL_PDF_FILES_COUNT=$(ls "${LOCAL_DIR_PATH}"/*.pdf 2> /dev/null | wc -l)
    
    if [ "${GLOBAL_PDF_FILES_COUNT}" -gt 0 ]; then
        GLOBAL_PDF_MUST_EXIST_FLAG=1
    fi
}

# Define a function to create subdirectories based on files extensions if not exist
function subDirectoryCreation () 
{
    # Local variables definition
    local LOCAL_DIR_PATH=${1}               # Local variable to hold passed directory path

    # Check if /txt/ subdirectory exists within passed directory      
    # in which files to be organized or not
    # Check also if this subdirectory needs to existed
    if [ ! -d "${LOCAL_DIR_PATH}"/txt/ ] && [ "${GLOBAL_TXT_MUST_EXIST_FLAG}" -eq 1 ]; then
        mkdir "${LOCAL_DIR_PATH}"/txt/
    fi

    # Check if /jpg/ subdirectory exists within passed directory      
    # in which files to be organized or not
    # Check also if this subdirectory needs to existed
    if [ ! -d "${LOCAL_DIR_PATH}"/jpg/ ] && [ "${GLOBAL_JPG_MUST_EXIST_FLAG}" -eq 1 ]; then
        mkdir "${LOCAL_DIR_PATH}"/jpg/    
    fi

    # Check if /pdf/ subdirectory exists within passed directory      
    # in which files to be organized or not
    # Check also if this subdirectory needs to existed
    if [ ! -d "${LOCAL_DIR_PATH}"/pdf/ ] && [ "${GLOBAL_PDF_MUST_EXIST_FLAG}" -eq 1 ]; then
        mkdir "${LOCAL_DIR_PATH}"/pdf/   
    fi
    
    # Check if /misc/ subdirectory exists within passed directory      
    # in which files to be organized or not
    if [ ! -d "${LOCAL_DIR_PATH}"/misc/ ]; then
        mkdir "${LOCAL_DIR_PATH}"/misc/    
    fi
}

# Define a function to move existing files to created subdirectories
# each one based on its extension 
function fileMove () 
{   
    # Local variables definition
    local LOCAL_DIR_PATH=${1}               # Local variable to hold passed directory path

    # Check if there are .txt files to be moved to txt subdirectory if exists
    if [ ${GLOBAL_TXT_MUST_EXIST_FLAG} -eq 1 ]; then
        mv "${LOCAL_DIR_PATH}"/*.txt "${LOCAL_DIR_PATH}"/txt/ 
    fi

    # Check if there are .jpg files to be moved to jpg subdirectory 
    if [ ${GLOBAL_JPG_MUST_EXIST_FLAG} -eq 1 ]; then
        mv "${LOCAL_DIR_PATH}"/*.jpg "${LOCAL_DIR_PATH}"/jpg/ 
    fi

    # Check if there are .pdf files to be moved to pdf subdirectory 
    if [ ${GLOBAL_PDF_MUST_EXIST_FLAG} -eq 1 ]; then
        mv "${LOCAL_DIR_PATH}"/*.pdf "${LOCAL_DIR_PATH}"/pdf/ 
    fi

   # Move rest of files (files with unknown or no file extensions) to misc subdirectory
   # through looping over rest of files in the passed directory 

   # Define local variable to hold output of "ls -p | grep -v /" command 
   # which is all files (not directories) in the passed directory
   local REST_OF_FILES_IN_DIRECTORY
   REST_OF_FILES_IN_DIRECTORY=$(ls -p "${LOCAL_DIR_PATH}" | grep -v /)

   # Loop over all extracted files 
   for file in ${REST_OF_FILES_IN_DIRECTORY}; do
        # Move each one to misc subdirectory
        mv "${LOCAL_DIR_PATH}"/"${file}" "${LOCAL_DIR_PATH}"/misc/
   done
}
