const { ethers } = require('hardhat');

async function main() {
  const Contract = await ethers.getContractFactory("World");
  const deployedContract = await Contract.attach('0xa3baa4472eacf445518ce7e6ec3aff5d471d0ca1');

  const account = "0x5482feac3dd1b1d4086c8d625df7371b79afbc51";
  const registry = "0xd529513024df2087425b88b2b105f68ee8de2e91";
  const item = "0x7b1549db8e2f98a0f00e0561247e8655524201ce";
  const token = "0x683e303e8f00c13150a39581260a6d0a84697a57";
  const profile = "0x522b0194e5ff7f81384062aa29a4f5ff04c79de1";
  const craft = "0xa0eac99be64f1b7c0a31e7714c2908879310de4a";
  const chainId = 252;

  const tx = await deployedContract.setProfile(profile);
  const receipt = await tx.wait();

  console.log('Transaction receipt: ', receipt);

  const tx2 = await deployedContract.setToken(token);
  const receipt2 = await tx2.wait();

  console.log('Transaction receipt2: ', receipt2);

  const tx3 = await deployedContract.setItem(item);
  const receipt3 = await tx3.wait();

  console.log('Transaction receipt3: ', receipt3);

  const tx4 = await deployedContract.configTokenBound(registry, account, chainId);
  const receipt4 = await tx4.wait();

  console.log('Transaction receipt4: ', receipt4);

  const tx5 = await deployedContract.setCraft(craft);
  const receipt5 = await tx5.wait();

  console.log('Transaction receipt5: ', receipt5);

  const CraftContract = await ethers.getContractFactory("CraftSystem");
  const deployedCraftContract = await CraftContract.attach(craft);

  const tx6 = await deployedCraftContract.setItem(item);
  const receipt6 = await tx6.wait();

  console.log('Transaction receipt7: ', receipt6);

  console.log('======================== DONE ========================');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});