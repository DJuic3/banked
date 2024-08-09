import 'package:bankedzw/ADMIN/REPORTS/reports.dart';
import 'package:bankedzw/ADMIN/USERMANAGEMENT/accountusers.dart';
import 'package:bankedzw/homescreen/stats/stats.dart';
import 'package:bankedzw/profile/profilescreen.dart';
import 'package:bankedzw/security/security.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../designation.dart';
import '../main.dart';
import '../unserved.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showLoginDialog = false;
  bool isAdmin = false;
  late final GoogleSignInAccount user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    checkAdminStatus();
    _getCurrentUser();
  }


  Future<void> logoutUser(BuildContext context) async {
    try {
      // Sign out from Google
      await GoogleSignIn().signOut();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to Login Page (assuming you have a LoginPage to redirect to)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      print('Error logging out: $e');
      // Optionally, show a dialog or snackbar to the user indicating the error
    }
  }
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                logoutUser(context); // Call the logout function
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> checkAdminStatus() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        // First, check if we have a cached admin status
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        bool? cachedAdminStatus = prefs.getBool('isAdmin');

        if (cachedAdminStatus != null) {
          setState(() {
            isAdmin = cachedAdminStatus;
          });
        } else {
          // If not cached, check Firestore
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();

          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            bool isAdminUser = userData['isAdmin'] ?? false;

            // Cache the admin status
            await prefs.setBool('isAdmin', isAdminUser);

            setState(() {
              isAdmin = isAdminUser;
            });
          } else {
            print('User document does not exist in Firestore');
          }
        }
      } catch (e) {
        print('Error checking admin status: $e');
      }
    } else {
      print('No user is currently signed in');
    }
  }
  void _getCurrentUser() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    _currentUser = googleSignIn.currentUser;
    if (_currentUser == null) {
      _currentUser = await googleSignIn.signInSilently();
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Service Turnaround Control System',
            style: TextStyle(fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
            fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
             DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/icons/bank.png')),

                  SizedBox(height: 10),
                  Text(
                    _currentUser?.email ?? 'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin) ...[
              Divider(),
              ListTile(
                title: Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold,
                color: Colors.red.shade900)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SUPER USER',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) =>  ()),
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                      child: Text(
                        '',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.newspaper, color: Colors.blueAccent),
                title: Text('User Management'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminPanel()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.purpleAccent),
                title: Text('Security'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SecurityPanel()),
                  );
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.perm_contact_cal_outlined, color: Colors.brown),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),

            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'More',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.document_scanner, color: Colors.orange),
              title: Text('Reports'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                logoutUser(context);
              },
            ),
          ],
        ),
      ),


      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 16),
            StatisticsGrid(
              onInformationDeskTap: () => setState(() => _showLoginDialog = true),
            ),
            SizedBox(height: 40),
            Center(
              child: Text(
                'TICKET MANAGEMENT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontFamily: "Poppins"
                ),
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TicketServingPage()),
                  );
                },
                child: Container(
                  width: 280,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6448FE), Color(0xFF5FC6FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6448FE).withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Text(
                          'OPEN TICKETS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -10,
                        bottom: -10,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

