# HealthPin 📍

**HealthPin** is a community-driven health resource mapping application designed to provide real-time access to vital health services. Built with Flutter and Supabase, it empowers users to discover, verify, and contribute to a global map of clinics, pharmacies, and emergency services.

---

## 🌟 Key Features

### 🗺️ Interactive Resource Map
- **Real-time Discovery**: Locate nearby clinics, hospitals, and pharmacies on an interactive map.
- **Dynamic Filtering**: Filter resources by category (Emergency, Pharmacy, Clinic, etc.).
- **Proximity Sorting**: View resources automatically sorted by distance from your current location.

### ➕ Resource Management
- **Community Contributions**: Add new health resources with photos, location data, and contact info.
- **Verification System**: Verified badges for trusted locations to ensure data accuracy.
- **Upvote/Community Trust**: Users can upvote resources to indicate availability and service quality.

### 🔍 Enhanced Search
- **Unified Experience**: Consistent, high-performance search interface across both map and list views.
- **Detailed Insights**: View opening hours, contact details, and precise addresses for every pinned location.

### 👤 User Experience
- **Premium Design System**: Adheres to the "Humanitarian Ground System" with a focus on high contrast, warm aesthetics, and clear typography.
- **Seamless Navigation**: Smooth transitions between Map, List, Dashboard, and Profile views.

---

## 🛠️ Technology Stack

- **Frontend**: [Flutter](https://flutter.dev/) (Dart)
- **Backend**: [Supabase](https://supabase.com/) (Database, Auth, Storage)
- **Maps**: [flutter_map](https://pub.dev/packages/flutter_map) with Leaflet-based logic
- **Location**: [geolocator](https://pub.dev/packages/geolocator) for precise GPS data
- **Theming**: Custom design system using [Google Fonts](https://pub.dev/packages/google_fonts) (Space Grotesk & Work Sans)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.10.8)
- Dart SDK (^3.0.0)
- A Supabase account and project

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/AdityaJandu/health-pin.git
   cd health-pin
   ```

2. **Setup Environment Variables**:
   Create a `.env` file in the root directory and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 📂 Project Highlights

The project follows a modular, component-based architecture to ensure maintainability and scalability:
- **Global Components**: Reusable UI elements like `EnhancedSearchBar` and `PrimaryButton`.
- **Feature-Based UI**: Separated logic for `Auth`, `Home`, `Resources`, and `Dashboard`.
- **Centralized Theming**: Unified `AppTheme` for consistent brand identity.
- **Service Layer**: Decoupled business logic for Auth, Database, and Location services.

---

## 🤝 Contributing

We welcome contributions from the community! Feel free to open issues or submit pull requests to help improve health resource accessibility for everyone.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
