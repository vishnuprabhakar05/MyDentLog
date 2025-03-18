import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart';

class GoogleAuthService {
  static GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/drive.file'],
  );

  static AuthClient? _authClient;

  Future<AuthClient?> getAuthClient() async {
    if (_authClient != null) return _authClient; // ✅ Use existing session if authenticated

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User canceled sign-in

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AccessCredentials credentials = AccessCredentials(
      AccessToken('Bearer', googleAuth.accessToken!, DateTime.now().add(Duration(hours: 1))),
      null, // No refresh token available
      ['https://www.googleapis.com/auth/drive.file'],
    );

    _authClient = authenticatedClient(http.Client(), credentials);
    return _authClient;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _authClient = null;
  }
}
