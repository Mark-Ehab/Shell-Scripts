#!/usr/bin/bash -i

#############################################################################
# Author      : Mark Ehab Tawfiq                                            #
# Date        : 11 Mar 2024                                                 #
# Script      : Process Monitor script                                      #
# description : This script is developed to help linux users to actively    #
#               monitor running processes on their linux machines. It       #
#               provides linux users the ability to view, manage and        #
#               analyze running processes through set of presented          #
#               services like:                                              #
#               1) List running processes.                                  #
#               2) Kill a running process.                                  #
#               3) Show statistics of a running process.                    #
#               4) Real-Time monitoring of actively running processes.      #
#               5) Filtering and searching for a running process.           #
#               6) Allowing users to configure update interval, alert.      #
#                  thresholds, etc.                                         #
#               7) Resource usage alerts.                                   #
#               8) Interactive mode where users can deal with script        #
#                  options through a user-friendly menu.                    #
#############################################################################

#################################################################################################
#                                   GLOBAL VARIABLES DEFINITIONS                                #
#################################################################################################

declare ARG=0                           # Global variable to hold passed argument from terminal
declare ERROR_FLAG=0                    # Global variable to hold error flag value
declare SCRIPT_DIRECTORY=0              # Global varible to hold directory path that contain this script
 
#################################################################################################
#                                           DEPENDANCIES                                        #
#################################################################################################

# Get the absolute path of the directory that contains this script during execution
SCRIPT_DIRECTORY=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Append process_monitor.conf to script directory path
SCRIPT_DIRECTORY+="/process_monitor.conf"

# Source process_monitor.conf file
source "${SCRIPT_DIRECTORY}"

#################################################################################################
#                                          COLOR CODING                                         #
#################################################################################################

