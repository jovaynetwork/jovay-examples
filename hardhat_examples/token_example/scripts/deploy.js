async function main() {
    const Token = await ethers.getContractFactory("MyToken");
    const gasLimit = 3_000_000; // or use estimated gas or default
    const token = await Token.deploy(ethers.parseUnits("1000", 6), { gasLimit: gasLimit });
    await token.waitForDeployment();
    console.log("Token address:", await token.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
