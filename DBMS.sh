#!/bin/bash

mkdir ./Database 2>> ./logs.txt
cd ./Database
echo -e "\n**************************Welcome To Our DBMS**************************\n"

select choice in "Create a Database" "List Databases" "Drop a Database" "Connect to a Database" "Exit"
do 
    case $choice in 
        "Create a Database")
            # replace your createDatabase Function here
            ;;
        "List Databases")
            # replace your listDatabase Function here
            ;;
        "Drop a Database")
            # replace your dropDatabase Function here
            ;;
        "Connect to a Database")
            # replace your connectDatabase Function here
            ;;
        "Exit")
            break 
            ;;
        *)
            echo "Wrong choice!" 
            ;;
    esac
done

