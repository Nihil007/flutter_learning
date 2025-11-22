const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const User = require("./user");

// Helper: find user by email or mobile
async function findUserByIdentifier(identifier) {
  if (!identifier) return null;
  // treat as email if contains @
  if (identifier.includes("@")) {
    return User.findOne({ email: identifier });
  } else {
    // otherwise treat as mobile
    return User.findOne({ mobile: identifier });
  }
}

// REGISTER
router.post("/register", async (req, res) => {
  try {
    const { name, email, mobile, password } = req.body;

    if (!mobile || !password) {
      return res.status(400).json({ message: "Mobile and password are required" });
    }

    // Check uniqueness: either email or mobile already exists
    if (email) {
      const existsEmail = await User.findOne({ email });
      if (existsEmail) return res.status(400).json({ message: "Email already in use" });
    }

    const existsMobile = await User.findOne({ mobile });
    if (existsMobile) return res.status(400).json({ message: "Mobile already in use" });

    const hashed = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email: email || undefined,
      mobile,
      password: hashed
    });

    const token = jwt.sign(
      { id: user._id, email: user.email, mobile: user.mobile },
      process.env.JWT_SECRET,
      { expiresIn: "24h" }
    );

    res.status(201).json({
      token,
      user: { id: user._id, name: user.name, email: user.email, mobile: user.mobile }
    });
  } catch (err) {
    console.error("Register error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

// LOGIN
// Body accepts either:
// { "identifier": "<email or mobile>", "password": "..." }
// OR { "email": "...", "password": "..." }
// OR { "mobile": "...", "password": "..." }
router.post("/login", async (req, res) => {
  try {
    const { identifier, email, mobile, password } = req.body;

    const id = identifier || email || mobile;
    if (!id || !password) {
      return res.status(400).json({ message: "Identifier (email or mobile) and password required" });
    }

    // Find user by identifier
    let user = await findUserByIdentifier(id);
    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: user._id, email: user.email, mobile: user.mobile },
      process.env.JWT_SECRET,
      { expiresIn: "24h" }
    );

    res.json({
      token,
      user: { id: user._id, name: user.name, email: user.email, mobile: user.mobile }
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;
