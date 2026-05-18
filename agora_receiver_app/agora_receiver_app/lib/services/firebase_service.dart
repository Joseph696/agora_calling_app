import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> registerUser({

    required String name,
    required String email,
    required String password,

  }) async {

    UserCredential userCredential =

        await _auth
            .createUserWithEmailAndPassword(

      email: email,
      password: password,
    );

    User? user = userCredential.user;

    if (user != null) {

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({

        'uid': user.uid,
        'name': name,
        'email': email,
        'isOnline': true,
      });
    }
  }

  Future<void> loginUser({

    required String email,
    required String password,

  }) async {

    await _auth.signInWithEmailAndPassword(

      email: email,
      password: password,
    );
  }

  Future<void> logoutUser() async {

    await _auth.signOut();
  }
}