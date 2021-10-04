import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/auth_provider.dart';
import 'package:firechat/home_screen.dart';
import 'package:firechat/loading.dart';
import 'package:firechat/styles.dart';
import 'package:flutter/material.dart';

// This screen shows the chat if user authenticated, and login otherwise
class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override // Overrides a predefined ancester function
  Widget build(BuildContext context) {
    return Scaffold(
      // Most basic container for app
      body: StreamBuilder(
          // Automatically rebuilds UI whenever stream changes
          stream: FirebaseAuth.instance.authStateChanges(), // State to watch
          // Builder function instructing what to build based on state
          builder: (context, snapshot) {
            // Authentication is loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            }
            // Something failed
            else if (snapshot.hasError) {
              return const Center(
                child: Text("Something went wrong!"),
              );
            }
            // User logged in, show the chat!
            else if (snapshot.hasData) {
              return const HomeScreen();
            }
            // User not logged in, show login button and page
            else {
              // Login component
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 225,
                    height: 50,
                    child: ElevatedButton(
                      child: Row(
                        children: const [
                          Icon(
                            Icons.login,
                            size: 30.0,
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            "Google Sign In",
                            textAlign: TextAlign.center,
                            style: googleText,
                          ),
                        ],
                      ),
                      onPressed: () {
                        // Instantiate and immediately call googleLogin()
                        AuthProvider().googleLogin();
                      },
                    ),
                  ),
                ),
              );
            }
          }),
    );
  }
}
