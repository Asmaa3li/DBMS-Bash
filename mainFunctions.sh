function createDatabase {
    read -p "Enter the name of the database you want to create: " name 
    if [[ $name =~ ^[A-Za-z_]+$ && ! $(type -t $name) ]] 
    then 
        mkdir ./Database/$name 2>> logs.txt 
        if [ $? == 0 ] 
        then 
            echo "The database ${name} has been created successfully" 
        else 
            echo "Error: The database ${name} already exists" 
        fi 
    else 
        echo "Error: Enter a valid name" 
    fi 
}