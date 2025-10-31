import 'package:homy/models/property/property_data.dart';

class FetchPropertyTourData {
  FetchPropertyTourData({
    int? id,
    int? userId,
    int? propertyId,
    int? propertyUserId,
    String? timeZone,
    int? tourStatus,
    String? createdAt,
    String? updatedAt,
    String? tourStatusText,
    String? statusType,
    PropertyData? property,
    PaymentDetails? payment,
    ClientData? user,
    bool? userConfirmedComplete,
    String? completionStatus,
    String? tourTime
  }) {
    _id = id;
    _userId = userId;
    _propertyId = propertyId;
    _propertyUserId = propertyUserId;
    _timeZone = timeZone;
    _tourStatus = tourStatus;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _property = property;
    _payment = payment;
    _tourStatusText = tourStatusText;
    _statusType = statusType;
    _userConfirmedComplete = userConfirmedComplete;
    _completionStatus = completionStatus;
    _tourTime = tourTime;


  }

  FetchPropertyTourData.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _propertyId = json['property_id'];
    _propertyUserId = json['agent_id'];
    _timeZone = json['time_zone'];
    _tourStatus = json['tour_status'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _tourStatusText = json['tour_status_text'];
    _statusType = json['status_type'];
    _tourTime = json['tour_time'];
    _completionStatus = json['completion_status'];
    _payment = json['payment_details'] != null
        ? PaymentDetails.fromJson(json['payment_details'])
        : null;
    _property = json['property'] != null
        ? PropertyData.fromJson(json['property'])
        : null;
    _userConfirmedComplete = json['user_confirmed_complete'] ?? false;
    _user = json['user_details'] != null
        ? ClientData.fromJson(json['user_details'])
        : null;
  }

  int? _id;
  int? _userId;
  int? _propertyId;
  int? _propertyUserId;
  String? _timeZone;
  int? _tourStatus;
  String? _createdAt;
  String? _updatedAt;
  PropertyData? _property;
  String? _tourStatusText;
  String? _statusType;
  bool? _userConfirmedComplete;
  String? _completionStatus;
  String? _tourTime;
  PaymentDetails? _payment;
  ClientData? _user;
  int? get id => _id;

  int? get userId => _userId;

  int? get propertyId => _propertyId;

  int? get propertyUserId => _propertyUserId;

  String? get timeZone => _timeZone;

  String? get tourTime => _tourTime;


  int? get tourStatus => _tourStatus;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  String? get tourStatusText => _tourStatusText;

  String? get statusType => _statusType;

  PropertyData? get property => _property;

  bool? get userConfirmedComplete => _userConfirmedComplete;

  String? get completionStatus => _completionStatus;

  PaymentDetails? get payment => _payment;

  ClientData? get client => _user;

  void setPropertyData(PropertyData? property) {
    _property = property;
  }
  

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['property_id'] = _propertyId;
    map['property_user_id'] = _propertyUserId;
    map['time_zone'] = _timeZone;
    map['tour_status'] = _tourStatus;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['tour_status_text'] = _tourStatusText;
    map['status_type'] = _statusType;
    map['user_confirmed_complete'] = _userConfirmedComplete;
    map['completion_status'] = _completionStatus;

    if (_property != null) {
      map['property'] = _property?.toJson();
    }
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_payment != null) {
      map['payment_details'] = _payment?.toJson();
    }
    return map;
  }
}


class PaymentDetails {
  PaymentDetails({
    String? paymentStatus,
    String? paymentMethod,
    String? paymentDate,
    String? paymentId,
    String? paymentAmount,
  });

  PaymentDetails.fromJson(dynamic json) {
    _paymentStatus = json['payment_status'];
    _paymentMethod = json['payment_method'];
    _paymentDate = json['payment_date'];
    _paymentId = json['payment_id'];
    _paymentAmount = json['payment_amount'];
  }

  String? _paymentStatus;
  String? _paymentMethod;
  String? _paymentDate;
  String? _paymentId;
  String? _paymentAmount;
  String? get paymentStatus => _paymentStatus;
  String? get paymentMethod => _paymentMethod;
  String? get paymentDate => _paymentDate;
  String? get paymentId => _paymentId;
  String? get paymentAmount => _paymentAmount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['payment_status'] = _paymentStatus;
    map['payment_method'] = _paymentMethod;
    map['payment_date'] = _paymentDate;
    map['payment_id'] = _paymentId;
    return map;
  }
} 

class ClientData {
  ClientData({
    int? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? address,
    String? avatar,
  });

  ClientData.fromJson(dynamic json) {
    _id = json['user_id'] ?? 0;
    _name = json['name'];
    _email = json['email'];
    _phoneNumber = json['phone_number'];
    _avatar = json['avatar'];
  }

  int? _id;
  String? _name;
  String? _email;
  String? _phoneNumber;
  String? _avatar;
  
  int? get id => _id;      
  String? get name => _name;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get avatar => _avatar;
  
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_id'] = _id;
    map['name'] = _name;
    map['email'] = _email;
    map['phone_number'] = _phoneNumber;
    map['avatar'] = _avatar;
    return map;
  }
}   
