## **Simple royalties distribution example**

### tronide deployment instructions

1. Delete default workspace and create your own in tronide.io.
2. Delete tests folder and all other files under the "contracts" folder.
3. Create a new empty RoyaltiesDistribution.sol file. TRON-IDE Interface should look like this: <img width="776" alt="image" src="https://github.com/user-attachments/assets/7a16a9a8-46e5-4e6a-a620-7b5fc246c1bc">

4. Copy the Solidity code from https://github.com/simbadMarino/royaltiesDistribution/blob/main/tronbox/contracts/RoyaltiesDistribution.sol and paste into tronide created file.
5. Save file by Ctrl+S(Win or Linux) or Cmd+S(mac). If a compiler issue appears on the pragma code line make sure to switch to the correct solidity version (0.8.20) under the Solidity Compiler section.

   <img width="348" alt="image" src="https://github.com/user-attachments/assets/6bacb46b-deab-4750-bb53-b51f7fd96590">

8. Click on Compile button
9. Open your Tronlink extension and make sure to select your desired tesnet account using Tronlink extension (Nile or Shasta)
10. Go to Deploy & run transactions section and select "Injected Tronweb". You should see your TRX balance after a couple seconds.
    <img width="370" alt="image" src="https://github.com/user-attachments/assets/786fd198-b87b-4e9f-90d7-858aa2dfdec0">
11. Make sure you have enough testnet TRX and copy/paste your TRC-20 contract token address as constructor parameter (You can use TXYZopYRdj2D9XRtbG411XZZ3kM5VkAeBf as the USDT test token).
12. Click on "Deploy" to deploy your contract.
    
      <img width="370" alt="image" src="https://github.com/user-attachments/assets/5e5d565b-0b3d-4db0-9c20-f4698111d67b">

14. If no errors you'll be able to interact and test your contract using the tron-ide built-in contract interaction feature:

       <img width="319" alt="image" src="https://github.com/user-attachments/assets/47d67ef0-36fb-475e-bb5e-1a4c3e05f8e0">







### tronbox deployment instructions
1. git clone this repo
2. Create a .env file for your private key
   You have to select your desired network depending on where do you want to deploy your contract.
   1. Use `export PRIVATE_KEY_NILE= "Your private key here without quotes" `for nile testnet
   2. Use `export PRIVATE_KEY_SHASTA= "Your private key here without quotes" `for shasta testnet
   3. Use `export PRIVATE_KEY_MAINNET= "Your private key here without quotes"``` for mainnet deployment (this will cost you real TRX so be cautios here)
3. Compile the code:` tronbox compile`
4. Deploy your contract: `source .env && tronbox migrate --network nile ` (Example for nile testnet, you can use shasta or mainnet instead in the network argument

For details on how to use tronbox please refer to https://github.com/tronprotocol/tronbox or https://developers.tron.network/reference/tronbox-command-line



