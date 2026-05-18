import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {

  List<UserModel> users = [];

  bool isLoading = false;

  void fetchUsers() {

    isLoading = true;

    notifyListeners();

    FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) {

      users = snapshot.docs.map((doc) {

        return UserModel.fromMap(
          doc.data(),
        );

      }).toList();

      print(users.length);

      isLoading = false;

      notifyListeners();
    });
  }
}