import Web3, { TransactionReceipt } from "web3";
import { Web3Account } from "web3-eth-accounts";

export default async function deploy(web3: Web3, account: Web3Account, contractBytecode: string, gas?: bigint): Promise<TransactionReceipt> {
  gas = gas || await web3.eth.estimateGas({
    from: account.address, // The address of the account sending the transaction
    data: contractBytecode, // The bytecode of the contract to be deployed
  }) + 10n;

  console.log('Deploying contract with gas:', gas.toString());

  const createTransaction = await web3.eth.accounts.signTransaction(
    {
      data: contractBytecode,
      nonce: await web3.eth.getTransactionCount(account.address),
      gas,
      gasPrice: await web3.eth.getGasPrice() + 1000n,
      chainId: await web3.eth.getChainId()
    },
    account.privateKey
  );

  return await web3.eth.sendSignedTransaction(
    createTransaction.rawTransaction
  );
};

