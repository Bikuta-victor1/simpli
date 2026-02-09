# Explain Edge Function

This Supabase Edge Function handles explanation requests from the iOS app, validates input, enforces rate limits, and calls the AI provider.

## Local Development

### Prerequisites

1. Install Supabase CLI:
   ```bash
   brew install supabase/tap/supabase
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   supabase link --project-ref YOUR_PROJECT_REF
   ```

### Setup

1. Set environment variables (secrets):
   ```bash
   supabase secrets set AI_API_KEY=your_openai_or_anthropic_key_here
   supabase secrets set AI_PROVIDER=openai
   ```
   
   Or for Anthropic:
   ```bash
   supabase secrets set AI_API_KEY=your_anthropic_key_here
   supabase secrets set AI_PROVIDER=anthropic
   ```

2. Run locally:
   ```bash
   supabase functions serve explain
   ```

3. Test the function:
   ```bash
   curl -X POST http://localhost:54321/functions/v1/explain \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_ANON_KEY" \
     -d '{
       "text": "This is a test text that needs to be explained simply.",
       "mode": "simple",
       "safetyContextToggle": false,
       "clientId": "test-client-123",
       "appVersion": "1.0"
     }'
   ```

## Deploy

Deploy to Supabase:
```bash
supabase functions deploy explain
```

## Environment Variables

Set these in Supabase Dashboard → Project Settings → Edge Functions → Secrets:

- `AI_API_KEY`: Your OpenAI or Anthropic API key
- `AI_PROVIDER`: "openai" or "anthropic"

## Rate Limiting

- **Limit**: 10 requests per day per `clientId` (device)
- **Window**: 24 hours
- **Storage**: In-memory (resets on function restart)
- **Production**: Consider using Redis or Supabase database for persistent rate limiting

## Input Limits

- **Min length**: 10 characters
- **Max length**: 4,000 characters
- **Output tokens**: 500 (configurable via `MAX_OUTPUT_TOKENS`)

## Supported Modes

- `simple`: Plain English explanation
- `bullets`: Bullet point format
- `actions`: Action-oriented format
- `eli12`: Explain Like I'm 12 (friendly, simple)

## Error Responses

- `400`: Validation error (text too long/short, invalid mode)
- `429`: Rate limit exceeded
- `500`: Server error or AI provider error
