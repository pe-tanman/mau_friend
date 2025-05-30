import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:mau_friend/providers/my_status_provider.dart';
import 'package:mau_friend/screens/welcome/authGate.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/themes/app_theme.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/link.dart';

class WelcomeScreen extends StatefulWidget {
  static const routeName = '/welcome';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                _buildAboutTab(),
                _buildFeaturesTab(),
                _buildPermissionTab(),
                _buildLoginTab(),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController, // PageController

            count: 4,
            effect: WormEffect(
              dotHeight: 10,
              dotWidth: 10,
              activeDotColor: AppColors.themeColor,
            ), // your preferred effect
            onDotClicked: (index) {},
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 60),
            Lottie.asset(
              'lib/assets/lotties/welcome_animation.json',
              height: 500,
            ),
            SizedBox(height: 30),
            Text('Welcome to mau', style: appTheme().textTheme.titleMedium),
            SizedBox(height: 30),
            primaryButton('Continue', () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Privacy and Peace',
              style: appTheme().textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 40),
          Card(
            elevation: 0,
          color: Colors.white,
          child:
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text('🤝', style: TextStyle(
                    fontSize: 30,
                  ),),
                  SizedBox(width: 10),
                  Text(
                    'Our Promise to You',
                    style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.themeColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Your location and familiar places are stored locally, never shared.',
                style: TextStyle(fontSize: 16, color: AppColors.themeColor),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '*Exept for Feeling Unsafe Mode',
                style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.themeColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
              ],
            ),
          )
          ),
          
          SizedBox(height: 30),
          Center(
            child: Link(
              uri: Uri.parse(
          'https://petanman.notion.site/Privacy-Policy-1efe73611a8f804388a5d41b98b7165f?pvs=4',
              ),
              target: LinkTarget.blank,
              builder: (BuildContext ctx, FollowLink? openLink) {
          return TextButton(
            onPressed: openLink,
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.open_in_new, color: AppColors.linkTextColor),
                SizedBox(width: 5),
                Text(
            'Our Privacy Policy',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.linkTextColor,
              decoration: TextDecoration.underline,
            ),
                ),
              ],
            ),
          );
              },
            ),
          ),
          SizedBox(height: 30),
          primaryButton('Accept and Continue', () {
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPermissionTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 70),
            Text(
              'Permissions',
              style: appTheme().textTheme.titleMedium,
            ),
            Lottie.asset(
              'lib/assets/lotties/location_animation.json',
              height: 300,
            ),
            Text(
              "To successfully share your status with your friends:",
              style: TextStyle(color: AppColors.darkText1),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
                vertical: 5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "✅ Allow Precise Location",
                    style: appTheme().textTheme.headlineSmall,
                  ),
                  Text(
                    "✅ Always Allow Location",
                    style: appTheme().textTheme.headlineSmall,
                  ),
                  Text(
                    "✅ Allow Notifications",
                    style: appTheme().textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            primaryButton('Continue', () {
              MyStatusProvider().initLocationSetting().then((_) {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('lib/assets/images/Group 9.svg'),
          SizedBox(height: 100),
          primaryButton('Get Started', () {
            Navigator.pushNamed(context, AuthGate.routeName);
          }),
          //add login button
        ],
      ),
    );
  }
}

Widget primaryButton(String text, VoidCallback onPressed) {
  return ElevatedButton(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(AppColors.themeColor),
    ),
    onPressed: onPressed,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.lightText1,
        ),
      ),
    ),
  );
}
