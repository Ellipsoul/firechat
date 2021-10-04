import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:firechat/auth_provider.dart';
import 'package:firechat/bottom_chat_bar.dart';
import 'package:firechat/loading.dart';
import 'package:firechat/styles.dart';

// Chat view when the user is logged in
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Accessing the current user from build method (nullable!)
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      // This is the top bar on a mobile app
      appBar: AppBar(
          title: Text(
            user!.displayName!, // Specify that variable will never be null
            style: appBarTheme,
          ),
          // Provide a button here for the user to sign out
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Sign Out',
                style: blackText,
              ),
              onPressed: () {
                // Sign the user out when pressed
                AuthProvider().signOut();
                // Also show a snackbar confirming the sign out
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You have signed out!'),
                  ),
                );
              },
            ),
          ]),
      // The actual main piece of the Scaffold
      body: Container(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            // Have the list of chats and the bottom text field in a column
            children: [Chats(), const BottomChatBar()],
          )),
    );
  }
}

// List of all chats queried from Firestore
class Chats extends StatelessWidget {
  // Grab the current authenticated user
  final user = FirebaseAuth.instance.currentUser;
  // Query firestore for all the chat messages
  final Stream<QuerySnapshot> _chatsStream = FirebaseFirestore.instance
      .collection('chats')
      .orderBy('createdAt', descending: false)
      .limit(15) // Remove this limit at some point
      .snapshots(); // Call this to return results as a stream

  Chats({Key? key}) : super(key: key);

  // Since the above is a stream, it's perfect for a streambuilder!
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        // Something went wrong building the chat list
        if (snapshot.hasError) {
          return Center(child: Text('$snapshot.error'));
        }
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loading();
        }
        // Widget gives child flexibility to expand and fill available space
        return Flexible(
          // Flexible prevents overflow error when keyboard is opened
          child: GestureDetector(
            // Close the keyboard if anything else is tapped
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            // List of chat messages
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              // Map the chat messages to a list
              children: snapshot.data!.docs.map(
                (DocumentSnapshot doc) {
                  // Doc id
                  String id = doc.id;
                  // Chat data
                  Map<String, dynamic> data =
                      doc.data()! as Map<String, dynamic>;

                  // Chats sent by the current user
                  if (user?.uid == data['owner']) {
                    return SentMessage(data: data);
                  } else {
                    // Chats sent by everyone else
                    return ReceivedMessage(data: data);
                  }
                },
              ).toList(),
            ),
          ),
        );
      },
    );
  }
}

// A message the user sent (appears on right)
class SentMessage extends StatelessWidget {
  const SentMessage({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(), // Dynamic width spacer
          Container(
            constraints: chatConstraints,
            padding: const EdgeInsets.only(
              left: 10.0,
              top: 5.0,
              bottom: 5.0,
              right: 5.0,
            ),
            decoration: const BoxDecoration(
              gradient: sent,
              borderRadius: round,
            ),
            child: GestureDetector(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      data['text'],
                      textAlign: TextAlign.right,
                      style: chatText,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      data['imageUrl'],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A message that any other user sent (appears on left)
class ReceivedMessage extends StatelessWidget {
  const ReceivedMessage({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            constraints: chatConstraints,
            padding: const EdgeInsets.only(
              left: 5.0,
              top: 5.0,
              bottom: 5.0,
              right: 10.0,
            ),
            decoration: const BoxDecoration(
              gradient: received,
              borderRadius: round,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    data['imageUrl'],
                  ),
                ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: Text(
                    data['text'],
                    textAlign: TextAlign.left,
                    style: chatText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(), // Dynamic width spacer
        ],
      ),
    );
  }
}
