async function main() {
    const MyNFT = await ethers.getContractFactory("MyNFT");
    const gasLimit = 3_000_000; // or use estimated gas or default
    const myNFT = await MyNFT.deploy({ gasLimit: gasLimit });
    await myNFT.waitForDeployment();
    console.log("MyNFT deployed to:", await myNFT.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
