import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:mau_friend/screens/authGate.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/themes/app_theme.dart';




import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/link.dart';class WelcomeScreen extends StatefulWidget {
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
              controller: _pageController,
              children: [
                _buildAboutTab(),
                _buildFeaturesTab(),
                _buildLoginTab(),
              ],
            ),
          ),
          SmoothPageIndicator(    
   controller: _pageController,  // PageController    

   count:  3,    
   effect:  WormEffect(
    dotHeight: 10,
    dotWidth: 10,
    activeDotColor: AppColors.themeColor

   ),  // your preferred effect    
   onDotClicked: (index){    
  }
)  ,
SizedBox(height: 80,)
   
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
  return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100,),
            Text('Welcome to mau', style: appTheme().textTheme.titleMedium,),
            SizedBox(height:20),
            Text('')
            
          ],
        ),
    );
  }

  Widget _buildFeaturesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 100),
          Text('Your location is never shared.', style: appTheme().textTheme.titleMedium),
          SizedBox(height: 20,),
          Text('mau is far Safer than location sharing apps',
          style: appTheme().textTheme.headlineMedium,),
          SizedBox(height: 20),
          Text('Your data is processed and stored on your device.\nNo worry about stoking and privacy invasion.',
          style: appTheme().textTheme.bodyLarge),
          SizedBox(height: 50),
          Text('For more info about privacy,', style: appTheme().textTheme.bodyLarge),
          Link(
            // 開きたいWebページのURLを指定
            uri: Uri.parse('https://petanman.notion.site/Privacy-Policy-1efe73611a8f804388a5d41b98b7165f?pvs=4'),
            // targetについては後述
            target: LinkTarget.blank,
            builder: (BuildContext ctx, FollowLink? openLink) {
              return TextButton(
                onPressed: openLink,
                child: const Text('our Privacy Policy', style: TextStyle(fontSize: 16)),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  // minimumSize:
                  //     MaterialStateProperty.all(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              );
            },
          ),

        ],
      ),
    );
  }
  Widget _buildLoginTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s Get Started',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          primaryButton('Get Started', () {
            // Navigate to the login screen
            Navigator.pushNamed(context, AuthGate.routeName);
          }),
          //add login button
        ],
      ),
    );
  }
}