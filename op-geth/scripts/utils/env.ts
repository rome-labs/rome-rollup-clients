interface Config {
  httpAddr: string;
  dataDir: string;
  password: string;
  port: number;
  jwtSecretPath: string;
  senderAddr: string;
  privateKey: string;
  host: string;
  airdropTitle: string;
}

export default function loadEnv(): Config {
  // Provide default values or throw an error if the environment variables are not set
  const httpAddr = process.env.HTTP_ADDR || 'http://0.0.0.0:8545';
  const gethName = process.env.GETH_NAME || 'op-geth';

  const baseDataDir = process.env.GETH_BASE_DATA_DIR || `${process.env.HOME}/.ethereum`;
  const dataDir = `${baseDataDir}/${gethName}-data`;

  const jwtSecretPath = process.env.JWT_PATH || `${dataDir}/jwtsecret`;

  const password = process.env.ACCOUNT_PASSWORD || 'qwerty';

  const port = process.env.PORT ? parseInt(process.env.PORT) as number : 3000;

  const senderAddr = process.env.GENESIS_ADDRESS || '';
  const privateKey = process.env.GENESIS_PRIVATE_KEY || '';

  const host = process.env.GETH_HOST || 'localhost:3000';
  const airdropTitle = process.env.AIRDROP_TITLE || '';

  return { httpAddr, dataDir, password, port, jwtSecretPath, senderAddr, privateKey, host, airdropTitle };
}
