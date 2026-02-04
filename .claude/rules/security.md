# Security Rules

## NEVER
- Hardcode secrets
- Commit .env files
- Use eval()
- Trust unvalidated input

## ALWAYS
- Use environment variables
- Validate all inputs
- Use parameterized queries
- Hash passwords (bcrypt, cost≥10)
