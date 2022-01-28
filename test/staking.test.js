const { expect } = require('chai');
const BigNumber = require('@ethersproject/bignumber');

describe('My NFT - Staking Test', function () {
  before(async function () {});

  it('Should accept the stakes of NFT batch', async function () {
    const provider = waffle.provider;

    const [owner] = await ethers.getSigners();
    const balance0ETH = await provider.getBalance(owner.address);
    console.log('signer :' + owner.address + ' balance : ' + balance0ETH);

    const MyToken = await ethers.getContractFactory('MyToken');
    const token = await MyToken.deploy();

    console.log('owner  :' + (await token.owner()));
    console.log(
      'token deployed, owner balance ' + (await token.balanceOf(owner.address))
    );

    const MyNft = await ethers.getContractFactory('MyNft');
    const nft = await MyNft.deploy();

    //minting MyToken
    console.log('minting MyToken');
    const tx1 = await token.connect(owner).mint(owner.address, 1000000000);
    await tx1.wait();
    console.log('minted MyToken ' + (await token.balanceOf(owner.address)));

    const Staking = await ethers.getContractFactory('Staking');
    const stake = await Staking.deploy(token.address, nft.address);
    console.log('Staking deployed ');

    nft.connect(owner).mint(stake.address, 1, 5, '0x12345678');
  });
});
