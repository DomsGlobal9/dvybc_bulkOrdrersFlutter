import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Google Sign-In Service Class
class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  static Future<void> initSignIn() async {
    if (!isInitialize) {
      await _googleSignIn.initialize(
        serverClientId:
        '484988555302-d91nev5jn5sit0qoe3oehpgpp58pl5mt.apps.googleusercontent.com',
      );
    }
    isInitialize = true;
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await initSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      final authorizationClient = googleUser.authorizationClient;
      GoogleSignInClientAuthorization? authorization = await authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;

      if (accessToken == null) {
        final authorization2 = await authorizationClient.authorizationForScopes(
          ['email', 'profile'],
        );
        if (authorization2?.accessToken == null) {
          throw FirebaseAuthException(code: "error", message: "error");
        }
        authorization = authorization2;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('B2BBulkOrders_users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // Create new user with complete structure
          await userDoc.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email ?? '',
            'phone': user.phoneNumber ?? '', // Added missing field
            'gender': '', // Added missing field
            'dob': '', // Added missing field
            'profileImageUrl': user.photoURL ?? '', // Fixed field name
            'signInMethod': 'google', // Fixed field name
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(), // Added missing field
          });
          print('New Google user created in B2BBulkOrders_users');
        } else {
          // Update existing user
          await userDoc.update({
            'updatedAt': FieldValue.serverTimestamp(),
            'signInMethod': 'google',
          });
          print('Existing Google user updated');
        }
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('Google sign-out successful');
    } catch (e) {
      print('Error signing out: $e');
      throw e;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user exists in database
  static Future<bool> userExistsInDatabase(String uid) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('B2BBulkOrders_users')
          .doc(uid)
          .get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }
}