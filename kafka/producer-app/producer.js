const mysql = require("mysql2/promise");

function must(name, value) {
    if (!value || !String(value).trim()) {
        throw new Error(`Missing environment variable: ${name}`);
    }
    return String(value).trim();
}

// DB config
const dbHost = must("DB_HOST", process.env.DB_HOST);
const dbPort = Number(process.env.DB_PORT || "3306");
const dbUser = must("DB_USER", process.env.DB_USER);
const dbPassword = process.env.DB_PASSWORD || "";
const dbName = must("DB_NAME", process.env.DB_NAME);

async function main() {

    // Create initial MySQL connection to create the database if it doesn't exist
    const connection = await mysql.createConnection({
        host: dbHost,
        port: dbPort,
        user: dbUser,
        password: dbPassword,
    });
    console.log(`Connected to MySQL at ${dbHost}:${dbPort}`);

    // Ensure the database exists
    await connection.execute(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);
    await connection.end();
    console.log(`Database '${dbName}' is ready.`);

    // Create a MySQL connection pool
    const pool = mysql.createPool({
        host: dbHost,
        port: dbPort,
        user: dbUser,
        password: dbPassword,
        database: dbName,
        connectionLimit: 5,
    });

    // Ensure the table exists
    console.log("Ensuring table 'user_events' exists...");
    await pool.execute(`
        CREATE TABLE IF NOT EXISTS user_events (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT,
            action VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    `);
    console.log("Table 'user_events' is ready.");

    console.log("Starting event production loop...");

    setInterval(async () => {
        try {
            await produceEvent(pool);
        } catch (err) {
            console.error("Error producing event:", err);
        }
    }, 1000);
}

async function produceEvent(pool) {

    // Create a sample event payload
    const payload = {
        user_id: Math.floor(Math.random() * 1000),
        action: "login",
    };

    // Insert event into the database
    await pool.execute(
        `INSERT INTO user_events (user_id, action) VALUES (?, ?)`,
        [payload.user_id, payload.action]
    );

    console.log("Inserted event into DB:", payload);
}

main().catch((err) => {
    console.error("Producer error:", err);
    process.exit(1);
});
