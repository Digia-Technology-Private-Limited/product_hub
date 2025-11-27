# Widgets Directory

This directory contains reusable native Flutter widgets that can be used in Digia pages or native screens.

## Overview

The widgets in this directory demonstrate how to create custom Flutter components that integrate seamlessly with Digia UI. These widgets can be registered with the Digia UI SDK and used within Digia Studio pages.

## Available Widgets

### DeliveryTypeStatus
- **File**: `delivery_type_status.dart`
- **Purpose**: Displays delivery type information with custom styling
- **Usage**: Registered as `custom/deliverytype-1BsfGx` in Digia Studio
- **Props**: `title` (String), `color` (Color)

### CustomButton
- **File**: `custom_button.dart`
- **Purpose**: A customizable button widget for Digia UI integration
- **Usage**: Can be registered and used in Digia Studio
- **Props**: `text` (String), `action` (String, optional)

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

## Widget Structure

Each custom widget should follow this pattern:

1. **Props Class**: Define a class that extends the data structure
2. **fromJson Method**: Static method to parse JSON from Digia Studio
3. **Widget Class**: The actual Flutter widget implementation
4. **Registration**: Register with DUIFactory using a unique ID

## Usage in Digia Studio

Once registered, widgets can be used in Digia Studio by referencing their ID:

- Widget ID: `custom/deliverytype-1BsfGx`
- Props are passed as JSON from Digia Studio
- Events can be handled through the message bus system

## When to Use Custom Widgets

**Use Custom Widgets when you need:**

- ✅ **Native Platform Features**: Camera, GPS, device sensors, file system access
- ✅ **Third-party Flutter Packages**: Complex animations, charts, maps, etc.
- ✅ **Performance-Critical Logic**: Custom rendering or complex state management
- ✅ **Missing Digia UI Components**: Specialized widgets not available in Digia Studio

**Use Digia UI Directly for:**

- ❌ **Basic UI Elements**: Buttons, text, images, lists (already available in Digia)
- ❌ **Standard Layouts**: Containers, columns, rows, cards
- ❌ **Simple Forms**: Text inputs, checkboxes, dropdowns
- ❌ **Navigation**: Standard app bars, bottom tabs, drawers

## Example Decision Matrix

| Component Type | Use Digia UI | Use Custom Widget | Reason |
|----------------|--------------|-------------------|---------|
| Product Card | ✅ | ❌ | Standard layout, available in Digia |
| Shopping Cart | ✅ | ❌ | Complex list with Digia components |
| Camera Button | ❌ | ✅ | Requires native camera API |
| Payment Form | ❌ | ✅ | Third-party payment SDK integration |
| Custom Animation | ❌ | ✅ | Complex Flutter animations |
| User Profile | ✅ | ❌ | Standard form fields |
| GPS Location | ❌ | ✅ | Native location services |

## Current Custom Widgets

### DeliveryTypeStatus
- **Use Case**: Custom styling for delivery status display
- **Why Custom**: Specific color and text formatting requirements
- **Alternative**: Could potentially be done with Digia UI styling, but custom widget provides more control

## Adding New Widgets

1. Create a new `.dart` file in this directory
2. Implement the props class and widget following the pattern above
3. Add registration logic to the appropriate init method
4. Update this README with the new widget information
