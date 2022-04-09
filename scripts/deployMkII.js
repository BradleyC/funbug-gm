async function main() {
    // deploy Registrar base
    funbugRegistrar = await ethers.getContractFactory("FunbugRegistrar")
    const funbugRDeployed = await funbugRegistrar.deploy()
    console.log("Funbug Registrar deployed to:", funbugRDeployed.address)

    // deploy Registrar proxy
    const registrarProxy = await upgrades.deployProxy(funbugRDeployed, { kind: 'uups' });
    await registrarProxy.deployed();
    console.log("The Registrar Proxy is deployed to:", registrarProxy.address);

    // deploy Funbugᵍᵐ base
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
    