function createTable {
    read -p "Enter the name of the table: " name
    if [[ $name =~ ^[A-Za-z_]+$ && ! -f ./$name ]]; then
        primaryKey=""
        tableSchema=""

        # Validate the number of fields
        read -p "Enter the number of fields: " fieldsNumber
        while ! [[ $fieldsNumber =~ ^[1-9]+$ ]]; do
            read -p "Enter a valid number of fields: " fieldsNumber
        done

        for ((i = 1; i <= fieldsNumber; i++)); do
            read -p "Enter the name of field ${i}: " fieldName

            # Validate the field name
            while [[ ! $fieldName =~ ^[A-Za-z_]+$ || $tableSchema =~ "${fieldName}|" ]]; do
                read -p "Not a valid name or field already exists, Try again: " fieldName
            done

            read -p "Enter the type of the field ${i}: " fieldType

            # Validate the field type
            valid_types=("int" "string") 
            while [[ ! "${valid_types[@]}" =~ "${fieldType}" ]]; do
                read -p "Invalid field type. Enter a valid field type (${valid_types[*]}): " fieldType
            done

            tableSchema+="${fieldName}|${fieldType}"

            if [ -z $primaryKey ]; then
                read -p "Do you want the ${fieldName} to be the primary key? Enter yes or no: " answer
                while [[ ${answer,,} != "yes" && ${answer,,} != "no" ]]; do
                    echo "Invalid input! Enter yes or no: "
                    read -p "Do you want the ${fieldName} to be the primary key? Enter yes or no: " answer
                done

                if [ ${answer,,} == "yes" ]; then
                    primaryKey=${fieldName}
                    tableSchema+="|PK"
                    echo -e "\033[32mThe field \"${fieldName}\" is now the Primary Key\033[0m"
                fi
            fi
            if [[ $i != $fieldsNumber ]]
            then
                tableSchema+="\n"
            fi
        done

        if [ -z $primaryKey ]; then 
            # If no primary key selected, set the last field as the primary key
            lastField=$(echo "$tableSchema" | awk '{print $1}' | tail -n 1)
            tableSchema=$(echo "$tableSchema" | sed '$s/$/|PK\n/')
            echo -e "\033[32mAs you didn't select a primary key, The field \"${lastField}\" is now the default Primary Key\033[0m"           
        fi

        # Display the table schema
        echo -e "Table Schema:\n$tableSchema"

        # Confirm table creation
        read -p "Do you want to create this table? (yes/no): " confirm
        if [[ ${confirm,,} == "yes" ]]; then
            echo -e $tableSchema > ./"${name}-metadata"
            touch ./$name
            echo -e "\033[32mYour table has been created successfully!\033[0m"
        else
            echo "Table creation aborted."
        fi
    else 
        echo "Please enter a valid name or the table already exists"
    fi
}


