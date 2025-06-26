# Hello App

A basic Flutter application with a clean architecture following Flutter Bloc guidelines.

## Features

- Clean project structure with separation of concerns
- Custom theming with light/dark mode support
- Reusable widget components
- Bootstrap pattern for app initialization
- Material 3 design system

## Project Structure

```
lib/
├── core/
│   ├── config/          # Global configs and constants
│   ├── errors/          # Global error classes/exceptions
│   ├── platform/        # Platform-specific integrations
│   ├── router/          # Navigation setup
│   ├── theme/           # ThemeData, color schemes, text styles
│   └── utils/           # Helpers, extensions, converters
├── features/
│   └── home/
│       └── presentation/
│           ├── pages/   # Home page screens
│           └── widgets/ # Home-specific widgets
├── shared/
│   └── widgets/         # Reusable UI components
├── bootstrap.dart       # App initialization
└── main.dart           # Entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.32.4 or later)
- Dart SDK
- Chrome (for web development)
- Android Studio/VS Code

### Installation

1. Clone the repository
2. Navigate to the project directory:
   ```bash
   cd hello_app
   ```
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run -d chrome
   ```

## Architecture

This project follows a clean architecture pattern with:

- **Core**: Contains cross-cutting concerns like theming, configuration, and utilities
- **Features**: Contains feature-specific code organized by domain
- **Shared**: Contains reusable components used across multiple features

## Theming

The app uses a custom theme system with:
- Material 3 design
- Light and dark theme support
- Consistent color schemes and typography
- Responsive design principles

## Development Guidelines

- Use `const` constructors wherever possible
- Follow the established folder structure
- Create reusable widgets for common UI patterns
- Use `Theme.of(context)` for consistent styling
- Prefer composition over inheritance for widgets

## Contributing

1. Follow the established project structure
2. Write clean, documented code
3. Test your changes
4. Follow Dart style guidelines
