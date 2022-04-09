async function main() {
    // have to write one script per "source" in hardhat config
    // multiple sources not allowed so we have to manually toggle in contract then deploy these individually
    funbugRegistrar = await ethers.getContractFactory("FunbugRegistrar")
    const funbugRDeployed = await funbugRegistrar.deploy()
    console.log("Funbug Registrar deployed to:", funbugRDeployed.address)

    const funbugGm = await ethers.getContractFactory("FUNBUGgm")
    const funbugGmDeployed = await funbugGm.deploy(funbugRDeployed.address)
  
    console.log("Funbugᵍᵐ deployed to:", funbugGmDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
    