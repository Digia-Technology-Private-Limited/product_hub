# Custom Widgets Directory

This directory contains reusable native Flutter widgets that can be used in Digia pages or native screens.

## Overview

The widgets in this directory demonstrate how to create custom Flutter components that integrate seamlessly with Digia UI. These widgets can be registered with the Digia UI SDK and used within Digia Studio pages.

## Available Widgets

### DeliveryTypeStatus
- **File**: `delivery_type_status.dart`
- **Purpose**: Displays delivery type information with custom styling
- **Usage**: Registered as `custom/deliverytype-1BsfGx` in Digia Studio
- **Props**: `title` (String), `color` (Color)

## Widget Structure Pattern

Each custom widget should follow this pattern:

1. **Props Class**: Define a class that extends the data structure
2. **fromJson Method**: Static method to parse JSON from Digia Studio
3. **Widget Class**: The actual Flutter widget implementation
4. **Registration**: Register with DUIFactory using a unique ID

## Registration Pattern

Widgets are registered using the `DUIFactory().registerWidget()` method:

```dart
void registerDeliveryTypeStatusCustomWidgets() {
  DUIFactory().registerWidget<DeliveryTypeWidgetProps>(
    'custom/deliverytype-1BsfGx', // ID in Digia Studio
    DeliveryTypeWidgetProps.fromJson,
    (props, childGroups) => DeliveryTypeStatus(
      props: props,
      commonProps: null,
      parent: null,
      refName: 'custom_deliveryType',
    ),
  );
}
```

## Complete Widget Implementation Example

### 1. Props Class

```dart
class DeliveryTypeWidgetProps {
  final String title;
  final Color color;

  DeliveryTypeWidgetProps({
    required this.title,
    required this.color,
  });

  static DeliveryTypeWidgetProps fromJson(Map<String, dynamic> json) {
    return DeliveryTypeWidgetProps(
      title: json['title'] as String,
      color: Color(int.parse(json['color'].replaceFirst('#', '0xff'))),
    );
  }
}
```

### 2. Widget Class

```dart
class DeliveryTypeStatus
    extends VirtualLeafStatelessWidget<DeliveryTypeWidgetProps> {
  DeliveryTypeStatus(
      {required super.props,
      required super.commonProps,
      required super.parent,
      required super.refName});

  @override
  Widget render(RenderPayload payload) {
    return DeliveryTypeStatusCustomWidget(
      title: props.title,
      color: props.color,
    );
  }
}

class DeliveryTypeStatusCustomWidget extends StatefulWidget {
  final String title;
  final Color color;

  const DeliveryTypeStatusCustomWidget({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  State<DeliveryTypeStatusCustomWidget> createState() =>
      _DeliveryTypeStatusCustomWidgetState();
}

class _DeliveryTypeStatusCustomWidgetState
    extends State<DeliveryTypeStatusCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color, width: 1),
      ),
      child: Text(
        widget.title,
        style: TextStyle(
          color: widget.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

### 3. Registration Function

```dart
void registerDeliveryTypeStatusCustomWidgets() {
  DUIFactory().registerWidget<DeliveryTypeWidgetProps>(
    'custom/deliverytype-1BsfGx', // Unique ID in Digia Studio
    DeliveryTypeWidgetProps.fromJson,
    (props, childGroups) => DeliveryTypeStatus(
      props: props,
      commonProps: null,
      parent: null,
      refName: 'custom_deliveryType',
    ),
  );
}
```

## Usage in Digia Studio

Once registered, widgets can be used in Digia Studio by referencing their ID:

- Widget ID: `custom/deliverytype-1BsfGx`
- Props are passed as JSON from Digia Studio
- Events can be handled through the message bus system

Example Digia Studio configuration:

```json
{
  "widget": "custom/deliverytype-1BsfGx",
  "props": {
    "title": "Express Delivery",
    "color": "#FF6B35"
  },
  "events": {
    "onTap": {
      "action": "postMessage",
      "channel": "delivery_status_tapped",
      "params": {
        "status": "express"
      }
    }
  }
}
```

## When to Use Custom Widgets

**Use Custom Widgets when you need:**

- ✅ **Native Platform Features**: Camera, GPS, device sensors, file system access
- ✅ **Third-party Flutter Packages**: Complex animations, charts, maps, etc.
- ✅ **Performance-Critical Logic**: Custom rendering or complex state management
- ✅ **Missing Digia UI Components**: Specialized widgets not available in Digia Studio
- ✅ **Custom Styling**: Specific design requirements that Digia UI can't achieve
- ✅ **Platform-Specific Behavior**: Different behavior on iOS vs Android

**Use Digia UI Directly for:**

- ❌ **Basic UI Elements**: Buttons, text, images, lists (already available in Digia)
- ❌ **Standard Layouts**: Containers, columns, rows, cards
- ❌ **Simple Forms**: Text inputs, checkboxes, dropdowns
- ❌ **Navigation**: Standard app bars, bottom tabs, drawers

## Decision Matrix

| Component Type | Use Digia UI | Use Custom Widget | Reason |
|----------------|--------------|-------------------|---------|
| Product Card | ✅ | ❌ | Standard layout, available in Digia |
| Shopping Cart | ✅ | ❌ | List + standard components |
| Camera Button | ❌ | ✅ | Native camera API needed |
| Payment Form | ❌ | ✅ | Third-party SDK integration |
| Custom Animation | ❌ | ✅ | Complex Flutter animations |
| GPS Location | ❌ | ✅ | Native location services |
| Charts/Graphs | ❌ | ✅ | Third-party charting library |
| File Picker | ❌ | ✅ | Native file system access |
| Status Badges | ❌ | ✅ | Custom styling requirements |
| Progress Indicators | ✅ | ❌ | Available in Digia UI |
| Modal Dialogs | ✅ | ❌ | Standard modal components |

## Current Custom Widgets

### DeliveryTypeStatus
- **Use Case**: Custom styling for delivery status display
- **Why Custom**: Specific color and text formatting requirements with rounded borders
- **Alternative**: Could potentially be done with Digia UI styling, but custom widget provides more control and reusability
- **Props**: `title` (String), `color` (Color hex)
- **Events**: Supports tap events through message bus

## Adding New Widgets

1. Create a new `.dart` file in this directory
2. Implement the props class and widget following the pattern above
3. Add registration logic to the appropriate init method
4. Update this README with the new widget information
5. Test the widget in both native and Digia contexts

### Template for New Widgets

```dart
// 1. Props class
class MyCustomWidgetProps {
  final String title;
  final Color color;

