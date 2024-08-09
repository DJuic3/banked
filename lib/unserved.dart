
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UnservedTicketPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> designations = [];
  String? selectedDesignation;
  String? generatedCode;
  bool isAdmin = false;
  String? userDesignation;

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat.Hm().format(dateTime); // Format to HH:MM
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo[800]!, Colors.indigo[600]!],
          ),
        ),
        child: FutureBuilder<String?>(
          future: _getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
            }

            if (!roleSnapshot.hasData || roleSnapshot.data == null) {
              return Center(child: Text('Unable to fetch user role.', style: TextStyle(color: Colors.white)));
            }

            String userRole = roleSnapshot.data!;

            return StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('reports')
                  .where('designation', isEqualTo: userRole)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No reports available for your role.', style: TextStyle(color: Colors.white)));
                }

                List<DocumentSnapshot> reports = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> reportData = reports[index].data() as Map<String, dynamic>;
                            Timestamp timeServedTimestamp = reportData['timeServed'];
                            Timestamp timeArrivedTimestamp = reportData['timeArrived'];
                            String formattedTimeServed = _formatTimestamp(timeServedTimestamp);
                            String formattedTimeArrived = _formatTimestamp(timeArrivedTimestamp);

                            return Card(
                              elevation: 4,
                              margin: EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ticket: ${reportData['ticketCode']}',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Chip(
                                          label: Text(reportData['designation']),
                                          backgroundColor: Colors.indigo[100],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Date: ${reportData['date']}'),
                                        Text('Wait Time: ${reportData['waitTimeMinutes']} min'),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Arrived: $formattedTimeArrived'),
                                        Text('Served: $formattedTimeServed'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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

                                  bool canServe = isAdmin || ticketData['designation'] == userDesignation;

                                  return ListTile(
                                    title: Text('Code: ${ticketData['code']}'),
                                    subtitle: Text('Designation: ${ticketData['designation']}'),
                                    trailing: canServe ? ElevatedButton(
                                      child: Text('Serve'),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                      onPressed: () async {
                                        DateTime now = DateTime.now();
                                        Duration waitTime = now.difference(ticketData['timeArrived'].toDate());

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
                                        });

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Ticket served and report generated')),
                                        );

                                      },
                                    ) : null,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<String?> _getUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.get('role') as String?;
    }
    return null;
  }
}



