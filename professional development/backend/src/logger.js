// backend/src/logger.js

const log4js = require("log4js");

// Configure log4js to write logs to stdout
log4js.configure({
    appenders: {
        out: { type: "stdout" } // Output logs to standard output
    },
    categories: {
        default: {
            appenders: ["out"],
            level: process.env.LOG_LEVEL || "info" // Log level from environment variables
        }
    }
});

// Create a logger instance for the backend service
const logger = log4js.getLogger("backend");

// Helper function to log structured JSON objects
function logJson(level, data) {
    // Convert the data object to a JSON string before logging
    logger[level](JSON.stringify(data));
}

// Export logger utilities
module.exports = {
    logger,
    logJson
};
