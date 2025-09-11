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
  /// **' orders'**
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
  /// **'Enter address'**
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
  /// **'Operation failed'**
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
  /// **'Manage privacy settings'**
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

  /// No description provided for @search_orders.
  ///
  /// In en, this message translates to:
  /// **'Search Orders'**
  String get search_orders;

  /// No description provided for @search_orders_hint.
  ///
  /// In en, this message translates to:
  /// **'Order number, customer, address...'**
  String get search_orders_hint;

  /// No description provided for @all_status.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get all_status;

  /// No description provided for @filters_applied.
  ///
  /// In en, this message translates to:
  /// **'Filters applied'**
  String get filters_applied;

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clear_all;

  /// No description provided for @no_orders_found.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get no_orders_found;

  /// No description provided for @try_adjusting_filters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters to see more results'**
  String get try_adjusting_filters;

  /// No description provided for @no_orders_created_yet.
  ///
  /// In en, this message translates to:
  /// **'No orders created yet. Tap + to create your first order'**
  String get no_orders_created_yet;

  /// No description provided for @view_details.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get view_details;

  /// No description provided for @mark_as_returned.
  ///
  /// In en, this message translates to:
  /// **'Mark as Returned'**
  String get mark_as_returned;

  /// No description provided for @mark_as_not_returned.
  ///
  /// In en, this message translates to:
  /// **'Mark as Not Returned'**
  String get mark_as_not_returned;

  /// No description provided for @customer_information.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customer_information;

  /// No description provided for @order_information.
  ///
  /// In en, this message translates to:
  /// **'Order Information'**
  String get order_information;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @company_information.
  ///
  /// In en, this message translates to:
  /// **'Company Information'**
  String get company_information;

  /// No description provided for @unknown_company.
  ///
  /// In en, this message translates to:
  /// **'Unknown Company'**
  String get unknown_company;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @currency_symbol.
  ///
  /// In en, this message translates to:
  /// **'AED'**
  String get currency_symbol;

  /// No description provided for @created_by.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get created_by;

  /// No description provided for @order_created_by.
  ///
  /// In en, this message translates to:
  /// **'Order Created By'**
  String get order_created_by;

  /// No description provided for @created_at.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get created_at;

  /// No description provided for @order_created_at.
  ///
  /// In en, this message translates to:
  /// **'Order Created At'**
  String get order_created_at;

  /// No description provided for @status_received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get status_received;

  /// No description provided for @status_returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get status_returned;

  /// No description provided for @status_not_returned.
  ///
  /// In en, this message translates to:
  /// **'Not returned'**
  String get status_not_returned;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @current_password.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get current_password;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @update_password.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get update_password;

  /// No description provided for @password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get password_updated;

  /// No description provided for @incorrect_password.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get incorrect_password;

  /// No description provided for @password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_mismatch;

  /// No description provided for @manage_orders.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get manage_orders;

  /// No description provided for @all_statuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get all_statuses;

  /// No description provided for @all_drivers.
  ///
  /// In en, this message translates to:
  /// **'All Drivers'**
  String get all_drivers;

  /// No description provided for @all_companies.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all_companies;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @update_status.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get update_status;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @select_status.
  ///
  /// In en, this message translates to:
  /// **'Select Status'**
  String get select_status;

  /// No description provided for @select_driver.
  ///
  /// In en, this message translates to:
  /// **'Select Driver'**
  String get select_driver;

  /// No description provided for @select_company.
  ///
  /// In en, this message translates to:
  /// **'Select Company'**
  String get select_company;

  /// No description provided for @unknown_user.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknown_user;

  /// No description provided for @delete_company_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this company?'**
  String get delete_company_confirm;

  /// No description provided for @company_deleted.
  ///
  /// In en, this message translates to:
  /// **'Company deleted successfully'**
  String get company_deleted;

  /// No description provided for @company_created.
  ///
  /// In en, this message translates to:
  /// **'Company created successfully'**
  String get company_created;

  /// No description provided for @company_updated.
  ///
  /// In en, this message translates to:
  /// **'Company updated successfully'**
  String get company_updated;

  /// No description provided for @no_companies_search.
  ///
  /// In en, this message translates to:
  /// **'No companies found matching your search'**
  String get no_companies_search;

  /// No description provided for @created_on.
  ///
  /// In en, this message translates to:
  /// **'Created On'**
  String get created_on;

  /// No description provided for @manage_drivers.
  ///
  /// In en, this message translates to:
  /// **'Manage Drivers'**
  String get manage_drivers;

  /// No description provided for @search_drivers.
  ///
  /// In en, this message translates to:
  /// **'Search Drivers'**
  String get search_drivers;

  /// No description provided for @enter_driver_search.
  ///
  /// In en, this message translates to:
  /// **'Enter driver name or phone...'**
  String get enter_driver_search;

  /// No description provided for @filter_by_company.
  ///
  /// In en, this message translates to:
  /// **'Filter by Company'**
  String get filter_by_company;

  /// No description provided for @delete_driver_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this driver?'**
  String get delete_driver_confirm;

  /// No description provided for @driver_deleted.
  ///
  /// In en, this message translates to:
  /// **'Driver deleted successfully'**
  String get driver_deleted;

  /// No description provided for @driver_created.
  ///
  /// In en, this message translates to:
  /// **'Driver created successfully'**
  String get driver_created;

  /// No description provided for @driver_updated.
  ///
  /// In en, this message translates to:
  /// **'Driver updated successfully'**
  String get driver_updated;

  /// No description provided for @no_drivers_filter.
  ///
  /// In en, this message translates to:
  /// **'No drivers found matching your filters'**
  String get no_drivers_filter;

  /// No description provided for @no_drivers_available.
  ///
  /// In en, this message translates to:
  /// **'No drivers available'**
  String get no_drivers_available;

  /// No description provided for @edit_driver.
  ///
  /// In en, this message translates to:
  /// **'Edit Driver'**
  String get edit_driver;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @enter_driver_name.
  ///
  /// In en, this message translates to:
  /// **'Enter driver name'**
  String get enter_driver_name;

  /// No description provided for @driver_name_required.
  ///
  /// In en, this message translates to:
  /// **'Driver name is required'**
  String get driver_name_required;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @enter_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enter_phone_number;

  /// No description provided for @phone_number_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phone_number_required;

  /// No description provided for @please_select_company.
  ///
  /// In en, this message translates to:
  /// **'Please select a company'**
  String get please_select_company;

  /// No description provided for @active_driver.
  ///
  /// In en, this message translates to:
  /// **'Active Driver'**
  String get active_driver;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @select_date_range.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get select_date_range;

  /// No description provided for @summary_statistics.
  ///
  /// In en, this message translates to:
  /// **'Summary Statistics'**
  String get summary_statistics;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @total_revenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get total_revenue;

  /// No description provided for @average_order.
  ///
  /// In en, this message translates to:
  /// **'Average Order'**
  String get average_order;

  /// No description provided for @company_performance.
  ///
  /// In en, this message translates to:
  /// **'Company Performance'**
  String get company_performance;

  /// No description provided for @driver_performance.
  ///
  /// In en, this message translates to:
  /// **'Driver Performance'**
  String get driver_performance;

  /// No description provided for @unknown_driver.
  ///
  /// In en, this message translates to:
  /// **'Unknown Driver'**
  String get unknown_driver;

  /// No description provided for @filtered_orders.
  ///
  /// In en, this message translates to:
  /// **'Filtered Orders'**
  String get filtered_orders;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @add_user.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get add_user;

  /// No description provided for @search_users.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get search_users;

  /// No description provided for @name_or_phone.
  ///
  /// In en, this message translates to:
  /// **'Name or phone...'**
  String get name_or_phone;

  /// No description provided for @all_roles.
  ///
  /// In en, this message translates to:
  /// **'All Roles'**
  String get all_roles;

  /// No description provided for @no_users_found.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get no_users_found;

  /// No description provided for @add_users_to_get_started.
  ///
  /// In en, this message translates to:
  /// **'Add users to get started'**
  String get add_users_to_get_started;

  /// No description provided for @delete_user.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get delete_user;

  /// No description provided for @are_you_sure_delete_user.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get are_you_sure_delete_user;

  /// No description provided for @action_cannot_be_undone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get action_cannot_be_undone;

  /// No description provided for @deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'deleted successfully'**
  String get deleted_successfully;

  /// No description provided for @failed_to_delete_user.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user'**
  String get failed_to_delete_user;

  /// No description provided for @activated.
  ///
  /// In en, this message translates to:
  /// **'activated'**
  String get activated;

  /// No description provided for @deactivated.
  ///
  /// In en, this message translates to:
  /// **'deactivated'**
  String get deactivated;

  /// No description provided for @failed_to_update_user_status.
  ///
  /// In en, this message translates to:
  /// **'Failed to update user status'**
  String get failed_to_update_user_status;

  /// No description provided for @user_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'User created successfully'**
  String get user_created_successfully;

  /// No description provided for @user_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'User updated successfully'**
  String get user_updated_successfully;

  /// No description provided for @create_user.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get create_user;

  /// No description provided for @edit_user.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get edit_user;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @enter_users_full_name.
  ///
  /// In en, this message translates to:
  /// **'Enter user\'s full name'**
  String get enter_users_full_name;

  /// No description provided for @name_is_required.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get name_is_required;

  /// No description provided for @email_address.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email_address;

  /// No description provided for @enter_email_address.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enter_email_address;

  /// No description provided for @email_is_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_is_required;

  /// No description provided for @please_enter_valid_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get please_enter_valid_email;

  /// No description provided for @enter_password.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enter_password;

  /// No description provided for @password_is_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_is_required;

  /// No description provided for @password_min_length.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get password_min_length;

  /// No description provided for @phone_number_is_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phone_number_is_required;

  /// No description provided for @default_role.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get default_role;

  /// No description provided for @active_user.
  ///
  /// In en, this message translates to:
  /// **'Active User'**
  String get active_user;

  /// No description provided for @user_can_login_access_system.
  ///
  /// In en, this message translates to:
  /// **'User can login and access the system'**
  String get user_can_login_access_system;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @status_out_for_delivery.
  ///
  /// In en, this message translates to:
  /// **'Out for delivery'**
  String get status_out_for_delivery;

  /// No description provided for @return_reason.
  ///
  /// In en, this message translates to:
  /// **'Return Reason'**
  String get return_reason;

  /// No description provided for @enter_return_reason.
  ///
  /// In en, this message translates to:
  /// **'Enter return reason'**
  String get enter_return_reason;

  /// No description provided for @return_reason_required.
  ///
  /// In en, this message translates to:
  /// **'Return reason is required'**
  String get return_reason_required;

  /// No description provided for @returned_reason.
  ///
  /// In en, this message translates to:
  /// **'Returned: {reason}'**
  String returned_reason(Object reason);

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @export_excel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get export_excel;

  /// No description provided for @export_successful.
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get export_successful;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error_occurred;

  /// No description provided for @date_range.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get date_range;

  /// No description provided for @edit_orders.
  ///
  /// In en, this message translates to:
  /// **'Edit {count} Orders'**
  String edit_orders(int count);

  /// No description provided for @select_fields_to_update.
  ///
  /// In en, this message translates to:
  /// **'Select fields to update:'**
  String get select_fields_to_update;

  /// No description provided for @company_optional.
  ///
  /// In en, this message translates to:
  /// **'Company (Optional)'**
  String get company_optional;

  /// No description provided for @leave_empty_to_keep_current.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep current'**
  String get leave_empty_to_keep_current;

  /// No description provided for @driver_optional.
  ///
  /// In en, this message translates to:
  /// **'Driver (Optional)'**
  String get driver_optional;

  /// No description provided for @status_optional.
  ///
  /// In en, this message translates to:
  /// **'Status (Optional)'**
  String get status_optional;

  /// No description provided for @update_orders.
  ///
  /// In en, this message translates to:
  /// **'Update Orders'**
  String get update_orders;

  /// No description provided for @please_select_field_to_update.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one field to update'**
  String get please_select_field_to_update;

  /// No description provided for @updating_orders.
  ///
  /// In en, this message translates to:
  /// **'Updating orders...'**
  String get updating_orders;

  /// No description provided for @updated_orders_count.
  ///
  /// In en, this message translates to:
  /// **'Updated {success} of {total} orders'**
  String updated_orders_count(int success, int total);

  /// No description provided for @failed_to_update_orders.
  ///
  /// In en, this message translates to:
  /// **'Failed to update orders: {error}'**
  String failed_to_update_orders(String error);

  /// No description provided for @no_change.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get no_change;

  /// No description provided for @productMetrics.
  ///
  /// In en, this message translates to:
  /// **'Product Metrics'**
  String get productMetrics;

  /// No description provided for @totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get totalProducts;

  /// No description provided for @activeProducts.
  ///
  /// In en, this message translates to:
  /// **'Active Products'**
  String get activeProducts;

  /// No description provided for @availableProducts.
  ///
  /// In en, this message translates to:
  /// **'Available Products'**
  String get availableProducts;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @averagePrice.
  ///
  /// In en, this message translates to:
  /// **'Average Price'**
  String get averagePrice;

  /// No description provided for @inventoryValue.
  ///
  /// In en, this message translates to:
  /// **'Inventory Value'**
  String get inventoryValue;

  /// No description provided for @restockNeeded.
  ///
  /// In en, this message translates to:
  /// **'Restock needed for out of stock products'**
  String get restockNeeded;

  /// No description provided for @lowStockWarning.
  ///
  /// In en, this message translates to:
  /// **'Several products have low stock levels'**
  String get lowStockWarning;

  /// No description provided for @total_cost.
  ///
  /// In en, this message translates to:
  /// **'Total Cost'**
  String get total_cost;

  /// No description provided for @quick_analysis.
  ///
  /// In en, this message translates to:
  /// **'Quick Analysis'**
  String get quick_analysis;

  /// No description provided for @analyze_current_data.
  ///
  /// In en, this message translates to:
  /// **'Analyze current data'**
  String get analyze_current_data;

  /// No description provided for @export_report.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get export_report;

  /// No description provided for @export_comprehensive_report.
  ///
  /// In en, this message translates to:
  /// **'Export comprehensive report'**
  String get export_comprehensive_report;

  /// No description provided for @share_results.
  ///
  /// In en, this message translates to:
  /// **'Share Results'**
  String get share_results;

  /// No description provided for @share_key_findings.
  ///
  /// In en, this message translates to:
  /// **'Share key findings'**
  String get share_key_findings;

  /// No description provided for @refresh_data.
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refresh_data;

  /// No description provided for @refresh_all_data.
  ///
  /// In en, this message translates to:
  /// **'Refresh all data'**
  String get refresh_all_data;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @analysis_results.
  ///
  /// In en, this message translates to:
  /// **'Analysis Results'**
  String get analysis_results;

  /// No description provided for @exporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting...'**
  String get exporting;

  /// No description provided for @comprehensive_report.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive Report'**
  String get comprehensive_report;

  /// No description provided for @report_exported_successfully.
  ///
  /// In en, this message translates to:
  /// **'Report exported successfully'**
  String get report_exported_successfully;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @system_results.
  ///
  /// In en, this message translates to:
  /// **'System Results'**
  String get system_results;

  /// No description provided for @share_link_generated.
  ///
  /// In en, this message translates to:
  /// **'Share link generated'**
  String get share_link_generated;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing...'**
  String get refreshing;

  /// No description provided for @data_refreshed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Data refreshed successfully'**
  String get data_refreshed_successfully;

  /// No description provided for @ai_assistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get ai_assistant;

  /// No description provided for @clear_chat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clear_chat;

  /// No description provided for @clear_chat_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the chat history?'**
  String get clear_chat_confirmation;

  /// No description provided for @type_message.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get type_message;

  /// No description provided for @hello_ai_assistant.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your AI assistant.'**
  String get hello_ai_assistant;

  /// No description provided for @ask_about_system.
  ///
  /// In en, this message translates to:
  /// **'Ask me about orders, drivers, companies, or analytics.'**
  String get ask_about_system;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get thinking;

  /// No description provided for @show_todays_orders.
  ///
  /// In en, this message translates to:
  /// **'Show today\'s orders'**
  String get show_todays_orders;

  /// No description provided for @analyze_performance.
  ///
  /// In en, this message translates to:
  /// **'Analyze performance'**
  String get analyze_performance;

  /// No description provided for @check_driver_status.
  ///
  /// In en, this message translates to:
  /// **'Check driver status'**
  String get check_driver_status;

  /// No description provided for @view_company_stats.
  ///
  /// In en, this message translates to:
  /// **'View company stats'**
  String get view_company_stats;

  /// No description provided for @no_message_available.
  ///
  /// In en, this message translates to:
  /// **'No message available'**
  String get no_message_available;

  /// No description provided for @ai_dashboard.
  ///
  /// In en, this message translates to:
  /// **'AI Dashboard'**
  String get ai_dashboard;

  /// No description provided for @stale_order_warning.
  ///
  /// In en, this message translates to:
  /// **'Order has been {days} days without status change!'**
  String stale_order_warning(Object days);

  /// No description provided for @stale_order_tooltip.
  ///
  /// In en, this message translates to:
  /// **'This order needs attention - no status change for {days} days'**
  String stale_order_tooltip(Object days);

  /// No description provided for @days_stale.
  ///
  /// In en, this message translates to:
  /// **'{days} days stale'**
  String days_stale(Object days);

  /// No description provided for @stale_order_detail_message.
  ///
  /// In en, this message translates to:
  /// **'This order has been {days} days without status change and may need attention.'**
  String stale_order_detail_message(Object days);

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @product_management.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get product_management;

  /// No description provided for @add_product.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get add_product;

  /// No description provided for @edit_product.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get edit_product;

  /// No description provided for @delete_product.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get delete_product;

  /// No description provided for @product_name.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get product_name;

  /// No description provided for @product_description.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get product_description;

  /// No description provided for @product_price.
  ///
  /// In en, this message translates to:
  /// **'Product Price'**
  String get product_price;

  /// No description provided for @product_category.
  ///
  /// In en, this message translates to:
  /// **'Product Category'**
  String get product_category;

  /// No description provided for @product_sku.
  ///
  /// In en, this message translates to:
  /// **'Product SKU'**
  String get product_sku;

  /// No description provided for @product_image.
  ///
  /// In en, this message translates to:
  /// **'Product Image'**
  String get product_image;

  /// No description provided for @search_products.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get search_products;

  /// No description provided for @category_filter.
  ///
  /// In en, this message translates to:
  /// **'Category Filter'**
  String get category_filter;

  /// No description provided for @all_categories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get all_categories;

  /// No description provided for @no_products_match_search.
  ///
  /// In en, this message translates to:
  /// **'No products match your search criteria'**
  String get no_products_match_search;

  /// No description provided for @no_products_add_first.
  ///
  /// In en, this message translates to:
  /// **'No products found. Add your first product!'**
  String get no_products_add_first;

  /// No description provided for @clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clear_filters;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @product_name_required.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get product_name_required;

  /// No description provided for @product_description_required.
  ///
  /// In en, this message translates to:
  /// **'Product description is required'**
  String get product_description_required;

  /// No description provided for @product_price_required.
  ///
  /// In en, this message translates to:
  /// **'Product price is required'**
  String get product_price_required;

  /// No description provided for @product_category_required.
  ///
  /// In en, this message translates to:
  /// **'Product category is required'**
  String get product_category_required;

  /// No description provided for @product_sku_required.
  ///
  /// In en, this message translates to:
  /// **'Product SKU is required'**
  String get product_sku_required;

  /// No description provided for @enter_product_name.
  ///
  /// In en, this message translates to:
  /// **'Enter product name'**
  String get enter_product_name;

  /// No description provided for @enter_product_description.
  ///
  /// In en, this message translates to:
  /// **'Enter product description'**
  String get enter_product_description;

  /// No description provided for @enter_product_price.
  ///
  /// In en, this message translates to:
  /// **'Enter product price (AED)'**
  String get enter_product_price;

  /// No description provided for @enter_product_category.
  ///
  /// In en, this message translates to:
  /// **'Enter product category'**
  String get enter_product_category;

  /// No description provided for @enter_product_sku.
  ///
  /// In en, this message translates to:
  /// **'Enter product SKU/Code'**
  String get enter_product_sku;

  /// No description provided for @enter_image_url.
  ///
  /// In en, this message translates to:
  /// **'Enter image URL (optional)'**
  String get enter_image_url;

  /// No description provided for @invalid_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get invalid_price;

  /// No description provided for @failed_update_product_status.
  ///
  /// In en, this message translates to:
  /// **'Failed to update product status'**
  String get failed_update_product_status;

  /// No description provided for @delete_product_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{productName}\"? This action cannot be undone.'**
  String delete_product_confirm(String productName);

  /// No description provided for @product_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get product_deleted_success;

  /// No description provided for @failed_delete_product.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete product'**
  String get failed_delete_product;

  /// No description provided for @product_created_success.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get product_created_success;

  /// No description provided for @product_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get product_updated_success;

  /// No description provided for @failed_create_product.
  ///
  /// In en, this message translates to:
  /// **'Failed to create product'**
  String get failed_create_product;

  /// No description provided for @failed_update_product.
  ///
  /// In en, this message translates to:
  /// **'Failed to update product'**
  String get failed_update_product;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @active_product.
  ///
  /// In en, this message translates to:
  /// **'Active Product'**
  String get active_product;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @select_products.
  ///
  /// In en, this message translates to:
  /// **'Select Products'**
  String get select_products;

  /// No description provided for @selected_products.
  ///
  /// In en, this message translates to:
  /// **'Selected Products'**
  String get selected_products;

  /// No description provided for @add_to_order.
  ///
  /// In en, this message translates to:
  /// **'Add to Order'**
  String get add_to_order;

  /// No description provided for @remove_from_order.
  ///
  /// In en, this message translates to:
  /// **'Remove from Order'**
  String get remove_from_order;

  /// No description provided for @product_notes.
  ///
  /// In en, this message translates to:
  /// **'Product Notes'**
  String get product_notes;

  /// No description provided for @enter_notes.
  ///
  /// In en, this message translates to:
  /// **'Enter notes (optional)'**
  String get enter_notes;

  /// No description provided for @order_total.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get order_total;

  /// No description provided for @no_products_selected.
  ///
  /// In en, this message translates to:
  /// **'No products selected'**
  String get no_products_selected;

  /// No description provided for @select_products_for_order.
  ///
  /// In en, this message translates to:
  /// **'Select products for this order'**
  String get select_products_for_order;

  /// No description provided for @products_in_order.
  ///
  /// In en, this message translates to:
  /// **'Products in Order'**
  String get products_in_order;
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
