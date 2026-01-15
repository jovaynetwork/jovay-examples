async function main() {
    const MyToken = await ethers.getContractFactory("MyToken");
    const gasLimit = 3_000_000; // or use estimated gas or default
    const myToken = await MyToken.deploy(ethers.parseUnits("1000000", 6), { gasLimit: gasLimit });
    await myToken.waitForDeployment();
    console.log("MyToken deployed to:", await myToken.getAddress());

    const SimpleStaking = await ethers.getContractFactory("SimpleStaking");
    const simpleStaking = await SimpleStaking.deploy(await myToken.getAddress(), { gasLimit: gasLimit });
    await simpleStaking.waitForDeployment();
    console.log("SimpleStaking deployed to:", await simpleStaking.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
