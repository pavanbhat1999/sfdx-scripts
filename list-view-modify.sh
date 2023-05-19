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
        echo "\n Enter the list view name to be modified, or press Control+C to exit:"
        read search_list

        matches=$(grep -irl "$search_list" force-app/main/default/objects/Case/listViews)

        if [[ -z $matches ]]; then
            echo "No matches found"
            continue
        fi

        echo "Multiple matches found. Please select the desired list view:"
        i=1
        for match in $matches; do
            echo "$i. $match"
            ((i++))
        done

        read -p "Enter the number corresponding to the list view: " selected_index
        if [[ $selected_index -gt 0 && $selected_index -le $i ]]; then
            file_to_change=$(sed -n "${selected_index}p" <<< "$matches")
            echo "Using the selected match: $file_to_change"

            echo "If you are ready to proceed, press any key to continue, or press Control+C to exit"
            read

      # Define the columns to be added
      columns_to_add="<columns>CASES.CASE_NUMBER</columns>\n<columns>NAME</columns>\n<columns>CASES.STATUS</columns>"

      # Add columns to the list view
      sed -i "/<columns>/d; /<\/fullName>/a $columns_to_add" "$file_to_change"
      sfdx project deploy start -o "$org_alias" -d "$file_to_change"

      echo "Metadata changed"
  else
      echo "Invalid selection"
        fi
    done
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
