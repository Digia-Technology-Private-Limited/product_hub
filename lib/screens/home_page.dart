import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/material.dart';

/// Home Page - Entry point for Digia UI integration
///
/// This is the main screen that loads the initial page from Digia Studio.
/// It serves as the root of the Digia UI experience and handles the
/// initial page rendering from Digia Studio configurations.
///
/// Key Features:
/// - Loads initial page from Digia Studio
/// - Provides Digia UI context for child components
/// - Handles navigation and state management
/// - Integrates with message bus for inter-component communication
///
/// Usage:
/// This widget is typically used as the home screen in MaterialApp:
/// ```dart
/// MaterialApp(
///   home: const HomePage(),
/// )
/// ```
///
/// Digia Studio Configuration:
/// The actual UI content is defined in Digia Studio and loaded dynamically.
/// This widget acts as a container that renders the configured page.
///
/// Navigation:
/// - Initial page loading from Digia Studio
/// - Navigation between pages handled by Digia UI
/// - Message bus integration for custom navigation logic
class HomePage extends StatelessWidget {
  /// Constructor for HomePage
  const HomePage({super.key});

  /// Build method that renders the Digia UI initial page
  ///
  /// This method creates the initial page using DUIFactory().createInitialPage()
  /// which loads the page configuration from Digia Studio.
  ///
  /// Returns a widget that displays the Digia Studio configured page.
  @override
  Widget build(BuildContext context) {
    return DUIFactory().createInitialPage();
  }
}
