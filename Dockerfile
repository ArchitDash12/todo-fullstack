# Use an official node.js runtime as a parent image
FROM node:24-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json .

# Install dependencies before the schema is copied into the image
RUN npm install --ignore-scripts

# Copy the rest of the application code to the working directory
COPY . .

# Generate the Prisma client used by the application
RUN npx prisma generate

# Expose the port the app runs on
EXPOSE 5000

# Generate the client after the Compose bind mount is applied, then start the app
CMD ["sh", "-c", "npx prisma generate && npx prisma db push && npx tsx ./src/server.js"]