declare BOLD=033[1m                                # Bold text color code
declare RED=033[31m                                # Red text color code
declare GREEN=033[32m                              # Green text color code
declare BLUE=033[34m                               # Blue text color code
declare YELLOW=033[33m                             # Yellow text color code
declare CYAN=033[36m                               # Cyan text color code
declare TERMINAL_TEXT_COLOR_RESET=033[0m           # Terminal text reset color code

#################################################################################################
#                                      FUNCTIONS DEFINITIONS                                    #
#################################################################################################

# Define a function to print a text on terminal based on desired color code
function print () 
{
    # Local variables definition
    local COLOR=$1                                  # Local variable to hold passed text color code
    local TEXT=$2                                   # Local variable to hold text to be printed

    # Print passed text on terminal based on passed text color code 
    echo -e -n "\\${COLOR}${TEXT}\\${TERMINAL_TEXT_COLOR_RESET}"
}

# Define a function to provide help manual for user to properly use the script
function showHelp()
{
    # Display help manual description 
    print "${CYAN}" "\\${BOLD}#######################\n# SCRIPT DISCRIPTION: #\n#######################\n"
    print "${TERMINAL_TEXT_COLOR_RESET}" "This script is developed to help linux users to actively monitor running processes on their linux machines. It provides linux users the ability to view, manage and analyze running processes through set of presented services which can be accessed through the following options:\n\n"

    # Display available services the script provides
    print "${BLUE}" "(1) " 
    print "${YELLOW}" "-l\t\t\t" 
    echo "List all actively running processes essential information"
    print "${BLUE}" "(2) " 
    print "${YELLOW}" "-p {PID}\t\t" 
    echo "Provide detailed information about a specfic process based on its PID"
    print "${BLUE}" "(3) " 
    print "${YELLOW}" "-s\t\t\t"
    echo "Display overall system process statistics" 
    print "${BLUE}" "(4) " 
    print "${YELLOW}" "--fname {name}\t" 
    echo "Get detailed information of a specific process based on its name"
    print "${BLUE}" "(5) " 
    print "${YELLOW}" "--fuser {user}\t" 
    echo "Get all processes details owned by a specific user"
    print "${BLUE}" "(6) " 
    print "${YELLOW}" "-i\t\t\t" 
    echo -e "Display user-friendly interactive screen"
    print "${BLUE}" "(7) " 
    print "${YELLOW}" "-k\t\t\t" 
    echo -e "Kill a specific process based on its PID"
    print "${BLUE}" "(8) " 
    print "${YELLOW}" "-h\t\t\t" 
    echo -e "Provide help manual for user to properly use the script\n"
}

# Define a function to list all actively running processes essential information 
function listAllProcesses () 
{
    # Print header of listAll service
    print "$BLUE" "\\${BOLD}##################################\n# List of all runninig processes #\n##################################\n" 
    
    # Print header of listAll service output columns
    print "$GREEN" "-----------------------------------------------\n" 
    print "$GREEN" "USER\tPID\tPPID\t%CPU\t%MEM\tCOMMAND\n"
    print "$GREEN" "-----------------------------------------------\n"

    # List all detailed information of actively running processes
    # which are USER,PID,PPID,%CPU,%MEM and COMMAND of each running
    # process
    ps --noheader -eo user,pid,ppid,%cpu,%mem,command | sort -nrk 4 | head -n 18 | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6}' 
}

# Define a function to provide detailed information about a specfic process based on its PID
function processInformation ()
{
    # Local variables definitions
    local PROCESS_ID=$1             # Local variable to hold passed process id for which detailed information to be shown
    
    # Check if a PID is passed or not
    if [ -z "${PROCESS_ID}" ]; 
    then
        # Print error message on the terminal
        print "${RED}" "Error: No PID is passed. Please try running the script again with passing a PID.\n"
        # Set ERROR_FLAG
        ERROR_FLAG=1
    else
        # Check if passed PID exists or not
        if [ ! -d /proc/"${PROCESS_ID}" ]; 
        then
            # Print error message on the terminal
            print "${RED}" "Error: This process doesn't exist. Please try running the script again with passing a valid PID.\n" 
            # Set ERROR_FLAG
            ERROR_FLAG=1 
        else
            # Print header of processInformation service 
            print "$BLUE" "\\${BOLD}#######################################################\nDetailed information of process with PID ==> ${PROCESS_ID}\n#######################################################\n" 
            
            # Print header of processInformation service output columns
            print "$GREEN" "-----------------------------------------------\n" 
            print "$GREEN" "USER\tPID\tPPID\t%CPU\t%MEM\tCOMMAND\n"
            print "$GREEN" "-----------------------------------------------\n"

            # Print detailed information of passed PID process on the terminal
            ps --noheader --pid "${PROCESS_ID}" -o user,pid,ppid,pcpu,pmem,command | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\n"}' 
        fi
    fi
}

# Define a function to display overall system process statistics
function processStatistics()
{
    # Local variables definitions
    local MEM_PERCENTAGE=0          # Local variable to hold derived overall system memory percentage
    local CPU_PERCENTAGE=0          # Local variable to hold derivrd oversll system CPU percentage

    # Print header of processStatistics service
    print "$BLUE" "\\${BOLD}#############################\\n# Overall System Statistics #\n#############################\n" 
    
    # Display total number of processes
    print "${YELLOW}" "Total number of processes: "
    ps -e --noheader | wc -l

    # Display overall system memory usage
    print "${YELLOW}" "Overall system memory usage: "
    print "${TERMINAL_TEXT_COLOR_RESET}" "$(free -m| awk '/Mem/{print $3}') MB "
    print "${TERMINAL_TEXT_COLOR_RESET}" "($(free | awk '/Mem/{printf("%0.2f%%\n",($3/$2)*100)}'))\n"

    # Display CPU load averages for the past 1,5 and 15 minutes
    print "${YELLOW}" "CPU load average in the past (1/5/15) minutes: "
    uptime | awk '{print($8 $9 $10)}'

    # Display total CPU time (usage) in percentage
    print "${YELLOW}" "(%)CPU Time(s):"
    top -b -n 1 | awk 'NR==3 {$1=""; print $0 "\n"}'

    # Assign memory and CPU usage percentage values
    MEM_PERCENTAGE=$(free | awk '/Mem/{printf("%d",($3/$2)*100)}')
    CPU_PERCENTAGE=$(top -b -n 1 | awk 'NR==3 {printf("%d",(100-$8))}')

    #Check if memory usage percentage exceeded predefined memory usage threshold
    if [ "${MEM_PERCENTAGE}" -gt "${MEMORY_ALERT_THRESHOLD}" ];
    then
        # Display an alert to tell the user that memory usage percentage 
        # exceeded predefined memory usage threshold
        print "${RED}" "ALERT: Memory usage exceeded ${MEMORY_ALERT_THRESHOLD}% ! \n"
    fi
    
    # Check if CPU usage percentage exceeded predefined CPU usage threshold
    if [ "${CPU_PERCENTAGE}" -gt "${CPU_ALERT_THRESHOLD}" ];
    then
        # Display an alert to tell the user that CPU usage percentage 
        # exceeded predefined CPU usage threshold
        print "${RED}" "ALERT: CPU usage exceeded ${CPU_ALERT_THRESHOLD}% ! \n"
    fi

    # Print new line on terminal
    echo ""
}

# Define a function to kill a process
function killProcess()
{
    # Local variables definitions
    local PROCESS_ID=$1             # Local variable to hold passed process id of process to be killed

    # Check if a PID is passed or not
    if [ -z "${PROCESS_ID}" ]; 
    then
        # Print error message on the terminal
        print "${RED}" "Error: No PID is passed. Please try running the script again with passing a PID.\n"
    else
        # Check if passed PID exists or not
        if [ ! -d /proc/"${PROCESS_ID}" ]; # This condition is valid too "$(ps -p "${PROCESS_ID}" > /dev/null 2>"&1")"
        then
            # Print error message on the terminal
            print "${RED}" "Error: This process doesn't exist. Please try running the script again with passing a valid PID.\n" 
        else
            # Ask the user if he is sure to kill the process or not
            read -r -p "Do you really want to kill process of PID ${PROCESS_ID}?(y/n) " ARG

            # Check if user's answer is yes
            if [ "${ARG}" = "y" ];
            then
                # Kill process associated with passed PID
                kill -KILL "${PROCESS_ID}"
                print "${YELLOW}" "Process of PID ${PROCESS_ID} is killed\n"
            fi
        fi
    fi
}

# Define a function to search for a specific process details based on its name
function findProcessByName()
{
    # Local variables definitions
    local PROCESS_NAME=$1           # Local variable to hold passed process name
    local PROCESS_ID=0              # Local variable to hold derived process id

    # Check if name is passed or not
    if [ -z "${PROCESS_NAME}" ];
    then
        # Print error message on terminal 
        print "${RED}" "Error : No process name is passed. Please try running the script again with passing process name to be seached for.\n"
        # Set ERROR_FLAG
        ERROR_FLAG=1 
    else
        # Check if process whose name is passed exists or not
        if [ -z "$(pgrep -x "${PROCESS_NAME}")" ];
        then
            # Print error message on terminal
            print "${RED}" "Error : This process doesn't exist. Please try running the script again with passing valid process name to be seached for.\n"
            # Set ERROR_FLAG
            ERROR_FLAG=1
        else
            # Display detailed information of process whose name is passed
            PROCESS_ID="$(pgrep -x "${PROCESS_NAME}" | awk 'NR==1 {print($0)}')" 

            # Print header of process information whose name is passed 
            print "$BLUE" "\\${BOLD}###################################################\nDetailed information of \\${RED}\\${BOLD}${PROCESS_NAME} \\${BLUE}\\${BOLD}process\n###################################################\n" 
            
            # Print header of process information output columns
            print "$GREEN" "-----------------------------------------------\n" 
            print "$GREEN" "USER\tPID\tPPID\t%CPU\t%MEM\tCOMMAND\n"
            print "$GREEN" "-----------------------------------------------\n"

            # Print detailed information of process whose name is passed on the terminal
            ps --noheader --pid "${PROCESS_ID}" -o user,pid,ppid,pcpu,pmem,command | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\n"}' 
        fi  
    fi
}

# Define a function to search for a specific process details based on its name
function findProcessesByUser()
{
    # Local variables definitions
    local USERNAME=$1

    # Check if username is passed or not
    if [ -z "${USERNAME}" ];
    then
        # Print error message on terminal 
        print "${RED}" "Error : No username is passed. Please try running the script again with passing username for whom you would like show their own processes.\n"
        # Set ERROR_FLAG
        ERROR_FLAG=1
    else
        # Check if passed username exists or not
        if [ -z "$(ps -u "${USERNAME}" 2> /dev/null)" ];
        then
            # Print error message on terminal
            print "${RED}" "Error : This username doesn't exist. Please try running the script again with passing existing username for whom you would like show their owned processes.\n"
            # Set ERROR_FLAG
            ERROR_FLAG=1 
        else
            # Print header of processes information whose username is passed 
            print "$BLUE" "\\${BOLD}###################################################\nDetailed information of \\${RED}\\${BOLD}${USERNAME} \\${BLUE}\\${BOLD}processes\n###################################################\n" 
            
            # Print header of processes information output columns
            print "$GREEN" "-----------------------------------------------\n" 
            print "$GREEN" "USER\tPID\tPPID\t%CPU\t%MEM\tCOMMAND\n"
            print "$GREEN" "-----------------------------------------------\n"

            # Print detailed information of process whose name is passed on the terminal
            ps --noheader -u "${USERNAME}" -o user,pid,ppid,%cpu,%mem,command | sort -nrk 4 | head -n 18 | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\n"}' 
        fi
    fi
}

# Define a function to display an interactive user-friendly screen for user to interact with script
function interactiveMode()
{
    # Local variables definitions
    local PROCESS_ID=0
    local PROCESS_NAME=0
    local USER_NAME=0
    local OPTION=0
    local ENTRY_FLAG=0

    # Display interactive mode user interface screen
    print "$YELLOW" "\\${BOLD}\t\t\t\t\t\t########################\n\t\t\t\t\t\t#   Interactive Mode   #\n\t\t\t\t\t\t########################\n" 
    print "${GREEN}" "\\${BOLD}#################\nChoose an option:\n#################\n"
    print "${BLUE}" "(1) "
    print "${TERMINAL_TEXT_COLOR_RESET}" "List all processes and overall system usage.\n"
    print "${BLUE}" "(2) "
    print "${TERMINAL_TEXT_COLOR_RESET}" "List detailed information of specific process based on its PID.\n"
    print "${BLUE}" "(3) "
    print "${TERMINAL_TEXT_COLOR_RESET}" "List detailed information of specific process based on its name.\n"
    print "${BLUE}" "(4) "
    print "${TERMINAL_TEXT_COLOR_RESET}" "List detailed information of all processes associated with a specific user.\n"
    print "${BLUE}" "(5) "
    print "${TERMINAL_TEXT_COLOR_RESET}" "Disaplay overall system usage.\n"
    print "${BLUE}" "(6) "
    print "${TERMINAL_TEXT_COLOR_RESET}" "Kill a specific process based on its PID.\n"
    print "${BLUE}" "(7) "
    print "${TERMINAL_TEXT_COLOR_RESET}" "Show help manual of script.\n"
    print "${BLUE}" "(8) "
    print "${TERMINAL_TEXT_COLOR_RESET}" "Exit.\n"

    # Prompt a message to ask the user to enter an option
    print "${CYAN}" "\\${BOLD}Enter an option: "
    read -r OPTION

    # Clear screen
    clear

    # Update screen based on predefined update interval
    while (true);
    do 
        # Check selected filtering option
        case "${OPTION}" in
        1)
            # Invoke listAllProcesses function
            listAllProcesses
            # Invoke processStatistics function 
            processStatistics 
        ;;
        2)
            # Check if user entered any input
            if [ "${ENTRY_FLAG}" -eq 0 ];
            then
                # Prompt a message to ask the user to enter an option
                print "${YELLOW}" "\\${BOLD}Enter process id: "
                read -r PROCESS_ID
                # Set ENRTY_FLAG
                ENTRY_FLAG=1
                # clear Screen
                clear
            fi

            # Invoke processInformation function 
            processInformation "${PROCESS_ID}"

            # Check if ERROR_FLAG is set or not
            if [ "${ERROR_FLAG}" -eq 1 ];
            then
                # Sleep for 3 secs
                sleep 3
                # Reset ERROR_FLAG
                ERROR_FLAG=0
                # Clear screen
                clear
                # Invoke interactiveMode function
                interactiveMode
            fi  
        ;;
        3)
            # Check if user entered any input
            if [ "${ENTRY_FLAG}" -eq 0 ];
            then
                # Prompt a message to ask the user to enter an option
                print "${YELLOW}" "\\${BOLD}Enter process name: "
                read -r PROCESS_NAME
                # Set ENRTY_FLAG
                ENTRY_FLAG=1
                # clear Screen
                clear
            fi            

            # Invoke findProcessByName function
            findProcessByName "${PROCESS_NAME}"

            # Check if ERROR_FLAG is set or not
            if [ "${ERROR_FLAG}" -eq 1 ];
            then
                # Sleep for 3 secs
                sleep 3
                # Reset ERROR_FLAG
                ERROR_FLAG=0
                # Clear screen
                clear
                # Invoke interactiveMode function
                interactiveMode
            fi  
        ;;
        4)
            # Check if user entered any input
            if [ "${ENTRY_FLAG}" -eq 0 ];
            then        
                # Prompt a message to ask the user to enter an option
                print "${YELLOW}" "\\${BOLD}Enter user name: "
                read -r USER_NAME
                # Set ENRTY_FLAG
                ENTRY_FLAG=1
                # clear Screen
                clear
            fi    
            
            # Invoke findProcessByUser function
            findProcessesByUser "${USER_NAME}"

            # Check if ERROR_FLAG is set or not
            if [ "${ERROR_FLAG}" -eq 1 ];
            then
                # Sleep for 3 secs
                sleep 3
                # Reset ERROR_FLAG
                ERROR_FLAG=0
                # Clear screen
                clear
                # Invoke interactiveMode function
                interactiveMode
            fi  
        ;;
        5)
            # Invoke processStatistics function 
            processStatistics 
        ;;        
        6)
            # Check if user entered any input
            if [ "${ENTRY_FLAG}" -eq 0 ];
            then   
                # Prompt a message to ask the user to enter an option
                print "${YELLOW}" "\\${BOLD}Enter process id: "
                read -r PROCESS_ID      
                # Set ENRTY_FLAG
                ENTRY_FLAG=1
                # clear Screen
                clear
            fi      

            # Invoke killProcess function
            killProcess "${PROCESS_ID}"
            
            # Sleep for 3 secs
            sleep 3
            # Clear screen
            clear
            # Invoke interactiveMode function
            interactiveMode
            
        ;;
        7)    
            # Invoke showHelp function
            showHelp
        ;;
        8)
            # Break script
            exit
        ;;
        *)
            # Display an error message for 5 sec
            print "${RED}" "Error: Invalid option, please select an option from 1-->8 and try again."

            # Sleep for 3 secs
            sleep 3

            # Clear screen
            clear

            # Invoke interactiveMode function
            interactiveMode
        ;;
        esac

        # Prompt a message to ask the user to enter q to quit the script
        # Make the prompt wait for user entry for predefined update interval
        read -rt "${UPDATE_INTERVAL}" -p "Enter q to quit or b to get back to main menu: " ARG
        
        # Check if user entered q to quit the script or not
        if [ "${ARG}" = 'q' ];
        then
            # Break the script
            exit
        elif [ "${ARG}" = 'b' ];
        then
            # Clear screen
            clear
            # Reset ENRTY_FLAG
            ENTRY_FLAG=0
            # Invoke interactiveMode function
            interactiveMode
        fi

        # Clear screen
        clear 
    done
} 

