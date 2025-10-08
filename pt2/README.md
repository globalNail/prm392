# GizmoHub Demo

![GizmoHub Demo](assets/images/placeholder.png)

GizmoHub is a Flutter demo app that showcases a Riverpod-powered shopping experience with clean layering, in-memory data, and Vietnamese Đdng currency formatting.

## Features

- **Login** with hardcoded credentials (`demo / 123456`) and error feedback.
- **Product catalog** with responsive grid, debounced search, pull-to-refresh, CRUD, and long-press quick actions.
- **Product details** view with edit/delete, add-to-cart, and semantic-friendly layout.
- **Shopping cart** with quantity management, totals in VND, and success checkout dialog.
- **Profile stub** including logout that resets navigation state.
- **SOLID-friendly architecture** split into core/domain/data/presentation, plus reusable widgets and centralized constants.
- **In-memory repository** backed by `assets/products.json` and local placeholder images (no network calls).

## Project structure

```text
lib/
  app.dart                 # MaterialApp + routing
  main.dart                # Entry point with ProviderScope
  core/                    # Constants, utils, widgets, exceptions
  domain/                  # Entities, repositories, use cases
  data/                    # Datasource, repository implementation, mappers
  presentation/            # Riverpod providers and screens
assets/
  products.json            # Seed catalog (8 demo items)
  images/                  # Placeholder + sample imagery
test/
  data/                    # Repository tests
  presentation/            # Cart controller + widget tests
```

## Getting started

This project targets Flutter stable 3.22 with null safety.

```bash
flutter pub get
flutter run
flutter test
```

## Credentials

- **Username:** `demo`
- **Password:** `123456`

## Testing

- `product_repository_impl_test.dart` validates asset loading and case-insensitive search.
- `cart_controller_test.dart` covers add/update/remove flows and total calculations.
- `product_card_widget_test.dart` ensures the widget renders and triggers callbacks.

Run the full suite with:

```bash
flutter test
```

## Notes

- Currency formatting is centralized in `CurrencyFormatter.vnd` via `intl`.
- Bottom navigation is shared through `AppNavigationBar` for consistency and DRYness.
- Cart totals and product CRUD stay in sync thanks to Riverpod state notifiers.
