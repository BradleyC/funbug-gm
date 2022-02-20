async function main() {
    const bounty = await ethers.getContractFactory("GovernIncent")
    // Gm Core address
    const bountyDeployed = await bounty.deploy('0x15dBb5929491D2E3e5466404d75dE36f3216e49C')
  
    console.log("Funbugᵍᵐ deployed to:", bountyDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
