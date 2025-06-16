import 'package:flutter/material.dart';
import 'package:mau_friend/providers/recommendation_enabled_provider.dart';
import 'package:mau_friend/utilities/prefs_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacySettingScreen extends ConsumerStatefulWidget {
  static const String routeName = '/privacy_setting';
  const PrivacySettingScreen({Key? key}) : super(key: key);

  @override
  _PrivacySettingScreenState createState() => _PrivacySettingScreenState();
}

class _PrivacySettingScreenState extends ConsumerState<PrivacySettingScreen> {
  bool _isRecommendationEnabled = false;

  @override
  void initState() {
    super.initState();
    _isRecommendationEnabled = ref.read(recommendationEnabledProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Favorite Place Recommendation'),
            subtitle: const Text('Enable recommendation of favorite places you often visit'),
            value: _isRecommendationEnabled,
            onChanged: (bool value) async{
              setState(() {
                _isRecommendationEnabled = value;
              });
                await PrefsHelper().updateRecommendationEnabled(value);
              ref
                  .read(recommendationEnabledProvider.notifier)
                  .loadRecommendationPrefs();
            },
          ),
        ],
      ),
    );
  }
}