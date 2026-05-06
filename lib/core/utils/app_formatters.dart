import 'package:intl/intl.dart';

abstract final class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormatter = DateFormat('dd MMM yyyy, hh:mm a');

  static String currency(num value) => _currencyFormatter.format(value);

  static String dateTime(DateTime value) => _dateFormatter.format(value);
}
