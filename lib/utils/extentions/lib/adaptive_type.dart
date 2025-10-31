import 'package:intl/intl.dart';

class Adapter {
  ///String to int
  static int? forceInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value == "") {
      return 0;
    }
    if (value is int) {
      return value;
    } else {
      try {
        return int.tryParse(value as String);
      } catch (e) {
        throw "$value is not valid parsable int";
      }
    }
  }

  double? forceDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value == "") {
      return 0.0;
    }
    if (value is double) {
      return value;
    } else {
      try {
        return double.tryParse(value as String);
      } catch (e) {
        throw "$value is not valid parsable double";
      }
    }
  }
}


extension A on int {
  String get numberFormat {
    return NumberFormat.compact().format(this);
  }

  String get getUserType {
    return this == 0
        ? 'Buyer'
        : this == 1
            ? 'Seller'
            : this == 2
                ? 'Broker'
                : 'Agency';
  }
}

// extension O on String {
//   String get image {
//     return '${ConstRes.itemBase}$this';
//   }

//   String getUserType(int userType) {
//     return userType == 0
//         ? S.current.buyer
//         : userType == 1
//             ? S.current.seller
//             : userType == 2
//                 ? S.current.broker
//                 : S.current.agency;
//   }
// }
