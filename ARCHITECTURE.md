# "Explain This Simply" - MVP Architecture

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS App (SwiftUI)                     │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │   Home   │  │  Result  │  │  History │  │   Share  │  │
│  │   View   │→ │   View   │  │   View   │  │ Extension│  │
│  └────┬─────┘  └──────────┘  └──────────┘  └────┬──────┘  │
│       │                                           │          │
│       └───────────┐       ┌──────────────────────┘          │
│                   │       │                                 │
│            ┌──────▼───────▼──────┐                          │
│            │  ViewModels         │                          │
│            │  (ObservableObject) │                          │
│            └──────┬───────────────┘                          │
│                   │                                           │
│            ┌──────▼───────────────┐                          │
│            │  Service Layer      │                          │
│            │  - ExplainService    │                          │
│            │  - HistoryService    │                          │
│            │  - OfflineQueue      │                          │
│            └──────┬───────────────┘                          │
│                   │                                           │
│            ┌──────▼───────────────┐                          │
│            │  Networking Layer    │                          │
│            │  (URLSession)        │                          │
│            └──────┬───────────────┘                          │
│                   │                                           │
│            ┌──────▼───────────────┐                          │
│            │  Local Storage       │                          │
│            │  (SwiftData/JSON)    │                          │
│            └──────────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ HTTPS POST
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Supabase Edge Function (/explain)               │
├─────────────────────────────────────────────────────────────┤
│  1. Request Validation (zod/manual)                          │
│  2. Rate Limiting (by deviceId/clientId)                     │
│  3. Input Length Check (2,000-4,000 chars)                   │
│  4. Abuse Filtering (light)                                  │
│  5. Prompt Building (system + mode-specific)                │
│  6. AI Provider Call (key from env)                          │
│  7. Output Token Capping                                     │
│  8. Response Structuring                                     │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ API Key (env)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  AI Provider (OpenAI/Anthropic)             │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

1. **User Input**: User pastes text → selects mode → taps "Explain"
2. **Client Validation**: Check text length, mode validity
3. **Network Request**: POST to `/explain` with request payload
4. **Backend Processing**:
   - Validate request
   - Check rate limit
   - Build prompt
   - Call AI provider
   - Structure response
5. **Response Handling**: Parse JSON → update UI
6. **Offline Fallback**: If network fails → save to queue → retry later

## API Contract

### POST /explain

**Request:**
```json
{
  "text": "string (max 4000 chars)",
  "mode": "simple" | "bullets" | "actions" | "eli12",
  "safetyContextToggle": boolean,
  "clientId": "string (device identifier)",
  "appVersion": "string"
}
```

**Success Response (200):**
```json
{
  "summary": "One sentence summary",
  "bullets": ["bullet 1", "bullet 2", ...],
  "actionItems": ["action 1", "action 2", "action 3"],
  "questions": ["question 1", "question 2"],
  "warnings": ["warning 1"] // optional
}
```

**Error Responses:**

**400 Validation Error:**
```json
{
  "error": "validation_error",
  "message": "Text exceeds maximum length of 4000 characters",
  "field": "text"
}
```

**429 Rate Limited:**
```json
{
  "error": "rate_limited",
  "message": "Rate limit exceeded. Try again tomorrow.",
  "retryAfter": 86400
}
```

**500 Provider Error:**
```json
{
  "error": "provider_error",
  "message": "AI service temporarily unavailable"
}
```

**503 Server Error:**
```json
{
  "error": "server_error",
  "message": "Internal server error"
}
```

**Offline Hint (iOS client-side):**
- Network unavailable → save to queue
- Show friendly message: "No internet connection. Your request will be processed when you're back online."

## Security & Cost Controls

1. **Input Character Limit**: 2,000-4,000 chars (configurable)
2. **Output Token Cap**: ~500 tokens (short responses)
3. **Rate Limiting**: 10 requests/day per deviceId
4. **Logging**: Log request metadata (length, mode, timestamp) but NOT full text
5. **API Key**: Stored in Supabase env vars, never in client

