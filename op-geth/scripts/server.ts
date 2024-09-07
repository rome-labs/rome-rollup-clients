import express from 'express';
import path from 'path';
import airdropRoute from './routes/airdrop';
import jwtRoute from './routes/jwt';
import loadEnv from './utils/env';

const app = express();
const { port, host } = loadEnv();

app.set('view engine', 'ejs');

app.use('/static', express.static('public'))

app.use(express.json());
app.use('/airdrop', airdropRoute);
app.use('/jwt', jwtRoute);

app.get('/request_airdrop', (req, res) => {
  res.render('index', { HOST: host });
});

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
