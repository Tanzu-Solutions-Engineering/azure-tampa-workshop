# Deploying Pivotal Cloud Foundry

## Service Principal

In order to deploy Pivotal Cloud Foundry using the Azure Marketplace, we will need to create a Service Principal so the platform can deploy itself.

To create a Service Principal using the Azure CLI, follow these steps.

> Note: Replace `\` with `^` if you are on Windows.

1. Run `az login` to authenticate with Azure.
1. You first need to create an AzureAD application.
    ```sh
    az ad app create --display-name "Service Principal for BOSH" \
    --password "PASSWORD" --homepage "http://BOSHAzureCPI" \
    --identifier-uris "http://BOSHAzureCPI" > azureApp.json
    ```

1. Copy your `appId` from `axureApp.json`.
1. We need to create an RBAC Service Principal.
    ```sh
    az ad sp create-for-rbac \
    --id <your-appId> \
    --role contributor \
    --scope /subscriptions/<your-subscriptionId> > azureSP.json
    ```

1. Currently, the Azure Marketplace Offering requires a special file layout. Extract the values location in `azureSP.json` and create a new file called `pcfSP.json` with this layout:
    ```json
    {
        "appId": "<your-appId>",
        "displayName": "<your-displayName>",
        "name": "<your-homePage>",
        "password": "<your-clientSecret>",
        "tenant": "<your-tenantId>"
    }
    ```

## Pivotal Network

The Azure Marketplace deployment for Pivotal Cloud Foundry requires an API token from the Pivotal Network.

1. Open the [Pivotal Network](https://network.pivotal.io) web site.
1. Log in.
1. In the top right corner, click on your name.
1. Select `Edit Profile`.
1. At the bottom of that page, there is a field called `API Token`. Copy that value or leave the web page open.

## Deploy Pivotal Cloud Foundry from the Azure Marketplace

In order for us to utilise our own instances of Pivotal Cloud Foundry, we will need to deploy it. The easiest way to deploy PCF is via the Azure Marketplace.

1. Open the [Azure Portal](https://portal.azure.com).
1. Go the Marketplace. If it is not in your left blade, you can find it by selecting the `More services` tab and searching for `Marketplace`.
1. In the Marketplace, search for `Cloud Foundry`.
1. Select `Pivotal Cloud Foundry on Mirosoft Azure`.
1. Click `Create`
1. For the Storage Account Name, we recommend using `p` to denote it's a Pivotal-specific storage account.
1. Paste your SSH Public Key.
1. For the Service Principal field, cick the folder icon and upload the `pcfSP.json` file you have just created.
1. Paste your Pivotal Network token from above.
1. Make sure you are using the same subscription you created the Service Principal in.
1. For the `Location` field, we recommend using the nearest data centre location to you.
1. Select `OK`
1. Proceed through the `Buy` blade by entering your information.

# Post-deployment

Deployments take roughly ~2 hours to complete, even though it shows as completed in the Azure Portal sooner. Here is how you can extract the necessary information from Azure and Pivotal Cloud Foundry to get started.

## Getting OpsManager Credentials.

1. Select the Resource Group PCF is was deployed to.
1. On the left side of the Resource Group blade, select the `Deployments` view.
1. Select `pivotal.pivotal-cloud-foundryazure-pcf-<date>`.
1. Under the `Outputs` section, you will see the username, password, and URL to log into OpsManager.
1. You can either copy this information to your laptop or come back to it as needed.

## Logging into AppsManager

We will need to log into AppsManager into order to download the Cloud Foundry cli and configure authentication so we can push our apps.

1. Log into OpsManager using the credentials from the previous section.
1. Select the `Pivotal Elastic Runtime` tile.
1. From the blades on the left, select `Domains` (2nd from the top). These domains are your top level domains for the Azure Marketplace PCF deployment. Copy these values to your laptop for later reference. For the Azure Marketplace deployment, PCF is configured to use a custom DNS provider, which allows us to easily resolve subdomains via IP addresses. **This is not recommended for production deployments.**
1. Select the `Credentials` tab.
1. Scroll to the `UAA` section. Open the `Admin Credentials` link in a new tab. Those credentials allow us to log into AppsManager.
1. Browse to `login.<system-domain>`, and enter the credentials from the previous step.
1. The page will load into the Apps you are authourised to use, select `PCF Apps Manager`.
1. Once logged in, on the top left, click the dropdown by "system" and select "Create a New Org". It does not matter what you name it.
1. After org has been created, make sure to create a space.