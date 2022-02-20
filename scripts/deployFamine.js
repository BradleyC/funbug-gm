async function main() {
    const famine = await ethers.getContractFactory("GovernIncent")
    const famineDeployed = await famine.deploy()
  
    console.log("Funbugᵍᵐ deployed to:", famineDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
