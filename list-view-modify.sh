#!/bin/bash
#---------------------------------------------------------------------------------------------------
# This script is written to easily add columns into the list view
#---------------------------------------------------------------------------------------------------
create_project() {
    # TODO: make user enter project name and org alias
    # echo "Please give a project name and press enter to continue and create a project ->"
    # read project_name
    # echo "Started Creating the project - $project_name"
    #INFO: Currently name is chosen automatically
    # check if a folder named temp exist or not
    project_name='temp'
    sfdx project generate -n $project_name
    echo "😎Project created successfully"
}
login_to_org(){
    # echo "Enter Org/Sandbox name to be used and press enter"
    # read orgAlias
    orgAlias='temporg'
    echo "Entered Org - $orgAlias"
    echo "Browser has been opened please login"
    sfdx org login web -d -a $orgAlias
    echo "LOGIN Successful 👍"
}
retrieve_case_metadata(){
    echo "Retrieve Case Object Metadata ..."
    cd $project_name
    sfdx project retrieve start -o $orgAlias -m CustomObject:Case
    echo "Case Object data received"
}
modify_list_view(){

while true; do

    echo "\n Search for the List View to be modified or press Control+c to exit"
    read searchList

    if grep -irl $searchList force-app/main/default/objects/Case/listViews;then
        echo 'Found'
        filetoChange=$(grep -irl $searchList force-app/main/default/objects/Case/listViews | head -1)
        echo "First match has been taken $filetoChange , Please specify properly next time"
        echo "If you are good to GO: Press Any Key to continue else press s to skip"
        read -n 1 choice
        if [[ "$choice" == "s" ]]; then
            continue
        fi
        # hard coded columns to be added
        # sed  -i -e '/<columns>/,/<\/columns>/d' -e '/<\/fullName>/r ../columns.xml' $filetoChange
        sed -i '/<columns>/d; /<\/fullName>/a <columns>CASES.CASE_NUMBER<\/columns>\n<columns>NAME<\/columns>\n<columns>CASES.STATUS<\/columns>' $filetoChange
        sfdx project deploy start -o $orgAlias -d $filetoChange

        echo "Changed Metadata"
    else
        echo 'Not Found'
    fi
done
}
cleanup(){
  echo "Deleting the project - $project_name"
  cd ..
  rm -rf "$project_name"
  echo "Project deleted"
}

#---------------------------------------------------------------------------------------------------
# Main Script
#---------------------------------------------------------------------------------------------------
echo "Welcome to new list view modification script"
echo "---------------------------------------------------------------------------------------------"
echo "WARNING!!! This script will modify the metadata of your list views therefore be aware of the changes"
echo "---------------------------------------------------------------------------------------------"

create_project
login_to_org
retrieve_case_metadata
modify_list_view
