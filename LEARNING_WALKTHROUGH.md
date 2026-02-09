# Learning Walkthrough: Understanding Each Component

Let's break down every piece of code and understand WHY it exists and HOW it works.

---

## Step 1: ExplanationMode Enum - The Foundation

**File**: `simpli/Models/ExplanationMode.swift`

### What is an Enum?

An enum (enumeration) is Swift's way of defining a fixed set of related values. Think of it like a menu with only 4 options - you can't order anything else.

```swift
enum ExplanationMode: String, CaseIterable, Identifiable, Codable {
    case simple = "simple"
    case bullets = "bullets"
    case actions = "actions"
    case eli12 = "eli12"
```

### Breaking Down the Syntax:

1. **`enum ExplanationMode`**: We're creating a new type called `ExplanationMode`
2. **`: String`**: This is a "raw value" type. Each case has a string value ("simple", "bullets", etc.)
   - Why? When we send this to the backend API, we need to convert it to a string
3. **`CaseIterable`**: This protocol gives us `.allCases` - a way to loop through all options
   - Why? In our UI, we use `ForEach(ExplanationMode.allCases)` to show all 4 mode buttons
4. **`Identifiable`**: SwiftUI needs this to uniquely identify each item in a list
   - Why? SwiftUI uses `id` to track which view is which when rendering
5. **`Codable`**: Allows automatic conversion to/from JSON
   - Why? When we send requests to the API, Swift automatically converts this to JSON

### The Properties:

```swift
var id: String { rawValue }
```
- **What**: Returns the string value ("simple", "bullets", etc.)
- **Why**: SwiftUI's `Identifiable` requires an `id` property

```swift
var displayName: String {
    switch self {
    case .simple: return "Simple"
    // ...
}
```
- **What**: Returns a user-friendly name
- **Why**: We don't want to show "eli12" to users - we want "Explain Like I'm 12"

