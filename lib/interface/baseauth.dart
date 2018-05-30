import 'dart:async';

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