function insertIntoTable {
    read -p "Enter the table you want to enter your data into: " tableName

    fields=()
    fieldsType=()

    # Read metadata file line by line
    if [[ -f "./${tableName}-metadata" ]]; then
        while IFS='|' read -r fieldName fieldType _; do
            fields+=("$fieldName")
            fieldsType+=("$fieldType")
        done < "./${tableName}-metadata" 
    else
        echo "Error: Metadata file '${tableName}-metadata' does not exist!" >> ../../logs.txt
    fi

    if [[ $tableName =~ ^[A-Za-z_]+$ && -f "./$tableName" ]]; then
        declare i=0
        line=""
        while (( i < ${#fields[@]} )); do

            read -p "Enter the value of field ${fields[i]}: " value

            if [[ ${fieldsType[i]} == "int" ]]; then
                while [[ ! $value =~ ^[0-9]*$ ]]; do
                    read -p "Please enter a valid integer value for the field ${fields[i]}: " value
                done

            elif [[ ${fieldsType[i]} == "string" ]]; then
                while [[ ! $value =~ ^[a-zA-Z_]*$ ]]; do
                    read -p "Please enter a valid string value for the field ${fields[i]}: " value
                done
            fi

            isFieldPK=$(awk -F'|' -v i="$i" 'NR == i+1 {print $3}' "./${tableName}-metadata")
            if [[ $isFieldPK == "PK" ]]; then
                if [[ -z "$value" ]]; then
                    echo -e "\033[31mThis field can't be null, you must enter a value!\033[0m"
                    continue
                fi

                allPrimaryFieldValues=$(cut -d'|' -f ${i+1} "./$tableName") 
                values_array=($(echo "$allPrimaryFieldValues" | cut -d'|' -f 1)) 
                duplicate_found=0

                # Check if value is duplicated 
                allPrimaryFieldValues=$(cut -d'|' -f ${i+1} "./$tableName") 

                # Count occurrences of $value in $allPrimaryFieldValues
                occurrences=$(echo "$allPrimaryFieldValues" | grep -c "$value")

                # If $occurrences is greater than ot equal 1, value is duplicated
                if [[ $occurrences -ge 1 ]]; then
                    echo -e "\033[31mThis value is duplicated, enter a unique value!\033[0m"
                    continue
                fi
            fi 
            
            line+="$value"
            if (( i < ${#fields[@]} - 1 )); then
                line+="|"
            fi

            (( i++ ))
        done

        echo -n "$line" >> "./$tableName"
        echo >> "./$tableName"
        echo -e "\033[1;32mData inserted successfully in ${tableName}\033[0m"

    else
        echo "Table does not exist or invalid table name"
    fi
}

function selectTable {
    PS3=$'\e[36m'"Choose number: "$'\e[0m'
    COLUMNS=12
    #read -p "enter table you want to connect to: " reply 
    check=$(cat ./$reply)

    if [ -f ./$reply ]; then
        echo -e "\e[32myou are now inside table $reply ...\e[0m"
        select choice in "Select all" "Select Column" "Select Row" "Enter another table" "Exit" ;
        do
            case $choice in
                "Select all")

                    if [[ -z "$check" ]];
                        then
                                echo "Empty Table"
                        else

                        echo "$check"

                        fi
                    ;;
                "Select Column")

                        if [[ -z "$check" ]];
                            then
                                echo "Empty Table"
                        else

                        selectColumn

                        fi
                        ;;

                "Select Row")
                        if [[ -z "$check" ]];
                            then
                                echo "Empty Table"
                        else
                        echo -e "available columns in $reply are: " 
                        selectRow
                    fi
                    ;;

                "Enter another table")

                read -p "Enter Another Table: " reply
                selectTable

                    ;;
                "Exit")
                    exit
                    ;;
                *)
                    echo -e  "\e[31mWrong Choice!\e[0m"  
                    ;;
            esac
        done
    else
        echo "Table $reply Does not Exist In $PWD"
    fi
}


function selectColumn {

    local column_names=($(cat "./$reply" | head -n 1 | tr '|' '\n'))
    options=("${column_names[@]}" "Exit")
    PS3="Select an option: "

    select column_choice in "${options[@]}"; 
        do
            case $REPLY in
                [1-${#options[@]}])

                if [[ $column_choice == "Exit" ]]; then
                    selectTable

                elif [[ "${column_names[@]}" =~ "$column_choice" ]]; 
                    then
                        column_data=$(awk -F "|" -v column="$REPLY" 'BEGIN{OFS=FS} NR>1{print $column}' "./$reply")
                    if [ -z "$column_data" ];
                        then
                            echo -e "\033[0;33mNo fields yet\033[0m"
                    else
                            echo -e "\e[95m$column_data\e[0m"
                    fi
                fi
                ;;

                *)
                    echo -e "\033[0;31mInvalid Input\033[0m"
                    ;;
            esac
        done
}

function selectRow {
    local column_names=($(cat "./$reply" | head -n 1 | tr '|' '\n'))
    local var=$(awk -F "|" 'NR>1{print $0}' ./$reply)
    local value_found=false

    PS3="Choose option: "
    options=("${column_names[@]}" "Exit")

    select column_choice in "${options[@]}";
      do
        case $REPLY in
           [1-${#options[@]}])
             if [[ $column_choice == "Exit" ]]; 
                then
                   exit

                elif [[ "${column_names[@]}" =~ "$column_choice" ]]; 
                   then
                     read -p "Enter value: " value
                     echo "Matching rows for $column_choice = $value:"

                for line in $var; do
                   if [[ "$line" == *"$value"* ]]; 
                     then
                        echo -e "\033[0;95m$line\033[0m"
                       value_found=true
                       selectTable
                   fi
               done

               if [[ "$value_found" == false ]]; 
                 then
                  echo "$value does not exist"
               fi
          fi
          ;;

          *)
            echo -e "\033[0;31mInvalid Input\033[0m"
          ;;
        esac
     done
}







