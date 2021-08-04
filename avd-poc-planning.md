
## AVD POC Planning

1. It's recommended to create a new Azure subscription to provision Azure Virtual Desktop (AVD) resources.
2. Have owner or contributor privileges on the subscription.
3. Register the DesktopVirtualization Resource Provider. Go to your Subscription >> Settings >> Resource providers and search for "desktop"

<img width="1095" alt="Screen Shot 2021-08-04 at 8 44 27 AM" src="https://user-images.githubusercontent.com/15897803/128211842-228f1af7-9992-4671-a7f9-c2bf8191b703.png">

4. Create a new Resource Group, Virtual Network (VNet) and have a line of sight into your on-prem Domain Controllers. This can be configured under your VNet's DNS Servers section. If you already have a line of sight, just peer the new VNet with an existing VNet.

5. Ensure on-prem identities are sync'ing to Azure Active Directory via AD Connect

6. By default AVD session hosts (VMs) are domain joined. So have your domain join credentials ready in this format. domainjoin@contoso.com / {password}
7. If you're planning to keep these VMs in a separate OU, pls create the OU beforehand and get the full OU path
8. Have a separate VM (domain joined) to perform admin activities or back door entry to your session hosts.
9. For multi-session desktops, we need to domain join the Azure Files or Azure NetApp Files. Pls refer to this document https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable 

10. Download the AzFilesHybrid module https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable#download-azfileshybrid-module on to your admin VM created in Step #8 
