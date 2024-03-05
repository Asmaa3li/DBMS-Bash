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
	      echo -e "\e[32mConnecting to $reply...\e[0m"
              PS3=$'\e[36m'"You are now in $reply database, please choose an option: "$'\e[0m'

	      select i in "create table" "list all tables" "delete table" "insert into table" "select from table" "update table" "back to main menu"  "Exit"
              do
              case $i in
              "back to main menu") 
		   parentMenu
		  
              ;;
              "Exit")
		   exit
              ;;
              "create table")
		    #add createTable function
            
              ;;
              "list all tables")
                    #add listTables function
              ;;
              "delete table")
                    #add deleteTable function
              ;;
              "insert into table")
                   #add insertIntoTable function
              ;;
              "select from table")
                  #add selectFromTable function
              ;;
              "update table")
                 #add updateTable function
              ;;
              *)
              echo "choose from 1 to 7"
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

PS3=$'\e[36m'"Choose number: "$'\e[0m'

COLUMNS=12

select choice in "Create a Database" "List Databases" "Drop a Database" "Connect to a Database" "Exit"
do
    case $choice in
        "Create a Database")
            createDatabase
            ;;
        "List Databases")
            # replace your listDatabase Function here
            listDatabases
            ;;
        "Drop a Database")
            # replace your dropDatabase Function here
	    dropDatabase
            ;;
        "Connect to a Database")
            # replace your connectDatabase Function here
            connectDatabase
            ;;
	"Exit")
       	    exit
	    ;;
        *)
            echo -e  "\e[31mWrong choice!\e[0m"  
            ;;
    esac
done

}
