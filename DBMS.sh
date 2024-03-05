#!/bin/bash
source ./mainFunctions.sh

mkdir -p ./Database 2>> ./logs.txt
# cd ./Database
echo -e "\n\e[33m**************************Welcome To Our DBMS**************************\e[0m\n" 
#source ./mainFunctions.sh

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

