class SubscriptionPlan {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final double price;
  final String currency;
  final int maxDevices;
  final int maxReadingsPerDay;
  final List<String> features;
  final List<int> durations;
  final bool isActive;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.price,
    required this.currency,
    required this.maxDevices,
    required this.maxReadingsPerDay,
    required this.features,
    required this.durations,
    required this.isActive,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'BRL',
      maxDevices: json['maxDevices'] ?? 0,
      maxReadingsPerDay: json['maxReadingsPerDay'] ?? 0,
      features: List<String>.from(json['features'] ?? []),
      durations: List<int>.from(json['durations'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }

  bool get isUnlimited => maxDevices == -1 || maxReadingsPerDay == -1;
  bool get isFree => price == 0;
}
