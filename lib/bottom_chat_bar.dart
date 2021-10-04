import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firechat/styles.dart';
import 'package:flutter/material.dart';

// This widget needs to be stateful since we need the state of the input field
class BottomChatBar extends StatefulWidget {
  const BottomChatBar({Key? key}) : super(key: key);

  @override
  _BottomChatBarState createState() => _BottomChatBarState();
}

// Normal stateful widget implementation
class _BottomChatBarState extends State<BottomChatBar> {
  // Instantiate a text editing controller
  final textController = TextEditingController();

  // Dipose of this controller when the widget is destroyed
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // Grab the authenticated user and the Firebase collection of chats
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference chatsRef = FirebaseFirestore.instance.collection("chats");

  // Async method that writes a document to Firestore
  Future sendMessage() async {
    if (textController.text.isNotEmpty) {
      if (textController.text.length < 40) {
        // If message is valid, try to make a Firestore write
        try {
          return chatsRef.doc().set(
            {
              "text": textController.text,
              "owner": user?.uid,
              "imageUrl": user?.photoURL,
              "createdAt": FieldValue.serverTimestamp(),
            },
          ).then(
            // Clear the text field after successful write
            (value) => {
              textController.clear(),
            },
          );
        } catch (e) {
          // Display error message if write failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$e'),
            ),
          );
        }
      } else {
        // Message too long
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Must be 40 characters or less'),
          ),
        );
      }
    } else {
      // Empty message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chat can't be empty"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xff161616),
        boxShadow: [boxShadow],
      ),
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              constraints: const BoxConstraints(
                maxWidth: 275,
              ),
              child: TextField(
                cursorColor: Colors.lightBlue,
                controller: textController, // Our defined text controller
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                style: inputText,
                keyboardType: TextInputType.text,
                onEditingComplete: sendMessage, // Runs when form is submitted
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xff212121),
                  border: outlineBorder,
                  enabledBorder: roundedBorder,
                  labelStyle: placeholder,
                  labelText: 'Enter message',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.only(
                    left: 20.0,
                    right: 10.0,
                    top: 0.0,
                    bottom: 0.0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 45,
              width: 50,
              child: FloatingActionButton(
                onPressed: sendMessage,
                elevation: 8.0,
                backgroundColor: Colors.lightBlue,
                child: const Center(
                  child: Icon(
                    Icons.send,
                    size: 30.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
