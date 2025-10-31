

import 'package:homy/models/reels/reels_model.dart';

class FetchReels {
  FetchReels({
    bool? status,
    String? message,
    List<ReelData>? data,
  }) {
    _status = status;
    _message = message;
    _data = data;
  }

  FetchReels.fromJson(dynamic json) {
    _status = json['status'];
    _message = json['message'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(ReelData.fromJson(v));
      });
    }
  }

  bool? _status;
  String? _message;
  List<ReelData>? _data;

  bool? get status => _status;

  String? get message => _message;

  List<ReelData>? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['message'] = _message;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
