async function main() {
    // have to write one script per "source" in hardhat config
    // multiple sources not allowed so we have to manually toggle in contract then deploy these individually
    const funbugCore = await ethers.getContractFactory("FUNBUGgm")
    // const funbugDeployed = await funbugCore.deploy()
  
    // console.log("Funbugᵍᵐ deployed to:", funbugDeployed.address)
    
    // const famine = await ethers.getContractFactory("GovernIncent")
    // const famineDeployed = await famine.deploy('0x87628323ade11376c42549cBF965d06E824939e2')
  
    // console.log("Famine deployed to:", famineDeployed.address)

    const bounty = await ethers.getContractFactory("GovernIncent")
    const bountyDeployed = await bounty.deploy('0x15dBb5929491D2E3e5466404d75dE36f3216e49C')
  
    console.log("Bounty deployed to:", bountyDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
    