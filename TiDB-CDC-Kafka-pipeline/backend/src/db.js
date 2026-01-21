// backend/src/db.js

const mysql = require("mysql2/promise");

// Create a connection pool to the database
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

// Export the pool
module.exports = pool;
