import 'package:logger/logger.dart';

Logger get logger => _logger;

final Logger _logger = Logger(
  printer: PrettyPrinter(
    dateTimeFormat: DateTimeFormat.dateAndTime,
  ),
);