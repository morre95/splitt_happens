# Claude Code Prompt — Flutter Receipt Bill Splitter

## Project overview

Build a Flutter mobile app called **Split Happens** that lets users photograph a restaurant receipt, automatically extract line items via OCR, assign items to friends, and calculate how much each person owes. The OCR layer uses Google ML Kit on-device; the parsing layer uses an LLM via OpenRouter to convert raw OCR text into structured JSON.

---

## Tech stack

- **Flutter 3.x**, Dart, Material 3
- **State management:** Riverpod (`flutter_riverpod`, `riverpod_annotation`)
- **OCR:** `google_mlkit_text_recognition` — on-device, offline
- **LLM parsing:** OpenRouter REST API (`https://openrouter.ai/api/v1/chat/completions`) using `http` package — model `google/gemini-flash-1.5` as default (cheap, fast)
- **Local persistence:** `drift` (SQLite) for saving past bills
- **Image handling:** `camera` + `image_picker` + `image` package for pre-processing
- **Code generation:** `freezed`, `json_serializable`, `build_runner`
- **Navigation:** `go_router`
- **PDF export:** `pdf` + `printing`
- **Sharing:** `share_plus`

---

## Project structure to generate

```
lib/
├── main.dart
├── app.dart                         # GoRouter setup, ProviderScope
├── core/
│   ├── constants.dart               # OpenRouter base URL, model name, API key env var
│   └── exceptions.dart              # OcrException, ParseException, NetworkException
├── models/
│   ├── bill.dart                    # Bill, Item, Person, Split — all Freezed + json_serializable
│   └── receipt_parse_result.dart    # Raw LLM output shape
├── services/
│   ├── ocr_service.dart             # ML Kit wrapper: InputImage → raw String
│   ├── image_preprocessor.dart      # Crop, deskew, contrast boost using `image` package
│   ├── receipt_parser_service.dart  # OpenRouter call: raw OCR text → ReceiptParseResult
│   └── split_calculator.dart        # Pure math: assign items → per-person totals with tax/tip proration
├── providers/
│   ├── bill_provider.dart           # BillNotifier: full bill state machine
│   ├── ocr_provider.dart            # FutureProvider wrapping OcrService
│   └── settings_provider.dart       # API key, preferred model, currency
├── database/
│   ├── app_database.dart            # Drift database with Bills, Items, People, Splits tables
│   └── daos/                        # bill_dao.dart, person_dao.dart
└── screens/
    ├── home/
    │   ├── home_screen.dart         # Past bills list + FAB to start new scan
    │   └── bill_card_widget.dart
    ├── scan/
    │   ├── scan_screen.dart         # Camera preview + capture button
    │   └── image_review_widget.dart # Confirm/retake before OCR
    ├── review_items/
    │   ├── review_items_screen.dart # Editable list of parsed items
    │   └── item_edit_tile.dart      # Inline edit: name, qty, price
    ├── people/
    │   ├── people_screen.dart       # Add/remove people for this bill
    │   └── person_chip.dart
    ├── assign/
    │   ├── assign_screen.dart       # Two-column layout: items left, people right
    │   └── assignment_tile.dart     # Checkboxes per person per item
    ├── summary/
    │   ├── summary_screen.dart      # Per-person breakdown + totals
    │   └── person_summary_card.dart
    └── settings/
        └── settings_screen.dart    # OpenRouter API key input, model selector
```

---

## Models (Freezed)

Generate all four core models using `@freezed`. Every model must have `fromJson` / `toJson` via `json_serializable`.

```dart
// Bill — top-level container
Bill { String id, String name, DateTime date, List<Item> items,
       List<Person> people, double taxAmount, double tipAmount,
       String currency }

// Item — a single receipt line
Item { String id, String name, double quantity, double unitPrice }

// Person — a participant in this bill
Person { String id, String name, Color avatarColor }

// Split — which person owns what fraction of which item
Split { String personId, String itemId,
        int portionNumerator, int portionDenominator }
```

---

## OcrService

Implement `OcrService` with a single public method:

