// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AdminPanel extends StatefulWidget {
//   @override
//   _AdminPanelState createState() => _AdminPanelState();
// }
//
// class _AdminPanelState extends State<AdminPanel> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<String> roles = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchRoles();
//   }
//
//   void _fetchRoles() async {
//     QuerySnapshot rolesSnapshot = await _firestore.collection('roles').get();
//     setState(() {
//       roles = rolesSnapshot.docs.map((doc) => doc['name'] as String).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text('USER MANAGEMENT'),
//         backgroundColor: Colors.blue[800],
//         elevation: 0,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _firestore.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           List<DocumentSnapshot> users = snapshot.data!.docs;
//
//           return ListView.builder(
//             itemCount: users.length,
//             itemBuilder: (context, index) {
//               Map<String, dynamic> userData = users[index].data() as Map<String, dynamic>;
//               String userId = users[index].id;
//
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                 child: Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   child: ExpansionTile(
//                     leading: CircleAvatar(
//                       backgroundColor: Colors.blue[800],
//                       child: Text(
//                         userData['name']?.substring(0, 1).toUpperCase() ?? '?',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     title: Text(userData['name'] ?? 'Unknown User'),
//                     subtitle: Text(userData['email'] ?? 'No email'),
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Role: ${userData['role'] ?? 'Not assigned'}'),
//                             SizedBox(height: 16),
//                             DropdownButton<String>(
//                               value: userData['role'] != null && roles.contains(userData['role'])
//                                   ? userData['role']
//                                   : null,
//                               hint: Text('Select a role'),
//                               items: roles.map((String role) {
//                                 return DropdownMenuItem<String>(
//                                   value: role,
//                                   child: Text(role),
//                                 );
//                               }).toList(),
//                               onChanged: (String? newValue) {
//                                 if (newValue != null) {
//                                   _firestore.collection('users').doc(userId).update({'role': newValue});
//                                 }
//                               },
//                             ),
//                             SizedBox(height: 16),
//                             ElevatedButton(
//                               child: Text('Delete User'),
//                               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                               onPressed: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (BuildContext context) {
//                                     return AlertDialog(
//                                       title: Text('Confirm Delete'),
//                                       content: Text('Are you sure you want to delete this user?'),
//                                       actions: [
//                                         TextButton(
//                                           child: Text('Cancel'),
//                                           onPressed: () => Navigator.of(context).pop(),
//                                         ),
//                                         TextButton(
//                                           child: Text('Delete'),
//                                           onPressed: () {
//                                             _firestore.collection('users').doc(userId).delete();
//                                             Navigator.of(context).pop();
//                                           },
//                                         ),
//                                       ],
//                                     );
//                                   },
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> roles = [];
  Map<String, String?> selectedRoles = {};

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  void _fetchRoles() async {
    QuerySnapshot rolesSnapshot = await _firestore.collection('roles').get();
    setState(() {
      roles = rolesSnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('USER MANAGEMENT'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<DocumentSnapshot> users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> userData = users[index].data() as Map<String, dynamic>;
              String userId = users[index].id;

              // Initialize or update selected role for this user
              if (!selectedRoles.containsKey(userId) || !roles.contains(selectedRoles[userId])) {
                selectedRoles[userId] = roles.contains(userData['role']) ? userData['role'] : null;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue[800],
                      child: Text(
                        userData['name']?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(userData['name'] ?? 'Unknown User'),
                    subtitle: Text(userData['email'] ?? 'No email'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Current Role: ${userData['role'] ?? 'Not assigned'}'),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: selectedRoles[userId],
                                    hint: Text('Select a role'),
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Not assigned'),
                                      ),
                                      ...roles.map((String role) {
                                        return DropdownMenuItem<String>(
                                          value: role,
                                          child: Text(role),
                                        );
                                      }).toList(),
                                    ],
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedRoles[userId] = newValue;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  child: Text('Save Role'),
                                  onPressed: () async {
                                    try {
                                      await _firestore.collection('users').doc(userId).update({'role': selectedRoles[userId]});
                                      setState(() {
                                        userData['role'] = selectedRoles[userId];
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Role updated successfully')),
                                      );
                                    } catch (e) {
                                      print('Error updating role: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to update role. Please try again.')),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              child: Text('Delete User',
                              style: TextStyle(
                                color: Colors.white
                              )),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Delete'),
                                      content: Text('Are you sure you want to delete this user?'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                        TextButton(
                                          child: Text('Delete'),
                                          onPressed: () {
                                            _firestore.collection('users').doc(userId).delete();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}