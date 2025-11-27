import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/material.dart';

/// Custom Widget Registration Example - Delivery Type Status Widget
///
/// This file demonstrates the complete process of creating and registering
/// custom widgets with Digia UI. It showcases the pattern for extending
/// Digia Studio components with native Flutter implementations.
///
/// Key Concepts Demonstrated:
/// 1. VirtualLeafStatelessWidget - Bridge between Digia and Flutter
/// 2. Props parsing from JSON - Type-safe data transfer
/// 3. Widget registration - Making custom widgets available in Digia Studio
/// 4. Render payload handling - Accessing Digia context and data
/// 5. Color parsing from hex strings - Common UI data transformation
///
/// Architecture Overview:
/// - DeliveryTypeStatus: Virtual widget that bridges Digia to Flutter
/// - DeliveryTypeStatusCustomWidget: Actual Flutter implementation
/// - DeliveryTypeWidgetProps: Type-safe props container
/// - registerDeliveryTypeStatusCustomWidgets(): Registration function
///
/// Usage in Digia Studio:
/// 1. Create a custom component in Digia Studio
/// 2. Assign it the ID 'custom/deliverytype-1BsfGx'
/// 3. Pass props as JSON: {"title": "Express", "color": "#FF5733"}
/// 4. The widget will render with the specified title and color
///
/// Props Schema:
/// ```json
/// {
///   "title": "string - Display text for delivery type",
///   "color": "string - Hex color code (e.g., '#FF5733')"
/// }
/// ```
///
/// Registration Process:
/// Call registerDeliveryTypeStatusCustomWidgets() AFTER DigiaUIAppBuilder or DigiaUIApp initialization
/// to make the widget available in Digia Studio components.
///
/// Example Usage:
/// ```dart
/// void main() async {
///   runApp(DigiaUIAppBuilder(
///     config: DigiaConfig.initialize(),
///     builder: (context, digiaUI) {
///       // Register custom widgets after Digia UI is ready
///       registerDeliveryTypeStatusCustomWidgets();
///       return MyApp();
///     },
///   ));
/// }
/// ```
///
/// Alternative Manual Initialization:
/// ```dart
/// void main() async {
///   // Initialize Digia UI first
///   final digiaUI = await DigiaConfig.initialize();
///
///   // Run app with Digia UI context
///   runApp(DigiaUIApp(
///     digiaUI: digiaUI,
///     builder: (context){
/// Register custom widgets after Digia initialization
///   registerDeliveryTypeStatusCustomWidgets();
///
///    return MyApp();
/// },
///   ));
/// }
/// ```
///
/// In Digia Studio:
/// - Create a custom component
/// - Set component ID to 'custom/deliverytype-1BsfGx'
/// - Configure props in the component settings
/// - The widget will render with native Flutter performance

/// Virtual Widget Bridge - Connects Digia UI to Flutter Implementation
///
/// Extends VirtualLeafStatelessWidget to create a bridge between Digia Studio
/// components and native Flutter widgets. This pattern allows Digia UI to
/// render custom Flutter widgets while maintaining the Digia component system.
///
/// Generic Type Parameters:
/// - DeliveryTypeWidgetProps: The props class for type-safe data transfer
///
/// Constructor Parameters:
/// - props: Parsed props from Digia Studio JSON configuration
/// - commonProps: Standard Digia component properties (layout, styling)
/// - parent: Parent component reference for hierarchy management
/// - refName: Reference name for component identification
///
/// Render Method:
/// Receives RenderPayload containing Digia context, theme, and navigation data.
/// Returns the actual Flutter widget to be rendered in the component tree.
class DeliveryTypeStatus
    extends VirtualLeafStatelessWidget<DeliveryTypeWidgetProps> {
  /// Constructor for the virtual widget bridge
  ///
  /// Creates the connection between Digia Studio configuration and
  /// the Flutter widget implementation.
  DeliveryTypeStatus(
      {required super.props,
      required super.commonProps,
      required super.parent,
      required super.refName});

  /// Render the Flutter widget with Digia-provided props
  ///
  /// This method is called by Digia UI when the component needs to be rendered.
  /// The payload contains context information, theme data, and navigation state.
  ///
  /// Parameters:
  /// - payload: Render context from Digia UI containing theme, navigation, etc.
  ///
  /// Returns:
  /// - DeliveryTypeStatusCustomWidget: The actual Flutter implementation
  @override
  Widget render(RenderPayload payload) {
    return DeliveryTypeStatusCustomWidget(
      title: props.title,
      color: props.color,
    );
  }
}