# Define a function to test process monitor script
function processMonitorScript()
{
    # Local variables definitions
    local ARG_1=$1              # Local variable to hold first passed argument 
    local ARG_2=$2              # Local variable to hold second passed argument


    # Update screen based on predefined update interval
    while (true);
    do 

        # Clear screen
        clear 
    
        # Check selected filtering option
        case "${ARG_1}" in
        -l)
            # Invoke listAllProcesses function
            listAllProcesses
            # Invoke processStatistics function 
            processStatistics 
        ;;
        -p)
            # Invoke processInformation function 
            processInformation "${ARG_2}"
            
            # Check if ERROR_FLAG is set or not
            if [ "${ERROR_FLAG}" -eq 1 ];
            then
                # Sleep for 3 sec
                sleep 3
                # Clear screen
                clear 
                # Break script
                exit
            fi  
        ;;
        -s)
            # Invoke processStatistics function 
            processStatistics 
        ;;
        --fname)
            # Invoke findProcessByName function
            findProcessByName "${ARG_2}"
           
            # Check if ERROR_FLAG is set or not
            if [ "${ERROR_FLAG}" -eq 1 ];
            then
                # Sleep for 3 sec
                sleep 3
                # Clear screen
                clear             
                # Break script
                exit
            fi  
        ;;
        --fuser)
            # Invoke findProcessByUser function
            findProcessesByUser "${ARG_2}"
            
            # Check if ERROR_FLAG is set or not
            if [ "${ERROR_FLAG}" -eq 1 ];
            then
                # Sleep for 3 sec
                sleep 3
                # Clear screen
                clear             
                # Break script
                exit
            fi  
        ;;        
        -i)
            # Invoke interactiveMode function 
            interactiveMode
        ;;
        -h)
            # Invoke showHelp function
            showHelp
            # Break script
            exit
        ;;
        -k)
            # Invoke killProcess function
            killProcess "${ARG_2}"
            # Sleep for 3 sec
            sleep 3
            # Clear screen
            clear             
            # Break script
            exit
        
        ;;
        *)
            # Invoke showHelp function
            showHelp
            # Break script
            exit
        ;;
        esac

        # Prompt a message to ask the user to enter q to quit the script
        # Make the prompt wait for user entry for predefined update interval
        read -rt "${UPDATE_INTERVAL}" -p "Enter q to quit: " ARG
        
        # Check if user entered q to quit the script or not
        if [ "${ARG}" = 'q' ];
        then
            # Break the script
            exit
        fi  

    done
}

#################################################################################################
#                                           ENTRY POINT                                         #
#################################################################################################

# Invoke processMonitorScript function
processMonitorScript "${1}" "${2}"