// backend/src/server.js

const express = require("express");
const crypto = require("crypto");
const bcrypt = require("bcryptjs");

const pool = require("./db");
const initDb = require("./initDb");
const { logJson } = require("./logger");
const authMiddleware = require("./auth");

const app = express();

// Parse incoming JSON request bodies
app.use(express.json());

// Basic CORS middleware for browser access
app.use((req, res, next) => {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    res.setHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");

    // Handle CORS preflight requests
    if (req.method === "OPTIONS") {
        return res.sendStatus(204);
    }

    next();
});

// Health check endpoint
app.get("/health", (req, res) => {
    res.json({ ok: true });
});

// Login endpoint
app.post("/login", async (req, res) => {
    try {
        // Extract client IP address
        const ip = req.socket.remoteAddress || "unknown";

        // Read credentials from request body
        const { username, password } = req.body || {};

        // Validate input
        if (!username || !password) {
            return res.status(400).json({
                error: "username and password are required"
            });
        }

        // Look up the user by username
        const [users] = await pool.query(
            "SELECT id, username, password_hash \
            FROM users WHERE username = ? ",
            [username]
        );

        // Reject if user does not exist
        if (users.length === 0) {
            return res.status(401).json({
                error: "Invalid credentials"
            });
        }

        const user = users[0]; // Get the first and only user

        // Compare provided password with stored hash
        const passwordMatch = await bcrypt.compare(password, user.password_hash);
        if (!passwordMatch) {
            return res.status(401).json({
                error: "Invalid credentials"
            });
        }

        // Generate a random authentication token
        const token = crypto.randomBytes(32).toString("hex");

        // Store the token in the database
        await pool.query(
            "INSERT INTO user_tokens (user_id, token) VALUES (?, ?)",
            [user.id, token]
        );

        // Log successful login event in structured JSON format
        logJson("info", {
            timestamp: new Date().toISOString(),
            userId: user.id,
            action: "LOGIN",
            ip
        });

        // Return the token to the client
        res.json({ token });
    } catch (error) {
        // Handle unexpected server errors
        res.status(500).json({
            error: "Server error",
            details: String(error)
        });
    }
});

// Protected profile endpoint
app.get("/profile", authMiddleware, async (req, res) => {
    res.json({ user: req.user });
});

// Read API port from environment variables
const PORT = process.env.PORT || 3000;

// Initialize database and start the server
(async () => {
    await initDb();
    app.listen(PORT, () => {
        console.log(`API listening on :${PORT}`);
    });
})();
