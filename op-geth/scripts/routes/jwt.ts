import express from 'express';
import loadEnv from '../utils/env';
import { readJwtSecret, createJwtToken } from '../utils/jwt';

const router = express.Router();
const { jwtSecretPath } = loadEnv();

let jwtSecret: string | null = null;

router.post('/', async (_, res) => {
  if (!jwtSecret)
    jwtSecret = await readJwtSecret(jwtSecretPath);

  const token = createJwtToken(jwtSecret);

  res.json({ token });
});

export default router;