```swift
var icon: String {
    switch self {
    case .simple: return "text.bubble"
    // ...
}
```
- **What**: Returns an SF Symbol name (Apple's icon system)
- **Why**: Each mode button needs a visual icon

### Real-World Usage:

```swift
let mode = ExplanationMode.simple
print(mode.displayName)  // "Simple"
print(mode.icon)         // "text.bubble"
print(mode.rawValue)     // "simple" (for API)
```

---

## Step 2: HomeViewModel - The Brain

**File**: `simpli/ViewModels/HomeViewModel.swift`

### What is a ViewModel?

A ViewModel is the "brain" of your view. It holds:
- **State** (what the user has typed, what mode is selected)
- **Business Logic** (can the user explain? is text too long?)
- **Actions** (what happens when user taps "Explain")

### The @Published Properties:

```swift
@Published var inputText: String = ""
@Published var selectedMode: ExplanationMode = .simple
@Published var isExplaining: Bool = false
```

**What is `@Published`?**
- It's a property wrapper from Combine framework
- When these values change, SwiftUI automatically updates the UI
- Think of it like a notification system: "Hey UI, `inputText` changed, redraw yourself!"

**Why separate from the View?**
- Views should be "dumb" - they just display
- ViewModels are "smart" - they contain logic
- This makes code testable and reusable

### Computed Properties (No Storage, Just Logic):

```swift
var characterCount: Int {
    inputText.count
}
```
- **What**: Calculates character count on-the-fly
- **Why**: We don't store this separately - we compute it when needed
- **How**: Every time SwiftUI reads this, it runs `inputText.count`

```swift
var canExplain: Bool {
    !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !isOverLimit
        && !isExplaining
}
```
- **What**: Determines if the "Explain" button should be enabled
- **Why**: We want to disable the button when:
  - Text is empty (after removing spaces)
  - Text is too long
  - Already processing a request
- **How**: This is evaluated every time SwiftUI checks the button state

### The @MainActor Annotation:

```swift
@MainActor
class HomeViewModel: ObservableObject {
```

**What is @MainActor?**
- Ensures all code runs on the main thread
- **Why**: UI updates MUST happen on the main thread in iOS
- **How**: Swift automatically dispatches to the main thread

### The Async Function:

```swift
func explain() async throws -> ExplainResponse {
    // ...
}
```

**Breaking it down:**
- **`async`**: This function can pause and wait (for network calls)
- **`throws`**: This function can fail (network errors, API errors)
- **Why**: Network calls take time - we don't want to freeze the UI

**How it's called:**
```swift
Task {
    await viewModel.explain()
}
```
- `Task` creates an async context
- `await` pauses here until `explain()` completes
- UI stays responsive during the wait

---

## Step 3: HomeView - The Face

**File**: `simpli/Views/HomeView.swift`

### What is a View?

A View is what the user sees. In SwiftUI, views are:
- **Declarative**: You describe WHAT you want, not HOW to draw it
- **Composable**: Small views combine into big views
- **Reactive**: They automatically update when data changes

### The @StateObject:

```swift
@StateObject private var viewModel = HomeViewModel()
```

**What is @StateObject?**
- Creates and owns the ViewModel
- Keeps it alive for the view's lifetime
- **Why**: The view needs the ViewModel to exist

**vs @ObservedObject:**
- `@StateObject`: "I own this, create it"
- `@ObservedObject`: "Someone else owns this, just watch it"
- **Rule**: If you're creating it, use `@StateObject`

### The TextEditor Binding:

```swift
TextEditor(text: $viewModel.inputText)
```

**What is `$`?**
- The `$` creates a "binding" - a two-way connection
- When user types → updates `viewModel.inputText`
- When `viewModel.inputText` changes → updates the TextEditor
- **Why**: We want real-time sync between UI and data

### The Button Action:

```swift
Button {
    Task {
        await viewModel.explain()
    }
} label: {
    // Button appearance
}
```

**Breaking it down:**
- `Button { }`: Action closure (what happens when tapped)
- `Task { }`: Creates async context
- `await`: Waits for the async function
- **Why**: We can't call `async` functions directly from a button

### NavigationDestination:

```swift
.navigationDestination(isPresented: $viewModel.showResult) {
    if let result = viewModel.result {
        ResultView(response: result)
    }
}
```

**What**: Shows ResultView when `showResult` becomes `true`
**How**: SwiftUI watches `showResult` - when it flips to `true`, it pushes ResultView
**Why**: Clean separation - ViewModel controls navigation, View just displays

---

## Step 4: Networking Layer - The Messenger

**File**: `simpli/Networking/APIClient.swift`

### Why a Separate Networking Layer?

- **Separation of Concerns**: Views don't know about HTTP
- **Testability**: Can mock network calls in tests
- **Reusability**: Other services can use the same client

### The URLSession:

```swift
private let session: URLSession
```

**What is URLSession?**
- Apple's networking framework
- Handles HTTP requests/responses
- Manages cookies, caching, authentication

**Why not use a library?**
- URLSession is built-in, no dependencies
- For MVP, it's sufficient
- Can upgrade to Alamofire later if needed

### The Request Building:

```swift
var urlRequest = URLRequest(url: url)
urlRequest.httpMethod = "POST"
urlRequest.allHTTPHeaderFields = Configuration.headers
urlRequest.httpBody = try JSONEncoder().encode(request)
```

**Step by step:**
1. Create request with URL
2. Set method to POST (we're sending data)
3. Add headers (API key, content type)
4. Encode our Swift struct to JSON

**What is JSONEncoder?**
- Converts Swift objects to JSON strings
- `ExplainRequest` is `Codable`, so it knows how to encode itself

### The Async/Await Pattern:

```swift
let (data, response) = try await session.data(for: urlRequest)
```

**What happens:**
1. `session.data()` starts network request
2. `await` pauses here (doesn't block UI)
3. When response arrives, continues
4. Returns `(data, response)` tuple

**Why not completion handlers?**
- Old way: `session.dataTask { data, response, error in ... }`
- New way: `await session.data()` - cleaner, easier to read

### Error Handling:

```swift
if httpResponse.statusCode != 200 {
    // Handle error
}
```

**HTTP Status Codes:**
- `200`: Success
- `400`: Bad request (validation error)
- `429`: Too many requests (rate limited)
- `500`: Server error

**Why throw custom errors?**
- `APIError.rateLimited` is more meaningful than "HTTP 429"
- ViewModel can show user-friendly messages

---

## Step 5: ExplainService - The Coordinator

**File**: `simpli/Services/ExplainService.swift`

### What is a Service?

A service coordinates between:
- ViewModels (who need data)
- Network layer (who fetches data)
- Models (the data itself)

### The Singleton Pattern:

```swift
static let shared = ExplainService()
```

**What**: One instance shared across the app
**Why**: 
- Don't need multiple instances
- Easy access: `ExplainService.shared.explain(...)`
- Can maintain state (like request queue)

**When NOT to use singleton:**
- If you need dependency injection for testing
- If you need multiple instances with different configs

### The Function Signature:

```swift
func explain(
    text: String,
    mode: ExplanationMode,
    safetyContextToggle: Bool
) async throws -> ExplainResponse
```

**Breaking it down:**
- **Input**: What the user provided
- **Output**: What the API returned
- **`async throws`**: Can wait and can fail

**Why this abstraction?**
- ViewModel doesn't need to know about:
  - Device ID generation
  - App version
  - Request building
- Service handles all that complexity

---

## Step 6: Backend - The Supabase Edge Function

**File**: `supabase/functions/explain/index.ts`

### Why Supabase Edge Functions?

- **Serverless**: No server to manage
- **Deno Runtime**: Modern TypeScript runtime
- **Integrated**: Works with Supabase ecosystem
- **Secure**: API keys stay on server

### The Request Flow:

```
iOS App → POST /explain → Edge Function → AI Provider → Edge Function → iOS App
```

**Step by step:**
1. iOS sends request with text + mode
2. Edge Function validates (length, mode, etc.)
3. Edge Function checks rate limit
4. Edge Function builds prompt
5. Edge Function calls AI provider
6. Edge Function parses response
7. Edge Function returns JSON to iOS

### Why Not Call AI Directly from iOS?

**Security:**
- API keys would be in the app (can be extracted)
- No rate limiting control
- No input validation

**Cost Control:**
- Can't limit usage per device
- Can't cap output tokens
- Can't monitor abuse

### The CORS Headers:

```typescript
const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};
```

**What is CORS?**
- Cross-Origin Resource Sharing
- Browsers block requests from different origins by default
- These headers say "it's OK, allow this request"

**Why needed?**
- iOS app makes requests from a different origin
- Without CORS, browser would block it

---

## Step 7: Error Handling - The Safety Net

**File**: `simpli/Networking/APIError.swift`

### Why Custom Errors?

Swift's built-in errors are generic. Custom errors:
- Are more descriptive
- Can carry context (retryAfter, field name)
- Make debugging easier

### The Error Cases:

```swift
case rateLimited(retryAfter: Int?)
case validationError(field: String, message: String)
```

**Why associated values?**
- `rateLimited` can tell us WHEN to retry
- `validationError` can tell us WHICH field failed
- More information = better UX

### Error Propagation:

```
APIClient throws APIError 
  → ExplainService re-throws 
    → HomeViewModel catches 
      → Shows user-friendly message
```

**Why not catch in APIClient?**
- APIClient should just throw - it doesn't know what to do
- ViewModel knows the UI - it can show alerts, disable buttons, etc.

---

## Step 8: Putting It All Together

### The Complete Flow:

1. **User types text** → `HomeView` TextEditor
2. **Text updates** → `$viewModel.inputText` binding
3. **Character count updates** → `characterCount` computed property
4. **Button enables/disables** → `canExplain` computed property
5. **User taps "Explain"** → Button action
6. **ViewModel calls service** → `await viewModel.explain()`
7. **Service builds request** → Adds device ID, app version
8. **APIClient sends HTTP** → POST to Supabase
9. **Edge Function validates** → Checks length, mode, rate limit
10. **Edge Function calls AI** → OpenAI/Anthropic API
11. **Response comes back** → JSON with explanation
12. **APIClient parses** → Converts JSON to `ExplainResponse`
13. **Service returns** → Back to ViewModel
14. **ViewModel updates** → `result` and `showResult = true`
15. **UI navigates** → `navigationDestination` shows `ResultView`

### Why This Architecture?

**Separation of Concerns:**
- View: "What to show"
- ViewModel: "What to do"
- Service: "How to do it"
- Network: "How to communicate"

**Testability:**
- Can test ViewModel with mock service
- Can test service with mock network
- Can test network with mock server

**Maintainability:**
- Change UI? Only touch Views
- Change business logic? Only touch ViewModels
- Change API? Only touch Network layer

---

## Common Questions

### Q: Why @MainActor on ViewModel?
**A**: UI updates must happen on main thread. @MainActor ensures all ViewModel code runs there.

### Q: Why async/await instead of completion handlers?
**A**: Cleaner code, easier error handling, no callback hell.

### Q: Why separate Service from ViewModel?
**A**: ViewModel handles UI state. Service handles business logic. Separation = easier testing.

### Q: Why not use a framework like Alamofire?
**A**: URLSession is sufficient for MVP. Can upgrade later if needed.

### Q: Why TypeScript for backend?
**A**: Supabase Edge Functions use Deno (TypeScript runtime). Can't use Swift on server.

---

## Next Steps

Now that you understand the components:

1. **Try modifying** the character limit
2. **Add a new mode** to ExplanationMode
3. **Change the UI** colors/styling
4. **Add logging** to see the flow
5. **Break something** and see how errors propagate

Want me to walk through any specific part in more detail?
