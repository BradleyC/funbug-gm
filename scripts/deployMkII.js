async function main() {
    // deploy Registrar base
    funbugRegistrar = await ethers.getContractFactory("FunbugRegistrar")
    const funbugRDeployed = await funbugRegistrar.deploy()
    console.log("Funbug Registrar deployed to:", funbugRDeployed.address)

    // deploy Registrar proxy
    const registrarProxy = await upgrades.deployProxy(funbugRegistrar, { kind: 'uups' });
    const registrarDeployed = await registrarProxy.deployed();
    console.log("The Registrar Proxy is deployed to:", registrarDeployed.address);

    // deploy Funbugᵍᵐ base
    const funbugGm = await ethers.getContractFactory("FUNBUGgm")
    const funbugGmDeployed = await funbugGm.deploy(funbugRDeployed.address)
    console.log("Funbugᵍᵐ deployed to:", funbugGmDeployed.address)

    // deploy Govern
    const governGm = await ethers.getContractFactory("GovernIncent")
    const governDeployed = await governGm.deploy(funbugGmDeployed.address)
    console.log("Govern deployed to:", governDeployed.address)
  }

  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
    