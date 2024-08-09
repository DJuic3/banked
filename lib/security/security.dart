// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'dart:math';
//
// import '../ADMIN/REPORTS/reports.dart';
//
// class SecurityPanel extends StatefulWidget {
//   @override
//   _SecurityPanelState createState() => _SecurityPanelState();
// }
//
// class _SecurityPanelState extends State<SecurityPanel> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   List<String> designations = [];
//   String? selectedDesignation;
//   String? generatedCode;
//   bool isAdmin = false;
//   String? userDesignation;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchDesignations();
//     _checkAdminStatus();
//     _fetchUserDesignation();
//   }
//
//   void _checkAdminStatus() async {
//     DocumentSnapshot userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
//     Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
//     setState(() {
//       isAdmin = userData['role'] == 'Admin';
//       userDesignation = userData['designation'];
//     });
//   }
//
//   void _fetchUserDesignation() async {
//     DocumentSnapshot userDoc = await _firestore.collection('users').doc(
//         _auth.currentUser!.uid).get();
//     setState(() {
//       userDesignation = (userDoc.data() as Map<String, dynamic>)['designation'];
//     });
//   }
//
//   void _fetchDesignations() async {
//     QuerySnapshot designationsSnapshot = await _firestore.collection(
//         'designations').get();
//     setState(() {
//       designations =
//           designationsSnapshot.docs.map((doc) => doc['name'] as String)
//               .toList();
//     });
//   }
//
//   String _generateUniqueCode() {
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     Random rnd = Random();
//     return String.fromCharCodes(Iterable.generate(
//         6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
//   }
//
//   void _createTicket() async {
//     if (selectedDesignation == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a designation')),
//       );
//       return;
//     }
//
//     String code = _generateUniqueCode();
//     DateTime now = DateTime.now();
//
//     await _firestore.collection('tickets').add({
//       'code': code,
//       'designation': selectedDesignation,
//       'timeArrived': now,
//       'date': DateFormat('yyyy-MM-dd').format(now),
//       'status': 'waiting',
//     });
//
//     setState(() {
//       generatedCode = code;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Ticket created successfully')),
//     );
//   }
//
//   void _showReports() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => ReportsPage()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text('Security Panel'),
//         backgroundColor: Colors.teal[700],
//         elevation: 0,
//         actions: [
//           if (isAdmin)
//             IconButton(
//               icon: Icon(Icons.assessment),
//               onPressed: _showReports,
//               tooltip: 'View Reports',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Create Ticket',
//                       style: TextStyle(
//                           fontSize: 24, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 16),
//                     DropdownButtonFormField<String>(
//                       decoration: InputDecoration(
//                         labelText: 'Select Designation',
//                         border: OutlineInputBorder(),
//                       ),
//                       value: selectedDesignation,
//                       items: designations.map((String designation) {
//                         return DropdownMenuItem<String>(
//                           value: designation,
//                           child: Text(designation),
//                         );
//                       }).toList(),
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           selectedDesignation = newValue;
//                         });
//                       },
//                     ),
//                     SizedBox(height: 16),
//                     ElevatedButton(
//                       child: Text('Generate Ticket'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.teal[700],
//                         padding: EdgeInsets.symmetric(vertical: 16),
//                       ),
//                       onPressed: _createTicket,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             if (generatedCode != null)
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         'Generated Code',
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold),
//                       ),
//                       SizedBox(height: 8),
//                       Text(
//                         generatedCode!,
//                         style: TextStyle(fontSize: 32,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.teal[700]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             SizedBox(height: 16),
//             Expanded(
//               child: Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: _firestore.collection('tickets')
//                       .where('status', isEqualTo: 'waiting')
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (!snapshot.hasData) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//
//                     List<DocumentSnapshot> tickets = snapshot.data!.docs;
//
//                     return ListView.builder(
//                       itemCount: tickets.length,
//                       itemBuilder: (context, index) {
//                         Map<String, dynamic> ticketData = tickets[index].data() as Map<String, dynamic>;
//                         String ticketId = tickets[index].id;
//
//                         bool canServe = isAdmin || ticketData['designation'] == userDesignation;
//
//                         return ListTile(
//                           title: Text('Code: ${ticketData['code']}'),
//                           subtitle: Text('Designation: ${ticketData['designation']}'),
//                           trailing: canServe ? ElevatedButton(
//                             child: Text('Serve'),
//                             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                             onPressed: () async {
//                               DateTime now = DateTime.now();
//                               Duration waitTime = now.difference(ticketData['timeArrived'].toDate());
//
//                               await _firestore.collection('tickets').doc(ticketId).update({
//                                 'status': 'served',
//                                 'timeServed': now,
//                               });
//
//                               await _firestore.collection('reports').add({
//                                 'ticketCode': ticketData['code'],
//                                 'designation': ticketData['designation'],
//                                 'date': ticketData['date'],
//                                 'timeArrived': ticketData['timeArrived'],
//                                 'timeServed': now,
//                                 'waitTimeMinutes': waitTime.inMinutes,
//                               });
//
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Ticket served and report generated')),
//                               );
//                             },
//                           ) : null,
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//             // Expanded(
//             //   child: Card(
//             //     elevation: 4,
//             //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             //     child: StreamBuilder<QuerySnapshot>(
//             //       stream: _firestore.collection('tickets')
//             //           .where('status', isEqualTo: 'waiting')
//             //           .snapshots(),
//             //       builder: (context, snapshot) {
//             //         if (!snapshot.hasData) {
//             //           return Center(child: CircularProgressIndicator());
//             //         }
//             //
//             //         List<DocumentSnapshot> tickets = snapshot.data!.docs;
//             //
//             //         return ListView.builder(
//             //           itemCount: tickets.length,
//             //           itemBuilder: (context, index) {
//             //             Map<String, dynamic> ticketData = tickets[index].data() as Map<String, dynamic>;
//             //             String ticketId = tickets[index].id;
//             //
//             //             bool canServe = isAdmin || ticketData['designation'] == userDesignation;
//             //
//             //             return ListTile(
//             //               title: Text('Code: ${ticketData['code']}'),
//             //               subtitle: Text('Designation: ${ticketData['designation']}'),
//             //               trailing: canServe ? ElevatedButton(
//             //                 child: Text('Serve'),
//             //                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//             //                 onPressed: () async {
//             //                   DateTime now = DateTime.now();
//             //                                     Duration waitTime = now.difference(ticketData['timeArrived'].toDate());
//             //
//             //                                     await _firestore.collection('tickets').doc(ticketId).update({
//             //                                       'status': 'served',
//             //                                       'timeServed': now,
//             //                                     });
//             //
//             //                                     await _firestore.collection('reports').add({
//             //                                       'ticketCode': ticketData['code'],
//             //                                       'designation': ticketData['designation'],
//             //                                       'date': ticketData['date'],
//             //                                       'timeArrived': ticketData['timeArrived'],
//             //                                       'timeServed': now,
//             //                                       'waitTimeMinutes': waitTime.inMinutes,
//             //                                     });
//             //
//             //                                     ScaffoldMessenger.of(context).showSnackBar(
//             //                                       SnackBar(content: Text('Ticket served and report generated')),
//             //                                     );
//             //
//             //                 },
//             //               ) : null,
//             //             );
//             //           },
//             //         );
//             //       },
//             //     ),
//             //   ),
//             // ),


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SecurityPanel extends StatefulWidget {
  @override
  _SecurityPanelState createState() => _SecurityPanelState();
}

