import { promises as fsPromises } from 'fs';
import jwt from 'jsonwebtoken';

// Read the JWT secret from the file system
export async function readJwtSecret(jwtSecretPath: string): Promise<string> {
  const secret = await fsPromises.readFile(jwtSecretPath);

  return secret.toString();
}

export function createJwtToken(jwtSecret: string): string {
  return jwt.sign({ iat: Math.floor(Date.now() / 1000) }, jwtSecret, { algorithm: 'HS256' });
}
