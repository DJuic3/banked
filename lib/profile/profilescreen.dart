
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late Future<Map<String, String>> _userDetailsFuture;



  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _userDetailsFuture = getUserDetails();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<Map<String, String>> getUserDetails() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (firebaseUser != null) {
        String? userName = firebaseUser.displayName;
        String? userEmail = firebaseUser.email;
        String? photoUrl = firebaseUser.photoURL;

        // Save the user details to shared preferences
        await prefs.setString('userName', userName ?? '');
        await prefs.setString('userEmail', userEmail ?? '');
        await prefs.setString('photoUrl', photoUrl ?? '');

        // Retrieve additional user information from SharedPreferences
        String country = prefs.getString('country') ?? '';
        String phoneNumber = prefs.getString('phoneNumber') ?? '';
        String yearOfCompletion = prefs.getString('yearOfCompletion') ?? '';
        String faculty = prefs.getString('faculty') ?? '';
        String registrationNumber = prefs.getString('registrationNumber') ?? '';
        String currentOccupation = prefs.getString('currentOccupation') ?? '';

        // Check if the user has already updated their profile
        bool hasUpdatedProfile = prefs.getBool('hasUpdatedProfile') ?? false;

        return {
          'userName': userName ?? '',
          'userEmail': userEmail ?? '',
          'userPhoto': photoUrl ?? '',
          'hasUpdatedProfile': hasUpdatedProfile.toString(),
          'country': country,
          'phoneNumber': phoneNumber,
          'yearOfCompletion': yearOfCompletion,
          'faculty': faculty,
          'registrationNumber': registrationNumber,
          'currentOccupation': currentOccupation,
        };
      }

      // If the user is not already signed in, initiate Google sign-in
      GoogleSignInAccount? googleUser = await _signInWithGoogle();
      if (googleUser != null) {
        String? userName = googleUser.displayName;
        String? userEmail = googleUser.email;
        String? photoUrl = googleUser.photoUrl;

        // Save the user details to shared preferences
        await prefs.setString('userName', userName ?? '');
        await prefs.setString('userEmail', userEmail ?? '');
        await prefs.setString('photoUrl', photoUrl ?? '');

        return {
          'userName': userName ?? '',
          'userEmail': userEmail ?? '',
          'userPhoto': photoUrl ?? '',
          'hasUpdatedProfile': 'false',
          'country': '',
          'phoneNumber': '',
          'yearOfCompletion': '',
          'faculty': '',
          'registrationNumber': '',
          'currentOccupation': '',
        };
      }
    } catch (e) {
      print('Error retrieving user details: $e');
    }

    return {
      'userName': '',
      'userEmail': '',
      'userPhoto': '',
      'hasUpdatedProfile': 'false',
      'country': '',
      'phoneNumber': '',
      'yearOfCompletion': '',
      'faculty': '',
      'registrationNumber': '',
      'currentOccupation': '',
    };
  }
  Future<void> _requestVerification(Map<String, String> userDetails, BuildContext context) async {
    try {
      // Check if a verification request already exists
      QuerySnapshot existingRequests = await FirebaseFirestore.instance
          .collection('verified')
          .where('userEmail', isEqualTo: userDetails['userEmail'])
          .get();

      if (existingRequests.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('A verification request already exists for this account.')),
        );
        return;
      }

      // Create a new verification request
      await FirebaseFirestore.instance.collection('verified').add({
        'userId': userDetails['userId'],
        'userName': userDetails['userName'],
        'userEmail': userDetails['userEmail'],
        'verified': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Find an admin user
      QuerySnapshot adminUsers = await FirebaseFirestore.instance
          .collection('users')
          .where('isAdmin', isEqualTo: true)
          .limit(1)
          .get();

      if (adminUsers.docs.isNotEmpty) {
        String adminId = adminUsers.docs.first.id;
        // Here you could send a notification to the admin
        // For now, we'll just print the admin ID
        print('Notification sent to admin: $adminId');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification request sent successfully!')),
      );
    } catch (e) {
      print('Error sending verification request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification request. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 3,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF5F5F5),
                  Color(0xFFF5F5F5)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'PROFILE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: 1.2,
                  color: Colors.black,
                ),
              ),

            ],

          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blue[800],
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Personal Info'),
              // Tab(text: 'Educational Info'),
            ],
          ),
          centerTitle: true,
        ),

      ),

      body: FutureBuilder<Map<String, String>>(
        future: _userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SpinKitThreeBounce(
                color: Colors.blue[800],
                size: 10.0,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No Data Available',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          } else {
            final userDetails = snapshot.data!;
            final bool hasUpdatedProfile = userDetails['hasUpdatedProfile'] == 'true';

            return TabBarView(
              controller: _tabController,
              children: [
                _buildPersonalInfoTab(userDetails, context),
                // _buildEducationalInfoTab(hasUpdatedProfile),
              ],
            );
          }
        },
      ),
    );
  }
  Widget _buildPersonalInfoTab(Map<String, String> userDetails, BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: userDetails['userPhoto'] != null && userDetails['userPhoto']!.isNotEmpty
                    ? NetworkImage(userDetails['userPhoto']!)
                    : null,
                child: userDetails['userPhoto'] == null || userDetails['userPhoto']!.isEmpty
                    ? Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.grey[400],
                )
                    : null,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Text(
          userDetails['userName']!,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 5),
        Text(
          userDetails['userEmail']!,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Full name',
                    border: UnderlineInputBorder(),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[600],
                    ),
                  ),
                  controller: TextEditingController(
                    text: userDetails['userName'],
                  ),
                  enabled: false,
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: UnderlineInputBorder(),
                    labelStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[600],
                    ),
                  ),
                  controller: TextEditingController(
                    text: userDetails['userEmail'],
                  ),
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 30),

      ],
    );
  }
  Widget _buildEducationalInfoTab(bool hasUpdatedProfile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(24.0),
        children: [
          if (!hasUpdatedProfile)
            _buildProfileInfoCard()
          else
            _buildProfileInfoCard(),
        ],
      ),
    );
  }
  Widget _buildProfileInfoCard() {
    return FutureBuilder<Map<String, String>>(
      future: getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return Text('No data available');
        }

        final userData = snapshot.data!;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: Colors.blue.withOpacity(0.2),
          child: Container(
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF3E5F5)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completed',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                SizedBox(height: 24),
                // _buildInfoItem('Registration Number', userData['registrationNumber'] ?? ''),
                // _buildInfoItem('Faculty', userData['faculty'] ?? ''),
                // _buildInfoItem('Department', _selectedDepartment ?? ''),
                // _buildInfoItem('Phone Number', userData['phoneNumber'] ?? ''),
                // _buildInfoItem('Current Occupation', userData['currentOccupation'] ?? ''),
                // _buildInfoItem('Year of completion', userData['yearOfCompletion'] ?? ''),
                // _buildInfoItem('Country Located In', userData['country'] ?? ''),
                // _buildInfoItem('Degrees', _selectedDegrees.join(', ')),
              ],
            ),
          ),
        );
      },
    );
  }


}
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
    'photoUrl',
    'birthday'
  ],
);
Future<GoogleSignInAccount?> _signInWithGoogle() async {
  try {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return null;
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with the credential
    await FirebaseAuth.instance.signInWithCredential(credential);

    // Return the GoogleSignInAccount
    return googleUser;
  } catch (e) {
    if (e is FirebaseAuthException &&
        e.code == 'provider-already-linked') {
      // If the provider is already linked, return the current user
      return FirebaseAuth.instance.currentUser != null
          ? await GoogleSignIn().signInSilently()
          : null;
    }
    print('Error during Google Sign-In: $e');
    return null;
  }
}

