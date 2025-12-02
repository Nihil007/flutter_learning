require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const authRoutes = require('./auth');


const app = express();
app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected to', process.env.MONGO_URI);
    app.listen(process.env.PORT || 4000, () =>
      console.log('Server running on port', process.env.PORT || 4000)
    );
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err);
  });

  const passwordSmsRoutes = require('./password_sms');
  app.use('/api/password', passwordSmsRoutes);

  app.get('/ping', (req, res) => {
  console.log('Ping hit!');
  res.send('pong');
  });