class _SecurityPanelState extends State<SecurityPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> designations = [];
  String? selectedDesignation;
  String? generatedCode;

  @override
  void initState() {
    super.initState();
    _fetchDesignations();
  }

  void _fetchDesignations() async {
    QuerySnapshot designationsSnapshot = await _firestore.collection('designations').get();
    setState(() {
      designations = designationsSnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  String _generateUniqueCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void _createTicket() async {
    if (selectedDesignation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a designation')),
      );
      return;
    }

    String code = _generateUniqueCode();
    DateTime now = DateTime.now();

    await _firestore.collection('tickets').add({
      'code': code,
      'designation': selectedDesignation,
      'timeArrived': now,
      'date': DateFormat('yyyy-MM-dd').format(now),
      'status': 'waiting',
    });

    setState(() {
      generatedCode = code;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket created successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Security Panel'),
        backgroundColor: Colors.blue[700],
        elevation: 0,
      ),
      body: Padding(

        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Ticket',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Designation',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedDesignation,
                      items: designations.map((String designation) {
                        return DropdownMenuItem<String>(
                          value: designation,
                          child: Text(designation),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDesignation = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: Text('Generate Ticket',
                      style: TextStyle(
                        color: Colors.white
                      ),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      ),
                      onPressed: _createTicket,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            if (generatedCode != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Generated Code',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        generatedCode!,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal[700]),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('tickets')
                      .where('status', isEqualTo: 'waiting')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    List<DocumentSnapshot> tickets = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> ticketData = tickets[index].data() as Map<String, dynamic>;
                        String ticketId = tickets[index].id;

                        return ListTile(
                          title: Text('Code: ${ticketData['code']}'),
                          subtitle: Text('Designation: ${ticketData['designation']}'),

                          trailing: ElevatedButton(
                            child: Text('Serve',
                            style: TextStyle(
                              color: Colors.white
                            ),),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade900),
                            onPressed: () async {
                              DateTime now = DateTime.now();
                              Duration waitTime = now.difference(ticketData['timeArrived'].toDate());

                              // Get the user's email from the ticket data (assuming it's stored)
                              String userEmail = ticketData['email'];

                              await _firestore.collection('tickets').doc(ticketId).update({
                                'status': 'served',
                                'timeServed': now,
                              });

                              await _firestore.collection('reports').add({
                                'ticketCode': ticketData['code'],
                                'designation': ticketData['designation'],
                                'date': ticketData['date'],
                                'timeArrived': ticketData['timeArrived'],
                                'timeServed': now,
                                'waitTimeMinutes': waitTime.inMinutes,
                                'email': userEmail, // Include email in the report
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ticket served and report generated')),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}