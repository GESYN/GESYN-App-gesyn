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
}

class CurrentSubscription {
  final SubscriptionInfo subscription;
  final Limits limits;
  final Usage usage;
  final NextPayment? nextPayment;

  CurrentSubscription({
    required this.subscription,
    required this.limits,
    required this.usage,
    this.nextPayment,
  });

  factory CurrentSubscription.fromJson(Map<String, dynamic> json) {
    return CurrentSubscription(
      subscription: SubscriptionInfo.fromJson(json['subscription'] ?? {}),
      limits: Limits.fromJson(json['limits'] ?? {}),
      usage: Usage.fromJson(json['usage'] ?? {}),
      nextPayment: json['nextPayment'] != null
          ? NextPayment.fromJson(json['nextPayment'])
          : null,
    );
  }
}

class SubscriptionInfo {
  final String id;
  final String planName;
  final String planDisplayName;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int daysRemaining;

  SubscriptionInfo({
    required this.id,
    required this.planName,
    required this.planDisplayName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.daysRemaining,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      id: json['id'] ?? '',
      planName: json['planName'] ?? '',
      planDisplayName: json['planDisplayName'] ?? '',
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['endDate'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? '',
      daysRemaining: json['daysRemaining'] ?? 0,
    );
  }
}

class Limits {
  final int maxDevices;
  final int maxReadingsPerDay;

  Limits({required this.maxDevices, required this.maxReadingsPerDay});

  factory Limits.fromJson(Map<String, dynamic> json) {
    return Limits(
      maxDevices: json['maxDevices'] ?? 0,
      maxReadingsPerDay: json['maxReadingsPerDay'] ?? 0,
    );
  }
}

class Usage {
  final int devicesUsed;
  final List<DeviceReading> todayReadings;

  Usage({required this.devicesUsed, required this.todayReadings});

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      devicesUsed: json['devicesUsed'] ?? 0,
      todayReadings:
          (json['todayReadings'] as List?)
              ?.map((e) => DeviceReading.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DeviceReading {
  final String deviceId;
  final String deviceName;
  final int count;

  DeviceReading({
    required this.deviceId,
    required this.deviceName,
    required this.count,
  });

  factory DeviceReading.fromJson(Map<String, dynamic> json) {
    return DeviceReading(
      deviceId: json['deviceId'] ?? '',
      deviceName: json['deviceName'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class NextPayment {
  final DateTime dueDate;
  final double amount;

  NextPayment({required this.dueDate, required this.amount});

  factory NextPayment.fromJson(Map<String, dynamic> json) {
    return NextPayment(
      dueDate: DateTime.parse(
        json['dueDate'] ?? DateTime.now().toIso8601String(),
      ),
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}

class CheckoutResponse {
  final String checkoutUrl;
  final String sessionId;
  final String? message;

  CheckoutResponse({
    required this.checkoutUrl,
    required this.sessionId,
    this.message,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      checkoutUrl: json['checkoutUrl'] ?? '',
      sessionId: json['sessionId'] ?? '',
      message: json['message'],
    );
  }
}
