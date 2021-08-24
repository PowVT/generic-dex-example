const fs = require('fs');
const chalk = require('chalk');
const ethers = require('ethers');

async function main() {
  console.log("📡 Deploy \n")
  // auto deploy to read contract directory and deploy them all (add ".args" files for arguments)
  //await autoDeploy();
  // OR
  // custom deploy (to use deployed addresses dynamically for example:)
  //const exampleToken = await deploy("ExampleToken")
  //const examplePriceOracle = await deploy("ExamplePriceOracle")
  //const smartContractWallet = await deploy("SmartContractWallet",[exampleToken.address,examplePriceOracle.address])
  const adaptive = await deploy("Adaptive")
  const dex = await deploy("DEX",["0xBBf6B92Afb479c82dDA49aedEec73D91Cc67A54c"])

  // your address here to get 100 adaptive on deploy:
  await adaptive.transfer("0xBBf6B92Afb479c82dDA49aedEec73D91Cc67A54c",""+(10*10**18))

  console.log("Approving DEX ("+dex.address+") to take Adaptive from main account...")
  await adaptive.approve(dex.address, ethers.utils.parseEther('100')) // My address approving Dex to take my funds on deploy.
  console.log("INIT exchange...")
  await dex.init(ethers.utils.parseEther('100'), adaptive.address, {value:ethers.utils.parseEther('100')}) // Calling init function, first value is the amount of ADP in terms of ETH (10**18) you want to put in, second term is the ADP token address so the init function can set up the contract link between this contract and the existing ADP token contract. Last input is the amount of gas to be sent with the function call. The gas will actually be used to fund the DEX with Ethereum.

}

main()
.then(() => process.exit(0))
.catch(error => {
  console.error(error);
  process.exit(1);
});


async function deploy(name,_args){
  let args = []
  if(_args){
    args = _args
  }
  console.log("📄 "+name)
  const contractArtifacts = artifacts.require(name);
  const contract = await contractArtifacts.new(...args)
  console.log(chalk.cyan(name),"deployed to:", chalk.magenta(contract.address));
  fs.writeFileSync("artifacts/"+name+".address",contract.address);
  console.log("\n")
  return contract;
}

async function autoDeploy() {
  let contractList = fs.readdirSync("./contracts")
  for(let c in contractList){
    if(contractList[c].indexOf(".sol")>=0 && contractList[c].indexOf(".swp.")<0){
      const name = contractList[c].replace(".sol","")
      let args = []
      try{
        const argsFile = "./contracts/"+name+".args"
        if (fs.existsSync(argsFile)) {
          args = JSON.parse(fs.readFileSync(argsFile))
        }
      }catch(e){
        console.log(e)
      }
      await deploy(name,args)
    }
  }
}
