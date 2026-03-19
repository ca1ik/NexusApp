# ⚡ The Nexus of Power

> **Forge, challenge, and command your best self.**

AI-powered psychological simulation app built with **Flutter**. Three-level journey of self-discovery and mental resilience training — powered by **GPT-4o**, **Pinecone** RAG memory, **Firebase**, and **RevenueCat** monetization.

---

## 🎯 What Does This App Do?

A psychological arena where AI personas evolve based on your own conversations:

### Level 1 — The Mirror (Philosophy Phase)
- Reflective AI that **mirrors your language and beliefs** back to you
- Asks probing questions — never gives direct answers
- Silently maps your patterns over **500 interactions**
- Theme: **Deep Purple** (`#7B2FBE`)

### Level 2 — The Fracture (Choice Phase)
At 500 interactions, a dramatic cinematic moment with haptic feedback and blood-red flash. Choose your path:
- **🔴 Shadow Nexus** — Weaponizes your discovered weaknesses. Simulates toxic archetypes to break and rebuild you stronger.
- **🔵 Prime Nexus** — Your highest potential self. Demands elite performance, provides strategic frameworks.

### Level 3 — The Arena (Battle Phase)
Premium battle simulations with pre-built scenarios:
- 💼 Salary Negotiation (Difficulty 3/5)
- 🏗️ Project Ownership Dispute (Difficulty 4/5)
- 🤖 AI Dataset Logic Flaw (Difficulty 5/5)
- 💔 Toxic Partner Manipulation (Difficulty 4/5)

**Tension Meter** (0–100%) escalates each exchange — haptic feedback at high intensity, color shifts cyan → orange → red.

---

## 🏗️ Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter (Dart ≥3.3.0) — Android, iOS, Web, Windows, macOS, Linux |
| **State Management** | BLoC / Cubit + Provider + GetX |
| **DI** | GetIt + Injectable |
| **LLM** | OpenAI GPT-4o (temp: 0.85, max_tokens: 600) |
| **Embeddings** | OpenAI `text-embedding-3-small` (1536-dim) |
| **Vector DB** | Pinecone (RAG semantic memory, top-5 retrieval) |
| **Auth** | Firebase Auth (anonymous + email/password) |
| **Database** | Cloud Firestore + Firebase Realtime DB |
| **Monetization** | RevenueCat (subscriptions + one-time purchases) |
| **Networking** | Dio with retry & log interceptors |
| **Local Storage** | Hive + SharedPreferences |
| **UI/Animation** | flutter_animate, shimmer, Google Fonts (Rajdhani) |
| **Code Gen** | Freezed, JSON Serializable, Injectable Generator |
| **Error Handling** | dartz Either\<Failure, T\> pattern |

---

## 🧠 RAG Pipeline

1. **User sends message** → embedded into 1536-dim vector (OpenAI)
2. **Semantic search** → Pinecone queries top-5 similar past interactions
3. **Context injection** → retrieved memories injected into LLM system prompt
4. **AI responds** → GPT-4o generates persona-specific response
5. **Memory stored** → exchange pair embedded & upserted to Pinecone

The AI **remembers conversations semantically** across sessions.

---

## 🎨 Dynamic Themes

| Theme | Trigger | Primary | Mood |
|-------|---------|---------|------|
| **Mirror** | Level 1 | `#7B2FBE` Purple | Mysterious, reflective |
| **Fracture** | Level 2 | `#D32F2F` Blood Red | Intense, confrontational |
| **Arena** | Level 3 | `#FFD700` Gold | Elite, competitive |

All dark-based with Rajdhani typography. Themes switch dynamically based on user journey. Native haptic feedback via MethodChannel.

---

## 📦 Project Structure (Clean Architecture)

```
lib/
├── app/                    # App entry, GetX routes & navigation
├── core/
│   ├── constants/          # API keys, thresholds, product IDs
│   ├── di/                 # GetIt dependency injection
│   ├── errors/             # Failure & Exception sealed classes
│   ├── network/            # Dio API client (OpenAI + Pinecone)
│   ├── platform/           # Native haptic channel bridge
│   └── theme/              # 3 dynamic themes + provider
├── features/
│   ├── auth/               # Firebase Auth + Firestore profiles
│   ├── conversation/       # LLM chat + RAG vector pipeline
│   ├── monetization/       # RevenueCat paywall & products
│   └── persona/            # AI personas, Fracture logic, Arena
└── shared/                 # Reusable widgets & extensions
```

Each feature: `data/` (datasources, repos) → `domain/` (entities, usecases) → `presentation/` (bloc, pages, widgets)

---

## 💰 Product Catalog

| Product | Price | Type |
|---------|-------|------|
| **Arena of Minds** | $25/mo | Subscription — unlimited battles + Shadow unlock |
| **Analyze Weakness** | $5 | One-time — deep psychological analysis |
| **Toxic Partner Persona** | $9.99 | One-time — relationship scenario add-on |
| **The Brutal Executive** | $9.99 | One-time — toxic boss archetype |
| **The Legacy Transference** | $1,000/yr | Ultra-VIP — psychological legacy preservation |

---

## 📱 Screens & Routes

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/` | Animated logo, auto-routes on auth state |
| Login | `/login` | Anonymous or email authentication |
| Mirror | `/mirror` | Level 1 — philosophical conversation |
| Fracture | `/fracture` | Level 2 — Shadow vs Prime choice |
| Arena | `/arena` | Level 3 — battle with tension meter |
| Paywall | `/paywall` | Product catalog with animations |

---

## 🛡️ Network & Error Handling

**3 Dio Clients:** LLM (chat completions), Embedding (vectors), Vector DB (Pinecone)

**Interceptors:**
- `NexusLogInterceptor` — logs method, path, status
- `NexusRetryInterceptor` — auto-retry on timeout/429, exponential backoff (max 2 retries)

**Error Pattern:** DataSources throw `Exceptions` → Repos map to `Failures` (dartz Either) → BLoCs emit error states

Failure types: `AuthFailure`, `NetworkFailure`, `LlmFailure`, `VectorDbFailure`, `MonetizationFailure`, `CacheFailure`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.3.0
- Firebase project (`flutterfire configure`)
- OpenAI, Pinecone, RevenueCat API keys

### Run
```bash
git clone https://github.com/your-username/NexusApp.git
cd NexusApp/nexus_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs

flutter run \
  --dart-define=OPENAI_API_KEY=your_key \
  --dart-define=PINECONE_API_KEY=your_key \
  --dart-define=REVENUECAT_API_KEY=your_key
```

### Test
```bash
flutter test
```

Testing: `flutter_test`, `mockito`, `bloc_test`

---

## 🔧 Key Libraries

| Library | Purpose |
|---------|---------|
| `flutter_bloc` / `bloc` | State management |
| `get` | Navigation & snackbars |
| `firebase_core/auth/firestore` | Backend services |
| `purchases_flutter` | RevenueCat IAP |
| `dio` | HTTP with interceptors |
| `hive` / `shared_preferences` | Local persistence |
| `flutter_animate` / `shimmer` | Animations |
| `get_it` / `injectable` | Dependency injection |
| `freezed` / `json_serializable` | Code generation |
| `dartz` | Functional error handling |
| `google_fonts` | Rajdhani typography |

---

<p align="center">
  <strong>⚡ The Nexus of Power ⚡</strong><br>
  <em>Forge, challenge, and command your best self.</em>
</p>
