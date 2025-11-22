// models/User.js
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema(
  {
    name: { type: String },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    resetPasswordToken: { type: String },         // hashed token
    resetPasswordExpires: { type: Date }          // expiry date/time
  },
  { timestamps: true, collection: 'user' }        // explicit collection name
);

module.exports = mongoose.model('User', UserSchema);
