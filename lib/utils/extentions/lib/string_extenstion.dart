import 'package:homy/utils/app_constant.dart';
import 'package:intl/intl.dart';

extension StringExtention<T extends String> on T {
  // T firstUpperCase() {
  //   String upperCase = "";
  //   var suffix = "";
  //   if (isNotEmpty) {
  //     upperCase = this[0].toUpperCase();
  //     suffix = substring(1, length);
  //   }
  //   return (upperCase + suffix) as T;
  // }

  ///Number with suffix 10k,10M ,1b
  String priceFormate({bool? disabled}) {
    double numericValue = double.parse(this);
    String formattedNumber = '';

    if (numericValue % 1 == 0) {
      /// If the numeric value is an integer, show it without decimal places
      formattedNumber = NumberFormat.compact().format(numericValue);
    } else {
      // If the numeric value has decimal places, format it with 2 decimal digits
      formattedNumber = NumberFormat('#,##0.00').format(numericValue);
    }

    // if (disabled == true) {
    //   return this;
    // }

    return formattedNumber;
  }
}

///Format string
extension FormatAmount on String {
  String formatAmount({bool prefix = false}) {
    return (prefix)
        ? "${Constant.currencySymbol}${toString()}"
        : "${toString()}${Constant.currencySymbol}"; // \u{20B9}"; //currencySymbol
  }

  String formatDate({
    String? format,
  }) {
    DateFormat dateFormat = DateFormat(format ?? "MMM d, yyyy");
    String formatted = dateFormat.format(DateTime.parse(this));
    return formatted;
  }

  String formatPercentage() {
    return "${toString()} %";
  }

  String formatId() {
    return " # ${toString()} "; // \u{20B9}"; //currencySymbol
  }

  String firstUpperCase() {
    String upperCase = "";
    var suffix = "";
    if (isNotEmpty) {
      upperCase = this[0].toUpperCase();
      suffix = substring(1, length);
    }
    return (upperCase + suffix);
  }
}



extension A on int {
  String get numberFormat {
    return NumberFormat.compact().format(this);
  }

  String get getUserType {
    return this == 0
        ? 'User'
        : this == 1
            ? 'Agent'
            : this == 2
                ? 'Broker'
                : this == 3
                    ? 'Agency'
                    : 'User';
  }
}

extension O on String {

  String getUserType(int userType) {
    return userType == 0
        ? 'Buyer'
        : userType == 1
            ? 'Seller'
            : userType == 2
                ? 'Broker'
                : 'Agency';
  }
}

extension QueryBuilder on String {
  String buildQuery(Map<String, dynamic>? queryParameters) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return this;
    }

    final Uri uri = Uri.parse(this);
    final Map<String, dynamic> existingParams = Map.from(uri.queryParameters);
    existingParams.addAll(queryParameters);

    final StringBuffer queryBuffer = StringBuffer(uri.path);
    if (existingParams.isNotEmpty) {
      queryBuffer.write('?');
      var first = true;
      existingParams.forEach((key, value) {
        if (!first) queryBuffer.write('&');
        queryBuffer.write('$key=${Uri.encodeComponent(value.toString())}');
        first = false;
      });
    }

    return queryBuffer.toString();
  }
}
