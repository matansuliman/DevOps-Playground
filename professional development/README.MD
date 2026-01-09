# DevOps Home Assignment

A minimal full-stack environment that integrates **Node.js**, **TiDB**, **TiCDC**, and **Kafka** (CDC pipeline).  
The backend writes to TiDB, TiCDC streams changes to Kafka, and a consumer prints database change events to the console.

---

## ✅ Prerequisites

- Docker
- Docker Compose v2

---

## 🔧 Environment Variables

1. Copy the example env file:

```bash
cp .env.example .env
```

(Windows PowerShell)

```powershell
Copy-Item .env.example .env
```

2. (Optional) Edit `.env` to adjust ports, topic name, or credentials.

---

## 🚀 Quick Start

Start everything with a single command:

```bash
docker compose up --build
```

Stop:

```bash
docker compose down
```

---

## 🔗 Services

| Service      | URL                  | Description        |
|-------------|-----------------------|--------------------|
| Frontend    | http://localhost:8080 | Login interface    |
| Backend API | http://localhost:3000 | REST API           |

---

## 🔑 Default Credentials

- **Username:** `admin`
- **Password:** `1234`

---

## 🧱 Architecture

**Flow:**

1. User logs in via **Frontend**
2. Frontend calls **Backend API**
3. Backend writes auth data (tokens/users) to **TiDB**
4. **TiCDC** captures DB changes and publishes them to **Kafka**
5. **Consumer** reads Kafka messages and logs change events to stdout (JSON)

**Pipeline:**

```
Frontend → Backend → TiDB → TiCDC → Kafka → Consumer
```

---

## 🧪 Useful Commands

View logs:

```bash
docker compose logs -f backend
docker compose logs -f consumer
docker compose logs -f ticdc
```

List Kafka topics (inside the kafka container):

```bash
docker exec -it kafka kafka-topics --bootstrap-server kafka:9092 --list
```

Check TiCDC changefeeds:

```bash
docker exec -it ticdc /cdc cli changefeed list --server=http://ticdc:8300
```

---

## ✅ Expected Output

After a successful login, you should see:

- Backend logs a `LOGIN` event (JSON)
- Consumer logs `DB_CHANGE` events (JSON) from TiCDC