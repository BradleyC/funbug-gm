async function main() {
    const bounty = await ethers.getContractFactory("GovernIncent")
    const bountyDeployed = await bounty.deploy()
  
    console.log("Funbugᵍᵐ deployed to:", bountyDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
