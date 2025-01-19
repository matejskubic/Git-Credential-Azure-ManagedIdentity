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
    local query_param=$2
    local jq_path=$(download_jq)
    # https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-use-vm-token#get-a-token-using-http
    token_response=$(curl -s --fail-with-body "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=${resource}${query_param}" -H "Metadata: true" -H "Accept: application/json")
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        local error_description=$(echo $token_response | "$jq_path" .error_description)
        echo $error_description
        echo "Error: Failed to get token response: $error_description" >&2
        echo $token_response >&2
        exit 2
    fi

    local access_token=$(echo $token_response | "$jq_path" -r .access_token)
    if [ -z "$access_token" ]; then
        echo "Error: Access token is empty" >&2
        echo "$token_response" >&2
        exit 3
    fi

    echo $access_token
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
    query_param=""

    while IFS= read -r line; do
        if [[ $line == username=* ]]; then
            value="${line#username=}"
            if [[ $value == /subscriptions/* ]]; then
                query_param="&msi_res_id=$value"
            elif [[ ${#value} -eq 36 ]]; then
                query_param="&client_id=$value"
            else
                query_param="&$value"
            fi
        fi
    done

    access_token=$(get_access_token $resource "$query_param")
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        get_git_credentials "$access_token"
    else
        exit $exit_code
    fi
else
    echo "Missing or unsupported command: '$1'"
    exit 1
fi
