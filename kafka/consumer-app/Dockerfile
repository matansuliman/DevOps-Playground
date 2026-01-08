FROM node:20-alpine

WORKDIR /app

# Copy dependencies
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev

# Copy application code
COPY . .

# Start the application
CMD ["node", "/app/consumer.js"]
