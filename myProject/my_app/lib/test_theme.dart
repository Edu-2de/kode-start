import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SimpleThemeTest extends StatelessWidget {
  const SimpleThemeTest({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.currentStyle == AppStyle.modern
          ? Colors.red
          : Colors.blue,
      appBar: AppBar(title: Text('Current: ${themeProvider.currentStyle}')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            themeProvider.toggleStyle();
          },
          child: const Text('Toggle Theme'),
        ),
      ),
    );
  }
}
