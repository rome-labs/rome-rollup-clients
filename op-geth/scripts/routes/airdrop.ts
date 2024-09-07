import express from 'express';
import Web3 from 'web3';
import loadEnv from '../utils/env';
import { rateLimitMiddleware } from '../middleware/rateLimit';

const router = express.Router();
const { httpAddr, senderAddr, privateKey } = loadEnv();

const web3 = new Web3(httpAddr);

import { updateRateLimit } from '../middleware/rateLimit'; // Import the updateRateLimit function

router.post('/', async (req, res) => {
  const { recipientAddr, amount } = req.body;

  // Check the rate limit before proceeding
  const rateLimitExceeded = rateLimitMiddleware(req, res);
  if (rateLimitExceeded) return;

  try {
    // const { address: senderAddr, privateKey } = await readKeystore(web3, dataDir, password);

    const transaction = {
      from: senderAddr,
      to: recipientAddr,
      value: web3.utils.toWei(amount, 'ether'),
      nonce: await web3.eth.getTransactionCount(senderAddr),
      gas: 22000,
      gasPrice: await web3.eth.getGasPrice(),
      chainId: await web3.eth.getChainId()
    };

    console.log(`Airdrop ${amount} ETH from ${senderAddr} to ${recipientAddr}`);

    const signedTx = await web3.eth.accounts.signTransaction(transaction, privateKey);
    const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

    console.log(`Transaction successful with hash: ${receipt.transactionHash}`);

    updateRateLimit(recipientAddr, parseFloat(amount));

    res.json({ success: true, transactionHash: receipt.transactionHash });
  } catch (error) {
    const error_t = error as Error;
    console.error(error_t);
    res.status(500).json({ success: false, error: error_t.message });
  }
});

export default router;
