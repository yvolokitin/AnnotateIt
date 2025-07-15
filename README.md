# AnnotateIt
AnnotateIt Vision Annotation Platform

AnnotateIt Project Structure
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
 +-- presentation/        # UI Layer
 ¦   +-- pages/           # Pages
 ¦   +-- widgets/         # Reusable widgets
 ¦   +-- utils/           # File utils
 ¦
 +-- main.dart            # Entry point of the application
