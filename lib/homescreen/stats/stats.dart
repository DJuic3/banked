import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';



class StatisticsGrid extends StatelessWidget {
  final VoidCallback onInformationDeskTap;

   StatisticsGrid({Key? key, required this.onInformationDeskTap}) : super(key: key);

  // Define all possible designations
  final List<String> allDesignations = [
    'Information Desk',
    'Credit Analyst',
    'Operations Manager',
    'Agro Yield',
    'Customer Consultant',
    'Teller',
    'Operations Clerk',
    'Managers Office',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reports').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Initialize counts for all designations to 0
        Map<String, int> designationCounts = Map.fromIterable(
            allDesignations,
            key: (item) => item,
            value: (_) => 0
        );

        // Count the items for each designation if data is available
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            String designation = doc['designation'];
            if (designationCounts.containsKey(designation)) {
              designationCounts[designation] = designationCounts[designation]! + 1;
            }
          }
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1.5,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: allDesignations.length,
          itemBuilder: (context, index) {
            String designation = allDesignations[index];
            return _buildStatCard(
              designation,
              designationCounts[designation] ?? 0,
              _getColorForDesignation(designation),
              designation == 'Information Desk' ? onInformationDeskTap : () {},
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForDesignation(String designation) {
    switch (designation) {
      case 'Information Desk':
        return Colors.blue;
      case 'Credit Analyst':
        return Colors.green;
      case 'Operations Manager':
        return Colors.orange;
      case 'Agro Yield':
        return Colors.purple;
      case 'Customer Consultant':
        return Colors.red;
      case 'Teller':
        return Colors.teal;
      case 'Operations Clerk':
        return Colors.indigo;
      case 'Managers Office':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}

class CustomerTable extends StatelessWidget {
  final List<CustomerRecord> records = [
    CustomerRecord(1, DateTime(2023, 1, 1, 9, 0), DateTime(2023, 1, 1, 9, 15), DateTime(2023, 1, 1)),
    CustomerRecord(2, DateTime(2023, 1, 1, 9, 30), DateTime(2023, 1, 1, 9, 40), DateTime(2023, 1, 1)),
    CustomerRecord(3, DateTime(2023, 1, 1, 10, 0), DateTime(2023, 1, 1, 10, 20), DateTime(2023, 1, 1)),
    CustomerRecord(4, DateTime(2023, 1, 1, 10, 30), DateTime(2023, 1, 1, 10, 45), DateTime(2023, 1, 1)),
    CustomerRecord(5, DateTime(2023, 1, 1, 11, 0), DateTime(2023, 1, 1, 11, 10), DateTime(2023, 1, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        child: DataTable(
          columns: [
            DataColumn(label: Text('Customer #')),
            DataColumn(label: Text('Time Arrived')),
            DataColumn(label: Text('Time Assisted')),
            DataColumn(label: Text('Wait Time')),
            DataColumn(label: Text('Date')),
          ],
          rows: records.map((record) {
            return DataRow(cells: [
              DataCell(Text(record.customerNumber.toString())),
              DataCell(Text(DateFormat('HH:mm').format(record.timeArrived))),
              DataCell(Text(DateFormat('HH:mm').format(record.timeAssisted))),
              DataCell(Text(formatDuration(record.timeAssisted.difference(record.timeArrived)))),
              DataCell(Text(DateFormat('dd/MM/yyyy').format(record.date))),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    return '${duration.inMinutes}m';
  }
}

class CustomerRecord {
  final int customerNumber;
  final DateTime timeArrived;
  final DateTime timeAssisted;
  final DateTime date;

  CustomerRecord(this.customerNumber, this.timeArrived, this.timeAssisted, this.date);
}