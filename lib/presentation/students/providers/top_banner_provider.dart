
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/top_banner.dart';
import '../../../services/api_service.dart';

final topBannerProvider = FutureProvider<List<TopBanner>>((ref) async {
  final api = ApiService();
  return await api.fetchTopBanners();
});
