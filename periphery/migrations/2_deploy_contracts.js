const Router = artifacts.require("UniswapV2Router02");
const WETH = artifacts.require("WETH");

module.exports = async function (deployer, network) {
  let weth;
  const FACTORY_ADDRESS = '0x199728a91034892aB8C3e0F98b4F085cA3fbb39D';

  if(network === 'mainnet'){
    weth = await WETH.at('0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2');
  }
  else{
    await deployer.deploy(WETH);
    weth = await WETH.deployed(); 
  }
  await deployer.deploy(Router,FACTORY_ADDRESS,weth.address);
};