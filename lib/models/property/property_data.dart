
import 'package:homy/models/media.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/models/property/category_model.dart';
class PropertyData {
  PropertyData({
    int? id,
    int? userId,
    String? title,
    int? propertyTypeId,
    int? propertyCategory,
    int? bedrooms,
    int? bathrooms,
    double? area,
    String? about,
    String? address,
    String? city,
    String? latitude,
    String? longitude,
    String? farFromHospital,
    String? farFromSchool,
    String? farFromGym,
    String? farFromMarket,
    String? farFromGasoline,
    String? farFromAirport,
    String? societyName,
    int? builtYear,
    int? furniture,
    String? facing,
    int? totalFloors,
    int? floorNumber,
    int? carParkings,
    int? maintenanceMonth,
    int? propertyAvailableFor,
    int? firstPrice,
    int? secondPrice,
    int? isHidden,
    bool? isFeatured,
    bool? isLiked,
    String? createdAt,
    String? updatedAt,
    bool? savedProperty,
    String? propertyType,
    String? distance,
    String? tourBookingFee,
    List<PropertyData>? relatedProperty,
    String? period,
    bool? paymentStatus,  
    bool? isPaidByUser,
    bool? isNftMinted,

    // PropertyType? propertyType,
    List<Media>? media,
    UserData? user,
    Categorys? category,
  }) {
    _id = id;
    _userId = userId;
    _title = title;
    _propertyTypeId = propertyTypeId;
    _propertyCategory = propertyCategory;
    _bedrooms = bedrooms;
    _bathrooms = bathrooms;
    _area = area;
    _about = about;
    _address = address;
    _city = city;
    _latitude = latitude;
    _longitude = longitude;
    _farFromHospital = farFromHospital;
    _farFromSchool = farFromSchool;
    _farFromGym = farFromGym;
    _farFromMarket = farFromMarket;
    _farFromGasoline = farFromGasoline;
    _farFromAirport = farFromAirport;
    _societyName = societyName;
    _builtYear = builtYear;
    _furniture = furniture;
    _facing = facing;
    _totalFloors = totalFloors;
    _floorNumber = floorNumber;
    _carParkings = carParkings;
    _maintenanceMonth = maintenanceMonth;
    _propertyAvailableFor = propertyAvailableFor;
    _firstPrice = firstPrice;
    _secondPrice = secondPrice;
    _isHidden = isHidden;
    _isFeatured = isFeatured;
    _isLiked = isLiked;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _savedProperty = savedProperty;
    _relatedProperty = relatedProperty;
    _propertyType = propertyType;
    _media = media;
    _user = user;
    _category = category;
    _distance = distance;
    _tourBookingFee = tourBookingFee;
    _period = period;
    _paymentStatus = paymentStatus;
    _isPaidByUser = isPaidByUser;
    _isNftMinted = isNftMinted;
  }