```dart
Future<String> extractText(File imageFile)
```

Internally: create an `InputImage` from the file, run `TextRecognizer` with `TextRecognitionScript.latin`, concatenate all `TextBlock.text` values preserving newlines, dispose the recognizer, and return the full string. Wrap errors in `OcrException`.

---

## ImagePreprocessor

Before OCR, pre-process the image using the `image` package:

```dart
Future<File> preprocess(File source)
```

Steps: decode image → auto-crop to the largest high-contrast rectangle (simple luminance threshold) → adjust contrast (+30%) → convert to grayscale → re-encode as JPEG at 90% quality → save to a temp file. This measurably improves ML Kit accuracy on thermal receipt paper.

---

## ReceiptParserService

Implement the OpenRouter call:

```dart
Future<ReceiptParseResult> parse(String ocrText, String apiKey)
```

Build a `POST https://openrouter.ai/api/v1/chat/completions` request with:
- Header `Authorization: Bearer $apiKey`
- Header `HTTP-Referer: Split Happens.app`
- Model: `google/gemini-flash-1.5`
- Temperature: `0.1` (low — we want deterministic extraction)
- System prompt instructing the model to return **only** a JSON object, no markdown fences, no commentary
- User message containing the raw OCR text

The system prompt for the LLM call must be:

```
You are a receipt parser. Extract all purchased items from the raw OCR text of a receipt.
Return ONLY a valid JSON object — no markdown, no explanation, no code fences.
The JSON must match this exact schema:
{
  "items": [{"name": "string", "quantity": number, "unit_price": number}],
  "subtotal": number,
  "tax": number,
  "tip": number,
  "total": number
}
Rules:
- Expand abbreviated item names to readable English where obvious (e.g. "CHKN SNDWCH" → "Chicken Sandwich").
- quantity defaults to 1 if not shown.
- All prices are plain numbers, no currency symbols.
- If tax, tip, or subtotal are not found, set them to 0.
- Do not include header lines, store name, address, phone number, or payment method lines as items.
```

Parse the response body as JSON, validate that `items` is a non-empty array, and return a `ReceiptParseResult`. Wrap errors in `ParseException` with the raw response body for debugging.

---

## SplitCalculator

Pure stateless class, no async. Key method:

```dart
Map<String, double> calculate({
  required List<Item> items,
  required List<Split> splits,
  required double taxAmount,
  required double tipAmount,
})
```

For each person: sum up `(unitPrice × quantity × portionNumerator / portionDenominator)` for all their splits. Then prorate tax and tip proportionally by each person's subtotal share. Return a map of `personId → finalAmount`. Use `Rational`-style fraction arithmetic (keep numerator/denominator as integers throughout) to avoid floating-point rounding errors accumulating across many items.

Also implement:

```dart
// Verify totals match — use this after parsing
bool validateTotal(ReceiptParseResult result)  // checks items sum ≈ subtotal ± 0.02
```

---

## BillNotifier (Riverpod)

State machine covering these stages: `idle → scanning → reviewing → assigning → summarised`. Expose:

```dart
void startScan(File image)        // triggers OCR + parse pipeline
void updateItem(Item item)        // user edits a line item
void addPerson(String name)
void removePerson(String id)
void assignItem(String itemId, String personId, bool shared)
void setSplit(Split split)
void setTaxTip(double tax, double tip)
AsyncValue<Bill> get currentBill
```

---

## Screens

### Scan screen
Show a live camera preview using the `camera` package. Add a circular capture button. On capture, show a full-screen image preview with "Looks good" / "Retake" buttons. On confirm, show a loading overlay with the message "Reading receipt…" while OCR + LLM parse run in parallel with a timeout of 15 seconds. On error, show a snackbar with a retry button.

### Review items screen
`ListView` of `ItemEditTile` widgets. Each tile shows item name, quantity, and price in inline editable `TextField`s. Add a floating "+" button to add a manual item. Add a swipe-to-delete. Show a summary row at the bottom: parsed subtotal, tax, tip, total — tappable to edit. Validate that item prices sum within ±$0.05 of the subtotal; if not, show a yellow warning banner above the list.

