// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class ReportsPage extends StatelessWidget {
//   String _formatTimestamp(Timestamp timestamp) {
//     DateTime dateTime = timestamp.toDate();
//     return DateFormat.Hm().format(dateTime); // Format to HH:MM
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Transaction Reports', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//         backgroundColor: Colors.indigo[800],
//         elevation: 0,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.indigo[800]!, Colors.indigo[600]!],
//           ),
//         ),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('reports').snapshots(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
//             }
//
//             List<DocumentSnapshot> reports = snapshot.data!.docs;
//
//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Recent Transactions',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
//                   ),
//                   SizedBox(height: 16),
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: reports.length,
//                       itemBuilder: (context, index) {
//                         Map<String, dynamic> reportData = reports[index].data() as Map<String, dynamic>;
//                         Timestamp timeServedTimestamp = reportData['timeServed'];
//                         Timestamp timeArrivedTimestamp = reportData['timeArrived'];
//                         String formattedTimeServed = _formatTimestamp(timeServedTimestamp);
//                         String formattedTimeArrived = _formatTimestamp(timeArrivedTimestamp);
//
//                         return Card(
//                           elevation: 4,
//                           margin: EdgeInsets.only(bottom: 16),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Ticket: ${reportData['ticketCode']}',
//                                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                                     ),
//                                     Chip(
//                                       label: Text(reportData['designation']),
//                                       backgroundColor: Colors.indigo[100],
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 8),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text('Date: ${reportData['date']}'),
//                                     Text('Wait Time: ${reportData['waitTimeMinutes']} min'),
//                                     Text('Served By: ${ticket['servedByEmail'] ?? 'NA'}'),
//                                   ],
//                                 ),
//                                 SizedBox(height: 8),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text('Arrived: $formattedTimeArrived'),
//                                     Text('Served: $formattedTimeServed'),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportsPage extends StatelessWidget {
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('reports').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
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
                                    Text('${reportData['servedByEmail'] ?? 'NA'}'),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}