  PropertyData.fromJson(dynamic json) {
    _id = json['id'];
    _userId = json['user_id'];
    _title = json['title'];
    _propertyTypeId = json['property_type_id'];
    _propertyCategory = json['property_category'];
    _bedrooms = json['bedrooms'];
    _bathrooms = json['bathrooms'];
    _area = json['area']?.toDouble();
    _about = json['about'];
    _address = json['address'];
    _city = json['city'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _farFromHospital = json['far_from_hospital'];
    _farFromSchool = json['far_from_school'];
    _farFromGym = json['far_from_gym'];
    _farFromMarket = json['far_from_market'];
    _farFromGasoline = json['far_from_gasoline'];
    _farFromAirport = json['far_from_airport'];
    _societyName = json['society_name'];
    _builtYear = json['built_year'];
    _furniture = json['furniture']??0;
    _facing = json['facing'];
    _totalFloors = json['total_floors'];
    _floorNumber = json['floor_number'];
    _carParkings = json['car_parkings'];
    _maintenanceMonth = json['maintenance_month'] ?? 0;
    _propertyAvailableFor = json['property_available_for'];
    _firstPrice = json['first_price'];
    _secondPrice = json['second_price'];
    _isHidden = json['is_hidden'];
    _isFeatured = json['is_featured'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _savedProperty = json['saved_property'];
    _propertyType = json['property_type'];
    _period = json['period'] ?? '';
    if (json['relatedProperty'] != null) {
      _relatedProperty = [];
      json['relatedProperty'].forEach((v) {
        _relatedProperty?.add(PropertyData.fromJson(v));
      });
    }
    _isLiked = json['is_liked'];
    // _propertyType = json['property_type'] != null
    //     ? PropertyType.fromJson(json['property_type'])
    //     : null;
    if (json['media'] != null) {
      _media = [];
      json['media'].forEach((v) {
        _media?.add(Media.fromJson(v));
      });
    }
    _user = json['agent'] != null ? UserData.fromJson(json['agent']) : null;
    _category = json['category'] != null ? Categorys.fromMap(json['category']) : null;
    _distance = json['distance'];
    _tourBookingFee = json['tour_booking_fee']??'1000';
    _paymentStatus = json['payment_status']??false;
    _isPaidByUser = json['is_paid_by_user']??false;
    _isNftMinted = json['is_nft_minted']??false;
  }

  int? _id;
  int? _userId;
  String? _title;
  int? _propertyTypeId;
  int? _propertyCategory;
  int? _bedrooms;
  int? _bathrooms;
  double? _area;
  String? _about;
  String? _address;
  String? _city;
  String? _latitude;
  String? _longitude;
  String? _farFromHospital;
  String? _farFromSchool;
  String? _farFromGym;
  String? _farFromMarket;
  String? _farFromGasoline;
  String? _farFromAirport;
  String? _societyName;
  int? _builtYear;
  int? _furniture;
  String? _facing;
  int? _totalFloors;
  int? _floorNumber;
  int? _carParkings;
  int? _maintenanceMonth;
  int? _propertyAvailableFor;
  int? _firstPrice;
  int? _secondPrice;
  int? _isHidden;
  bool? _isFeatured;
  bool? _isLiked;
  String? _createdAt;
  String? _updatedAt;
  bool? _savedProperty;
  List<PropertyData>? _relatedProperty;
  String? _propertyType;
  List<Media>? _media;
  UserData? _user;
  Categorys? _category;
  String? _distance;
  String? _tourBookingFee;
  String? _period;
  bool?  _paymentStatus;
  int? get id => _id;
  bool? _isPaidByUser;
  bool? _isNftMinted;
  int? get userId => _userId;

  String? get title => _title;

  int? get propertyTypeId => _propertyTypeId;

  int? get propertyCategory => _propertyCategory;

  int? get bedrooms => _bedrooms;

  int? get bathrooms => _bathrooms;

  double? get area => _area;

  String? get about => _about;

  String? get address => _address;

  String? get city => _city;

  String? get period => _period;

  String? get latitude => _latitude;

  String? get longitude => _longitude;

  String? get farFromHospital => _farFromHospital;

  String? get farFromSchool => _farFromSchool;

  String? get farFromGym => _farFromGym;

  String? get farFromMarket => _farFromMarket;

  String? get farFromGasoline => _farFromGasoline;

  String? get farFromAirport => _farFromAirport;

  String? get societyName => _societyName;

  int? get builtYear => _builtYear;

  int? get furniture => _furniture;

  String? get facing => _facing;

  int? get totalFloors => _totalFloors;

  int? get floorNumber => _floorNumber;

  int? get carParkings => _carParkings;

  int? get maintenanceMonth => _maintenanceMonth;

  int? get propertyAvailableFor => _propertyAvailableFor;

  int? get firstPrice => _firstPrice;

  int? get secondPrice => _secondPrice;

  int? get isHidden => _isHidden;

  bool? get isFeatured => _isFeatured;

  bool? get isLiked => _isLiked;

  String? get createdAt => _createdAt;

  String? get updatedAt => _updatedAt;

  bool? get savedProperty => _savedProperty;

  String? get distance => _distance;

  String? get tourBookingFee => _tourBookingFee;

  set savedProperty(bool? value) {
    _savedProperty = value;
  }

  set paymentStatus(bool? value) {
    _paymentStatus = value;
  }

  set isNftMinted(bool? value) {
    _isNftMinted = value;
  }

  List<PropertyData>? get relatedProperty => _relatedProperty;

  String? get propertyType => _propertyType;

  List<Media>? get media => _media;

  UserData? get user => _user;

  Categorys? get category => _category;

  bool? get paymentStatus => _paymentStatus;

  bool? get isPaidByUser => _isPaidByUser;

  bool? get isNftMinted => _isNftMinted;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['user_id'] = _userId;
    map['title'] = _title;
    map['property_type_id'] = _propertyTypeId;
    map['property_category'] = _propertyCategory;
    map['bedrooms'] = _bedrooms;
    map['bathrooms'] = _bathrooms;
    map['area'] = _area;
    map['about'] = _about;
    map['address'] = _address;
    map['city'] = _city;
    map['latitude'] = _latitude;
    map['longitude'] = _longitude;
    map['far_from_hospital'] = _farFromHospital;
    map['far_from_school'] = _farFromSchool;
    map['far_from_gym'] = _farFromGym;
    map['far_from_market'] = _farFromMarket;
    map['far_from_gasoline'] = _farFromGasoline;
    map['far_from_airport'] = _farFromAirport;
    map['society_name'] = _societyName;
    map['built_year'] = _builtYear;
    map['furniture'] = _furniture;
    map['facing'] = _facing;
    map['total_floors'] = _totalFloors;
    map['floor_number'] = _floorNumber;
    map['car_parkings'] = _carParkings;
    map['maintenance_month'] = _maintenanceMonth;
    map['property_available_for'] = _propertyAvailableFor;
    map['first_price'] = _firstPrice;
    map['second_price'] = _secondPrice;
    map['is_hidden'] = _isHidden;
    map['is_featured'] = _isFeatured;
    map['is_liked'] = _isLiked;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['saved_property'] = _savedProperty;
    map['property_type'] = _propertyType;
    map['distance'] = _distance;
    map['period'] = _period;
    if (_relatedProperty != null) {
      map['relatedProperty'] =
          _relatedProperty?.map((v) => v.toJson()).toList();
    }
    // if (_propertyType != null) {
    //   map['property_type'] = _propertyType?.toJson();
    // }
    if (_media != null) {
      map['media'] = _media?.map((v) => v.toJson()).toList();
    }
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    if (_category != null) {
      map['category'] = _category?.toMap();
    }
    map['tour_booking_fee'] = _tourBookingFee;
    map['payment_status'] = _paymentStatus;
    map['is_paid_by_user'] = _isPaidByUser;
    map['is_nft_minted'] = _isNftMinted;

    return map;
  }
}


class UtilitiesCustom {
  String image;
  String name;
  String duration;

  UtilitiesCustom(this.image, this.name, this.duration);
}
