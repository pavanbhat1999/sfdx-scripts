#!/bin/bash
#---------------------------------------------------------------------------------------------------
# This script is written to easily add columns into the list view
#---------------------------------------------------------------------------------------------------
echo "Welcome to new list view modification script"

echo "---------------------------------------------------------------------------------------------"

echo "WARNING!!! This script will modify the metadata of your list views therefore be aware of the changes"


# TODO: make user enter project name and org alias
# echo "Please give a project name and press enter to continue and create a project ->"
# read project_name
#

# echo "Started Creating the project - $project_name"

#INFO: Currently name is chosen automatically
project_name='temp'
sfdx project generate -n $project_name

echo "😎Project created successfully"

# echo "Enter Org/Sandbox name to be used and press enter"
# read orgAlias

orgAlias='temporg'
echo "Entered Org - $orgAlias"

echo "Browser has been opened please login"
sfdx org login web -d -a $orgAlias

echo "LOGIN Successful 👍"

echo "Retrieve Case Object Metadata ..."

cd $project_name
sfdx project retrieve start -o $orgAlias -m CustomObject:Case
echo "Case Object data received"


while true; do

    echo "Search for the List View to be modified or press Control+c to exit"
    read searchList

    if grep -irl $searchList force-app/main/default/objects/Case/listViews;then
        echo 'Found'
        filetoChange=$(grep -irl $searchList force-app/main/default/objects/Case/listViews | fzf --height=~15)
        echo 'First match has been taken $filetoChange , Please specify properly next time'
        # hard coded columns to be added
        # sed  -i -e '/<columns>/,/<\/columns>/d' -e '/<\/fullName>/r ../columns.xml' $filetoChange
        sed -i '/<columns>/d; /<\/fullName>/a <columns>CASES.CASE_NUMBER<\/columns>\n<columns>NAME<\/columns>\n<columns>CASES.STATUS<\/columns>' $filetoChange
        sfdx project deploy start -o $orgAlias -d $filetoChange

        echo "Changed Metadata"
    else
        echo 'Not Found'
    fi
done


# cd ..
# rm -rf $project_name/
