async function main() {
    const famine = await ethers.getContractFactory("GovernIncent")
    // Gm Core address
    const famineDeployed = await famine.deploy('0x0516D324468c870e005021eDC9dFcD6126C3B8b4')
  
    console.log("Funbug Famine Scorekeeping deployed to:", famineDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
