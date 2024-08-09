import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'homescreen/homescreen.dart';
import 'package:lottie/lottie.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDjA_nromfPAmlosJdrzUht_i9rHuKpGoM",
      appId: "1:739611103226:web:1f6748365f212a8e185e43",
      messagingSenderId: "739611103226",
      projectId: "banker-dc808",
    ),
  );

  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          } else {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.hasData && !snapshot.data!.exists) {
                  return AwaitingRolePage();
                }

                if (snapshot.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

                  // Check if the user is an admin
                  bool isAdmin = data['role'] == 'admin' && data['isAdmin'] == true;

                  if (isAdmin) {
                    // Admin users get unrestricted access
                    return DashboardPage();
                  } else if (data['role'] == null || data['role'] == '') {
                    return AwaitingRolePage();
                  } else {
                    return const DashboardPage();
                  }
                }

                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          }
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
class AwaitingRolePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F6FD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              SizedBox(height: 40),
          Text(
            'Welcome Aboard!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Expanded(
            child: Lottie.network(
              'https://assets5.lottiefiles.com/packages/lf20_bujdzzfn.json',
              fit: BoxFit.contain,
            ),
          ),
          Text(
            'Awaiting Role Assignment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Your account is set up, but a role hasnt been assigned yet. Please contact an administrator to complete your account setup.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ElevatedButton(
          child: Text(
            'Contact Admin',
            style: TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Color(0xFF3B82F6),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            // Implement contact admin functionality
          },
        ),
        SizedBox(height: 16),
        TextButton(
          child: Text(
            'Sign Out',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        SizedBox(height: 24),
        ],
      ),
    ),
    ),
    );
  }
}
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser
          ?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Create or update user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(
          userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName,
        'lastLogin': FieldValue.serverTimestamp(),
        'role':'',
      }, SetOptions(merge: true));

      // Save user info using shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', userCredential.user!.uid);
      await prefs.setString('userEmail', userCredential.user!.email ?? '');
      await prefs.setString('userName', userCredential.user!.displayName ?? '');

      // Show success toast
      Fluttertoast.showToast(
          msg: "Login successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );

      // Navigate to homepage on successful login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
    } catch (e) {
      print(e);
      // Show error toast
      Fluttertoast.showToast(
          msg: "Login failed: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      // Remain on LoginPage (no navigation)
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // colors: [Colors.blue[900]!, Colors.blue[700]!],
            colors: [Colors.white!, Colors.white!],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bank Logo
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset('assets/icons/bank.png',

                          // color: Colors.blue[900],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    // Bank Name
                    const Center(
                      child:  Text(
                        'Service Turnaround Control System',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Your Trusted Financial Partner',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 60),
                    // Sign In Button
                    _isLoading
                        ? SpinKitCircle(color: Colors.white, size: 50.0)
                        : ElevatedButton.icon(
                      icon: Image.asset(
                        'assets/icons/google.png',
                        height: 24.0,
                      ),
                      label: Text(
                        'Sign in with Google',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue[900],
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => _handleGoogleSignIn(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}