import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

//Keep this interface auth provider neutral!
abstract class BaseAuth {

  Future<String> currentUser();
  Future<String> signIn(String email, String password);
  Future<String> createUser(String email, String password);
  Future<void> signOut();
  Future<void> sendVerificationMail();
  Future<bool> userIsVerified();
  Future<String> currentUserEmail();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> createUser(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> currentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.uid : null;
  }

  Future<String> currentUserEmail() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user != null ? user.email : null;    
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendVerificationMail() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.sendEmailVerification();
  }

  Future<bool> userIsVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;    
  }

}