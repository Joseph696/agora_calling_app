import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/firebase_service.dart';

class AuthController
    extends ChangeNotifier {

  final FirebaseService
      firebaseService =
          FirebaseService();

  bool isLoading = false;

  Future<void> register({

    required String name,

    required String email,

    required String password,

  }) async {

    try {

      isLoading = true;

      notifyListeners();

      await firebaseService
          .registerUser(

        name: name,

        email: email,

        password: password,
      );

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }

  Future<void> login({

    required String email,

    required String password,

  }) async {

    try {

      isLoading = true;

      notifyListeners();

      await firebaseService
          .loginUser(

        email: email,

        password: password,
      );

      // USER ONLINE
      await FirebaseFirestore
          .instance
          .collection('users')
          .doc(
            FirebaseAuth
                .instance
                .currentUser!
                .uid,
          )
          .update({

        'isOnline': true,
      });

      SharedPreferences prefs =
          await SharedPreferences
              .getInstance();

      await prefs.setBool(
        'isLogin',
        true,
      );

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }

  Future<void> logout() async {

    // USER OFFLINE
    await FirebaseFirestore
        .instance
        .collection('users')
        .doc(
          FirebaseAuth
              .instance
              .currentUser!
              .uid,
        )
        .update({

      'isOnline': false,
    });

    SharedPreferences prefs =
        await SharedPreferences
            .getInstance();

    await prefs.clear();

    await firebaseService
        .logoutUser();
  }
}