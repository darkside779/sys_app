App Structure
1. Authentication

Firebase Authentication (Email/Password, or Phone if needed).

Roles:

Admin → Can add/edit/delete delivery data.

User → Can view their assigned deliveries/orders.

2. Firestore Database Structure

(Cloud Firestore is better than Realtime DB for this case)

Collections & Documents:

users (collection)
  userId (document)
    name: string
    role: string ("admin" | "user")
    phone: string
    language: string ("ar" | "en")
    createdAt: timestamp

delivery_companies (collection)
  companyId (document)
    name: string
    address: string
    contact: string
    createdAt: timestamp

drivers (collection)
  driverId (document)
    name: string
    phone: string
    companyId: reference (delivery_companies/companyId)
    createdAt: timestamp

orders (collection)
  orderId (document)
    companyId: reference (delivery_companies/companyId)
    driverId: reference (drivers/driverId)
    customerName: string
    customerAddress: string
    date: timestamp
    cost: number
    orderNumber: string
    state: string ("Received" | "Returned" | "Not returned")
    note: string (optional)
    createdBy: reference (users/userId)
    createdAt: timestamp

3. App Navigation

Splash Screen (detects user language + login status)

Authentication

Login / Register (with language switch option)

Admin Screens

Dashboard (summary of orders, stats)

Manage Companies (Add/Edit/Delete delivery companies)

Manage Drivers (Assign to company, edit, delete)

Manage Orders (Add/Edit/Delete, update status, notes)

Reports (filter orders by date, company, driver, status)

User Screens

My Orders (list view, filter by status/date)

Order Details (with state, cost, driver info, notes)

Profile (update language preference, contact info)

4. Multilingual Support (Arabic/English)

Use Flutter’s intl package for localization.

Store language preference in user profile (users.language).

Right-to-Left (RTL) support for Arabic.

Example:

English: "Order Received"

Arabic: "تم استلام الطلب"

5. Order Status Workflow

Order created → State defaults to "Received".

Admin can update to:

"Returned"

"Not returned"

6. Optional Enhancements

Push Notifications (Firebase Cloud Messaging): Notify users when order status changes.

Analytics (Firebase Analytics): Track usage, completed/returned orders.



lib/
│
├── main.dart                # App entry point
│
├── app/
│   ├── app.dart             # MaterialApp setup, routes, localization
│   ├── router.dart          # App navigation routes
│   ├── theme.dart           # Colors, fonts, styles
│
├── services/
│   ├── auth_service.dart    # Firebase Auth (login, register, logout)
│   ├── db_service.dart      # Firestore read/write
│   ├── notification_service.dart # (optional) Push notifications
│
├── models/
│   ├── user_model.dart
│   ├── company_model.dart
│   ├── driver_model.dart
│   ├── order_model.dart
│
├── providers/
│   ├── auth_provider.dart   # State management for user session
│   ├── order_provider.dart  # State for orders
│   ├── company_provider.dart
│   ├── driver_provider.dart
│
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │
│   ├── user/
│   │   ├── user_home_screen.dart
│   │   ├── add_order_screen.dart
│   │   ├── my_orders_screen.dart
│   │   ├── order_detail_screen.dart
│   │
│   ├── admin/
│   │   ├── admin_home_screen.dart
│   │   ├── manage_companies_screen.dart
│   │   ├── manage_drivers_screen.dart
│   │   ├── manage_orders_screen.dart
│   │   ├── reports_screen.dart
│
├── widgets/
│   ├── custom_button.dart
│   ├── custom_textfield.dart
│   ├── order_card.dart
│   ├── company_card.dart
│   ├── driver_card.dart
│
├── localization/
│   ├── app_localizations.dart    # intl setup
│   ├── en.json                   # English strings
│   ├── ar.json                   # Arabic strings
│
└── utils/
    ├── constants.dart            # Static values (states, etc.)
    ├── helpers.dart              # Helper functions (format date, etc.)


