async function sendTransaction(params) {
       try {
            const network = await window.ethereum.request({
                method: 'wallet_switchEthereumChain',
                params: [{ chainId: '0xAA36A7' }], //need to change during launch
            });
            console.log({network})
            // Network switched successfully
        } catch (error) {
            console.error('Failed to switch network:', error);
        }

        var contractAddress = '0xaf8FdC377477F29A0edBf03Eb9BAc3a56339E754';
        try {
            var web3 = new Web3(window.ethereum);
            var token = new web3.eth.Contract(PBMC_ABI, contractAddress);
            const userAccount = "0xAA737Df2b2C4175205Af4644cb4e44d7b9CeE5D4"
            const pbmValue = Web3.utils.toWei("1", 'ether');
            const tx = await token.methods.transfer('0x44CC7204F08B2C4fe927f88B939Be4A703179e28', pbmValue).send({ from: userAccount })
            console.log({tx})
        } catch (err) {
            console.log(err);
        }
    }