async function main() {
    const bounty = await ethers.getContractFactory("GovernIncent")
    // Gm Core address
    const bountyDeployed = await bounty.deploy('0x0516D324468c870e005021eDC9dFcD6126C3B8b4')
  
    console.log("Funbug Bounty Scorekeeping deployed to:", bountyDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
