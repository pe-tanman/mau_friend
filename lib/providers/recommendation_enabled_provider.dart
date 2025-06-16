import 'package:mau_friend/utilities/prefs_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class RecommendationEnabledProvider extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> loadRecommendationPrefs() async {
    final result = await PrefsHelper().getRecommendationEnabled();
    state = result;
  }
}

final recommendationEnabledProvider =
    NotifierProvider<RecommendationEnabledProvider, bool>(
      RecommendationEnabledProvider.new,
    );