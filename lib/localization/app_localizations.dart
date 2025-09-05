import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Delivery System'**
  String get app_name;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @total_orders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get total_orders;

  /// No description provided for @completed_orders.
  ///
  /// In en, this message translates to:
  /// **'Completed Orders'**
  String get completed_orders;

  /// No description provided for @pending_orders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get pending_orders;

  /// No description provided for @today_orders.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Orders'**
  String get today_orders;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @order_number.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get order_number;

  /// No description provided for @customer_name.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customer_name;

  /// No description provided for @customer_address.
  ///
  /// In en, this message translates to:
  /// **'Customer Address'**
  String get customer_address;

  /// No description provided for @order_date.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get order_date;

  /// No description provided for @order_status.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get order_status;

  /// No description provided for @order_details.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_details;

  /// No description provided for @create_order.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get create_order;

  /// No description provided for @update_order.
  ///
  /// In en, this message translates to:
  /// **'Update Order'**
  String get update_order;

  /// No description provided for @delete_order.
  ///
  /// In en, this message translates to:
  /// **'Delete Order'**
  String get delete_order;

  /// No description provided for @order_received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get order_received;

  /// No description provided for @order_returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get order_returned;

  /// No description provided for @order_not_returned.
  ///
  /// In en, this message translates to:
  /// **'Not Returned'**
  String get order_not_returned;

  /// No description provided for @order_note.
  ///
  /// In en, this message translates to:
  /// **'Order Note'**
  String get order_note;

  /// No description provided for @companies.
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get companies;

  /// No description provided for @company_name.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get company_name;

  /// No description provided for @company_address.
  ///
  /// In en, this message translates to:
  /// **'Company Address'**
  String get company_address;

  /// No description provided for @company_phone.
  ///
  /// In en, this message translates to:
  /// **'Company Phone'**
  String get company_phone;

  /// No description provided for @company_email.
  ///
  /// In en, this message translates to:
  /// **'Company Email'**
  String get company_email;

  /// No description provided for @company_details.
  ///
  /// In en, this message translates to:
  /// **'Company Details'**
  String get company_details;

  /// No description provided for @create_company.
  ///
  /// In en, this message translates to:
  /// **'Create Company'**
  String get create_company;

  /// No description provided for @update_company.
  ///
  /// In en, this message translates to:
  /// **'Update Company'**
  String get update_company;

  /// No description provided for @delete_company.
  ///
  /// In en, this message translates to:
  /// **'Delete Company'**
  String get delete_company;

  /// No description provided for @delivery_companies.
  ///
  /// In en, this message translates to:
  /// **'Delivery Companies'**
  String get delivery_companies;

  /// No description provided for @manage_companies.
  ///
  /// In en, this message translates to:
  /// **'Manage Companies'**
  String get manage_companies;

  /// No description provided for @edit_company.
  ///
  /// In en, this message translates to:
  /// **'Edit Company'**
  String get edit_company;

  /// No description provided for @search_companies.
  ///
  /// In en, this message translates to:
  /// **'Search Companies'**
  String get search_companies;

  /// No description provided for @search_companies_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter company name, address, or contact...'**
  String get search_companies_hint;

  /// No description provided for @no_companies_found.
  ///
  /// In en, this message translates to:
  /// **'No companies found matching your search'**
  String get no_companies_found;

  /// No description provided for @no_companies_available.
  ///
  /// In en, this message translates to:
  /// **'No companies available'**
  String get no_companies_available;

  /// No description provided for @contact_info.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contact_info;

  /// No description provided for @enter_contact_info.
  ///
  /// In en, this message translates to:
  /// **'Enter email or phone'**
  String get enter_contact_info;

  /// No description provided for @contact_info_required.
  ///
  /// In en, this message translates to:
  /// **'Contact info is required'**
  String get contact_info_required;

  /// No description provided for @enter_company_name.
  ///
  /// In en, this message translates to:
  /// **'Enter company name'**
  String get enter_company_name;

  /// No description provided for @company_name_required.
  ///
  /// In en, this message translates to:
  /// **'Company name is required'**
  String get company_name_required;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @enter_address.
  ///
  /// In en, this message translates to:
  /// **'Enter company address'**
  String get enter_address;

  /// No description provided for @address_required.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get address_required;

  /// No description provided for @active_company.
  ///
  /// In en, this message translates to:
  /// **'Active Company'**
  String get active_company;

  /// No description provided for @drivers.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get drivers;

  /// No description provided for @driver_name.
  ///
  /// In en, this message translates to:
  /// **'Driver Name'**
  String get driver_name;

  /// No description provided for @driver_phone.
  ///
  /// In en, this message translates to:
  /// **'Driver Phone'**
  String get driver_phone;

  /// No description provided for @driver_email.
  ///
  /// In en, this message translates to:
  /// **'Driver Email'**
  String get driver_email;

  /// No description provided for @driver_license.
  ///
  /// In en, this message translates to:
  /// **'Driver License'**
  String get driver_license;

  /// No description provided for @driver_company.
  ///
  /// In en, this message translates to:
  /// **'Driver Company'**
  String get driver_company;

  /// No description provided for @driver_details.
  ///
  /// In en, this message translates to:
  /// **'Driver Details'**
  String get driver_details;

  /// No description provided for @create_driver.
  ///
  /// In en, this message translates to:
  /// **'Create Driver'**
  String get create_driver;

  /// No description provided for @update_driver.
  ///
  /// In en, this message translates to:
  /// **'Update Driver'**
  String get update_driver;

  /// No description provided for @delete_driver.
  ///
  /// In en, this message translates to:
  /// **'Delete Driver'**
  String get delete_driver;

  /// No description provided for @assign_driver.
  ///
  /// In en, this message translates to:
  /// **'Assign Driver'**
  String get assign_driver;

  /// No description provided for @assign_later.
  ///
  /// In en, this message translates to:
  /// **'Assign later'**
  String get assign_later;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @user_role.
  ///
  /// In en, this message translates to:
  /// **'User Role'**
  String get user_role;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @required_field.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get required_field;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalid_email;

  /// No description provided for @password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_too_short;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @invalid_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalid_phone_number;

  /// No description provided for @network_error.
  ///
  /// In en, this message translates to:
  /// **'Network connection error. Please check your internet connection.'**
  String get network_error;

  /// No description provided for @server_error.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get server_error;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get login_failed;

  /// No description provided for @registration_failed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please try again.'**
  String get registration_failed;

  /// No description provided for @update_failed.
  ///
  /// In en, this message translates to:
  /// **'Update failed. Please try again.'**
  String get update_failed;

  /// No description provided for @delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed. Please try again.'**
  String get delete_failed;

  /// No description provided for @load_data_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data. Please try again.'**
  String get load_data_failed;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get login_success;

  /// No description provided for @registration_success.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registration_success;

  /// No description provided for @update_success.
  ///
  /// In en, this message translates to:
  /// **'Update successful'**
  String get update_success;

  /// No description provided for @delete_success.
  ///
  /// In en, this message translates to:
  /// **'Delete successful'**
  String get delete_success;

  /// No description provided for @data_saved.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully'**
  String get data_saved;

  /// No description provided for @company_created_success.
  ///
  /// In en, this message translates to:
  /// **'Company created successfully'**
  String get company_created_success;

  /// No description provided for @company_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Company updated successfully'**
  String get company_updated_success;

  /// No description provided for @company_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Company deleted successfully'**
  String get company_deleted_success;

  /// No description provided for @operation_failed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. Please try again'**
  String get operation_failed;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get this_week;

  /// No description provided for @this_month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get this_month;

  /// No description provided for @select_date.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get select_date;

  /// No description provided for @select_time.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get select_time;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @user_dashboard.
  ///
  /// In en, this message translates to:
  /// **'User Dashboard'**
  String get user_dashboard;

  /// No description provided for @driver_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Driver Dashboard'**
  String get driver_dashboard;

  /// No description provided for @view_orders_manage_profile.
  ///
  /// In en, this message translates to:
  /// **'View your orders and manage your profile'**
  String get view_orders_manage_profile;

  /// No description provided for @view_manage_orders.
  ///
  /// In en, this message translates to:
  /// **'View and manage your assigned orders'**
  String get view_manage_orders;

  /// No description provided for @recent_orders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recent_orders;

  /// No description provided for @no_orders_yet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get no_orders_yet;

  /// No description provided for @orders_appear_when_assigned.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here once assigned'**
  String get orders_appear_when_assigned;

  /// No description provided for @no_orders_assigned.
  ///
  /// In en, this message translates to:
  /// **'No orders assigned'**
  String get no_orders_assigned;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @refresh_orders.
  ///
  /// In en, this message translates to:
  /// **'Refresh Orders'**
  String get refresh_orders;

  /// No description provided for @update_profile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get update_profile;

  /// No description provided for @view_all_orders.
  ///
  /// In en, this message translates to:
  /// **'View All Orders'**
  String get view_all_orders;

  /// No description provided for @view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all;

  /// No description provided for @account_information.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get account_information;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manage_notification_preferences.
  ///
  /// In en, this message translates to:
  /// **'Manage notification preferences'**
  String get manage_notification_preferences;

  /// No description provided for @privacy_security.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacy_security;

  /// No description provided for @manage_privacy_settings.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy settings'**
  String get manage_privacy_settings;

  /// No description provided for @my_statistics.
  ///
  /// In en, this message translates to:
  /// **'My Statistics'**
  String get my_statistics;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @not_returned.
  ///
  /// In en, this message translates to:
  /// **'Not Returned'**
  String get not_returned;

  /// No description provided for @are_you_sure_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get are_you_sure_logout;

  /// No description provided for @orders_list_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Orders List - Coming Soon'**
  String get orders_list_coming_soon;

  /// No description provided for @my_orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get my_orders;

  /// No description provided for @driver_user.
  ///
  /// In en, this message translates to:
  /// **'Driver User'**
  String get driver_user;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @order_hash.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get order_hash;

  /// No description provided for @view_reports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get view_reports;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
