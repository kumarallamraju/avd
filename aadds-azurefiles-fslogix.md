# Configuring FSLogix with Multi-session desktops and domain joining the Azure Files with Azure AD DS

This blog assumes you have already configured Azure Active Directory Domain Services. 
In order to use FSLogix with multi-session desktops we need to first domain join the Azure Files to Azure ADDS

####Step 1####

Go to Azure Portal https://portal.azure.com
Create an ADLS Gen2 Storage Account with LRS tier.
Once the storage account is created, go to Settings >> Configuration

<img width="296" alt="Screen Shot 2021-07-25 at 9 15 41 PM" src="https://user-images.githubusercontent.com/15897803/126932405-08edafdb-65ca-4483-bb54-141035f27186.png">


Click on Identity-based access for file shares

<img width="534" alt="Screen Shot 2021-07-25 at 9 18 37 PM" src="https://user-images.githubusercontent.com/15897803/126932541-1abe5aa0-633f-40f3-bb5f-863dfd123d79.png">

Initially you'll see Active Directory Not Configured

<img width="676" alt="Screen Shot 2021-07-25 at 4 05 13 PM" src="https://user-images.githubusercontent.com/15897803/126932585-74a1dbb7-5b0a-42d5-96ce-b14773a1938d.png">

Click on "Not Configured" link

<img width="1097" alt="Screen Shot 2021-07-25 at 4 06 32 PM" src="https://user-images.githubusercontent.com/15897803/126932665-a21e4067-4d21-4004-906c-929f0bf27aea.png">

Click on Setup under Azure ADDS box

Move the toggle button

![image](https://user-images.githubusercontent.com/15897803/126932833-b9d2ff3f-33a4-4acc-be9d-0dbaa70f9d40.png)


![image](https://user-images.githubusercontent.com/15897803/126932893-3dd0824f-e0ed-4595-802c-5750a7354ff5.png)

Save the changes. 
Go back to your Azure file share. In my case I named it as “avdfileshare”. Click on 3 dots on the right side and Connect

Copy & save the PowerShell code in your Utility (or Admin) VM. We’ll need this code to mount the file share.

#####################################################################################################################
$connectTestResult = Test-NetConnection -ComputerName {storage-account-name}.file.core.windows.net -Port 445

if ($connectTestResult.TcpTestSucceeded) {

    # Save the password so the drive will persist on reboot
    
    cmd.exe /C "cmdkey /add:`"{storage-account-name}.file.core.windows.net`" /user:`"localhost\{storage-account-name}`" /pass:`{access key}"
    
    # Mount the drive
    
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\{storage-account-name}.file.core.windows.net\avdfileshare" -Persist
    
} else {

    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
    
}
#####################################################################################################################

This completes the Azure Files Domain Join with Azure ADDS


####Step 2####
Now RDP into your Utility (or Admin) VM, Open the PowerShell ISE. Open the PowerShell code that was saved in Step#1. Run the Code.
This code should mount the file share. Open your File Explorer

<img width="217" alt="Screen Shot 2021-07-25 at 8 07 47 PM" src="https://user-images.githubusercontent.com/15897803/126933437-e3627539-79d2-4024-9579-e89e8ee54b73.png">


Double Click on the mounted file share.
Create a folder. In my case I have created a folder named “whprofiles”

Right click on the folder >> Properties

Click on Security Tab >> Advanced

Click on Add

![image](https://user-images.githubusercontent.com/15897803/126933533-dc8b57af-c588-4d1e-a95d-36d9b5f0e0bd.png)

Save the Changes.

This completes the NTFS permissions on the mounted file share.


####Step 3####

Go back to Azure Portal and Select your storage account 

Data Storage >> File shares >> Click on your file share (avdfileshare)

Click on Access Control (IAM)

Add >> Add role assignment 

Select the role named “Storage File Data SMS Share Contributor” and add the right group. 

![image](https://user-images.githubusercontent.com/15897803/126933823-5ba1bae2-534c-4d8b-b696-61250887745a.png)

This steps completes assigning the RBAC roles to the Azure File Share.

Now we’ll setup FSLogix via GPOs

-	Download FSLogix from https://aka.ms/fslogix/download
-	Extract and copy the fslogix.admx file to C:\Windows\PolicyDefinitions and copy the fslogix.adml file to C:\Windows\PolicyDefinitions\en-US folder.
-	Open your GPO editor in your Admin VM
-	Create a GPO named “FSLogixProfiles” (this could be any name of your choice)
-	Right click on FSLogixProfiles >> Edit
-	Computer Configuration >> Policies >> Administrative Templates >> FSLogix
-	Profile Containers and configure the following settings

![image](https://user-images.githubusercontent.com/15897803/126933962-66441351-c46b-42cf-b0cb-e05cfc8f51cc.png)

Size in MBs – 30000

VHD location -  \\{storage-account-name}.file.core.windows.net\avdfileshare\whprofiles 

Create an OU named "AVDPooled"

Right click on AVDPooled OU and Link an Existing GPO

Select FSLogixProfiles from the list

gpupdate /force


Now create a Pooled Desktops (multi-session) host pool, Application Group and Workspace.
Add the users to the Desktop Application Group.

<img width="640" alt="Screen Shot 2021-07-25 at 9 48 55 PM" src="https://user-images.githubusercontent.com/15897803/126934615-0de9fabc-c831-40c6-a54b-89d30d5d50ad.png">

<img width="637" alt="Screen Shot 2021-07-25 at 9 49 06 PM" src="https://user-images.githubusercontent.com/15897803/126934628-f5334ae9-40d2-48ed-949b-b1b4dd9694e1.png">


<img width="718" alt="Screen Shot 2021-07-25 at 9 49 22 PM" src="https://user-images.githubusercontent.com/15897803/126934634-a12fd689-fc7d-474d-8db7-31f7bace9c0f.png">













