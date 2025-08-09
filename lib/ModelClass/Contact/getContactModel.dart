import 'package:project/Bloc/Response/errorResponse.dart';

/// success : true
/// data : {"status":true,"contact":{"contactAddress":"Pavoorchathram","contactPhone":"6374073525","contactMail":"paulrajmmc@gmail.com","contactGoogleMap":"https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d7883.212885713128!2d77.37161144614221!3d8.91612993916573!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3b04262900000001%3A0x9b2e7842b3ce4498!2sPAUL%20DENTAL%20CARE!5e0!3m2!1sen!2sin!4v1742038295303!5m2!1sen!2sin"}}
/// message : "Contact List"

class GetContactModel {
  GetContactModel({
    bool? success,
    Data? data,
    String? message,
    ErrorResponse? errorResponse,
  }) {
    _success = success;
    _data = data;
    _message = message;
  }

  GetContactModel.fromJson(dynamic json) {
    _success = json['success'];
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
    _message = json['message'];
    if (json['errors'] != null && json['errors'] is Map<String, dynamic>) {
      errorResponse = ErrorResponse.fromJson(json['errors']);
    } else {
      errorResponse = null;
    }
  }
  bool? _success;
  Data? _data;
  String? _message;
  ErrorResponse? errorResponse;
  GetContactModel copyWith({
    bool? success,
    Data? data,
    String? message,
  }) =>
      GetContactModel(
        success: success ?? _success,
        data: data ?? _data,
        message: message ?? _message,
      );
  bool? get success => _success;
  Data? get data => _data;
  String? get message => _message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    map['message'] = _message;
    if (errorResponse != null) {
      map['errors'] = errorResponse!.toJson();
    }
    return map;
  }
}

/// status : true
/// contact : {"contactAddress":"Pavoorchathram","contactPhone":"6374073525","contactMail":"paulrajmmc@gmail.com","contactGoogleMap":"https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d7883.212885713128!2d77.37161144614221!3d8.91612993916573!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3b04262900000001%3A0x9b2e7842b3ce4498!2sPAUL%20DENTAL%20CARE!5e0!3m2!1sen!2sin!4v1742038295303!5m2!1sen!2sin"}

class Data {
  Data({
    bool? status,
    Contact? contact,
  }) {
    _status = status;
    _contact = contact;
  }

  Data.fromJson(dynamic json) {
    _status = json['status'];
    _contact =
        json['contact'] != null ? Contact.fromJson(json['contact']) : null;
  }
  bool? _status;
  Contact? _contact;
  Data copyWith({
    bool? status,
    Contact? contact,
  }) =>
      Data(
        status: status ?? _status,
        contact: contact ?? _contact,
      );
  bool? get status => _status;
  Contact? get contact => _contact;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    if (_contact != null) {
      map['contact'] = _contact?.toJson();
    }
    return map;
  }
}

/// contactAddress : "Pavoorchathram"
/// contactPhone : "6374073525"
/// contactMail : "paulrajmmc@gmail.com"
/// contactGoogleMap : "https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d7883.212885713128!2d77.37161144614221!3d8.91612993916573!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3b04262900000001%3A0x9b2e7842b3ce4498!2sPAUL%20DENTAL%20CARE!5e0!3m2!1sen!2sin!4v1742038295303!5m2!1sen!2sin"

class Contact {
  Contact({
    String? contactAddress,
    String? contactPhone,
    String? contactMail,
    String? contactGoogleMap,
  }) {
    _contactAddress = contactAddress;
    _contactPhone = contactPhone;
    _contactMail = contactMail;
    _contactGoogleMap = contactGoogleMap;
  }

  Contact.fromJson(dynamic json) {
    _contactAddress = json['contactAddress'];
    _contactPhone = json['contactPhone'];
    _contactMail = json['contactMail'];
    _contactGoogleMap = json['contactGoogleMap'];
  }
  String? _contactAddress;
  String? _contactPhone;
  String? _contactMail;
  String? _contactGoogleMap;
  Contact copyWith({
    String? contactAddress,
    String? contactPhone,
    String? contactMail,
    String? contactGoogleMap,
  }) =>
      Contact(
        contactAddress: contactAddress ?? _contactAddress,
        contactPhone: contactPhone ?? _contactPhone,
        contactMail: contactMail ?? _contactMail,
        contactGoogleMap: contactGoogleMap ?? _contactGoogleMap,
      );
  String? get contactAddress => _contactAddress;
  String? get contactPhone => _contactPhone;
  String? get contactMail => _contactMail;
  String? get contactGoogleMap => _contactGoogleMap;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['contactAddress'] = _contactAddress;
    map['contactPhone'] = _contactPhone;
    map['contactMail'] = _contactMail;
    map['contactGoogleMap'] = _contactGoogleMap;
    return map;
  }
}
