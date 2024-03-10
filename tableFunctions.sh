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

            # Add field names to the first line of the table file
            fieldNames=$(echo -e "$tableSchema" | awk -F'|' '{printf "%s|", $1}' | sed 's/|$//' )
            echo "$fieldNames" > $name

            echo -e "\033[32mYour table has been created successfully!\033[0m"
        else
            echo "Table creation aborted."
        fi
    else 
        echo "Please enter a valid name or the table already exists"
    fi
}

function insertIntoTable {
    if [[ $(ls | wc -l) == 0 ]]; then
        echo -e "\033[0;33mYou don't have any tables yet!\033[0m"
        return
    fi

    read -p "Enter the table you want to enter your data into: " tableName
    if [[ $tableName =~ ^[A-Za-z_]+$ && -f "./$tableName" ]]; then
        # Read metadata file line by line
        fields=()
        fieldsType=()
        if [[ -f "./${tableName}-metadata" ]]; then
            while IFS='|' read -r fieldName fieldType _; do
                fields+=("$fieldName")
                fieldsType+=("$fieldType")
            done < "./${tableName}-metadata" 
        else
            echo "Error: Metadata file '${tableName}-metadata' does not exist!" >> ../../logs.txt
        fi

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

                # Check if value is duplicated 
                allPrimaryFieldValues=()
                if [[ -f "./${tableName}-metadata" ]]; then
                    while IFS='|' read -r PKFieldValue _; do
                        allPrimaryFieldValues+=$PKFieldValue
                    done < "./$tableName" 
                fi

                if [[ $allPrimaryFieldValues =~ $value ]]; then
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

function listTables {
    local tables=$(ls | grep -v "\-metadata$")
    local table_count=$(echo "$tables" | wc -l)
    if [ $table_count -ge 1 ]; then
        echo -e "You have $table_count table(s) in $(basename "$PWD") database:\n$tables"
    else
        echo "You do not have any tables yet."
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
    local column_names=($(head -n 1 "./$reply" | tr '|' '\n'))
    local var=$(awk -F "|" 'NR>1{print $0}' ./$reply)
    local value_found=false

    while true; do
        PS3="Choose option: "
        options=("${column_names[@]}" "Exit")

        select column_choice in "${options[@]}"; do
            case $REPLY in
                [1-${#options[@]}])
                    if [[ $column_choice == "Exit" ]]; then
                        exit
                    else
                        read -p "Enter value: " value
                        echo "Matching rows for $column_choice = $value:"

                        value_found=false
                        for line in $var; do
                            columns=($(echo "$line" | tr '|' ' '))
                            column_index=-1

                            # Find the index of the selected column in the column_names array
                            for (( i=0; i<${#column_names[@]}; i++ )); do
                                if [[ "${column_names[$i]}" == "$column_choice" ]]; then
                                    column_index=$i
                                    break
                                fi
                            done

                            # Check if the value in the selected column matches exactly the value provided by the user
                            if [[ "${columns[$column_index]}" == "$value" ]]; then
                                echo -e "\033[0;95m$line\033[0m"
                                value_found=true
                            fi
                        done

                        if [[ "$value_found" == false ]]; then
                            echo "$value does not exist"
                        fi
                    fi
                    ;;
                *)
                    echo -e "\033[0;31mInvalid Input\033[0m"
                    ;;
            esac
            break
        done
    done
}


function deleteTable {
        read -p "enter table you want to connect to: " reply
  if [ -f ./$reply ];
 then
 echo -e "\e[32myou are now inside table $reply ...\e[0m"
 select choice in "Delete All" "Delete Column" "Delete Row" "Drop Table" "Exit" ;
 do
    case $choice in

         "Delete All")
                 cat /dev/null > ./$reply
                 echo "Content Deleted Successfully.."
                 ;;

        "Delete Column")
                deleteColumn
            ;;
        "Delete Row")
                deleteRow

        #selectColumn

       ;;

        "Drop Table")

         read -p "Are You Sure You Want To Drop This Table(y/n)? " answer

         # selectRow

         if [ $answer == 'y' ];
         then
                 rm ./$reply && rm ./$reply-metadata
                  echo -e  "\e[32mTable Deleted Successfully Now You Are Back To Main Menu...\e[0m"
                  parentMenu

         else
                  selectTable
         fi
           ;;
        "Exit")
            exit
            ;;
        *)
         echo -e  "\e[31mWrong choice!\e[0m"  
            ;;
    esac
done

else
 echo -e "\033[0;31mtable $reply does not exist in $PWD\033[0m"
fi
}

