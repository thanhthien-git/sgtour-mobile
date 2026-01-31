import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:sgtourcus/api/api_service.dart';
import '../models/legal_document_model.dart';
import '../services/file/storage_service.dart';

final legalDocumentServiceProvider = Provider<LegalDocumentService>((ref) {
  return LegalDocumentService();
});

class LegalDocumentService {
  final ApiService _api = ApiService();
  static const String _boxName = 'legal_documents';
  static const String _fetchedKey = 'legal_documents_fetched';

  Future<void> fetchAndStoreLegalDocuments() async {
    try {
      final alreadyFetched =
          StorageService.instance.getBool(_fetchedKey) ?? false;
      if (alreadyFetched) {
        return;
      }

      final response = await _api.get('/legal-documents');
      final documents = (response.data as List)
          .map(
            (json) => LegalDocumentModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final box = await Hive.openBox<Map>(_boxName);
      for (final doc in documents) {
        final key = '${doc.type.value}_${doc.languageCode}';
        await box.put(key, doc.toJson());
      }

      await StorageService.instance.setBool(_fetchedKey, true);
    } catch (e) {
      print('Failed to fetch legal documents: $e');
    }
  }

  Future<LegalDocumentModel?> getDocument(
    LegalDocumentType type,
    String languageCode,
  ) async {
    try {
      final box = await Hive.openBox<Map>(_boxName);

      final requestedKey = '${type.value}_$languageCode';
      final requestedDoc = box.get(requestedKey);
      if (requestedDoc != null) {
        return LegalDocumentModel.fromJson(
          Map<String, dynamic>.from(requestedDoc),
        );
      }

      final englishKey = '${type.value}_en';
      final englishDoc = box.get(englishKey);
      if (englishDoc != null) {
        return LegalDocumentModel.fromJson(
          Map<String, dynamic>.from(englishDoc),
        );
      }

      // Fallback to first available document of this type
      for (final key in box.keys) {
        if (key.toString().startsWith(type.value)) {
          final doc = box.get(key);
          if (doc != null) {
            return LegalDocumentModel.fromJson(Map<String, dynamic>.from(doc));
          }
        }
      }

      return null;
    } catch (e) {
      print('Failed to get legal document: $e');
      return null;
    }
  }

  /// Clears all stored legal documents and resets the fetched flag
  /// Useful for testing or forcing a re-fetch
  Future<void> clearDocuments() async {
    try {
      final box = await Hive.openBox<Map>(_boxName);
      await box.clear();
      await StorageService.instance.setBool(_fetchedKey, false);
    } catch (e) {
      print('Failed to clear legal documents: $e');
    }
  }
}
