
## Azure Virtual Desktop (AVD) POC Planning Document

In an effort to fast track your AVD POC pls have the following prerequisites ready.

1. It's recommended to create a new Azure subscription to provision Azure Virtual Desktop (AVD) resources.
2. Have owner or contributor privileges on the subscription.
3. Register the DesktopVirtualization Resource Provider. Go to your Subscription >> Settings >> Resource providers and search for "desktop"

<img width="1095" alt="Screen Shot 2021-08-04 at 8 44 27 AM" src="https://user-images.githubusercontent.com/15897803/128211842-228f1af7-9992-4671-a7f9-c2bf8191b703.png">

4. Create a new Resource Group, Virtual Network (VNet) and have a line of sight into your on-prem Domain Controllers. This can be configured under your VNet's DNS Servers section. If you already have a line of sight, just peer the new VNet with an existing VNet.

5. Ensure on-prem identities are sync'ing to Azure Active Directory via AD Connect

6. By default AVD session hosts (VMs) are domain joined. Have your domain join credentials ready in this format. domainjoin@contoso.com / {password}

8. If you're planning to keep these VMs in a separate OU, pls create the OU beforehand and get the full OU path
9. Have a separate VM (e.g. adminVM) to perform admin activities or back door entry to your session hosts. Pls make sure this VM is also domain joined.

### Personal Desktops

### Multi-session Desktops

11. For multi-session desktops, we need to domain join the Azure Files or Azure NetApp Files. Pls create an ADLS Gen2 storage account and refer to this document https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable 

10. Download the AzFilesHybrid module https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable#download-azfileshybrid-module on to your admin VM created in Step #9


11. Install the Az module on your admin VM. https://docs.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-6.3.0

12. Download this file https://github.com/kumarallamraju/avd/blob/main/azurefiles-smb.ps1 and input your subscription, resource group and storage account details.

14. Execute the script line by line which will help you to easily troubleshoot.

15. If all goes well, you'll see a mounted file share in your admin VM

![Screen Shot 2021-08-04 at 9 13 14 AM](https://user-images.githubusercontent.com/15897803/128216477-5d3a33f5-7948-4204-8496-49fe88829a7e.png)


16. Create a folder inside the mounted file share.
17. Right click on the folder >> Security >> Advanced. Click on Add. Select your users/groups that will be using multi-session desktops

<img width="373" alt="Screen Shot 2021-08-04 at 9 17 39 AM" src="https://user-images.githubusercontent.com/15897803/128217171-e6ab0f6b-91bb-4c43-97bc-efac8f5aa359.png">


## Steps to create a Golden Image for AVD

One of our MVPs put together a nice blog. I'm referencing his blog here https://www.robinhobo.com/windows-virtual-desktop-wvd-image-management-how-to-manage-and-deploy-custom-images-including-versioning-with-the-azure-shared-image-gallery-sig/
