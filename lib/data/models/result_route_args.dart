import 'dart:typed_data';

import 'package:ai_app/data/models/upload_history_model.dart';

class ResultRouteArgs {
  const ResultRouteArgs({
    required this.session,
    this.fileBytes,
  });

  final UploadHistoryModel session;
  final Uint8List? fileBytes;
}
