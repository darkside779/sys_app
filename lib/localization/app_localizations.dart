// ignore_for_file: unnecessary_import

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = {};

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
        await rootBundle.loadString('assets/localization/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // App specific translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get logout => translate('logout');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get name => translate('name');
  String get phone => translate('phone');
  String get language => translate('language');
  String get english => translate('english');
  String get arabic => translate('arabic');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get add => translate('add');
  String get search => translate('search');
  String get filter => translate('filter');
  String get clear => translate('clear');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get warning => translate('warning');
  String get info => translate('info');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  
  // Dashboard
  String get dashboard => translate('dashboard');
  String get statistics => translate('statistics');
  String get totalOrders => translate('total_orders');
  String get completedOrders => translate('completed_orders');
  String get pendingOrders => translate('pending_orders');
  String get todayOrders => translate('today_orders');
  
  // Orders
  String get orders => translate('orders');
  String get orderNumber => translate('order_number');
  String get customerName => translate('customer_name');
  String get customerAddress => translate('customer_address');
  String get orderDate => translate('order_date');
  String get orderStatus => translate('order_status');
  String get orderDetails => translate('order_details');
  String get createOrder => translate('create_order');
  String get updateOrder => translate('update_order');
  String get deleteOrder => translate('delete_order');
  String get orderReceived => translate('order_received');
  String get orderReturned => translate('order_returned');
  String get orderNotReturned => translate('order_not_returned');
  String get orderNote => translate('order_note');
  
  // Companies
  String get companies => translate('companies');
  String get companyName => translate('company_name');
  String get companyAddress => translate('company_address');
  String get companyPhone => translate('company_phone');
  String get companyEmail => translate('company_email');
  String get companyDetails => translate('company_details');
  String get createCompany => translate('create_company');
  String get updateCompany => translate('update_company');
  String get deleteCompany => translate('delete_company');
  String get deliveryCompanies => translate('delivery_companies');
  
  // Drivers
  String get drivers => translate('drivers');
  String get driverName => translate('driver_name');
  String get driverPhone => translate('driver_phone');
  String get driverEmail => translate('driver_email');
  String get driverLicense => translate('driver_license');
  String get driverCompany => translate('driver_company');
  String get driverDetails => translate('driver_details');
  String get createDriver => translate('create_driver');
  String get updateDriver => translate('update_driver');
  String get deleteDriver => translate('delete_driver');
  String get assignDriver => translate('assign_driver');
  
  // Users
  String get users => translate('users');
  String get userRole => translate('user_role');
  String get admin => translate('admin');
  String get user => translate('user');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get account => translate('account');
  
  // Navigation
  String get home => translate('home');
  String get back => translate('back');
  String get next => translate('next');
  String get previous => translate('previous');
  String get menu => translate('menu');
  String get close => translate('close');
  
  // Validation messages
  String get requiredField => translate('required_field');
  String get invalidEmail => translate('invalid_email');
  String get passwordTooShort => translate('password_too_short');
  String get passwordsDoNotMatch => translate('passwords_do_not_match');
  String get invalidPhoneNumber => translate('invalid_phone_number');
  
  // Error messages
  String get networkError => translate('network_error');
  String get serverError => translate('server_error');
  String get loginFailed => translate('login_failed');
  String get registrationFailed => translate('registration_failed');
  String get updateFailed => translate('update_failed');
  String get deleteFailed => translate('delete_failed');
  String get loadDataFailed => translate('load_data_failed');
  
  // Success messages
  String get loginSuccess => translate('login_success');
  String get registrationSuccess => translate('registration_success');
  String get updateSuccess => translate('update_success');
  String get deleteSuccess => translate('delete_success');
  String get dataSaved => translate('data_saved');
  
  // Date and time
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get thisWeek => translate('this_week');
  String get thisMonth => translate('this_month');
  String get selectDate => translate('select_date');
  String get selectTime => translate('select_time');
  
  // Status
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get enabled => translate('enabled');
  String get disabled => translate('disabled');
  String get online => translate('online');
  String get offline => translate('offline');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access to translations
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this)!;
}