/// Native Flutter Implementation - Delivery Type Status Widget
///
/// The actual Flutter widget that gets rendered. This demonstrates how to
/// create performant native widgets that integrate seamlessly with Digia UI.
///
/// Features:
/// - Simple text display with custom color
/// - State management ready (extends StatefulWidget)
/// - Consistent with Flutter widget patterns
/// - Can be easily extended with animations, gestures, etc.
///
/// Props:
/// - title: The text to display (e.g., "Express Delivery")
/// - color: The color for the text (from Digia Studio configuration)
class DeliveryTypeStatusCustomWidget extends StatefulWidget {
  /// Display text for the delivery type
  final String title;

  /// Color for the text styling
  final Color color;

  /// Constructor with required props from Digia configuration
  const DeliveryTypeStatusCustomWidget({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  State<DeliveryTypeStatusCustomWidget> createState() =>
      _DeliveryTypeStatusCustomWidgetState();
}

/// State management for the custom widget
///
/// Currently minimal state management, but structured to allow for
/// future enhancements like animations, loading states, or user interactions.
///
/// State can be expanded to include:
/// - Animation controllers for entrance effects
/// - Loading states for async operations
/// - User interaction handling (taps, hovers)
/// - Dynamic color changes based on app state
class _DeliveryTypeStatusCustomWidgetState
    extends State<DeliveryTypeStatusCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.title,
      style: TextStyle(color: widget.color),
    );
  }
}

/// Type-Safe Props Container - Data Transfer from Digia to Flutter
///
/// Defines the structure and types for data passed from Digia Studio
/// to the Flutter widget. Ensures type safety and provides JSON parsing.
///
/// Properties:
/// - title: String - The display text for delivery status
/// - color: Color - The text color (parsed from hex string)
///
/// JSON Parsing:
/// Converts Digia Studio JSON props to strongly-typed Dart objects.
/// Handles hex color string parsing for Flutter Color objects.
class DeliveryTypeWidgetProps {
  /// Display text for the delivery type (e.g., "Express", "Standard")
  final String title;

  /// Color for text styling, parsed from hex string (e.g., "#FF5733")
  final Color color;

  /// Constructor for creating props programmatically
  DeliveryTypeWidgetProps({
    required this.title,
    required this.color,
  });

  /// JSON deserialization factory method
  ///
  /// Converts JSON from Digia Studio into type-safe props object.
  /// Handles color parsing from hex strings to Flutter Color objects.
  ///
  /// Parameters:
  /// - json: Map containing 'title' and 'color' keys from Digia Studio
  ///
  /// Returns:
  /// - DeliveryTypeWidgetProps: Parsed and validated props object
  ///
  /// Throws:
  /// - FormatException: If color string is not valid hex
  /// - TypeError: If required fields are missing or wrong type
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "title": "Express Delivery",
  ///   "color": "#FF5733"
  /// }
  /// ```
  static DeliveryTypeWidgetProps fromJson(Map<String, dynamic> json) {
    return DeliveryTypeWidgetProps(
      title: json['title'] as String,
      color: Color(int.parse(json['color'].replaceFirst('#', '0xff'))),
    );
  }
}

/// Widget Registration Function - Makes Custom Widget Available in Digia Studio
///
/// Registers the custom delivery type widget with Digia UI's factory system.
/// This function must be called during app initialization to make the widget
/// available for use in Digia Studio components.
///
/// Registration Process:
/// 1. Calls DUIFactory().registerWidget() with component ID
/// 2. Provides props parser (fromJson function)
/// 3. Provides widget builder function that creates VirtualLeafStatelessWidget
///
/// Component ID: 'custom/deliverytype-1BsfGx'
/// - 'custom/' prefix indicates custom widget (not built-in)
/// - 'deliverytype-1BsfGx' is the unique identifier in Digia Studio
///
/// Usage:
/// ```dart
/// void main() async {
///   // Initialize Digia UI first
///   final digiaUI = await DigiaConfig.initialize();
///
///   // Register custom widgets after initialization
///   registerDeliveryTypeStatusCustomWidgets();
///
///   // Run app with Digia UI
///   runApp(DigiaUIApp(
///     digiaUI: digiaUI,
///     builder: (context) => MyApp(),
///   ));
/// }
/// ```
///
/// In Digia Studio:
/// - Create a new component
/// - Set the component type to 'custom/deliverytype-1BsfGx'
/// - Configure the title and color props
/// - The widget will appear in the preview and build
void registerDeliveryTypeStatusCustomWidgets() {
  DUIFactory().registerWidget<DeliveryTypeWidgetProps>(
    'custom/deliverytype-1BsfGx', // Unique ID in Digia Studio
    DeliveryTypeWidgetProps.fromJson, // JSON parser function
    (props, childGroups) => DeliveryTypeStatus(
      props: props,
      commonProps: null, // Standard Digia props (layout, etc.)
      parent: null, // Parent component reference
      refName: 'custom_deliveryType', // Reference name for debugging
    ),
  );
}
