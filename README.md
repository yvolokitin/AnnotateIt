# VAP
Vision Annotation Platform

VAP Project Structure
lib/
 +-- core/                # Core utilities and shared components
 ¦   +-- constants/       # App-wide constants
 ¦   +-- error/           # Error handling and exceptions
 ¦   +-- network/         # API clients, HTTP services
 ¦   +-- usecases/        # Business logic (Use Cases)
 ¦   +-- utils/           # Helpers, formatters, converters
 ¦
 +-- data/                # Data layer (Repositories, Models, Data sources)
 ¦   +-- datasources/     # Remote and Local Data sources
 ¦   ¦   +-- local/       # Local DB operations
 ¦   ¦   +-- remote/      # API clients and network requests
 ¦   +-- models/         # DTOs and data models
 ¦   +-- repositories/   # Repository implementations
 ¦
 +-- domain/              # Business logic (Entities, Repositories, UseCases)
 ¦   +-- entities/        # Core business models
 ¦   +-- repositories/    # Repository contracts (Interfaces)
 ¦   +-- usecases/        # Business logic, interactors
 ¦
 +-- presentation/        # UI Layer
 ¦   +-- screens/         # Screens and pages
 ¦   +-- widgets/         # Reusable widgets
 ¦   +-- providers/       # State management (Riverpod, Provider, Bloc, etc.)
 ¦
 +-- main.dart            # Entry point of the application
 +-- routes.dart          # App-wide navigation management
 +-- injection.dart       # Dependency injection setup (GetIt)
