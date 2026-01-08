const { Kafka } = require("kafkajs");

// Kafka configuration variables
function must(name, value) {
    if (!value || !String(value).trim()) {
        throw new Error(`Missing environment variable: ${name}`);
    }
    return String(value).trim();
}

const broker = must("KAFKA_BROKER_URL", process.env.KAFKA_BROKER_URL);
const topic = must("KAFKA_TOPIC", process.env.KAFKA_TOPIC);
const groupId = must("KAFKA_CONSUMER_GROUP", process.env.KAFKA_CONSUMER_GROUP);

// Simple retry helper (useful during Kafka startup)
async function retry(fn, retries = 10, delayMs = 1000) {
    let lastError;
    for (let i = 0; i < retries; i++) {
        try {
            return await fn();
        } catch (err) {
            lastError = err;
            await new Promise((resolve) => setTimeout(resolve, delayMs));
        }
    }
    throw lastError;
}

async function main() {
    // Create Kafka client
    const kafka = new Kafka({
        clientId: "demo-consumer",
        brokers: [broker],
    });

    // Create Kafka consumer in the group
    const consumer = kafka.consumer({ groupId });

    // Connect to the Kafka broker
    await consumer.connect();
    console.log(`connected to broker ${broker}`);

    // Subscribe to the topic (retry handles metadata race on startup)
    await retry(() =>
        consumer.subscribe({ topic, fromBeginning: true })
    );
    console.log(`Subscribed to topic ${topic}`);

    // Start consuming messages
    await consumer.run({
        eachMessage: async ({ topic, partition, message }) => {
            const value = message.value?.toString() || "";

            console.log("---");
            console.log(`topic=${topic} partition=${partition} offset=${message.offset}`);
            console.log(`value=${value}`);
        },
    });
}

main().catch((err) => {
    console.error("Fatal error:", err);
    process.exit(1);
});