  MyCustomWidgetProps({
    required this.title,
    required this.color,
  });

  static MyCustomWidgetProps fromJson(Map<String, dynamic> json) {
    return MyCustomWidgetProps(
      title: json['title'] as String,
      color: Color(int.parse(json['color'].replaceFirst('#', '0xff'))),
    );
  }
}

// 2. Widget class
class MyCustomWidget extends VirtualLeafStatelessWidget<MyCustomWidgetProps> {
  MyCustomWidget(
      {required super.props,
      required super.commonProps,
      required super.parent,
      required super.refName});

  @override
  Widget render(RenderPayload payload) {
    return MyCustomWidgetImpl(
      title: props.title,
      color: props.color,
    );
  }
}

// 3. Implementation
class MyCustomWidgetImpl extends StatelessWidget {
  final String title;
  final Color color;

  const MyCustomWidgetImpl({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(title, style: TextStyle(color: color)),
    );
  }
}

// 4. Registration
void registerMyCustomWidget() {
  DUIFactory().registerWidget<MyCustomWidgetProps>(
    'custom/my-widget-id',
    MyCustomWidgetProps.fromJson,
    (props, childGroups) => MyCustomWidget(
      props: props,
      commonProps: null,
      parent: null,
      refName: 'custom_myWidget',
    ),
  );
}
```

## Best Practices

### 1. Keep Widgets Focused
- Each widget should have a single responsibility
- Avoid complex state management within widgets
- Use props for configuration, not behavior

### 2. Handle Props Safely
- Always validate props in `fromJson`
- Provide sensible defaults
- Handle null/undefined values gracefully

### 3. Use Proper Naming
- Widget IDs should be unique and descriptive
- Use kebab-case for IDs: `custom/my-widget-name`
- Follow Flutter naming conventions for classes

### 4. Test Thoroughly
- Test in both native and Digia contexts
- Verify props parsing works correctly
- Test event handling through message bus

### 5. Document Your Widgets
- Update this README when adding new widgets
- Include use cases and prop descriptions
- Provide examples of Digia Studio usage

## Integration with Analytics

Custom widgets can integrate with analytics through the message bus:

```dart
// In widget implementation
void _handleTap() {
  // Handle widget-specific logic
  // ...

  // Send analytics event
  DUIAppState().postMessage(
    'analytics_event',
    {
      'name': 'custom_widget_tapped',
      'params': {'widget_id': 'delivery_type_status'}
    },
  );
}
```

## Troubleshooting

### Widget Not Appearing in Digia Studio
- Check that registration is called before Digia UI initialization
- Verify the widget ID matches exactly in Digia Studio
- Ensure props parsing doesn't throw exceptions

### Props Not Working
- Check `fromJson` method for correct parsing
- Verify prop names match Digia Studio configuration
- Add debug prints to see what props are received

### Events Not Firing
- Ensure message bus is properly initialized
- Check channel names match between widget and handler
- Verify Digia Studio event configuration
