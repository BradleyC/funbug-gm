async function main() {
    const famine = await ethers.getContractFactory("GovernIncent")
    // Gm Core address
    const famineDeployed = await famine.deploy('0x87628323ade11376c42549cBF965d06E824939e2')
  
    console.log("Funbugᵍᵐ deployed to:", famineDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
