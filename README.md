# Daily Planner 📱

A beautiful, mindful mobile app built with Flutter for managing daily tasks and organizing thoughts across categories.

## ✨ Features

### 🏠 Daily Checklist
- **Fresh Start Daily**: Only today's tasks displayed on home screen
- **Time-Based Organization**: Left column shows time slots, right column shows tasks
- **Smart Task Entry**: Auto-fills current time when adding tasks
- **Automatic Sorting**: Tasks automatically arranged by time
- **Date Navigation**: Swipe left/right to view previous/next dates
- **Real-Time Clock**: Live clock display in header
- **Personalized Greeting**: "Hello, Username" in top right

### 📁 Categories System
- **Flexible Organization**: Create custom categories (Notes, Learnings, Books, etc.)
- **Color Coding**: Each category has a custom color
- **Rich Content**: Add/edit/delete content within each category
- **Timestamp Tracking**: Creation and edit timestamps for all entries
- **Visual Grid**: Beautiful grid layout for category overview

### 🔍 Search & Navigation
- **Global Search**: Search across all tasks and categories
- **Calendar Integration**: Pick any date to view that day's tasks
- **Intuitive Navigation**: Easy menu-based navigation

### 📄 Monthly PDF Reports
- **Auto-Generation**: Automatically creates monthly PDFs on the last day of each month
- **Comprehensive Content**: 
  - Daily checklists with hourly activities
  - All categories (each starts on new page)
  - Handwritten-style font for diary feel
  - Timestamps, days, and dates for all entries
- **Professional Format**: Clean, organized PDF layout

### 🎨 Beautiful UI/UX
- **Mindful Design**: Soft colors and rounded corners
- **Smooth Animations**: Built-in Flutter animations
- **Clean Interface**: Minimal, easy-to-use design
- **Material Design 3**: Modern UI components

## 🛠️ Technical Stack

- **Framework**: Flutter + Dart
- **Database**: Hive (Local NoSQL database)
- **State Management**: Provider
- **PDF Generation**: `pdf` package
- **Typography**: Custom handwritten fonts
- **Calendar**: `table_calendar` package

## 📂 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── task.dart            # Task model with Hive annotations
│   ├── category.dart        # Category and CategoryEntry models
│   └── user_settings.dart   # User preferences model
├── providers/               # State management
│   ├── task_provider.dart   # Task state management
│   ├── category_provider.dart # Category state management
│   └── search_provider.dart # Search functionality
├── screens/                 # UI Screens
│   ├── home_screen.dart     # Main daily planner screen
│   ├── categories_screen.dart # Categories overview
│   ├── category_detail_screen.dart # Individual category view
│   ├── search_screen.dart   # Search interface
│   ├── calendar_screen.dart # Calendar picker
│   └── settings_screen.dart # App settings
├── widgets/                 # Reusable UI components
│   ├── task_item.dart       # Individual task display
│   ├── category_card.dart   # Category preview card
│   ├── add_task_dialog.dart # Task creation dialog
│   ├── add_category_dialog.dart # Category creation dialog
│   └── app_drawer.dart      # Navigation drawer
├── services/               # Business logic
│   ├── database_service.dart # Hive database operations
│   └── pdf_service.dart     # PDF generation
└── utils/                  # Utilities
    ├── app_theme.dart      # App-wide styling
    └── date_utils.dart     # Date formatting helpers
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.8.1)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

3. **Add handwritten font**
   - Download a handwritten font (e.g., from Google Fonts)
   - Replace `assets/fonts/handwritten.ttf` with your chosen font
   - Recommended fonts: Kalam, Caveat, Dancing Script

4. **Run the app**
   ```bash
   flutter run
   ```

## 📝 Usage Guide

### Daily Planning
1. **Adding Tasks**: Tap the `+` button to add a new task
2. **Completing Tasks**: Tap the checkbox to mark as complete
3. **Navigation**: Swipe left/right to view different dates
4. **Time Selection**: Tasks auto-fill current time, but you can change it

### Category Management
1. **Creating Categories**: Go to Categories → Tap `+` → Choose name and color
2. **Adding Content**: Open a category → Type in the text field → Tap send
3. **Editing**: Long press or use menu options to edit/delete
4. **Organization**: Categories are sorted alphabetically

### Monthly Reports
- PDFs are automatically generated on the last day of each month
- Access via Menu → Monthly Reports
- Share or save PDFs directly from the app

## 🔧 Customization

### Adding New Categories
The app comes with default categories (Notes, Learnings, Books), but you can:
- Add unlimited custom categories
- Choose from 10 predefined colors
- Customize category names and content

### Changing Themes
- Primary color: Indigo (#6366F1)
- Easy to customize in `utils/app_theme.dart`
- Material Design 3 theming system

### PDF Styling
- Modify PDF layout in `services/pdf_service.dart`
- Change fonts, colors, and formatting
- Customize header/footer content

## 🐛 Known Issues & TODos

### Current Limitations
- [ ] No cloud sync (local storage only)
- [ ] Single user support
- [ ] Basic theme options

### Planned Features
- [ ] Dark mode
- [ ] Cloud backup/sync
- [ ] Task templates
- [ ] Weekly/yearly views
- [ ] Reminder notifications
- [ ] Data export/import
- [ ] Multiple user profiles

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Built with ❤️ using Flutter**

*Happy Planning! 📋✨*
