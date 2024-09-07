import { promises as fsPromises } from 'fs';
import * as path from 'path';
import Web3 from 'web3';

import { Web3Account } from 'web3-eth-accounts';

// Connect to an Ethereum node
export default async function readKeystore(web3: Web3, dataDir: string, pass: string = "asdf"): Promise<Web3Account> {
  const keystoreDir = path.join(dataDir, 'keystore');

  const files = await fsPromises.readdir(keystoreDir);

  files.sort(); // Sort files to ensure consistency; might need customization based on naming conventions
  const firstFile = files[0]; // Assume there is at least one file
  const keyfilePath = path.join(keystoreDir, firstFile);

  const encryptedKey = await fsPromises.readFile(keyfilePath, { encoding: 'utf8' });

  return web3.eth.accounts.decrypt(encryptedKey, pass);
}

