# Explain This Simply

A SwiftUI iOS app that simplifies complex text using AI. Users can paste text, select an explanation mode, and receive structured explanations with summaries, key points, action items, and questions.

## Features

- 🎯 **Four Explanation Modes**:
  - Simple: Plain English, no jargon
  - Bullet Points: Clear bullet format
  - Action Items: Action-oriented breakdown
  - Explain Like I'm 12: Friendly, simple language

- 🔒 **Security & Cost Controls**:
  - Rate limiting (10 requests/day per device)
  - Input length limits (4,000 characters max)
  - Output token capping (500 tokens)
  - API keys stored securely on backend

- 📱 **Offline Support**:
  - Queue requests when offline
  - Automatic retry when connection restored
  - Friendly offline messaging

- 📚 **Local History** (iOS 17+):
  - Save past explanations
  - SwiftData persistence
  - Quick access to previous results

- 🔗 **Share Extension**:
  - Share text from Safari, Notes, etc.
  - Direct integration with main app

## Architecture

### iOS App (SwiftUI)
- **MVVM Architecture**: ViewModels manage state and business logic
- **Service Layer**: ExplainService, HistoryService, OfflineQueueService
- **Networking**: URLSession-based APIClient
- **Local Storage**: SwiftData (iOS 17+) or JSON fallback

### Backend (Supabase Edge Functions)
- **Deno Runtime**: TypeScript Edge Functions
- **Security**: Rate limiting, input validation, output capping
- **AI Integration**: OpenAI or Anthropic API
- **CORS**: Configured for iOS app requests

## Project Structure

```
simpli/
├── simpli/                          # iOS App
│   ├── Views/                       # SwiftUI Views
│   │   ├── HomeView.swift
│   │   └── ResultView.swift
│   ├── ViewModels/                  # State Management
│   │   ├── HomeViewModel.swift
│   │   └── ResultViewModel.swift
│   ├── Models/                      # Data Models
│   │   ├── ExplanationMode.swift
│   │   ├── ExplainRequest.swift
│   │   └── ExplainResponse.swift
│   ├── Services/                    # Business Logic
│   │   ├── ExplainService.swift
│   │   └── HistoryService.swift
│   ├── Networking/                  # API Layer
│   │   ├── APIClient.swift
│   │   ├── Configuration.swift
│   │   └── APIError.swift
│   └── Utils/
│       └── DeviceID.swift
│
├── supabase/
│   └── functions/
│       └── explain/                 # Edge Function
│           ├── index.ts
│           ├── types.ts
│           ├── validation.ts
│           ├── rateLimit.ts
│           ├── promptBuilder.ts
│           └── README.md
│
├── ARCHITECTURE.md                  # Detailed architecture docs
├── BUILD_GUIDE.md                   # Step-by-step build guide
└── README.md                        # This file
```

## Quick Start

### Prerequisites

1. **Xcode 15.0+** with iOS 17.0+ deployment target (or iOS 16.0+ for JSON storage)
2. **Supabase Account**: [Create one here](https://supabase.com)
3. **AI API Key**: OpenAI or Anthropic API key

### Setup Steps

#### 1. iOS App Configuration

1. Open `simpli.xcodeproj` in Xcode
2. Update `simpli/Networking/Configuration.swift`:
   ```swift
   static let baseURL = "https://YOUR_PROJECT_REF.supabase.co/functions/v1/explain"
   static let supabaseAnonKey = "YOUR_ANON_KEY"
   ```
   (Get these from Supabase Dashboard → Project Settings → API)

3. Build and run: ⌘R

#### 2. Supabase Edge Function Setup

1. Install Supabase CLI:
   ```bash
   brew install supabase/tap/supabase
   ```

2. Login and link project:
   ```bash
   supabase login
   supabase link --project-ref YOUR_PROJECT_REF
   ```

3. Set secrets:
   ```bash
   supabase secrets set AI_API_KEY=your_key_here
   supabase secrets set AI_PROVIDER=openai
   ```

4. Deploy function:
   ```bash
   supabase functions deploy explain
   ```

5. Test locally (optional):
   ```bash
   supabase functions serve explain
   ```

### Testing

1. **Unit Tests**: Run with ⌘U
2. **UI Tests**: Select test scheme and run
3. **Manual Testing**:
   - Paste text in HomeView
   - Select different modes
   - Verify character counter
   - Test offline functionality (Airplane mode)

## Development Guide

See [BUILD_GUIDE.md](./BUILD_GUIDE.md) for detailed step-by-step instructions covering:
- Step 0: Prerequisites & Setup
- Step 1: Basic Home UI
- Step 2-3: Mode selector & Result screen
- Step 4-5: Networking & Backend
- Step 6-7: End-to-end integration
- Step 8-9: Offline & History
- Step 10-12: Share extension & Release

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
- `400`: Validation error
- `429`: Rate limited
- `500`: Server/AI provider error

## Security Considerations

- ✅ API keys stored in Supabase secrets (never in client)
- ✅ Rate limiting per device (10/day)
- ✅ Input length validation (4,000 char max)
- ✅ Output token capping (500 tokens)
- ✅ CORS configured for iOS app
- ✅ No user data stored server-side (MVP)

## Cost Controls

- **Input Limit**: 4,000 characters max
- **Output Tokens**: 500 tokens max
- **Rate Limit**: 10 requests/day per device
- **Model**: Uses cost-effective models (gpt-4o-mini or claude-3-haiku)

## Future Enhancements

- [ ] User authentication (optional)
- [ ] Server-side history sync
- [ ] More explanation modes
- [ ] Export to PDF/Notes
- [ ] Widget support
- [ ] Analytics (privacy-friendly)

## License

[Your License Here]

## Support

For issues or questions, please open an issue on GitHub or contact [your contact info].
