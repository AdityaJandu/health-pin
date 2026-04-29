# Project Structure 🏗️

This document provides a comprehensive, file-by-file overview of the **HealthPin** codebase architecture and directory organization within the main source directory.

## 📁 Root Directory Layout

```text
healthpin/
├── android/              # Android-specific platform code
├── ios/                  # iOS-specific platform code
├── lib/                  # Main application source code (Dart)
├── test/                 # Widget and unit tests
├── web/                  # Web-specific platform configuration
├── assets/               # Static assets (images, icons, etc.)
├── pubspec.yaml          # Project dependencies and configuration
└── README.md             # Project overview
```

---

## 📂 Lib Directory Breakdown (Exhaustive)

The `lib/` directory is organized by functional layer and feature modules to ensure a clean separation of concerns.

### 🚀 Application Entry Point
- `lib/main.dart`: The core entry point of the Flutter application. Initializes services (like Supabase, Geolocator) and runs the root app widget.

### 🧩 `lib/components/`
Contains globally reusable UI components that are shared across multiple features.
- `custom_text_field.dart`: Themed, generic input fields used in forms.
- `enhanced_search_bar.dart`: Unified, globally accessible search interface used in both map and list views.
- `primary_button.dart`: Standard brand-styled CTA button.

### 🎨 `lib/theme/`
Centralized design system configuration.
- `app_theme.dart`: Defines all brand colors (DeepForest, ClayOrange, WarmOffWhite), typography (Google Fonts: Space Grotesk & Work Sans), and global decoration constants.

### 🏗️ `lib/models/`
Data structure definitions (POJOs/Entities).
- `flag_model.dart`: Data structure for content moderation flags.
- `resource_model.dart`: Core health resource data structure (clinics, pharmacies, etc.).
- `resource_type.dart`: Categorization logic and enum structures for resources.
- `upvote_model.dart`: Data structure tracking user interactions and trust scoring.
- `user_model.dart`: Profile and authentication data structure.

### ⚙️ `lib/services/`
Handles business logic and external integrations.
- `auth_service.dart`: Handles user authentication with Supabase.
- `image_service.dart`: Handles photo selection, upload, and processing logic.
- `location_permission_service.dart`: Manages GPS permissions and retrieves the user's current device location.
- `resource_service.dart`: Handles CRUD operations for health pins (fetching, adding, upvoting).
- `user_database_service.dart`: Manages user profile data storage and retrieval.

### 📱 `lib/ui/`
The Presentation Layer, organized by feature module.

#### `lib/ui/auth/`
User onboarding and login flows.
- `auth_gate.dart`: High-level widget that automatically routes users to the dashboard or login screen based on session state.
- **`screens/`**
  - `login_screen.dart`: UI for existing user login.
  - `sign_up_screen.dart`: UI for new user registration.
  - `splash_screen.dart`: Initial loading screen presented on app launch.
- **`widgets/`** (Currently empty or for future auth-specific micro-components).

#### `lib/ui/dashboard/`
The main navigation shell.
- **`screens/`**
  - `dash_board.dart`: The main wrapper screen holding the `BottomNavBar` and managing top-level tab state.
- **`widgets/`**
  - `bottom_nav_bar.dart`: The themed bottom navigation using the `salomon_bottom_bar` package.

#### `lib/ui/home/`
Main dashboard and interactive mapping experience.
- **`screens/`**
  - `home_map_screen.dart`: The primary interactive map interface.
- **`widgets/`**
  - `count_badge.dart`: Small UI component for showing active filter/result counts.
  - `map_icon_button.dart`: Reusable, floating map controls.
  - `map_states.dart`: Loading and error state overlays for the map.
  - `resource_badges.dart`: Reusable indicators (Verified, Distance, Open/Closed, Type, Upvotes).
  - `resource_bottom_sheet.dart`: The draggable sheet showing an expandable list of nearby resources on the map.
  - `resource_card.dart`: A specific card presentation format for resources.
  - `resource_list_item.dart`: The highly modular, primary card view for resources used across the app.
  - `resource_map_view.dart`: Core Map UI rendering pins and handling map-specific gestures.
  - `resource_preview_card.dart`: A condensed resource card meant for quick previews.
  - `resource_search_bar.dart`: Legacy/specific search bar components.
  - `resource_ui_elements.dart`: Larger structural UI elements for resource cards (photo banners, formatted rows).
  - `type_filter_bar.dart`: Horizontal scrollable list for filtering resource types (Emergency, Clinic, etc.).

#### `lib/ui/profile/`
User profile and submission management.
- **`screens/`**
  - `profile_screen.dart`: Main user profile interface displaying stats and submissions.
- **`widgets/`**
  - `profile_header.dart`: User avatar and core info display.
  - `profile_stats_strip.dart`: Horizontal metric display (e.g., number of verified pins, upvotes).
  - `profile_submissions_list.dart`: A specialized list view showing resources added by the current user.

#### `lib/ui/resources/`
Management of resource lists and additions.
- **`screens/`**
  - `add_resource_screen.dart`: The multi-section, complex form for pinning new locations to the map.
  - `list_resource_screen.dart`: A standalone, scrollable, searchable resource discovery screen (alternative to the map).
- **`widgets/`**
  - `location_input_section.dart`: Form component specifically handling GPS coordinate fetching and input.
  - `resource_image_picker.dart`: Specialized UI for capturing/selecting photos during resource creation.
  - `resource_list_header.dart`: The integrated title and search bar for the `list_resource_screen.dart`.
  - `resource_list_states.dart`: Custom shimmer loading skeletons and error/empty states for lists.
  - `resource_list_view.dart`: The `ListView` builder that handles rendering a collection of `ResourceListItem`s.
  - `resource_type_dropdown.dart`: Form component for selecting the resource category.
  - `section_card.dart`: The generic, styled container used for grouping form elements together in `add_resource_screen.dart`.

### 🛠️ `lib/utils/`
Stateless helper functions and formatting logic.
- `resource_utils.dart`: Contains critical business logic for UI, such as calculating whether a resource is currently open based on a complex opening hours string, and string formatting tools.

---

## 🧬 Architectural Principles

1. **Component-Based UI**: UI is broken down into small, modular widgets to maximize reuse and simplify testing. Complex files (like list items or large screens) are systematically broken down into distinct sub-files.
2. **Service Decoupling**: Business logic is abstracted into external services, allowing the UI to remain declarative and focused strictly on presentation.
3. **Reactive State**: Uses Streams and Listeners (primarily via Supabase) to ensure real-time updates and synchronization across different parts of the application.
4. **Theme Consistency**: Absolutely all styling derives from the centralized `AppTheme` class to ensure visual harmony and strict adherence to the "Humanitarian Ground System" design specifications.
