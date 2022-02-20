async function main() {
    // have to write one script per "source" in hardhat config
    // multiple sources not allowed so we have to manually toggle in contract then deploy these individually
    const funbugCore = await ethers.getContractFactory("FUNBUGgm")
    const funbugDeployed = await funbugCore.deploy()
  
    console.log("Funbugᵍᵐ deployed to:", funbugDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
    