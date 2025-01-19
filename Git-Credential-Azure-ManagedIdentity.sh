#!/bin/bash

# Function to download jq to a temporary location
download_jq() {
    local jq_temp="$HOME/jq"
    if [ ! -f "$jq_temp" ]; then
        curl -s -L -o "$jq_temp" "https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64"
        chmod +x "$jq_temp"
    fi
    echo "$jq_temp"
}

# Function to get the access token from Azure Managed Identity
get_access_token() {
    local resource=$1
    local jq_path=$(download_jq)
    local token_response=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=${resource}" -H "Metadata: true")
    echo $(echo $token_response | "$jq_path" -r .access_token)
}

# Function to get the credentials for Git
get_git_credentials() {
    local access_token=$1
    echo "username=ManagedIdentity"
    echo "password=$access_token"
}

# Main script execution
if [ "$1" == "get" ]; then
    resource="499b84ac-1321-427f-aa17-267ca6975798"
    access_token=$(get_access_token $resource)
    get_git_credentials $access_token
else
    echo "Unsupported command: $1"
    exit 1
fi


