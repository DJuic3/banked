// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class TicketServingPage extends StatefulWidget {
//   const TicketServingPage({super.key});
//
//   @override
//   _TicketServingPageState createState() => _TicketServingPageState();
// }
//
// class _TicketServingPageState extends State<TicketServingPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String? userRole;
//
//   @override
//   void initState() {
//     super.initState();
//     loadUserRole();
//   }
//
//   void loadUserRole() async {
//     User? currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
//       setState(() {
//         userRole = userDoc['role'];
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Ticket Serving Page'),
//       ),
//       body: userRole == null
//           ? Center(child: CircularProgressIndicator())
//           : StreamBuilder<QuerySnapshot>(
//         stream: _firestore
//             .collection('tickets')
//             .where('status', isEqualTo: 'waiting')
//             .where('designation', isEqualTo: userRole)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(child: Text('No tickets available'));
//           }
//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               var ticket = snapshot.data!.docs[index];
//               return TicketCard(
//                 ticket: ticket,
//                 onServe: () => serveTicket(ticket.id),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   void serveTicket(String ticketId) async {
//     await _firestore.collection('tickets').doc(ticketId).update({'status': 'served'});
//   }
// }
//
// class TicketCard extends StatelessWidget {
//   final QueryDocumentSnapshot ticket;
//   final VoidCallback onServe;
//
//   TicketCard({required this.ticket, required this.onServe});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.all(8.0),
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Code: ${ticket['code']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text('Date: ${ticket['date']}'),
//             Text('Designation: ${ticket['designation']}'),
//             Text('Status: ${ticket['status']}'),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: onServe,
//               child: Text('Serve Ticket'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TicketServingPage extends StatefulWidget {
  const TicketServingPage({super.key});

  @override
  _TicketServingPageState createState() => _TicketServingPageState();
}

class _TicketServingPageState extends State<TicketServingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userRole;
  bool isAdmin = false;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  void loadUserInfo() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      setState(() {
        userRole = userDoc['role'];
        isAdmin = userRole == 'Admin'; // Assuming 'Admin' is the role for admin users
        userEmail = currentUser.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Queue Management', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: userRole == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: isAdmin
            ? _firestore.collection('tickets').where('status', isEqualTo: 'waiting').snapshots()
            : _firestore.collection('tickets').where('status', isEqualTo: 'waiting').where('designation', isEqualTo: userRole).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No tickets available', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var ticket = snapshot.data!.docs[index];
              return TicketCard(
                ticket: ticket,
                onServe: () => serveTicket(ticket.id),
              );
            },
          );
        },
      ),
    );
  }


  void serveTicket(String ticketId) async {
    if (userEmail == null) return;

    DateTime now = DateTime.now();

    // Update the ticket
    await _firestore.collection('tickets').doc(ticketId).update({
      'status': 'served',
      'servedBy': userRole,
      'servedByEmail': userEmail,
      'servedAt': now,
    });

    // Fetch the original ticket data
    DocumentSnapshot ticketDoc = await _firestore.collection('tickets').doc(ticketId).get();
    Map<String, dynamic> ticketData = ticketDoc.data() as Map<String, dynamic>;

    // Calculate wait time
    Duration waitTime = now.difference(ticketData['timeArrived'].toDate());

    // Create a report
    await _firestore.collection('reports').add({
      'ticketCode': ticketData['code'],
      'designation': ticketData['designation'],
      'date': ticketData['date'],
      'timeArrived': ticketData['timeArrived'],
      'timeServed': now,
      'waitTimeMinutes': waitTime.inMinutes,
      'servedBy': userRole,
      'servedByEmail': userEmail,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket served and report generated')),
    );
  }
}

class TicketCard extends StatelessWidget {
  final QueryDocumentSnapshot ticket;
  final VoidCallback onServe;

  TicketCard({required this.ticket, required this.onServe});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket ${ticket['code']}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                ),
                Chip(
                  label: Text(
                    ticket['designation'],
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blue[800],
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  DateFormat('MMM dd, yyyy').format(DateTime.parse(ticket['date'])),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  DateFormat('hh:mm a').format(DateTime.parse(ticket['date'])),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: onServe,
              child: Text('Serve Ticket',
              style: TextStyle(
                color:Colors.white
              ),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}