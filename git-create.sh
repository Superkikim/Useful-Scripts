#!/bin/sh

###############################################################################
#
# Author:  Akim Sissaoui
# Website: https://akim.sissaoui.com/informatique
#
# Description:
#    This script ease the github repository creation
#    It will create a github folder in your home folder if it does not exist
#    Then it will create a new folder based on $1 variable, make it a git 
#    repo and create a github repository on your github account. $2 allow you
#    to specify public or private.
#
# Requirement:
#    This scripts use SSH to retrieve your github username, therefore,
#    authentication via SSH to github according to following URL is required:
#
#  https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/
#
#    An API token has been generated from https://github.com/settings/tokens and
#    added into textfile. Token needs admin tree permissions
#
#    ~/.github
#
# Usage:
#    ./git-create.sh [repo name] [type]
#
#    [repo name]  required: Repositery name. Must follow Github repository
#                 name requirements
#    [type]       optional: private or public. Default is private
#
# Example:
#
#    Below example will create MyApp Github repository as private
#
#    ./git-create.sh MyApp private
#
#
#    Below example will create MyCreation Github repository as public
#
#    ./git-create.sh MyCreation public
#
###############################################################################

# Parse parameters
reponame=$1
private=$2

# Check reponame
if [ -z $reponame ]
then
	echo "Repository name is required. Exiting"
exit 1
fi

# Define if private or public
if [ -z $private ]
then
   private="true"
else
   case $private in
      private)
	private="true"
        ;;
      public)
        private="false"
        ;;
      *)
        echo "[type] parameter not recognized. Exiting."
        exit 1
   esac
fi

# Create github folder in the current user home folder if it does not exist
if [ ! -d ~/github ]; then
  mkdir ~/github
fi

# Test the ssh authentication and save the result in the $git_user variable
git_user=$(ssh -T git@github.com -o "StrictHostKeyChecking no" 2>&1 > /dev/null)

# Verify if ssh connection was successfull
success=`grep -c successfully <<< "$git_user"`

# If ssh connection was successful, parse username otherwise exit with exit code 1
if [ $success -eq 1 ]
then
	git_user=`echo $git_user | sed -e 's/.*Hi //' -e 's/You.*//'`
	git_user=${git_user%??}
else
	echo "ssh authentication failed. Please verify ssh authentication."
	exit 1
fi

# Check if repository exists
for repo in $(curl -s -H "Authorization: token `cat ~/.github`" https://api.github.com/user/repos | grep -o 'git@[^"]*' | grep .git)
do
        if [ $reponame = $(echo $repo | sed -e 's/.*\///' -e 's/.git.*//') ]
        then
                echo "Repository with name $reponame already exists. Exiting."
                exit 1
        fi
done

# Check if local folder already exit
if [ -d ~/github/$reponame ]
then
   echo "Folder ~/github/$reponame already exist. Exiting."
   exit 1
fi

# Create local folder repository
mkdir ~/github/$reponame
cd ~/github/$reponame
git init

# Create remote repository
curl -H "Authorization: token `cat ~/.github`" https://api.github.com/user/repos -d "{\"name\":\"$reponame\",\"private\":$private}"
git remote add origin https://github.com/$git_user/$reponame.git

echo "Repository $reponame has been created in ~/github/$reponame and as remote repository at https://github.com/$git_user/$reponame"
if [ $private = "true" ]
then
   echo "This is a private repository."
fi 
echo
echo "You can now add files, commit and push to populate the remote repository"
echo
exit 0
