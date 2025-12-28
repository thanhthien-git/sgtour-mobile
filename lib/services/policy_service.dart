import 'package:sgtour_mobile/api/api_service.dart';
import 'package:sgtour_mobile/models/policy_model.dart';
import 'package:sgtour_mobile/services/storage_service.dart';

/// Service for fetching and managing policy content
class PolicyService {
  static const String _cachePrefixKey = 'policy_cache_';
  static const String _cacheExpiryPrefixKey = 'policy_cache_expiry_';
  static const Duration _cacheExpiry = Duration(days: 7);

  final ApiService _apiService = ApiService();

  Future<PolicyModel> fetchPolicy(
    String policyType,
    String languageCode,
  ) async {
    try {
      final cached = _getCachedPolicy(policyType, languageCode);
      if (cached != null) {
        return cached;
      }

      final response = await _apiService.get(
        '/policies/$policyType',
        queryParameters: {'languageCode': languageCode},
      );

      if (response.statusCode == 200 && response.data != null) {
        final policy = PolicyModel.fromJson(response.data);
        _cachePolicy(policyType, policy);
        return policy;
      }

      if (languageCode != 'en') {
        return fetchPolicy(policyType, 'en');
      }

      return _getDefaultPolicy(policyType);
    } catch (e) {
      final cached = _getCachedPolicy(policyType, languageCode);
      if (cached != null) {
        return cached;
      }

      if (languageCode != 'en') {
        return fetchPolicy(policyType, 'en');
      }

      return _getDefaultPolicy(policyType);
    }
  }

  PolicyModel? _getCachedPolicy(String policyType, String languageCode) {
    final cacheKey = _cachePrefixKey + policyType + '_' + languageCode;
    final expiryKey = _cacheExpiryPrefixKey + policyType + '_' + languageCode;

    try {
      final expiryTimeMs = StorageService.instance.getInt(expiryKey);
      if (expiryTimeMs != null &&
          DateTime.now().millisecondsSinceEpoch < expiryTimeMs) {
        final cachedJson = StorageService.instance.getString(cacheKey);
        if (cachedJson != null && cachedJson.isNotEmpty) {
          return null;
        }
      }
    } catch (_) {}

    return null;
  }

  void _cachePolicy(String policyType, PolicyModel policy) {
    try {
      final expiryKey =
          _cacheExpiryPrefixKey + policyType + '_' + policy.languageCode;
      final expiryTime = DateTime.now()
          .add(_cacheExpiry)
          .millisecondsSinceEpoch;

      StorageService.instance.setInt(expiryKey, expiryTime);
    } catch (_) {}
  }

  PolicyModel _getDefaultPolicy(String policyType) {
    final defaultContent = _getDefaultContent(policyType);
    return PolicyModel(
      title: policyType.toUpperCase(),
      content: defaultContent,
      languageCode: 'en',
    );
  }

  String _getDefaultContent(String policyType) {
    final defaults = {
      'privacy': '''PRIVACY POLICY

Last Updated: December 2025

1. Introduction
This privacy policy explains how we collect, use, and protect your information.

2. Information We Collect
We collect information you provide directly, such as:
- Account registration details
- Profile information
- Tour booking information
- Payment information
- Communication preferences

3. How We Use Your Information
We use your information to:
- Provide and improve our services
- Process your bookings
- Send you updates and notifications
- Comply with legal obligations

4. Data Security
We implement appropriate security measures to protect your personal information from unauthorized access, alteration, and disclosure.

5. Your Rights
You have the right to:
- Access your personal information
- Correct inaccurate data
- Request deletion of your data
- Opt-out of marketing communications

6. Contact Us
If you have questions about this privacy policy, please contact us at support@sgtour.com''',
      'terms': '''TERMS OF SERVICE

Last Updated: December 2025

1. Acceptance of Terms
By using this application, you agree to these terms and conditions.

2. User Responsibilities
You agree to:
- Provide accurate information
- Use the service lawfully
- Not engage in unauthorized activities
- Respect intellectual property rights

3. Booking and Cancellation
- Bookings are subject to availability
- Cancellation policies vary by tour
- Refunds are processed according to our policy

4. Limitation of Liability
We are not liable for indirect or consequential damages arising from your use of the service.

5. Intellectual Property
All content is protected by copyright. You may not reproduce or distribute without permission.

6. Modifications
We reserve the right to modify these terms at any time. Continued use constitutes acceptance.

7. Governing Law
These terms are governed by applicable law.

8. Contact
For terms inquiries, contact support@sgtour.com''',
    };

    return defaults[policyType] ??
        'Content not available. Please try again later.';
  }
}
