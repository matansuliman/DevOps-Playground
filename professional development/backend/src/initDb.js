// backend/src/initDb.js

const pool = require("./db");
const bcrypt = require("bcryptjs");

// Initialize database schema and seed default data
async function initDb() {
  // Create users table if it does not exist
  await pool.query(`
    CREATE TABLE IF NOT EXISTS users (
      id BIGINT PRIMARY KEY AUTO_INCREMENT,
      username VARCHAR(255) NOT NULL UNIQUE,
      password_hash VARCHAR(255) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // Create user_tokens table if it does not exist
  // Uses a foreign key to reference users table
  await pool.query(`
    CREATE TABLE IF NOT EXISTS user_tokens (
      id BIGINT PRIMARY KEY AUTO_INCREMENT,
      user_id BIGINT NOT NULL,
      token VARCHAR(255) NOT NULL UNIQUE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);

  // Read default user credentials from environment variables
  const defaultUser = process.env.DEFAULT_USER;
  const defaultPass = process.env.DEFAULT_PASS;

  // Check if the default user already exists
  const [rows] = await pool.query(
    "SELECT id FROM users WHERE username = ?",
    [defaultUser]
  );

  // Create the default user only if it does not exist
  if (rows.length === 0) {
    // Hash the default password before storing
    const passwordHash = await bcrypt.hash(defaultPass, 10);
    await pool.query(
      "INSERT INTO users (username, password_hash) VALUES (?, ?)",
      [defaultUser, passwordHash]
    );
  }
}

// Export the initialization function
module.exports = initDb;