## Data Model

### Local-First History (MVP)

**Why local-first?**
- No auth required for v1
- Faster UX (instant load)
- Works offline
- Privacy-friendly

**SwiftData Model (iOS 17+):**
```swift
@Model
class Explanation {
    var id: UUID
    var inputText: String
    var mode: String
    var summary: String
    var bullets: [String]
    var actionItems: [String]
    var questions: [String]
    var createdAt: Date
    var isFavorite: Bool
}
```

**Alternative (iOS < 17):**
- JSON file in Documents directory
- Simple array of Explanation structs
- Codable for persistence

### Server-Side (Future - Optional)

If we add server-side history later:
```sql
CREATE TABLE explanations (
  id UUID PRIMARY KEY,
  device_id TEXT NOT NULL,
  input_length INTEGER,
  mode TEXT,
  created_at TIMESTAMP,
  -- Don't store full text for privacy
  summary_preview TEXT
);

-- RLS: Users can only see their own explanations
ALTER TABLE explanations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own explanations" ON explanations
  FOR SELECT USING (device_id = current_setting('app.device_id'));
```

## Project Structure

### iOS App
```
simpli/
├── App/
│   └── simpliApp.swift
├── Views/
│   ├── HomeView.swift
│   ├── ResultView.swift
│   └── HistoryView.swift
├── ViewModels/
│   ├── HomeViewModel.swift
│   ├── ResultViewModel.swift
│   └── HistoryViewModel.swift
├── Models/
│   ├── Explanation.swift
│   ├── ExplainRequest.swift
│   ├── ExplainResponse.swift
│   └── ExplanationMode.swift
├── Services/
│   ├── ExplainService.swift
│   ├── HistoryService.swift
│   └── OfflineQueueService.swift
├── Networking/
│   ├── APIClient.swift
│   └── Configuration.swift
├── Utils/
│   └── Extensions.swift
└── Resources/
    └── Assets.xcassets/
```

### Supabase Edge Function
```
supabase/
└── functions/
    └── explain/
        ├── index.ts
        ├── types.ts
        ├── validation.ts
        ├── rateLimit.ts
        ├── promptBuilder.ts
        └── README.md
```

## Prompt Strategy

### System Prompt (Base)
```
You are a helpful assistant that explains complex topics simply. 
Rules:
- Do not invent details; if unclear, say what's missing.
- Be concise and accurate.
- Follow the requested format strictly.
- If the user indicates this is legal/medical/financial content, 
  include: "This isn't professional advice."
```

### Mode-Specific Prompts

**Simple:**
```
Explain the following in plain English with no jargon: {text}
Provide: 1) One sentence summary, 2) 5-8 key points, 3) 3 action items, 4) Questions to ask next.
```

**Bullets:**
```
Convert the following into clear bullet points: {text}
Provide: 1) One sentence summary, 2) 5-8 bullet points, 3) 3 action items, 4) Questions to ask next.
```

**Actions:**
```
Extract actionable steps from: {text}
Provide: 1) One sentence summary, 2) 5-8 key points, 3) 3-5 action items, 4) Questions to ask next.
```

**ELI12:**
```
Explain this like the user is 12 years old: {text}
Use friendly, short sentences. Provide: 1) One sentence summary, 2) 5-8 key points, 3) 3 action items, 4) Questions to ask next.
```

## Testing Plan

### Unit Tests
- `PromptBuilder`: Test mode-specific prompt generation
- `ResponseParser`: Test JSON parsing and error handling
- `OfflineQueue`: Test queue operations (add, retry, clear)

### Integration Tests
- `/explain` happy path
- Rate limit enforcement
- Validation error responses
- Network failure handling

### UI Tests
- Paste text → select mode → explain → result renders
- Copy/share functionality
- Offline message display