function deleteRow {
    local column_names=($(head -n 1 "./$reply" | tr '|' '\n'))
    local var=$(awk -F "|" 'NR>1{print $0}' ./$reply)
    local value_found=false

    PS3="Choose option: "
    options=("${column_names[@]}" "Exit")

    select column_choice in "${options[@]}"; do
        case $REPLY in
            [1-${#options[@]}])
                if [[ $column_choice == "Exit" ]]; then
                    exit
                elif [[ "${column_names[@]}" =~ "$column_choice" ]]; then
                    read -p "Enter value: " value
                    echo "Matching rows for $column_choice = $value:"
                    value_found=false

                    if [[ -z "$var" ]]; then
                        echo "Empty table"
                    else
                        while IFS= read -r line; do
                            if [[ "$line" == *"$value"* ]]; then
                                echo -e "\033[0;95m$line\033[0m"
                                value_found=true
                            fi
                        done <<< "$var"

                        if [[ "$value_found" == true ]]; then
                            awk -F "|" -v value="$value" '$0 !~ value' "./$reply" > "./$reply.tmp" && mv "./$reply.tmp" "./$reply"
                            echo "Row(s) containing $value deleted successfully."
                        else
                            echo "$value does not exist in any row."
                        fi
                    fi
                fi
                ;;
            *)
                echo -e "\033[0;31mInvalid Input\033[0m"
                ;;
        esac
    done
}

deleteColumn() {
    # Read column names from metadata file
    local column_names=($(awk -F '|' '{print $1}' "${reply}-metadata"))
    PS3="Select a column to delete or exit: "
    
    options=("${column_names[@]}" "Exit")

    select column_choice in "${options[@]}"; do
        case $REPLY in
            [1-$(( ${#options[@]} ))])
                if [[ $column_choice == "Exit" ]]; then
                    exit
                else
                    # Check if the selected column is the primary key
                    local primary_key_column=$(awk -F '|' '{ if ($3 == "PK") print $1 }' "${reply}-metadata")
                    if [[ $column_choice == "$primary_key_column" ]]; then
                        echo -e "\033[31mYou cannot delete the primary key column.\033[0m"
                    else
                        # Delete the selected column
                        awk -F "|" -v column="$REPLY" 'BEGIN{OFS=FS} { $column=""; sub(/\|/, ""); print }' "./$reply" > "./$reply.tmp" && mv "./$reply.tmp" "./$reply"
                        echo -e "\033[32mColumn '$column_choice' deleted successfully.\033[0m"

                        # Remove the deleted column from column_names array
                        unset 'column_names[$REPLY-1]'
                        column_names=("${column_names[@]}")

                        # Update the metadata file
                        awk -v deleted_column="$column_choice" -F '|' 'BEGIN{OFS=FS} $1 != deleted_column { print }' "${reply}-metadata" > "${reply}-metadata.tmp" && mv "${reply}-metadata.tmp" "${reply}-metadata"
                    fi
                fi
                ;;
            *)
                echo -e "\033[0;31mInvalid Input\033[0m"
                ;;
        esac
    done
}

function updateTable {
    read -p "Enter table name: " reply
    
    # Check if the table exists
    if [[ ! -f "./$reply" ]]; then
        echo "Table '$reply' does not exist"
        return
    fi

    # Check if the table is empty
    if [[ ! -s "./$reply" ]]; then
        echo "Table '$reply' is empty"
        return
    fi

    metadata="./$reply-metadata"
    
    # Extract column names and data types from metadata
    local column_names=()
    local data_types=()
    local primary_key_column=""
    while IFS='|' read -r column_name data_type constraints; do
        column_names+=("$column_name")
        data_types+=("$data_type")
        if [[ "$constraints" == "PK" ]]; then
            primary_key_column="$column_name"
        fi
    done < "$metadata"

    PS3="Select a column to update or Exit: "
    options=("${column_names[@]}" "Exit")

    select column_choice in "${options[@]}"; do
        case $REPLY in
            [1-$(( ${#column_names[@]} + 1 ))])
                if [[ $column_choice == "Exit" ]]; then
                    exit
                elif [[ $column_choice == "$primary_key_column" ]]; then
                   echo -e "\e[31mYou cannot update the primary key column.\e[0m"
                else
                    column_index=$((REPLY - 1))
                    read -p "Enter the old value for $column_choice: " old_value
                    
                    if ! awk -F "|" -v column="$REPLY" -v old="$old_value" '$column == old { found=1; exit } END { exit !found }' "./$reply"; then
                        echo -e "\e[31mOld value '$old_value' does not exist in column '$column_choice'\e[0m"
                        continue
                    fi
                    
                    read -p "Enter the new value for $column_choice: " new_value

                    # Validate data type for the new value
                    if [[ ${data_types[$column_index]} == "int" && ! $new_value =~ ^[0-9]+$ ]]; then
                        echo "Invalid data type for $column_choice. Must be an integer."
                    elif [[ ${data_types[$column_index]} == "string" && ! $new_value =~ ^[a-zA-Z]+$ ]]; then
                    echo -e "\e[31mInvalid data type for $column_choice. Must be a string.\e[0m"
                    else
                        # move old value into tmp
                        awk -F "|" -v column="$REPLY" -v old="$old_value" -v new="$new_value" 'BEGIN{OFS=FS} { if ($column == old) $column = new; print }' "./$reply" > "./$reply.tmp" && mv "./$reply.tmp" "./$reply"

                        echo -e "\e[32mColumn '$column_choice' updated successfully.\e[0m"
                    fi
                fi
                ;;
            *)
                echo "Invalid Input"
                ;;
        esac
    done
}

