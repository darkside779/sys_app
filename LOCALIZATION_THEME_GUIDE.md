# Localization & Theme Guide

## Overview
This Flutter delivery system app now includes comprehensive internationalization (i18n) support for English and Arabic languages, along with a complete theme system that supports both light and dark modes with RTL (Right-to-Left) layout support.

## 🌍 Internationalization Features

### Supported Languages
- **English (en)** - Left-to-Right (LTR)
- **Arabic (ar)** - Right-to-Left (RTL)

### Files Structure
```
lib/
├── localization/
│   └── app_localizations.dart     # Main localization configuration
assets/
└── localization/
    ├── en.json                    # English translations
    └── ar.json                    # Arabic translations
```

### Usage Examples

#### Basic Text Translation
```dart
// Using the extension method
Text(context.tr.welcome)
Text(context.tr.login)
Text(context.tr.orders)

// Using the traditional method
Text(AppLocalizations.of(context)!.welcome)
```

#### Common Translations Available
- Authentication: `login`, `logout`, `register`, `password`, etc.
- Navigation: `home`, `back`, `next`, `menu`, `close`
- Actions: `save`, `delete`, `edit`, `add`, `search`, `filter`
- Orders: `orders`, `orderNumber`, `customerName`, `orderStatus`
- Companies: `companies`, `companyName`, `deliveryCompanies`
- Drivers: `drivers`, `driverName`, `assignDriver`
- Status messages: `success`, `error`, `loading`, `networkError`

## 🎨 Theme System

### Theme Features
- **Material Design 3** compliance
- **Light and Dark mode** support
- **RTL layout** support for Arabic
- **Consistent color scheme** across the app
- **Custom button styles** for different purposes
- **Form input styling** with proper focus states

### Color Palette
```dart
// Primary Colors
primaryColor: Color(0xFF2196F3)      // Blue
secondaryColor: Color(0xFF03DAC6)    // Teal

// Status Colors
successColor: Color(0xFF4CAF50)      // Green
warningColor: Color(0xFFFF9800)      // Orange
errorColor: Color(0xFFF44336)        // Red
infoColor: Color(0xFF2196F3)         // Blue
```

### Custom Button Styles
```dart
// Usage examples
ElevatedButton(
  style: AppTheme.primaryButtonStyle,
  onPressed: () {},
  child: Text('Primary Action'),
)

ElevatedButton(
  style: AppTheme.successButtonStyle,
  onPressed: () {},
  child: Text('Success Action'),
)

ElevatedButton(
  style: AppTheme.errorButtonStyle,
  onPressed: () {},
  child: Text('Delete'),
)
```

## 🛠️ Common Widgets

### Available Common Widgets
The `CommonWidgets` class provides pre-built, localized components:

#### Localized Buttons
```dart
// Primary button with loading state
CommonWidgets.primaryButton(
  context: context,
  getText: (tr) => tr.save,
  onPressed: () => _saveData(),
  isLoading: _isLoading,
  icon: Icons.save,
)

// Secondary button
CommonWidgets.secondaryButton(
  context: context,
  getText: (tr) => tr.cancel,
  onPressed: () => Navigator.pop(context),
)
```

#### Localized Form Fields
```dart
CommonWidgets.localizedTextFormField(
  context: context,
  getLabel: (tr) => tr.email,
  getHint: (tr) => tr.enterEmail,
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => _validateEmail(value),
  prefixIcon: Icon(Icons.email),
)
```

#### Localized App Bar
```dart
CommonWidgets.localizedAppBar(
  context,
  (tr) => tr.orders,
  actions: [
    CommonWidgets.languageSwitcher(
      context: context,
      onLanguageChanged: _changeLanguage,
    ),
  ],
)
```

