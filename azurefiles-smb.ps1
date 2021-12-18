 ## Join the Storage Account for SMB Auth Microsoft Source:
## https://docs.microsoft.com/en-us/azure/storage/files/storage-files-identity-ad-ds-enable

# Download AzFilesHybrid module from the below github page
# https://github.com/Azure-Samples/azure-files-samples/releases

 # Download AzFilesHybrid module from the below github page
# https://github.com/Azure-Samples/azure-files-samples/releases

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-PSRepository -Name “PSGallery” -InstallationPolicy Trusted
Install-Module -Name Az -AllowClobber

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

cd C:\Users\kumara\Downloads\AzFilesHybrid

.\CopyToPSPath.ps1

#Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid


#Login with an Azure AD credential that has either storage account owner or contributor Azure role assignment
Get-AzContext
Connect-AzAccount 

#Define parameters
$SubscriptionId = "80cf225d-41c6-4df5-84e8-4ca9d781f731"
$ResourceGroupName = "rg-wvd"
$StorageAccountName = "kasftp"

#Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId 

# Register the target storage account with your active directory environment under the target OU (for example: specify the OU with Name as "UserAccounts" or DistinguishedName as "OU=UserAccounts,DC=CONTOSO,DC=COM"). 
# You can use to this PowerShell cmdlet: Get-ADOrganizationalUnit to find the Name and DistinguishedName of your target OU. If you are using the OU Name, specify it with -OrganizationalUnitName as shown below. If you are using the OU DistinguishedName, you can set it with -OrganizationalUnitDistinguishedName. You can choose to provide one of the two names to specify the target OU.
# You can choose to create the identity that represents the storage account as either a Service Logon Account or Computer Account (default parameter value), depends on the AD permission you have and preference. 
# Run Get-Help Join-AzStorageAccountForAuth for more details on this cmdlet.

Join-AzStorageAccountForAuth `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -DomainAccountType "ComputerAccount" `
        -OrganizationalUnitDistinguishedName "OU=NoComputerPwExpiration,DC=wvdlabs,DC=com" # If you don't provide the OU name as an input parameter, the AD identity that represents the storage account is created under the root directory.

#You can run the Debug-AzStorageAccountAuth cmdlet to conduct a set of basic checks on your AD configuration with the logged on AD user. This cmdlet is supported on AzFilesHybrid v0.1.2+ version. For more details on the checks performed in this cmdlet, see Azure Files Windows troubleshooting guide.
Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose


# Confirm the feature is enabled
# Get the target storage account
$storageaccount = Get-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName

# List the directory service of the selected service account
$storageAccount.AzureFilesIdentityBasedAuth.DirectoryServiceOptions

# List the directory domain information if the storage account has enabled AD DS authentication for file shares
$storageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties

# Mount the file share as super user

#Define parameters
$StorageAccountName = "xxxxx"
$ShareName = "xxxx"
$StorageAccountKey = "xxxx"
#$suffix = ".file.core.windows.net"

####
#  Copy the below code (line 76 to 84) from Azure Portal > Storage Account > File Shares > Connect
#  Run the code below to test the connection and mount the share
####

$connectTestResult = Test-NetConnection -ComputerName kasftp.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot
    cmd.exe /C "cmdkey /add:`"xxxx.file.core.windows.net`" /user:`"Azure\xxxx`" /pass:""
    # Mount the drive
    New-PSDrive -Name K -PSProvider FileSystem -Root "\\xxxx.file.core.windows.net\fslogixprofiles" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}

  # Set recommended NTFS permissions on the file share
    Start-Process icacls -ArgumentList "K: /grant $($Group):(M)" -Wait -NoNewWindow -PassThru -ErrorAction 'Stop'
    Start-Process icacls -ArgumentList 'K: /grant "Creator Owner":(OI)(CI)(IO)(M)' -Wait -NoNewWindow -PassThru -ErrorAction 'Stop'
    Start-Process icacls -ArgumentList 'K: /remove "Authenticated Users"' -Wait -NoNewWindow -PassThru -ErrorAction 'Stop'
    Start-Process icacls -ArgumentList 'K: /remove "Builtin\Users"' -Wait -NoNewWindow -PassThru -ErrorAction 'Stop'
    Write-Error -Message "Setting the NTFS permissions on the Azure file share succeeded" -Type 'INFO' 


#Unmount the mapped drive
    Remove-PSDrive -Name 'K' -PSProvider 'FileSystem' -Force -ErrorAction 'Stop'
    Write-Error -Message "Unmounting the Azure file share succeeded" -Type 'INFO' 


