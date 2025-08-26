class Provider {
  final String id;
  final String firstName;
  final String lastName;
  final String directPhoneNumber;
  final String email;
  final String fullCompanyName;
  final String businessAddress;
  final String salesPerson;
  final String purchasePlan;
  final String shippingAddress;
  final String package;
  final String? additionalNotes;
  final bool isApproved;
  final DateTime registrationDate;
  final DateTime? approvalDate;
  final String country; // Add country field

  Provider({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.directPhoneNumber,
    required this.email,
    required this.fullCompanyName,
    required this.businessAddress,
    required this.salesPerson,
    required this.purchasePlan,
    required this.shippingAddress,
    required this.package,
    this.additionalNotes,
    this.isApproved = false,
    required this.registrationDate,
    this.approvalDate,
    this.country = 'USA', // Default to USA
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      directPhoneNumber: json['directPhoneNumber'],
      email: json['email'],
      fullCompanyName: json['fullCompanyName'],
      businessAddress: json['businessAddress'],
      salesPerson: json['salesPerson'],
      purchasePlan: json['purchasePlan'],
      shippingAddress: json['shippingAddress'],
      package: json['package'],
      additionalNotes: json['additionalNotes'],
      isApproved: json['isApproved'] ?? false,
      registrationDate: DateTime.parse(json['registrationDate']),
      approvalDate: json['approvalDate'] != null 
          ? DateTime.parse(json['approvalDate']) 
          : null,
      country: json['country'] ?? 'USA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'directPhoneNumber': directPhoneNumber,
      'email': email,
      'fullCompanyName': fullCompanyName,
      'businessAddress': businessAddress,
      'salesPerson': salesPerson,
      'purchasePlan': purchasePlan,
      'shippingAddress': shippingAddress,
      'package': package,
      'additionalNotes': additionalNotes,
      'isApproved': isApproved,
      'registrationDate': registrationDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'country': country,
    };
  }

  Provider copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? directPhoneNumber,
    String? email,
    String? fullCompanyName,
    String? businessAddress,
    String? salesPerson,
    String? purchasePlan,
    String? shippingAddress,
    String? package,
    String? additionalNotes,
    bool? isApproved,
    DateTime? registrationDate,
    DateTime? approvalDate,
    String? country,
  }) {
    return Provider(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      directPhoneNumber: directPhoneNumber ?? this.directPhoneNumber,
      email: email ?? this.email,
      fullCompanyName: fullCompanyName ?? this.fullCompanyName,
      businessAddress: businessAddress ?? this.businessAddress,
      salesPerson: salesPerson ?? this.salesPerson,
      purchasePlan: purchasePlan ?? this.purchasePlan,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      package: package ?? this.package,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      isApproved: isApproved ?? this.isApproved,
      registrationDate: registrationDate ?? this.registrationDate,
      approvalDate: approvalDate ?? this.approvalDate,
      country: country ?? this.country,
    );
  }

  // Getter for full name
  String get fullName => '$firstName $lastName';
}
