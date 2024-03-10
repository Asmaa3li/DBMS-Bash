source ./tableFunctions.sh


function createDatabase {
    read -p "Enter the name of the database you want to create: " name 
    if [[ $name =~ ^[A-Za-z_]+$ && ! $(type -t $name) ]] 
    then 
        mkdir ./Database/$name 2>> logs.txt 
        if [ $? == 0 ] 
        then 
            echo -e "\e[32mThe database ${name} has been created successfully\e[0m" 
        else 
            echo -e "\e[31mError: The database ${name} already exists\e[0m" 
        fi 
    else 
        echo "Error: Enter a valid name" 
    fi 
}

function listDatabases {
    if [[ $(ls "./Database" 2>> ./logs.txt | wc -l) == 0 ]] 
    then
        echo "You don't have any databases"
    else
        for database in `ls ./Database` 
        do
            echo $database
        done
    fi
}

function dropDatabase {
    echo -e "\e[95mWrite the DB you want to drop: \e[0m"
    read -r reply

    if [[ "$reply" =~ ^[[:alpha:]_][[:alnum:]_-]*[[:alnum:]]*$ ]] ;
    then
        if test -d ./Database/$reply; then
            rm -r ./Database/$reply
            echo -e  "\e[32mdatabase $reply deleted successfully\e[0m"
        else
            echo -e  "\e[31mdatabase $reply does not exist.\e[0m"
        fi
    else
	    echo -e "\e[31mInvalid Input\e[0m"
    fi
}

function connectDatabase {
    # read -p "Write the DB you want to connect to: " reply
    echo -e "\e[95mWrite the DB you want to connect to: \e[0m"
    read -r reply

    if [[ "$reply" =~ ^[[:alpha:]_][[:alnum:]_-]*[[:alnum:]]*$ ]] ;
    then        
        if test -d ./Database/$reply; then
            COLUMNS=12
            while true;
            do
                #cd ./Database/$reply
                echo -e "\e[32mConnecting to $reply...\e[0m"
                cd ./Database/$reply
                PS3=$'\e[36m'"You are now in $reply database, please choose an option: "$'\e[0m'
            
                select i in "create table" "list all tables" "delete table" "insert into table" "select from table" "update table" "back to main menu"  "Exit"
                    do
                        case $i in
                        "back to main menu") 
                            cd ../..
                            parentMenu
                            ;;
                        "Exit")
                            exit
                            ;;
                        "create table")
                            createTable    
                            ;;
                        "list all tables")
                            #add listTables function
                            if [ $(ls -1 | wc -l) -ge 1 ];
                            then
                              echo -e "you have $(ls -1 | wc -l) tables in $reply database: \n$(ls "$PWD")"
                            else
                              echo "you do not have any tables yet"
                            fi
                            ;;
                        "delete table")
                            #add deleteTable function
                            deleteTable
                            ;;
                        "insert into table")
                            insertIntoTable
                            ;;
                        "select from table")
                            #add selectFromTable function
                            read -p "enter table you want to connect to: " reply
                            selectTable

                            ;;
                        "update table")
                            #add updateTable function
                            updateTable
                            ;;
                        *)
                            echo "choose from 1 to 8"
                            ;;
                    esac
                done 
            done
        else
            echo -e "\e[31mDatabase '$reply' does not exist.\e[0m"
        fi
    else
        echo -e "\e[31mInvalid Input\e[0m"
    fi
}

function parentMenu {
    PS3=$'\e[36m'"Select an option: "$'\e[0m'

    COLUMNS=12

    select choice in "Create a Database" "List Databases" "Drop a Database" "Connect to a Database" "Exit"
    do
        case $choice in
            "Create a Database")
                createDatabase
                ;;
            "List Databases")
                listDatabases
                ;;
            "Drop a Database")
                dropDatabase
                ;;
            "Connect to a Database")
                connectDatabase
                ;;
        "Exit")
                exit
            ;;
            *)
                echo -e "\e[31mWrong choice!\e[0m"  
                ;;
        esac
    done
}

