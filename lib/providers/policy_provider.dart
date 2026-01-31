import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtourcus/models/legal_document_model.dart';
import 'package:sgtourcus/providers/locale_provider.dart';
import 'package:sgtourcus/services/legal_document_service.dart';

final policyProvider = FutureProvider.family<LegalDocumentModel, String>((
  ref,
  policyType,
) async {
  final localeState = ref.watch(localeProvider);
  final languageCode = localeState.locale.languageCode;

  final legalDocumentService = ref.read(legalDocumentServiceProvider);

  // Convert policyType string to enum
  final docType = policyType == 'privacy'
      ? LegalDocumentType.privacyPolicy
      : LegalDocumentType.termsOfService;

  final document = await legalDocumentService.getDocument(
    docType,
    languageCode,
  );

  if (document == null) {
    throw Exception('Document not found');
  }

  return document;
});
