import 'dart:convert';

import 'package:ai_app/core/utils/app_constants.dart';
import 'package:ai_app/data/models/upload_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  late final SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  List<UploadHistoryModel> getHistory() {
    final rawItems =
        _preferences.getStringList(AppConstants.historyStorageKey) ?? <String>[];

    final history = rawItems
        .map(
          (String item) => UploadHistoryModel.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();

    history.sort(
      (UploadHistoryModel a, UploadHistoryModel b) =>
          b.createdAt.compareTo(a.createdAt),
    );

    return history;
  }

  Future<void> saveSession(UploadHistoryModel session) async {
    final history = getHistory()
      ..removeWhere((UploadHistoryModel item) => item.id == session.id)
      ..insert(0, session);

    await _persist(history);
  }

  Future<void> updateSession(UploadHistoryModel session) async {
    final history = getHistory();
    final index = history.indexWhere(
      (UploadHistoryModel item) => item.id == session.id,
    );

    if (index >= 0) {
      history[index] = session;
    } else {
      history.insert(0, session);
    }

    await _persist(history);
  }

  Future<void> _persist(List<UploadHistoryModel> history) async {
    final trimmed = history.take(AppConstants.maxHistoryItems).toList();

    await _preferences.setStringList(
      AppConstants.historyStorageKey,
      trimmed
          .map((UploadHistoryModel item) => jsonEncode(item.toJson()))
          .toList(),
    );
  }
}
