# Producer → TiDB → TiCDC → Kafka → Consumer (Docker + Node.js)

This repo is a minimal, **realistic CDC (Change Data Capture)** example that shows how a database can be the **source of truth**, while Kafka is used as the **event bus**.

---

## 🧠 What you’re building

A small end‑to‑end pipeline:

1. **Producer (Node.js)** inserts rows into a **TiDB** table
2. **TiCDC** watches TiDB for changes and publishes them into **Kafka**
3. **Consumer (Node.js)** subscribes to the Kafka topic and prints the events

---

## 🏗 Architecture

```text
Producer (Node.js)
   │  INSERT rows
   ▼
TiDB (MySQL-compatible)
   │  CDC stream (changefeed)
   ▼
TiCDC
   │  publish (canal-json)
   ▼
Kafka topic (demo-topic)
   │  consume
   ▼
Consumer (Node.js)
```

---

## 🧱 Services (Docker Compose)

### Kafka
- Kafka broker used as the message bus
- Topic used in this demo: **`demo-topic`**

### TiDB cluster (PD + TiKV + TiDB)
- **PD**: placement driver / cluster metadata
- **TiKV**: storage engine
- **TiDB**: SQL layer (MySQL protocol, port `4000`)

### TiCDC
- CDC engine that creates a **changefeed** from TiDB to Kafka
- Sink URI is configured to Kafka with **`protocol=canal-json`**

### ticdc-init (one-shot)
- Creates the changefeed once, after Kafka + TiCDC are ready  
  (If it already exists, it should be a no-op depending on TiCDC behavior.)

### Producer (Node.js)
- Connects to TiDB (MySQL protocol)
- Ensures DB + table exist
- Inserts a new row every ~1 second

### Consumer (Node.js)
- Subscribes to Kafka topic `demo-topic`
- Prints each consumed message

---

## 📦 Message format

TiCDC publishes messages using **`canal-json`** format (configured in the changefeed sink URI).
So the consumer receives JSON payloads representing row-level changes.

> Tip: The consumer in this repo prints the raw message value.  
> You can extend it to parse JSON and implement real processing.

---

## ✅ Prerequisites

- Docker
- Docker Compose

---

## 🚀 Run

```bash
docker compose up --build
```

---

## 🔎 Verify it works

### 1) Producer: rows are inserted into TiDB
```bash
docker compose logs -f producer
```

You should see logs like:
- “Connected to MySQL…”
- “Table 'user_events' is ready.”
- “Inserted event into DB: …”

### 2) TiCDC: changefeed is created
```bash
docker compose logs -f ticdc-init
```

You should see it creating the changefeed (id `demo`) with sink to Kafka topic `demo-topic`.

### 3) Consumer: events arrive from Kafka
```bash
docker compose logs -f consumer
```

You should see messages printed with topic / partition / offset and the JSON value.

---

## 🛠 Useful commands

### See running containers
```bash
docker compose ps
```

### Recreate everything from scratch (including volumes)
```bash
docker compose down -v
docker compose up --build
```

### Optional: Connect to TiDB with a MySQL container

```bash
docker exec -it mysql mysql -h tidb -P 4000 -u root
```

Then:
```sql
SHOW DATABASES;
USE demo;
SELECT * FROM user_events ORDER BY id DESC LIMIT 10;
```

---

## 🧯 Troubleshooting

### TiDB is “unhealthy”
- Check logs:
  ```bash
  docker compose logs -f tidb
  ```
- If the cluster was left in a bad state, reset:
  ```bash
  docker compose down -v
  docker compose up --build
  ```

### Consumer starts but sees no events
- Make sure `ticdc-init` succeeded (changefeed exists)
- Ensure producer is inserting rows
- Verify the topic name matches:
  - consumer env: `KAFKA_TOPIC=demo-topic`
  - TiCDC sink URI uses `/demo-topic`
