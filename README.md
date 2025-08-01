# AnnotateIt - Vision Annotation Tool
AnnotateIt Vision Annotation Platform

## Features

- **Multiple Annotation Types**: Support for bounding boxes, polygons, and classification annotations
- **Project Management**: Create and manage annotation projects with customizable labels
- **Dataset Import/Export**: Import and export datasets in various formats
- **Google ML Kit Integration**: Automatic image labeling using Google's ML Kit (see [ML Kit documentation](docs/ml_kit_image_labeling.md))

## System Requirements

Please see [SYSTEM_REQUIREMENTS.md](SYSTEM_REQUIREMENTS.md) for detailed information about hardware and software requirements.

## Store Listing

For Microsoft Store submission information, see [STORE_LISTING.md](STORE_LISTING.md).

## Project Structure
lib/
 +-- core/                # Core utilities and shared components
 �   +-- constants/       # App-wide constants
 �   +-- error/           # Error handling and exceptions
 �   +-- network/         # API clients, HTTP services
 �   +-- usecases/        # Business logic (Use Cases)
 �   +-- utils/           # Helpers, formatters, converters
 �
 +-- data/                # Data layer (Repositories, Models, Data sources)
 �   +-- datasources/     # Remote and Local Data sources
 �   �   +-- local/       # Local DB operations
 �   �   +-- remote/      # API clients and network requests
 �   +-- models/         # DTOs and data models
 �   +-- repositories/   # Repository implementations
 �
 +-- presentation/        # UI Layer
 �   +-- pages/           # Pages
 �   +-- widgets/         # Reusable widgets
 �   +-- utils/           # File utils
 �
 +-- main.dart            # Entry point of the application
