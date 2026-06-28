import 'package:flutter/material.dart';

class ThemeSwitcher extends StatelessWidget {
  final VoidCallback onToggle;

  const ThemeSwitcher({Key? key, required this.onToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
      trailing: Switch(
        value: isDark,
        onChanged: (_) => onToggle(),
      ),
      onTap: onToggle,
    );
  }
}
