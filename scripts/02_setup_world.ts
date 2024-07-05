const { ethers } = require('hardhat');

async function main() {
  const Contract = await ethers.getContractFactory("World");
  const deployedContract = await Contract.attach('0x03771ad7ee7c6aa5298698a3ae8fb9e8af72758c');

  const account = "0x0fe1a48a9b8de6646e38b7e2a14d135f53c88c9e";
  const registry = "0x13d3766a1e5325c12b93850f7364d4449d4eb4d8";
  const banking = "0xe8d309dca98bfd96b0ec98ffc831edc94131368f";
  const item = "0x82c5c4c2a453262bdc80ed630f681a7054997db2";
  const token = "0xb86c5077d067210b6289d7885294c636d41f7b1e";
  const profile = "0x083702e73c7266f5976939d5541e3392096ed5ff";
  const craft = "0xfed07120164edd6477670726ac35328da4123f68";
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