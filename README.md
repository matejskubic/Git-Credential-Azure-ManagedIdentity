# Git-Credential-Azure-ManagedIdentity

## Setup Git Credential Helper

To use the `Git-Credential-Azure-ManagedIdentity.sh` script as a Git credential helper, follow these steps:

1. **Download the script** to a location on your Azure resource (e.g., `/home/azureuser/Git-Credential-Azure-ManagedIdentity.sh`).

2. **Make the script executable**:
    ```bash
    chmod +x /home/azureuser/Git-Credential-Azure-ManagedIdentity.sh
    ```

3. **Update your `.gitconfig` file** to use the script as a credential helper:
    ```ini
    [credential]
        helper = /home/azureuser/Git-Credential-Azure-ManagedIdentity.sh
    ```

## Using the Username

You can specify the username in the Git URL to provide additional context for the managed identity. Here are some examples:

- **Using Default Managed Identity**:
    ```bash
    git clone https://dev.azure.com/your_organization/your_project/_git/your_repository
    ```

- **Using Client ID**:
    ```bash
    git clone https://<client_id>@dev.azure.com/your_organization/your_project/_git/your_repository
    ```

- **Using MSI Resource ID**:

    `msi_res_id` is in the format `/subscriptions/_subscription_id_/resourcegroups/_RG_name_/providers/microsoft.managedidentity/userassignedidentities/_name_`
    
    ```bash
    git clone https://<msi_res_id>@dev.azure.com/your_organization/your_project/_git/your_repository
    ```

In these examples, replace `<client_id>` or `<msi_res_id>` with the appropriate values for your managed identity.

Check for https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-use-vm-token#get-a-token-using-http for more details.  

## Example

Here is an example of how to clone a repository using a client ID:

```bash
git clone https://12345678-1234-1234-1234-123456789abc@dev.azure.com/your_organization/your_project/_git/your_repository
```

This setup allows the Git client to use the Azure Managed Identity to authenticate with Azure DevOps or other Git services that support OAuth tokens from Microsoft Azure/Entra ID.
