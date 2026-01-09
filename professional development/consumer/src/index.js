// consumer/src/index.js

const { Kafka } = require("kafkajs");
const { logJson } = require("./logger");

// Read Kafka configuration from environment variables
const KAFKA_BROKERS = [process.env.KAFKA_BROKER_URL];

const KAFKA_TOPIC = process.env.KAFKA_TOPIC;
const KAFKA_GROUP_ID = process.env.KAFKA_GROUP_ID;

// Safely parse JSON messages from Kafka
function safeJsonParse(value) {
    try {
        return JSON.parse(value);
    } catch {
        return null;
    }
}

// Main consumer logic
async function main() {
    // Log consumer startup
    logJson("info", {
        timestamp: new Date().toISOString(),
        action: "CONSUMER_START",
        brokers: KAFKA_BROKERS,
        topic: KAFKA_TOPIC,
        groupId: KAFKA_GROUP_ID
    });

    const kafka = new Kafka({
        brokers: KAFKA_BROKERS
    });

    // Create a Kafka consumer
    const consumer = kafka.consumer({
        groupId: KAFKA_GROUP_ID
    });

    // Connect to Kafka cluster
    await consumer.connect();
    // Subscribe to the specified topic
    await consumer.subscribe({ topic: KAFKA_TOPIC });

    // Start consumption loop
    await consumer.run({
        eachMessage: async ({ topic, partition, message }) => {
            const raw = message?.value?.toString("utf8") || "";
            const parsed = safeJsonParse(raw);

            // Log warning for invalid JSON messages
            if (!parsed) {
                logJson("warn", {
                    timestamp: new Date().toISOString(),
                    action: "CDC_MESSAGE_INVALID_JSON",
                    topic,
                    partition,
                    rawPreview: raw.slice(0, 500)
                });
                return;
            }

            // Log database row changes from TiCDC
            logJson("info", {
                timestamp: new Date().toISOString(),
                action: "DB_CHANGE",
                op: parsed.type,
                database: parsed.database,
                table: parsed.table,
                before: parsed.old || null,
                after: parsed.data || null
            });
        }
    });
}

// Simple retry delay
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

// Retry loop to handle Kafka startup timing issues
(async () => {
    while (true) {
        try {
            await main();
            break;
        } catch (error) {
            logJson("error", {
                timestamp: new Date().toISOString(),
                action: "CONSUMER_RETRY",
                error: String(error)
            });
            await sleep(3000);
        }
    }
})();
