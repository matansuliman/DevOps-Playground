// backend/src/auth.js

const pool = require("./db");

// Middleware to authenticate requests using a Bearer token
async function authMiddleware(req, res, next) {
    // Read the Authorization header
    const header = req.headers["authorization"] || "";

    // Extract token from "Bearer <token>"
    const token = header.startsWith("Bearer ") ? header.slice(7) : null;

    // Reject request if no token is provided
    if (!token) {
        return res.status(401).json({ error: "Missing token" });
    }

    // Look up the user associated with the provided token using a subquery
    const [rows] = await pool.query(
        `
            SELECT id, username
            FROM users
            WHERE id = (
                SELECT user_id
                FROM user_tokens
                WHERE token = ?
            )
        `,
        [token]
    );

    // Reject request if the token is not valid
    if (rows.length === 0) {
        return res.status(401).json({ error: "Invalid token" });
    }

    // Attach authenticated user to the request object
    req.user = rows[0];

    // Continue to the next middleware or route handler
    next();
}

// Export the authentication middleware
module.exports = authMiddleware;
