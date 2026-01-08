const { Kafka } = require("kafkajs");

// Kafka configuration variables
const broker = process.env.KAFKA_BROKER;
const topic = process.env.KAFKA_TOPIC;
const groupId = process.env.KAFKA_CONSUMER_GROUP;

async function main() {
    // Create Kafka client
    const kafka = new Kafka({ clientId: "demo-consumer", brokers: [broker] });
    // Create Kafka consumer in the group
    const consumer = kafka.consumer({ groupId });

    // Connect to the Kafka broker
    await consumer.connect();
    console.log(`connected to broker ${broker}`);

    // Subscribe to the topic
    await consumer.subscribe({ topic, fromBeginning: true });
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
    console.error("Error:", err);
    process.exit(1);
});
