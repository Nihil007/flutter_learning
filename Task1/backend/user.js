// models/User.js  (replace /mnt/data/user.js)
const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema(
  {
    name: { type: String },
    email: { type: String, required: true, unique: true, sparse: true },
    mobile: { type: String, required: true, unique: true, sparse: true },
    password: { type: String, required: true },
    resetPasswordToken: { type: String },
    resetPasswordExpires: { type: Date }
  },
  { timestamps: true, collection: 'user' }
);

// Optional: create indexes (ensures unique constraints)
UserSchema.index({ email: 1 }, { unique: true, sparse: true });
UserSchema.index({ mobile: 1 }, { unique: true, sparse: true });

module.exports = mongoose.model('User', UserSchema);
