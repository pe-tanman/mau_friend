class CustomWidgetInfo {
  final String name;
  final String iconLink;
  final String status;

  CustomWidgetInfo({
    required this.name,
    required this.iconLink,
    required this.status,
  });


  CustomWidgetInfo.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String,
      iconLink = json['iconLink'] as String,
      status = json['status'] as String;

  Map<String, dynamic> toJson() => {
    'name': name,
    'iconLink': iconLink,
    'status': status,
  };
}
