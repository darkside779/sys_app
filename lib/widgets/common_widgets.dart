import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../localization/localization_extension.dart';
import '../app/theme.dart';

/// Common UI components that work with the app's theme and localization
class CommonWidgets {
  
  /// Creates a localized text widget
  static Widget localizedText(
    BuildContext context,
    String Function(AppLocalizations) getText, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      getText(context.tr),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Creates a primary button with localized text
  static Widget primaryButton({
    required BuildContext context,
    required String Function(AppLocalizations) getText,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppTheme.primaryButtonStyle,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    getText(context.tr),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
    );
  }

  /// Creates a secondary button with localized text
  static Widget secondaryButton({
    required BuildContext context,
    required String Function(AppLocalizations) getText,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppTheme.secondaryButtonStyle,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    getText(context.tr),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
    );
  }

  /// Creates a localized text form field
  static Widget localizedTextFormField({
    required BuildContext context,
    required String Function(AppLocalizations) getLabel,
    String Function(AppLocalizations)? getHint,
    TextEditingController? controller,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLines,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines,
      enabled: enabled,
      style: TextStyle(
        color: Colors.black, // Force black text in all modes
        fontSize: 16,
      ),
      decoration: AppTheme.getInputDecoration(
        labelText: getLabel(context.tr),
        hintText: getHint?.call(context.tr),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }

  /// Creates a success button
  static Widget successButton({
    required BuildContext context,
    required String Function(AppLocalizations) getText,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppTheme.successButtonStyle,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    getText(context.tr),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
    );
  }

  /// Creates a warning button
  static Widget warningButton({
    required BuildContext context,
    required String Function(AppLocalizations) getText,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppTheme.warningButtonStyle,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    getText(context.tr),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
    );
  }

  /// Creates an error button
  static Widget errorButton({
    required BuildContext context,
    required String Function(AppLocalizations) getText,
    required VoidCallback onPressed,
    bool isLoading = false,
    IconData? icon,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: AppTheme.errorButtonStyle,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    getText(context.tr),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
    );
  }

  /// Creates a localized app bar
  static AppBar localizedAppBar(
    BuildContext context,
    String Function(AppLocalizations) getTitle, {
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
  }) {
    return AppBar(
      title: Text(getTitle(context.tr)),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  /// Creates a localized card with title and content
  static Widget localizedCard({
    required BuildContext context,
    String Function(AppLocalizations)? getTitle,
    required Widget content,
    List<Widget>? actions,
    EdgeInsetsGeometry? padding,
  }) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (getTitle != null) ...[
              Text(
                getTitle(context.tr),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
            ],
            content,
            if (actions != null && actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Creates a localized dialog
  static void showLocalizedDialog({
    required BuildContext context,
    required String Function(AppLocalizations) getTitle,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTitle(context.tr)),
          content: content,
          actions: actions ??
              [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.tr.ok),
                ),
              ],
        );
      },
    );
  }

  /// Creates a localized snack bar
  static void showLocalizedSnackBar({
    required BuildContext context,
    required String Function(AppLocalizations) getMessage,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppTheme.successColor;
        icon = Icons.check_circle;
        break;
      case SnackBarType.error:
        backgroundColor = AppTheme.errorColor;
        icon = Icons.error;
        break;
      case SnackBarType.warning:
        backgroundColor = AppTheme.warningColor;
        icon = Icons.warning;
        break;
      case SnackBarType.info:
      backgroundColor = AppTheme.infoColor;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(getMessage(context.tr))),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Creates a localized loading widget
  static Widget localizedLoading(
    BuildContext context,
    String Function(AppLocalizations) getMessage,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            getMessage(context.tr),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  /// Creates an RTL-aware padding
  static Widget rtlPadding({
    required BuildContext context,
    required Widget child,
    double? start,
    double? top,
    double? end,
    double? bottom,
  }) {
    return Padding(
      padding: AppTheme.getRTLPadding(
        context,
        start: start,
        top: top,
        end: end,
        bottom: bottom,
      ),
      child: child,
    );
  }

  /// Creates a language switcher button
  static Widget languageSwitcher({
    required BuildContext context,
    required ValueChanged<Locale> onLanguageChanged,
  }) {
    final currentLocale = Localizations.localeOf(context);
    
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      onSelected: onLanguageChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(context.tr.english),
              ),
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, 
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('ar'),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(context.tr.arabic),
              ),
              if (currentLocale.languageCode == 'ar')
                const Icon(Icons.check, 
                  color: AppTheme.primaryColor,
                  size: 16,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Enum for different types of snack bars
enum SnackBarType {
  success,
  error,
  warning,
  info,
}
