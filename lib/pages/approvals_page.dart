import 'package:flutter/material.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class ApprovalsPage extends StatefulWidget {
  const ApprovalsPage({super.key});

  @override
  State<ApprovalsPage> createState() => _ApprovalsPageState();
}

class _ApprovalsPageState extends State<ApprovalsPage> {
  bool isLoading = false;
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Approvals'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.approval, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Approvals Page',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Fitur akan segera datang...'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi kembali ke home
                Navigator.pop(context);
              },
              child: Text('Kembali ke Home'),
            ),
          ],
        ),
      ),
    );
  }
}
