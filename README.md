# VAP
Vision Annotation Platform

VAP Project Structure
lib/
 +-- core/                # Core utilities and shared components
    +-- constants/       # App-wide constants
    +-- error/           # Error handling and exceptions
    +-- network/         # API clients, HTTP services
    +-- usecases/        # Business logic (Use Cases)
    +-- utils/           # Helpers, formatters, converters
 
 +-- data/                # Data layer (Repositories, Models, Data sources)
    +-- datasources/     # Remote and Local Data sources
       +-- local/       # Local DB operations
       +-- remote/      # API clients and network requests
    +-- models/         # DTOs and data models
    +-- repositories/   # Repository implementations
 
 +-- domain/              # Business logic (Entities, Repositories, UseCases)
    +-- entities/        # Core business models
    +-- repositories/    # Repository contracts (Interfaces)
    +-- usecases/        # Business logic, interactors
 
 +-- presentation/        # UI Layer
    +-- screens/         # Screens and pages
    +-- widgets/         # Reusable widgets
    +-- providers/       # State management (Riverpod, Provider, Bloc, etc.)
 
 +-- main.dart            # Entry point of the application
 +-- routes.dart          # App-wide navigation management
 +-- injection.dart       # Dependency injection setup (GetIt)


## 🛠️ Drift Code Generation

To generate the necessary `.g.dart` files for Drift, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```


---

## 🛠️ Drift Code Generation (Updated)

To generate the necessary `.g.dart` files for Drift, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

For continuous generation during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```


---

## 📄 Licenses

This project uses the following open-source libraries:

### 🧩 Drift
- [Drift](https://drift.simonbinder.eu) is used for local database management.
- Licensed under the MIT License.
- Copyright (c) Simon Binder

### 🌱 Riverpod
- [Riverpod](https://riverpod.dev) is used for state management and dependency injection.
- Licensed under the MIT License.
- Copyright (c) Remi Rousselet