### Assign screen
Two-pane layout. Left: scrollable list of items with name and price. Right: for each item, a row of avatar chips (one per person) that toggle selected/unselected. A selected chip means that person shares this item. If multiple people are selected for one item, show a small fraction badge (e.g. "½"). Add a "Split equally" button in the AppBar that assigns all items to all people.

### Summary screen
Card per person showing their assigned items as a sub-list, their subtotal, their share of tax and tip, and their **total in large bold text**. Show a grand total at the bottom. Two action buttons: "Share as text" (uses `share_plus` to share a plain-text breakdown) and "Export PDF" (generates a simple PDF using the `pdf` package and opens it with `printing`).

### Settings screen
A `TextField` for the OpenRouter API key (obscured, with show/hide toggle). A `DropdownButton` for model selection offering at minimum: `google/gemini-flash-1.5`, `openai/gpt-4o-mini`, `anthropic/claude-haiku-4-5`. Persist settings using `SharedPreferences` via the `settings_provider`.

---

## Drift database schema

```sql
CREATE TABLE bills (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, date INTEGER NOT NULL,
  tax_amount REAL NOT NULL DEFAULT 0, tip_amount REAL NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'USD'
);
CREATE TABLE items (
  id TEXT PRIMARY KEY, bill_id TEXT NOT NULL REFERENCES bills(id),
  name TEXT NOT NULL, quantity REAL NOT NULL, unit_price REAL NOT NULL
);
CREATE TABLE people (
  id TEXT PRIMARY KEY, bill_id TEXT NOT NULL REFERENCES bills(id),
  name TEXT NOT NULL, avatar_color INTEGER NOT NULL
);
CREATE TABLE splits (
  id TEXT PRIMARY KEY, bill_id TEXT NOT NULL,
  item_id TEXT NOT NULL, person_id TEXT NOT NULL,
  portion_numerator INTEGER NOT NULL, portion_denominator INTEGER NOT NULL
);
```

---

## Error handling rules

- Every `Future` in a service must have a typed catch that wraps the error in a domain exception (`OcrException`, `ParseException`, `NetworkException`).
- Never swallow errors silently. Always propagate to the provider.
- In the UI, use `AsyncValue.when` and show an `ErrorWidget` with a retry callback on error states.
- Add a 15-second timeout on the OpenRouter HTTP call. If it times out, surface a message: "Parsing timed out. Check your connection or try a different model."

---

## Code quality requirements

- All public methods and classes must have dartdoc comments.
- Run `flutter analyze` with zero warnings before considering a file done.
- Use `const` constructors wherever possible.
- No `BuildContext` stored across async gaps — use `mounted` checks.
- The `SplitCalculator` must have unit tests in `test/split_calculator_test.dart` covering: equal split, unequal split, tax proration, tip proration, and the edge case where one person takes all items.

---

## pubspec.yaml dependencies to include

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  google_mlkit_text_recognition: ^0.13.1
  camera: ^0.11.0
  image_picker: ^1.1.2
  image: ^4.2.0
  http: ^1.2.1
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  go_router: ^14.2.7
  shared_preferences: ^2.3.1
  pdf: ^3.10.8
  printing: ^5.13.1
  share_plus: ^10.0.2
  uuid: ^4.4.0

dev_dependencies:
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  drift_dev: ^2.18.0
  flutter_test:
    sdk: flutter
```

---

## First steps for Claude Code

1. Replace `pubspec.yaml` with the dependencies above
2. Run `flutter pub get`
3. Generate the full directory structure above with all files stubbed
4. Implement models first (run `dart run build_runner build` after)
5. Implement services in order: `ImagePreprocessor` → `OcrService` → `ReceiptParserService` → `SplitCalculator`
6. Set up Drift database
7. Implement Riverpod providers
8. Implement screens in navigation order
9. Write unit tests for `SplitCalculator`
10. Run `flutter analyze` and fix all warnings
