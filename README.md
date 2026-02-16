# Currency Converter App

A real-time currency converter mobile app built with Flutter, featuring live exchange rates, multi-currency simultaneous conversion, and locale-aware formatting.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)

## About the Project

Currency Converter App fetches live exchange rates from the HG Brasil Finance API and lets you convert between multiple currencies simultaneously. Type a value in any currency field and all others update instantly.

### Features

- **Live Exchange Rates** — Real-time data from HG Brasil Finance API
- **Multi-Currency Conversion** — Convert between 10+ currencies at once (USD, EUR, GBP, JPY, BTC, BRL, ARS, CAD, AUD, CNY)
- **Locale-Aware Formatting** — BRL uses comma decimals, JPY has no decimals, BTC shows 8 decimal places
- **Dynamic Currency List** — Add or remove currencies on the fly (minimum 2)
- **Persistent Preferences** — Your active currency selections are saved locally
- **Smart Input Formatting** — Automatic thousands separators and decimal handling as you type
- **Light & Dark Theme** — Material Design 3 theming that follows your system preference
- **Error Handling** — Network error display with retry functionality

## Screenshots

| Home Screen | Add Currency | Dark Mode |
|:-----------:|:------------:|:---------:|
| <img width="320" height="480" alt="home" src="https://github.com/user-attachments/assets/e1d660d6-531d-4c52-b698-c259821fdf9c" /> | <img width="320" height="480" alt="add_currency" src="https://github.com/user-attachments/assets/16f7067c-39ac-46ef-8789-05fbc509aae1" /> | <img width="320" height="480" alt="dark_mode" src="https://github.com/user-attachments/assets/9890d821-5f76-4336-8581-6253f2527376" />

## Built With

| Technology | Purpose |
|---|---|
| **Flutter** 3.0+ | Cross-platform mobile framework |
| **Dart** | Programming language |
| **flutter_riverpod** | State management (StateNotifier pattern) |
| **Dio** | HTTP client for API requests |
| **GetIt** | Dependency injection / service locator |
| **dartz** | Functional programming (`Either` type for error handling) |
| **SharedPreferences** | Local data persistence |
| **Equatable** | Value equality for domain entities |
| **HG Brasil Finance API** | Real-time exchange rate data |
| **Material Design 3** | UI design system |

## Architecture

The project follows **Clean Architecture** with clear layer separation:

```
lib/
├── core/                          # Shared utilities, theme, constants, error types
├── features/currency_converter/
│   ├── data/                      # API data sources, local cache, models, repository impl
│   ├── domain/                    # Entities, repository interfaces, use cases
│   └── presentation/             # Riverpod providers, screens, widgets
├── injection_container.dart       # GetIt dependency registration
└── main.dart                      # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.0 or higher ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio (for Android) or Xcode (for iOS)

### Installation

```bash
# Clone the repository
git clone https://github.com/EvansHenriq/currency-converter-app.git
cd currency-converter-app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

No API key is needed — the HG Brasil Finance endpoint used is public.

## Challenges & Solutions

### 1. Real-Time Multi-Field Conversion Without Feedback Loops

When the user types in one currency field, all other fields must update simultaneously. This creates a risk of circular updates — field A updates field B, which triggers an update back to field A, and so on.

**Solution:** An `_isUpdating` flag in the converter screen acts as a guard. When a conversion is triggered, the flag prevents listener callbacks from firing recursive updates until the current batch completes.

### 2. Locale-Aware Currency Formatting

Different currencies have different formatting rules: BRL uses comma as decimal separator with 2 decimal places, JPY has zero decimals, and BTC requires 8 decimal places. Handling input parsing and output formatting across all these rules is non-trivial.

**Solution:** Built two dedicated classes — `CurrencyFormatter` (handles parsing and display formatting per currency) and `CurrencyTextInputFormatter` (a `TextInputFormatter` subclass that formats in real-time as the user types, extracting digits and reapplying separators on each keystroke).
