# Backend Context

## Tech Stack
- Runtime: [Node.js/Bun]
- Framework: [Express/Fastify/Hono]
- Database: [PostgreSQL/MongoDB]
- ORM: [Prisma/Drizzle]

## API Endpoints
| Method | Path | Auth | Request | Response |
|--------|------|------|---------|----------|
| POST | /auth/login | No | {email,pass} | {token} |
| GET | /users/me | Yes | - | User |

## Environment
```
PORT=3001
DATABASE_URL=...
JWT_SECRET=[REDACTED]
```

## Recent Changes
- [date]: [change]
