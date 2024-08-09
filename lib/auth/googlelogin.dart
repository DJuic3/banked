// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
//
//
// class LoginDialog extends StatefulWidget {
//   // final VoidCallback onDismiss;
//   // final Function(String, String) onLogin;
//   final void Function(BuildContext)? onDismiss;
//   final void Function(BuildContext)? onLogin;
//
//   LoginDialog({required this.onDismiss, required this.onLogin});
//
//   @override
//   _LoginDialogState createState() => _LoginDialogState();
// }
//
// class _LoginDialogState extends State<LoginDialog> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Login'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextField(
//             controller: _emailController,
//             decoration: InputDecoration(labelText: 'Email'),
//           ),
//           SizedBox(height: 8),
//           TextField(
//             controller: _passwordController,
//             decoration: InputDecoration(labelText: 'Password'),
//             obscureText: true,
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: widget.onDismiss,
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () => widget.onLogin(_emailController.text, _passwordController.text),
//           child: Text('Login'),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }