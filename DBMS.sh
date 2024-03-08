#!/bin/bash
source ./mainFunctions.sh

mkdir -p ./Database 2>> ./logs.txt
# cd ./Database 
#source ./mainFunctions.sh
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"
reset="\033[0m" 


bar=""
for ((i=0; i<50; i++)); do
    bar+="\u2500"
done

# Print 
echo -e "$bar\u252c$bar\u2500\u2500"
echo -e "${red}                                          Welcome${green} To${yellow} Our${blue} DBMS${reset}"
echo -e "$bar\u2534$bar\u2500\u2500"







parentMenu










: <<'END_COMMENT'
PS3="enter number: "
COLUMNS=12
select choice in "Create a Database" "List Databases" "Drop a Database" "Connect to a Database" "Exit"
do 
    case $choice in 
	"Exit")
            break
	    exit i0
            ;;
        "Create a Database")
            createDatabase
            ;;
        "List Databases")
            # replace your listDatabase Function here
            listDatabases
            ;;
        "Drop a Database")
            # replace your dropDatabase Function here
            ;;
        "Connect to a Database")
            # replace your connectDatabase Function here
	    connectDatabase
            ;;       
        *)
            echo "Wrong choice!" 
            ;;
    esac
done
END_COMMENT

