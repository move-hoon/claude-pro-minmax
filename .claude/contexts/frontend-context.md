# Frontend Context

## Tech Stack
- Framework: [Next.js/React]
- State: [Zustand/TanStack Query]
- Styling: [Tailwind]

## Components
| Component | Purpose |
|-----------|---------|
| AuthProvider | Auth state |
| ProtectedRoute | Route guard |

## Routes
| Path | Component | Auth |
|------|-----------|------|
| / | Landing | No |
| /dashboard | Dashboard | Yes |

## API
```typescript
const API = process.env.NEXT_PUBLIC_API_URL
headers: { Authorization: `Bearer ${token}` }
```
