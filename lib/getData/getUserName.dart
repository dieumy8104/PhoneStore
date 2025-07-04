import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GetCurrentUserName extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lấy thông tin user hiện tại từ FirebaseAuth
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Text('No user logged in');
    }

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(currentUser.uid).get(),
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data!.exists) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Text(
                'First Name: ${data['fullName']}  ');
          } else {
            return Text('User document not found');
          }
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return Text('Loading...');
      }),
    );
  }
}
