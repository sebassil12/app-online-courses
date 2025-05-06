//sections of imports
import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'pages/student_register_page.dart';
import 'pages/student_summary_page.dart';

//Definition of the main function
void main() {
  runApp(MyApp());
}
//Definition of the MyApp class
//StatetelessWidget is a widget that does not require mutable state
//It is used to create a widget that does not change over time
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Academy App',
      initialRoute: 'auth',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'auth':
            return MaterialPageRoute(builder: (_) => const AuthPage());

          case 'register_student':
            final userId = settings.arguments as int?;
            if (userId != null) {
              return MaterialPageRoute(
                builder: (_) => StudentRegisterPage(userId: userId),
              );
            }
            return null;

          case 'summary_student':
            final userId = settings.arguments as int?;
            if (userId != null) {
              return MaterialPageRoute(
                builder: (_) => StudentSummaryPage(userId: userId),
              );
            }
            return null;

          default:
            return null;
        }
      },
    );
  }
}