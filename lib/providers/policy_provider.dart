import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sgtour_mobile/models/policy_model.dart';
import 'package:sgtour_mobile/providers/locale_provider.dart';
import 'package:sgtour_mobile/services/policy_service.dart';

final policyProvider = FutureProvider.family<PolicyModel, String>((
  ref,
  policyType,
) async {
  final localeState = ref.watch(localeProvider);
  final languageCode = localeState.locale.languageCode;

  final policyService = PolicyService();
  return policyService.fetchPolicy(policyType, languageCode);
});
