import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mau_friend/providers/add_location_provider.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:mau_friend/screens/myaccount/add_location_screen.dart';
import 'package:mau_friend/utilities/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/recommendation';

  const RecommendationScreen({super.key});

  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  Map result = {};
  bool isLoading = true;
  PageController _pageController = PageController();
  List<Widget> pageList = [];

  Future<void> callLocationDataAnalysis() async {
    final behaviorData = await BehaviorDatabaseHelper().getJsonString();
    final callable = FirebaseFunctions.instance.httpsCallable(
      'analyze_behavior',
    );

    try {
      final call = await callable.call(behaviorData);
      result = call.data;
      addLocationScreenList();
      await Future.delayed(Duration(milliseconds: 300));
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error calling function: $e");
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing location data.')),
      );
    }
  }

  void initState() {
    super.initState();
    callLocationDataAnalysis();
  }

  void addLocationScreenList() {
    var list = <Widget>[];
    for (var location in result['suggested_status']) {
      list.add(
        AddLocationScreen(
          suggestedLocation: RegisteredLocation(
            name: location['status'],
            icon: location['emoji'],
            coordinates: LatLng(location['lat'], location['lng']),
            radius: location['radius'],
          ),
        ),
      );
    }
    pageList = list;
  }

  Future<void> goNextPage() async {
    final currentIndex = _pageController.page?.round() ?? 0;
    if (currentIndex < pageList.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      await Future.delayed(Duration(milliseconds: 300));
      pageList.removeAt(currentIndex);
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All suggestions have been checked!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          (isLoading)
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Analyzing your location data...'),
                    SizedBox(height: 30),
                    LinearProgressIndicator(),
                  ],
                ),
              )
              : Stack(
                children: [
                    PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    children: pageList,
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 30,
                      ),
                      color: Theme.of(context).scaffoldBackgroundColor,
                      height: 130,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                goNextPage();
                              },
                              label: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                ),
                                child: Text("Discard"),
                              ),
                              icon: Icon(Icons.close),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                final locationData = ref.read(
                                  addLocationProvider,
                                );
                                MyLocationDatabaseHelper().insertData(
                                  locationData.name,
                                  locationData.icon,
                                  locationData.coordinates,
                                  locationData.radius,
                                );
                                goNextPage();
                              },

                              label: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 10,
                                ),
                                child: Text("Add"),
                              ),
                              icon: Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
