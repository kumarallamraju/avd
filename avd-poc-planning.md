
## Azure Virtual Desktop (AVD) POC Planning Document

In an effort to fast track  AVD POC please have the following prerequisites ready.

1. It's recommended to create a new Azure subscription to provision Azure Virtual Desktop (AVD) resources.
2. Have owner or contributor privileges on your Azure subscription.
3. Register the DesktopVirtualization Resource Provider (if not already registered). Go to your Subscription >> Settings >> Resource providers and search for "desktop"

<img width="1095" alt="Screen Shot 2021-08-04 at 8 44 27 AM" src="https://user-images.githubusercontent.com/15897803/128211842-228f1af7-9992-4671-a7f9-c2bf8191b703.png">

4. Create a new Resource Group, Virtual Network (VNet) and have a line of sight into your on-prem Domain Controllers. This can be configured under your VNet's DNS Servers section. If you already have a line of sight, just peer the new VNet with an existing VNet.

![onprem-dc](https://user-images.githubusercontent.com/15897803/134075992-6d951d2e-9fdf-4a3f-b4ca-89148a784347.png)


5. Ensure on-prem identities are sync'ing to Azure Active Directory via AD Connect

6. By default AVD session hosts (VMs) are domain joined. Have your domain join credentials ready in this format. domainjoin@contoso.com / {password}

7. If you're planning to keep these VMs in a separate OU, please create an OU beforehand and get the full OU path
8. Provision a separate VM (e.g. adminVM) to perform admin activities or back door entry to your session hosts. Please make sure this VM is also domain joined.

9. In order to successfully provision Azure Virtual Desktop, please ensure the following URLs are unblocked in your Network Security Groups or 3rd party firewalls(e.g. Palo Alto)

- Azure Commercial and GovCloud: https://docs.microsoft.com/en-us/azure/virtual-desktop/safe-url-list#virtual-machines

### Create a Log Analytics Workspace

1. Head over to Azure Portal https://portal.azure.com
2. Create a new Log Analytics Workspace (LAW) before creating Personal/Multi-session hostpools. This is needed to enable monitoring.

![Screen Shot 2022-09-16 at 8 07 58 AM](https://user-images.githubusercontent.com/15897803/190671349-63227538-6bb4-4e46-9ed6-f1410ab22412.png)

### Personal Desktops

1. Head over to Azure Portal https://portal.azure.com
2. Search for "Azure Virtual Desktop"
3. Manage >> Host pools >> + Create
4. Select your target subscription, resource group, region
5. Preferred app group type: Desktop
6. Host pool type: Personal
7. Next
8. We'll add VMs later
9. Next: Workspace
10. Create a new workspace (e.g. personalWS)
![Screen Shot 2022-09-16 at 8 11 49 AM](https://user-images.githubusercontent.com/15897803/190672473-22383ce9-0940-4ae7-a93d-c5469a7677b4.png)


11. Enable Monitoring and select the right LAW that was created earlier.
![Screen Shot 2022-09-16 at 8 14 10 AM](https://user-images.githubusercontent.com/15897803/190672584-76b6a241-53f0-4f20-bf77-d26b3f4e3e14.png)

12. Add tags (you can always add them later)
13. Review the summary screen. Go back if you need to make changes
14. Create a Host pool


### Multi-session Desktops

1. For multi-session desktops, we need an Azure Storage Account and Standard/Premium File Share to domain join the Azure Files or Azure NetApp Files. This document outlines the steps to domain join the Azure Storage Account https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable 

2. Download the AzFilesHybrid module https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable#download-azfileshybrid-module on to your admin VM created in Step #8; Launch PowerShell ISE as Administrator

3. Install the Az module on your admin VM. https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-6.3.0

4. Download this file https://github.com/kumarallamraju/avd/blob/main/azurefiles-smb.ps1 and input your subscription, resource group and storage account details.

5. Execute the script line by line which will help you to easily troubleshoot.

6. If all goes well, you'll see a mounted file share in your admin VM

![Screen Shot 2021-08-04 at 9 13 14 AM](https://user-images.githubusercontent.com/15897803/128216477-5d3a33f5-7948-4204-8496-49fe88829a7e.png)


7. Create a folder inside the mounted file share.
8. Right click on the folder >> Security >> Advanced. Click on Add. Select your users/groups that will be using multi-session desktops
9. Type: Allow, Applies to: This folder only, Basic Permissions: Modify (don't give full control). Save the changes

<img width="373" alt="Screen Shot 2021-08-04 at 9 17 39 AM" src="https://user-images.githubusercontent.com/15897803/128217171-e6ab0f6b-91bb-4c43-97bc-efac8f5aa359.png">

10. Go back to Azure Portal >> Select your storage account >> file share >> click on Access Control (IAM)

11. Add >> Add role assingment >> Assign Storage File Data SMB Share Contributor privileges to the same users/groups you did in step #17. Alternatively you can give Storage File Data SMB Share Elevated Contributor privileges to an admin user.

<img width="425" alt="Screen Shot 2021-08-04 at 9 23 10 AM" src="https://user-images.githubusercontent.com/15897803/128217887-03c229a7-f081-4d11-a39d-e89ade66ac13.png">


### Steps to create a Golden Image for AVD

One of our MVPs put together a nice blog. I'm referencing his blog here https://www.robinhobo.com/windows-virtual-desktop-wvd-image-management-how-to-manage-and-deploy-custom-images-including-versioning-with-the-azure-shared-image-gallery-sig/


## Accessing AVD Workspaces
- Web: https://rdweb.wvd.microsoft.com/arm/webclient/index.html
- Windows Desktop Client: Download from https://docs.microsoft.com/en-us/windows-server/remote/remote-desktop-services/clients/windowsdesktop and install on your Client machines
- Input the feed discovery URL: https://rdweb.wvd.microsoft.com/api/arm/feeddiscovery (Azure Commercial Cloud)
- Input the feed discovery URL: https://rdweb.wvd.azure.us/api/arm/feeddiscovery (Azure Gov Cloud)
- Enter your credentials and you should see your subscribed AVD workspaces.

![Screen Shot 2021-08-04 at 11 01 24 AM](https://user-images.githubusercontent.com/15897803/128231529-945b1ebd-18ca-4c89-b6a0-800ad952d187.png)
