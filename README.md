# Database Management System Using Bash Shell Scripting
The Project aims to develop DBMS CLI Menu based app that will enables users to handle CRUD operations.

# Installation
* Clone the repository:git `clone https://github.com/Asmaa3li/DBMS-Bash.git`
* Run the dbms.sh script `./dbms.sh`

# Main Menu:
* Create Database
* List Databases
* Connect To Databases
* Drop Database
* Exit
  
<img src="images/1.png" alt="Image 1" width="700" height="200">


# Connect To Database Menu:
And upon user Connect to Specific Database, there will be new Screen with this Menu:

<img src="images/2.png" alt="Image 1" width="700">


### 1- Create a Table
#### Notes:
1. Enter the number of fields.
2. Enter a valid field name.
3. Enter a valid field type.
4. Field names must not be duplicated.
5. If you choose a primary key, you will not be prompted to choose another one. If you do not choose one at all, then the last field will be designated as the default primary key.
6. You will be able to review the table schema before confirming the creation of the table.

  <img src="images/3.png" alt="Image 1" width="700" height="400">


### 2- List all tables

  <img src="images/4.png" alt="Image 1" width="700" height="225">

### 3- Insert into a table
#### Notes:
1. Enter valid values for each field.
2. The primary key field must have unique values.
3. The primary key field cannot be NULL.
4. Each field, other than the primary key, can be NULL.
  
  <img src="images/5.png" alt="Image 1" width="700" height="400">

### 4. Select from table
  * Select all<br>
  * Select Column<br>
  * Select Row<br>
  * Enter another table<br>
  * Exit

  <img src="images/6.png" alt="Image 1" width="700">

### 5. Delete table
  * delete all<br>
  * delete Column<br>
  * delete Row<br>
  * drop table
      
  <img src="images/7.png" alt="Image 1" width="700">

### 6- Update table
### 7- Back to main menu
### 8- Exit
