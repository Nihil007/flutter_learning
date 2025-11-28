// routes/password_sms.js
const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const twilio = require('twilio');
const rateLimit = require('express-rate-limit');

const User = require('./user'); // adjust path if your structure differs

// Config from env
const ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID || '';
const AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN || '';
const TWILIO_FROM = process.env.TWILIO_PHONE_NUMBER || '';
const JWT_SECRET = process.env.JWT_SECRET || 'secret';
const OTP_EXPIRES_MIN = Number(process.env.OTP_EXPIRES_MIN || 5);
const RESET_TOKEN_EXPIRES = process.env.RESET_TOKEN_EXPIRES || '15m';
const SEND_SMS = (process.env.SEND_SMS || 'true') === 'true';

const twilioClient = (ACCOUNT_SID && AUTH_TOKEN) ? twilio(ACCOUNT_SID, AUTH_TOKEN) : null;

// limiter to avoid abuse
const forgotLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 3,
  message: { message: 'Too many requests, try again later.' }
});

// helper: hash OTP
function hashOtp(otp) {
  return crypto.createHash('sha256').update(otp).digest('hex');
}

// helper: normalize mobile (very simple)
function normalizeMobile(mobile) {
  if (!mobile) return mobile;
  const digits = mobile.replace(/[^\d+]/g, '');
  return digits.startsWith('+') ? digits : digits;
}

// POST /api/password/forgot-sms
router.post('/forgot-sms', forgotLimiter, async (req, res) => {
  try {
    const { mobile } = req.body;
    if (!mobile) return res.status(400).json({ message: 'Mobile required' });

    const normalized = normalizeMobile(mobile);
    const user = await User.findOne({ mobile: normalized });
    // generic response to avoid enumeration
    if (!user) return res.json({ message: 'If that mobile is registered, an OTP has been sent.' });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const hashed = hashOtp(otp);
    const expires = Date.now() + OTP_EXPIRES_MIN * 60 * 1000;

    user.resetPasswordOtp = hashed;
    user.resetPasswordOtpExpires = new Date(expires);
    await user.save();

    const text = `Your password reset code is ${otp}. It expires in ${OTP_EXPIRES_MIN} minutes.`;

    if (SEND_SMS && twilioClient) {
      const to = normalized.startsWith('+') ? normalized : `+91${normalized}`;
      try {
        await twilioClient.messages.create({ body: text, from: TWILIO_FROM, to });
      } catch (smsErr) {
        console.error('Twilio send error:', smsErr);
        // do not reveal to client
      }
    } else {
      console.log(`[DEV SMS] OTP for ${normalized}: ${otp}`);
    }

    return res.json({ message: 'If that mobile is registered, an OTP has been sent.' });
  } catch (err) {
    console.error('forgot-sms error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/password/verify-otp
router.post('/verify-otp', async (req, res) => {
  try {
    const { mobile, otp } = req.body;
    if (!mobile || !otp) return res.status(400).json({ message: 'Mobile and OTP required' });

    const normalized = normalizeMobile(mobile);
    const user = await User.findOne({ mobile: normalized });
    if (!user) return res.status(400).json({ message: 'Invalid OTP or expired' });

    if (!user.resetPasswordOtp || !user.resetPasswordOtpExpires) {
      return res.status(400).json({ message: 'No OTP found' });
    }

    if (user.resetPasswordOtpExpires.getTime() < Date.now()) {
      return res.status(400).json({ message: 'OTP expired' });
    }

    const hashed = hashOtp(otp);
    if (hashed !== user.resetPasswordOtp) {
      return res.status(400).json({ message: 'Invalid OTP' });
    }

    const resetToken = jwt.sign({ id: user._id, purpose: 'password_reset' }, JWT_SECRET, { expiresIn: RESET_TOKEN_EXPIRES });

    user.resetPasswordOtp = undefined;
    user.resetPasswordOtpExpires = undefined;
    await user.save();

    return res.json({ success: true, resetToken, message: 'OTP verified' });
  } catch (err) {
    console.error('verify-otp error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/password/reset-with-token
router.post('/reset-with-token', async (req, res) => {
  try {
    const { token, password } = req.body;
    if (!token || !password) return res.status(400).json({ message: 'Token and new password required' });

    let decoded;
    try {
      decoded = jwt.verify(token, JWT_SECRET);
    } catch (e) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }

    if (!decoded || decoded.purpose !== 'password_reset') {
      return res.status(400).json({ message: 'Invalid token' });
    }

    const user = await User.findById(decoded.id);
    if (!user) return res.status(400).json({ message: 'Invalid token' });

    const hashed = await bcrypt.hash(password, 10);
    user.password = hashed;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    user.resetPasswordOtp = undefined;
    user.resetPasswordOtpExpires = undefined;
    await user.save();

    // optional confirmation SMS
    try {
      if (SEND_SMS && twilioClient) {
        const to = user.mobile.startsWith('+') ? user.mobile : `+91${user.mobile}`;
        await twilioClient.messages.create({
          body: 'Your password has been reset successfully. If this was not you, contact support.',
          from: TWILIO_FROM,
          to
        });
      } else {
        console.log(`[DEV SMS] Password reset confirmation for ${user.mobile}`);
      }
    } catch (e) {
      console.warn('Could not send confirmation SMS', e);
    }

    return res.json({ success: true, message: 'Password reset successful' });
  } catch (err) {
    console.error('reset-with-token error:', err);
    return res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
