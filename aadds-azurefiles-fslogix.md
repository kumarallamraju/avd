This blog assumes you have already configured Azure Active Directory Domain Services. 
In order to use FSLogix with multi-session desktops we need to first domain join the Azure Files to Azure ADDS

Go to Azure Portal https://portal.azure.com
Create an ADLS Gen2 Storage Account with LRS tier.
Once the storage account is created, go to Settings >> Configuration

<img width="296" alt="Screen Shot 2021-07-25 at 9 15 41 PM" src="https://user-images.githubusercontent.com/15897803/126932405-08edafdb-65ca-4483-bb54-141035f27186.png">


