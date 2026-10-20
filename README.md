# Todo Fullstack

A full-stack todo application built while learning how to connect a browser frontend, an Express API, PostgreSQL, Prisma ORM, JWT authentication, and Docker.

This README covers how to run the app, how the pieces fit together, and the problems that came up during development.

## Contents

- [What this project does](#what-this-project-does)
- [Tech stack](#tech-stack)
  - [Supporting libraries](#supporting-libraries)
- [Project structure](#project-structure)
- [How the application works](#how-the-application-works)
- [Run with Docker Compose](#run-with-docker-compose)
  - [Prerequisites](#prerequisites)
  - [Configure environment variables](#1-configure-environment-variables)
  - [Start the application](#2-start-the-application)
- [Why Docker was useful](#why-docker-was-useful)
  - [Docker networking lesson](#a-docker-networking-lesson)
  - [Docker volume lesson](#a-docker-volume-lesson)
- [PostgreSQL and Prisma](#postgresql-and-prisma)
  - [The database schema](#the-database-schema)
  - [Prisma commands](#prisma-commands)
  - [Why the Prisma client setup looks different](#why-the-prisma-client-setup-looks-different)
- [API reference](#api-reference)
  - [Register](#register)
  - [Login](#login)
  - [List todos](#list-todos)
  - [Create a todo](#create-a-todo)
  - [Complete a todo](#complete-a-todo)
  - [Delete a todo](#delete-a-todo)
- [Challenges solved while building this project](#challenges-solved-while-building-this-project)
  - [Duplicate Prisma relation field](#1-duplicate-prisma-relation-field)
  - [Prisma connection URL warning](#2-prisma-connection-url-warning)
  - [Prisma package version mismatch](#3-prisma-package-version-mismatch)
  - [Prisma 7 runtime client](#4-prisma-7-runtime-client)
  - [Generated files hidden by a Docker bind mount](#5-generated-files-hidden-by-a-docker-bind-mount)
  - [PostgreSQL started after the app](#6-postgresql-started-after-the-app)
  - [Missing database tables](#7-missing-database-tables)
  - [Frontend submit appeared to do nothing](#8-frontend-submit-appeared-to-do-nothing)
  - [PostgreSQL volume path](#9-postgresql-volume-path)
- [Local development without Docker](#local-development-without-docker)
- [Deployment notes](#deployment-notes)
- [Security notes before publishing](#security-notes-before-publishing)
- [Useful commands](#useful-commands)
- [What I learned](#what-i-learned)

## What this project does

- Serves a browser-based todo interface.
- Registers users and hashes passwords with `bcryptjs`.
- Authenticates users with JSON Web Tokens.
- Gives every new user a default todo.
- Stores users and todos in PostgreSQL.
- Uses Prisma for the database schema and queries.
- Runs the Node.js app and PostgreSQL database together with Docker Compose.
- Protects todo routes with authentication middleware.

## Tech stack

The app has a browser frontend, a Node.js API, a PostgreSQL database, and a Docker-based development environment.

<table>
  <tr>
    <td align="center" width="180">
      <img src="https://cdn.simpleicons.org/nodedotjs/339933" alt="Node.js logo" height="52">
      <br><strong>Node.js</strong><br>
      <img src="https://img.shields.io/badge/Node.js-runtime-339933?logo=nodedotjs&logoColor=white" alt="Node.js badge">
    </td>
    <td align="center" width="180">
      <img src="https://cdn.simpleicons.org/express/000000" alt="Express logo" height="52">
      <br><strong>Express</strong><br>
      <img src="https://img.shields.io/badge/Express-API-000000?logo=express&logoColor=white" alt="Express badge">
    </td>
    <td align="center" width="180">
      <img src="https://cdn.simpleicons.org/postgresql/4169E1" alt="PostgreSQL logo" height="52">
      <br><strong>PostgreSQL</strong><br>
      <img src="https://img.shields.io/badge/PostgreSQL-database-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL badge">
    </td>
    <td align="center" width="180">
      <img src="https://cdn.simpleicons.org/prisma/2D3748" alt="Prisma logo" height="52">
      <br><strong>Prisma</strong><br>
      <img src="https://img.shields.io/badge/Prisma-ORM-2D3748?logo=prisma&logoColor=white" alt="Prisma badge">
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="https://cdn.simpleicons.org/docker/2496ED" alt="Docker logo" height="52">
      <br><strong>Docker</strong><br>
      <img src="https://img.shields.io/badge/Docker-containers-2496ED?logo=docker&logoColor=white" alt="Docker badge">
    </td>
    <td align="center">
      <img src="https://cdn.simpleicons.org/dockercompose/2496ED" alt="Docker Compose logo" height="52">
      <br><strong>Docker Compose</strong><br>
      <img src="https://img.shields.io/badge/Compose-local%20stack-2496ED?logo=docker&logoColor=white" alt="Docker Compose badge">
    </td>
    <td align="center">
      <img src="https://cdn.simpleicons.org/javascript/F7DF1E" alt="JavaScript logo" height="52">
      <br><strong>JavaScript</strong><br>
      <img src="https://img.shields.io/badge/JavaScript-frontend-F7DF1E?logo=javascript&logoColor=black" alt="JavaScript badge">
    </td>
    <td align="center">
      <img src="https://cdn.simpleicons.org/jsonwebtokens/000000" alt="JWT logo" height="52">
      <br><strong>JWT</strong><br>
      <img src="https://img.shields.io/badge/JWT-authentication-000000?logo=jsonwebtokens&logoColor=white" alt="JWT badge">
    </td>
  </tr>
</table>

### Supporting libraries

| Technology | Why it is used | Badge |
| --- | --- | --- |
| `@prisma/adapter-pg` | PostgreSQL driver adapter for the Prisma client | ![Prisma adapter badge](https://img.shields.io/badge/Prisma%20adapter-PostgreSQL-2D3748?logo=prisma&logoColor=white) |
| `bcryptjs` | Password hashing before storage | ![bcryptjs badge](https://img.shields.io/badge/bcryptjs-password%20hashing-F7DF1E?logo=javascript&logoColor=black) |
| HTML | Page structure and accessible form controls | ![HTML badge](https://img.shields.io/badge/HTML-markup-E34F26?logo=html5&logoColor=white) |
| CSS | Layout, colors, and responsive styling | ![CSS badge](https://img.shields.io/badge/CSS-styling-1572B6?logo=css3&logoColor=white) |

## Project structure

```text
todo-fullstack/
├── Dockerfile
├── docker-compose.yaml
├── package.json
├── package-lock.json
├── prisma.config.ts
├── prisma/
│   ├── schema.prisma
│   └── migrations/
├── public/
│   ├── index.html
│   ├── fanta.css
│   └── styles.css
└── src/
    ├── db.js
    ├── prismaClient.js
    ├── server.js
    ├── middleware/
    │   └── authMiddleware.js
    └── routes/
        ├── authRoutes.js
        └── todoRoutes.js
```

The generated Prisma client is written to `src/generated/prisma`. It is generated code and is ignored by Git.

## How the application works

The browser loads the frontend from the same Express server that handles the API:

```text
Browser
   │
   ├── GET /
   ├── POST /auth/register
   ├── POST /auth/login
   └── /todos requests with an Authorization header
          │
          ▼
      Express app
          │
          ▼
       Prisma client
          │
          ▼
      PostgreSQL
```

After login or registration, the browser stores the JWT in `localStorage`. Todo requests send that token in the `Authorization` header. The authentication middleware verifies the token and places the user ID on `req.userId`.

## Run with Docker Compose

### Prerequisites

Install:

- Docker Desktop
- Git, if cloning the project

Make sure Docker Desktop is running before using Compose.

### 1. Configure environment variables

Create `todo-fullstack/.env`:

```env
JWT_SECRET=replace-this-with-a-long-random-secret
PORT=5000
DATABASE_URL=postgresql://postgres:postgres@db:5432/todoapp
```

The `db` hostname is important inside Docker Compose. It is the Compose service name, not `localhost`.

Do not commit `.env`. It contains secrets and is ignored by `.gitignore`.

### 2. Start the application

From inside the `todo-fullstack` directory:

```bash
docker compose up --build
```

Open:

```text
http://localhost:5000
```

Run in the background instead:

```bash
docker compose up --build -d
```

Check container status:

```bash
docker compose ps
```

View logs:

```bash
docker compose logs -f app
docker compose logs -f db
```

Stop the containers:

```bash
docker compose down
```

Stop the containers and delete the PostgreSQL data volume:

```bash
docker compose down -v
```

Use `down -v` only when you intentionally want to erase the local database.

## Why Docker was useful

Before Docker, the app and database depended on local machine setup. PostgreSQL had to be installed, started, configured, and given the correct database and credentials.

Docker solved that by describing the environment as code:

- The `app` service builds from the `Dockerfile`.
- The `db` service uses the official `postgres:13-alpine` image.
- Compose gives the services a shared network.
- The app reaches PostgreSQL at `db:5432`.
- A named volume keeps database data after containers stop.
- The PostgreSQL health check prevents the app from starting before the database is ready.

### A Docker networking lesson

Inside the app container, this is correct:

```env
DATABASE_URL=postgresql://postgres:postgres@db:5432/todoapp
```

From your Windows host, `db` is not a resolvable hostname. Host tools should use `localhost:5432` instead.

### A Docker volume lesson

The Compose file bind-mounts the source code into `/app` for convenient development. That mount can hide generated files created while building the image. The container startup command therefore runs Prisma generation again after the mount is active.

The anonymous `/app/node_modules` volume prevents the host project from hiding the container's Linux dependencies.

## PostgreSQL and Prisma

### The database schema

The Prisma schema contains two related models:

```text
User 1 ──── many Todo
```

Each todo has a `userId`, so users can only read and modify their own todos.

The database connection URL is intentionally not kept in `schema.prisma`. Current Prisma versions support putting the connection URL in `prisma.config.ts`:

```ts
datasource: {
  url: env("DATABASE_URL"),
}
```

This keeps schema structure separate from environment-specific connection details.

### Prisma commands

Generate the client:

```bash
npx prisma generate
```

Validate the schema:

```bash
npx prisma validate
```

Inspect the database in Prisma Studio:

```bash
npx prisma studio
```

Create a migration during development:

```bash
npx prisma migrate dev --name describe-your-change
```

Apply committed migrations in production:

```bash
npx prisma migrate deploy
```

The current Docker development command uses `prisma db push` so a fresh local database receives the schema automatically. `db push` is convenient for learning and prototyping, but production deployments should use committed migrations with `prisma migrate deploy`.

### Why the Prisma client setup looks different

The project uses the current Prisma client generator:

```prisma
generator client {
  provider = "prisma-client"
  output   = "../src/generated/prisma"
}
```

The generated client is imported from that output directory, and PostgreSQL is connected through `PrismaPg`. This is why the project does not use the older default `@prisma/client` import alone.

## API reference

### Register

```http
POST /auth/register
Content-Type: application/json

{
  "username": "student@example.com",
  "password": "password123"
}
```

Returns a JWT and creates a default todo.

### Login

```http
POST /auth/login
Content-Type: application/json

{
  "username": "student@example.com",
  "password": "password123"
}
```

### List todos

```http
GET /todos
Authorization: <jwt>
```

### Create a todo

```http
POST /todos
Authorization: <jwt>
Content-Type: application/json

{
  "task": "Learn Docker volumes"
}
```

### Complete a todo

```http
PUT /todos/:id
Authorization: <jwt>
Content-Type: application/json

{
  "completed": true
}
```

### Delete a todo

```http
DELETE /todos/:id
Authorization: <jwt>
```

The `todo-app.rest` file contains request examples for REST clients that support `.rest` files.

## Challenges solved while building this project

### 1. Duplicate Prisma relation field

The `Todo` model originally declared `userId` twice: once as an integer and once as a relation. Prisma needs both a scalar foreign key and a differently named relation field:

```prisma
userId Int
user   User @relation(fields: [userId], references: [id])
```

The routes use the integer `userId`, while Prisma uses `user` for relation metadata.

### 2. Prisma connection URL warning

Newer Prisma versions can reject a datasource URL directly inside the schema. The fix was to:

- Remove `url = env("DATABASE_URL")` from `schema.prisma`.
- Add `prisma.config.ts`.
- Load the URL with `env("DATABASE_URL")`.
- Keep the secret in `.env` or the deployment platform's environment settings.

### 3. Prisma package version mismatch

The project initially had Prisma CLI 5 and `@prisma/client` 7. Mixing major versions creates confusing generation and runtime behavior. Both packages are now kept on the same major version.

### 4. Prisma 7 runtime client

The current generated client requires the PostgreSQL adapter. The application creates Prisma with:

```js
const adapter = new PrismaPg({
    connectionString: process.env.DATABASE_URL
})
const prisma = new PrismaClient({ adapter })
```

The generated TypeScript client is executed with `tsx`.

### 5. Generated files hidden by a Docker bind mount

The source mount:

```yaml
- .:/app
```

can hide generated files that were created during the image build. Prisma generation is run again in the container startup command so the mounted project has the generated client available.

### 6. PostgreSQL started after the app

`depends_on` alone does not mean PostgreSQL is ready to accept connections. The Compose file uses a `pg_isready` health check and waits for the `healthy` condition before starting the app.

### 7. Missing database tables

Starting PostgreSQL creates the database server, but it does not automatically create application tables. The development container runs:

```bash
npx prisma db push
```

That applies the schema to a fresh local database. For production, use migrations instead.

### 8. Frontend submit appeared to do nothing

The frontend declared `textError` but later referenced an undefined `error` variable. That JavaScript exception happened before the request was sent. Fixing the variable allowed login and signup requests to reach the API.

Signup also attempted to send more than one response. Returning the successful response fixed the `headers already sent` problem.

### 9. PostgreSQL volume path

The PostgreSQL data directory must be:

```text
/var/lib/postgresql/data
```

A typo in that path can make persistence behave unexpectedly.

## Local development without Docker

Docker is the recommended path because it supplies PostgreSQL. If running the Node app directly on the host:

1. Install and start PostgreSQL locally.
2. Create the `todoapp` database.
3. Set `DATABASE_URL` to a host-accessible URL:

```env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/todoapp
```

4. Install dependencies:

```bash
npm install
```

5. Generate the client and apply the schema:

```bash
npx prisma generate
npx prisma db push
```

6. Start the development server:

```bash
npm run dev
```

## Deployment notes

The current Docker Compose setup is intended for local development. Vercel does not run `docker compose up` as a persistent production service.

For the current Express-and-container architecture, a container platform such as Render, Railway, Fly.io, or Northflank is a better fit:

1. Create a managed PostgreSQL database.
2. Deploy the app using the `Dockerfile`.
3. Set `DATABASE_URL`, `JWT_SECRET`, and `NODE_ENV=production`.
4. Use the managed database's complete PostgreSQL connection string.
5. Use `prisma migrate deploy` during deployment rather than `prisma db push`.

The local Compose hostname `db` will not work on a hosted platform. Replace it with the complete URL provided by the managed database service.

## Security notes before publishing

- Never commit `.env`.
- Use a long random `JWT_SECRET` in production.
- Do not use `your_jwt_secret_key` outside local learning.
- Do not expose real database passwords in README files, Compose files, screenshots, or API examples.
- Use HTTPS in production.
- Add request validation before treating this as a production application.
- Consider rate limiting login and registration endpoints.
- Use secure cookie-based sessions or carefully review local storage token risks for a public application.

## Useful commands

```bash
# Start in the foreground
docker compose up --build

# Start in the background
docker compose up --build -d

# See all services
docker compose ps

# Follow application logs
docker compose logs -f app

# Open a shell in the app container
docker compose exec app sh

# Run Prisma validation in the container
docker compose exec app npx prisma validate

# Stop services
docker compose down

# Remove containers and database data
docker compose down -v
```

## What I learned

The main steps in building this project were:

1. Build an Express server.
2. Serve a frontend from the backend.
3. Add REST endpoints.
4. Add authentication and password hashing.
5. Replace an in-memory or SQLite-style approach with PostgreSQL.
6. Model relationships with Prisma.
7. Containerize the application.
8. Coordinate an app container and a database container.
9. Debug environment variables, generated code, networking, volumes, and startup order.
10. Prepare the app for deployment on a container platform.

When something appears to do nothing, check the browser console, network request, application logs, database logs, environment variables, and container status in that order.
