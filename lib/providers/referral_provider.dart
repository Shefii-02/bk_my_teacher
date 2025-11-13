import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

// ✅ PROVIDER: Create the FutureProvider to load referral stats
final referralStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ApiService();
  final response = await api.referralStats(); // this should call your /referral/stats API
  return response ?? {};
});