#### Localized Dialogs and Snack Bars
```dart
// Show dialog
CommonWidgets.showLocalizedDialog(
  context: context,
  getTitle: (tr) => tr.confirmDelete,
  content: Text(context.tr.areYouSure),
  actions: [
    CommonWidgets.errorButton(
      context: context,
      getText: (tr) => tr.delete,
      onPressed: () => _deleteItem(),
    ),
  ],
);

// Show snack bar
CommonWidgets.showLocalizedSnackBar(
  context: context,
  getMessage: (tr) => tr.dataSaved,
  type: SnackBarType.success,
);
```

## 🔄 RTL Support

### Automatic RTL Detection
The app automatically switches to RTL layout when Arabic is selected:

```dart
// Text direction is automatically set based on locale
Directionality(
  textDirection: _getTextDirection(context),
  child: child!,
)
```

### RTL-Aware Utilities
```dart
// RTL-aware padding
CommonWidgets.rtlPadding(
  context: context,
  child: Text('Content'),
  start: 16,
  end: 8,
)

// RTL-aware alignment
Alignment alignment = AppTheme.getRTLAlignment(
  context, 
  Alignment.centerLeft
);
```

## 🚀 Getting Started

### 1. Install Dependencies
Make sure your `pubspec.yaml` includes:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  provider: ^6.1.1

flutter:
  assets:
    - assets/localization/
```

### 2. Initialize in Main App
```dart
// main.dart is already configured with:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DeliverySystemApp());
}
```

### 3. Use in Your Widgets
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonWidgets.localizedAppBar(
        context,
        (tr) => tr.appName,
      ),
      body: Column(
        children: [
          CommonWidgets.localizedText(
            context,
            (tr) => tr.welcome,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          CommonWidgets.primaryButton(
            context: context,
            getText: (tr) => tr.getStarted,
            onPressed: () => _navigate(),
          ),
        ],
      ),
    );
  }
}
```

## 📱 Language Switching

### Built-in Language Switcher
```dart
// Add to app bar or settings page
CommonWidgets.languageSwitcher(
  context: context,
  onLanguageChanged: (locale) {
    // Update app locale
    _updateLocale(locale);
  },
)
```

### Manual Language Change
```dart
// In your app widget or provider
void _changeLanguage(Locale newLocale) {
  // Update user preference
  userProvider.updateLanguage(newLocale.languageCode);
  
  // Restart app or update state
  setState(() {
    _currentLocale = newLocale;
  });
}
```

## 🎯 Best Practices

### 1. Always Use Localized Strings
```dart
// ✅ Good
Text(context.tr.welcome)

// ❌ Avoid
Text('Welcome')
```

### 2. Use Common Widgets
```dart
// ✅ Good - Consistent styling and localization
CommonWidgets.primaryButton(
  context: context,
  getText: (tr) => tr.save,
  onPressed: _save,
)

// ❌ Avoid - Inconsistent styling
ElevatedButton(
  onPressed: _save,
  child: Text('Save'),
)
```

### 3. Test Both Languages
- Always test your UI in both English and Arabic
- Check for text overflow in Arabic (typically longer)
- Verify RTL layout correctness

### 4. Handle RTL Layouts
- Use `EdgeInsetsDirectional` for padding
- Use `AlignmentDirectional` for alignment
- Test icon positions in RTL mode

## 🔧 Adding New Translations

### 1. Add to JSON Files
```json
// en.json
{
  "new_feature": "New Feature",
  "new_description": "This is a new feature description"
}

// ar.json
{
  "new_feature": "ميزة جديدة",
  "new_description": "هذا وصف للميزة الجديدة"
}
```

### 2. Add to AppLocalizations
```dart
// In app_localizations.dart
String get newFeature => translate('new_feature');
String get newDescription => translate('new_description');
```

### 3. Use in Code
```dart
Text(context.tr.newFeature)
Text(context.tr.newDescription)
```

This comprehensive localization and theme system provides a solid foundation for building a multilingual, accessible Flutter application with professional UI/UX standards.
