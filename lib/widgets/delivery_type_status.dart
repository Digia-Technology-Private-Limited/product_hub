import 'package:digia_ui/digia_ui.dart';
import 'package:flutter/material.dart';

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
    return Text(
      widget.title,
      style: TextStyle(color: widget.color),
    );
  }
}

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
