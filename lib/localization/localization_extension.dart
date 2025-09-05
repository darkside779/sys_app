import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

extension BuildContextLocalization on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this);
}
