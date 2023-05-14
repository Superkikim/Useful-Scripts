#!/bin/sh

###############################################################################
#
# Author:  Akim Sissaoui
# Website: https://akim.sissaoui.com/informatique
#
# Description:
#    This script simplifies the creation of a GitHub repository.
#    If not already present, it will create a "github" directory in the home folder.
#    Subsequently, it will create a new directory based on the user-provided name,
#    initialize it as a git repository, and create a corresponding GitHub repository.
#    User can choose to create a private or public repository.
#
# Requirements:
#    1. SSH authentication to GitHub as described at:
#       https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/
#    2. A GitHub API token generated from https://github.com/settings/tokens
#       (with admin tree permissions) and stored in the ~/.github file.
#
# Usage:
#    ./git-create.sh <repo_name> <repo_type>
#
#    <repo_name>  required: Repository name adhering to GitHub's naming convention.
#    <repo_type>  required: Can be "private" or "public".
#
# Examples:
#    1. Create a private GitHub repository named "MyApp":
#       ./git-create.sh MyApp private
#    2. Create a public GitHub repository named "MyCreation":
#       ./git-create.sh MyCreation public
#
###############################################################################

print_help() {
    echo "Usage: ./git-create.sh <repo_name> <repo_type>"
    echo
    echo "<repo_name>  required: Repository name adhering to GitHub's naming convention."
    echo "<repo_type>  required: Can be 'private' or 'public'."
    echo
    echo "Examples:"
    echo "1. Create a private GitHub repository named 'MyApp':"
    echo "   ./git-create.sh MyApp private"
    echo "2. Create a public GitHub repository named 'MyCreation':"
    echo "   ./git-create.sh MyCreation public"
}

pre_reqs() {
    error_message=""
    # Check if required parameters are provided
    if [ -z "$reponame" ]
    then
      error_message+="Error: Repository name is required.\n"
    fi

    if [ -z "$repo_type" ]
    then
      error_message+="Error: Repository type is required.\n"
    fi

    # Check if the required files exist
    if [ ! -f ~/.github ]
    then
      error_message+="Error: ~/.github file does not exist.\n"
    fi

    if [ ! -f ~/.ssh/github.key ]
    then
      error_message+="Error: ~/.ssh/github.key file does not exist.\n"
    fi

    # Test the ssh authentication
    git_user=$(ssh -i ~/.ssh/github.key -T git@github.com -o "StrictHostKeyChecking no" 2>&1 > /dev/null)
    if [[ $git_user != *"successfully"* ]]
    then
      error_message+="Error: SSH authentication failed. Please verify SSH authentication.\n"
    fi

    git_user=$(echo $git_user | sed -e 's/.*Hi //' -e 's/You.*//')

    # Check if repository already exists
    if curl -s -H "Authorization: token $(cat ~/.github)" "https://api.github.com/repos/$git_user/$reponame" | grep -q "\"not found\""
    then
      error_message+="Error: Repository $reponame already exists.\n"
    fi

   
    # Check if local directory already exists
    if [ -d ~/github/$reponame ]
    then
      error_message+="Error: Directory ~/github/$reponame already exists.\n"
    fi

    # Return error message if any error occurred
    if [ ! -z "$error_message" ]
    then
      echo -e $error_message
      exit 1
    fi
}

create_repo() {
    private="true"
    if [ "$repo_type" = "public" ]; then
      private="false"
    fi

    # Ensure the presence of ~/github directory
    mkdir -p ~/github

    # Create local directory and initialize it as a git repository
    mkdir -p ~/github/$reponame && cd "$_"
    git init > /dev/null 2>&1


    # Create remote repository
    curl -H "Authorization: token $(cat ~/.github)" https://api.github.com/user/repos -d "{\"name\":\"$reponame\",\"private\":\"$private\"}"

    # Add the remote repository
    git remote add origin https://github.com/$git_user/$reponame.git

    echo "Successfully created the repository $reponame in ~/github/$reponame and as a remote repository at https://github.com/$git_user/$reponame"
    if [ "$private" = "true" ]
    then
       echo "This is a private repository."
    fi 
    echo
    echo "You can now add files, commit, and push to populate the remote repository."
    echo
    exit 0
}

# Parse parameters
reponame=$1
repo_type=$2

if [[ "$1" = "--help" ]]; then
    print_help
    exit 0
fi

pre_reqs
create_repo
