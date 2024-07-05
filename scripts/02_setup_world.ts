const { ethers } = require('hardhat');

async function main() {
  const Contract = await ethers.getContractFactory("World");
  const deployedContract = await Contract.attach('0x63e1e906f734b97002d4dbc05f60d6a34f1f4f74');

  const account = "0x9eae0b75faf48767067e29b2737de766466f7dbb";
  const registry = "0x3dc90dd6a45866a9876edf3d04cc591f569efb07";
  const banking = "0x03b27ca68ffe9c5cc667d3b75d046a3d85dac35e";
  const item = "0xec1a72219a0879041c4b311b48e58b7015a22f11";
  const token = "0x28296b5a57e2f16e47fafb9a86718e69bf826fb8";
  const profile = "0x030609a73fbb073fccb90e6262d7c3b9d733dac4";
  const craft = "0x0885577dc804ed638237ee1020b0a6b67bcba92d";
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

  const tx6 = await deployedContract.setBanking(banking);
  const receipt6 = await tx6.wait();

  console.log('Transaction receipt6: ', receipt6);

  const CraftContract = await ethers.getContractFactory("CraftSystem");
  const deployedCraftContract = await CraftContract.attach(craft);

  const tx7 = await deployedCraftContract.setItem(item);
  const receipt7 = await tx7.wait();

  console.log('Transaction receipt7: ', receipt7);

  console.log('======================== DONE ========================');
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});