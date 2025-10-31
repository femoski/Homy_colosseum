// ignore_for_file: unnecessary_getters_setters

class Conversation {
  bool? _iBlocked;
  bool? _iAmBlocked;
  String? _conversationId;
  int? _deletedId;
  bool? _isDeleted;
  String? _lastMessage;
  String? _newMessage;
  int? _time;

  ChatUser? _user;

  Conversation(
      {bool? iBlocked,
      bool? iAmBlocked,
      String? conversationId,
      int? deletedId,
      bool? isDeleted,
      String? lastMessage,
      String? newMessage,
      int? time,
      ChatUser? user}) {
    if (iBlocked != null) {
      _iBlocked = iBlocked;
    }
    if (iAmBlocked != null) {
      _iAmBlocked = iAmBlocked;
    }
    if (conversationId != null) {
      _conversationId = conversationId;
    }
    if (deletedId != null) {
      _deletedId = deletedId;
    }
    if (isDeleted != null) {
      _isDeleted = isDeleted;
    }
    if (lastMessage != null) {
      _lastMessage = lastMessage;
    }
    if (newMessage != null) {
      _newMessage = newMessage;
    }
    if (time != null) {
      _time = time;
    }
    if (user != null) {
      _user = user;
    }
  }

  bool? get iBlocked => _iBlocked;

  bool? get iAmBlocked => _iAmBlocked;

  String? get conversationId => _conversationId;

  void setConversationId(String value) {
    _conversationId = value;
  }

  int? get deletedId => _deletedId;

  bool? get isDeleted => _isDeleted;

  String? get lastMessage => _lastMessage;

  String? get newMessage => _newMessage;

  int? get time => _time;

  ChatUser? get user => _user;

  Conversation.fromJson(Map<String, dynamic> json) {
    _iBlocked = json['iBlocked'];
    _iAmBlocked = json['iAmBlocked'];
    _conversationId = json['conversationId'];
    _deletedId = json['deletedId'];
    _isDeleted = json['isDeleted'];
    _lastMessage = json['lastMessage'];
    _newMessage = json['newMessage'];
    _time = json['time'];
    _user = json['user'] != null ? ChatUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['iBlocked'] = _iBlocked;
    data['iAmBlocked'] = _iAmBlocked;
    data['conversationId'] = _conversationId;
    data['deletedId'] = _deletedId;
    data['isDeleted'] = _isDeleted;
    data['lastMessage'] = _lastMessage;
    data['newMessage'] = _newMessage;
    data['time'] = _time;
    if (_user != null) {
      data['user'] = _user!.toJson();
    }
    return data;
  }
}

class ChatUser {
  int? _userID;
  String? _identity;
  String? _image;
  String? _name;
  int? _userType;
  int? _msgCount;
  int? _verificationStatus;

  ChatUser(
      {int? userID,
      String? identity,
      String? image,
      String? name,
      int? userType,
      int? msgCount,
      int? verificationStatus}) {
    if (userID != null) {
      _userID = userID;
    }
    if (identity != null) {
      _identity = identity;
    }
    if (image != null) {
      _image = image;
    }
    if (name != null) {
      _name = name;
    }
    if (userType != null) {
      _userType = userType;
    }
    if (msgCount != null) {
      _msgCount = msgCount;
    }
    if (verificationStatus != null) {
      _verificationStatus = verificationStatus;
    }
  }

  ChatUser.fromJson(Map<String, dynamic> json) {
    _userID = json['userID'];
    _identity = json['identity'];
    _image = json['image'];
    _name = json['name'];
    _userType = json['userType'];
    _msgCount = json['msgCount'];
    _verificationStatus = json['verificationStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = _userID;
    data['identity'] = _identity;
    data['image'] = _image;
    data['name'] = _name;
    data['userType'] = _userType;
    data['msgCount'] = _msgCount;
    data['verificationStatus'] = _verificationStatus;
    return data;
  }

  int? get userID => _userID;

  String? get identity => _identity;

  String? get image => _image;

  String? get name => _name;

  int? get userType => _userType;

  int? get msgCount => _msgCount;

  int? get verificationStatus => _verificationStatus;

  set msgCount(int? value) {
    _msgCount = value;
  }

  set identity(String? value) {
    _identity = value;
  }

  set image(String? value) {
    _image = value;
  }

  set name(String? value) {
    _name = value;
  }

  set userType(int? value) {
    _userType = value;
  }

  set verificationStatus(int? value) {
    _verificationStatus = value;
  }
}
