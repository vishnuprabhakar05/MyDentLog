import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.standard(
    scopes: [drive.DriveApi.driveFileScope],
  );

  /// Uploads a file to Google Drive and returns the file's URL
  static Future<String?> uploadFile(File file) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Fix: Use http.Client() properly
      final http.Client baseClient = http.Client();
      final AuthClient authClient = authenticatedClient(
        baseClient,
        AccessCredentials(
          AccessToken('Bearer', googleAuth.accessToken!, DateTime.now().toUtc().add(Duration(hours: 1))),
          null, // Refresh token is not needed here
          [drive.DriveApi.driveFileScope],
        ),
      );

      final drive.DriveApi driveApi = drive.DriveApi(authClient);

      final drive.File driveFile = drive.File()
        ..name = path.basename(file.path)
        ..parents = ["root"]; // Change folder ID if needed

      final drive.Media media = drive.Media(file.openRead(), file.lengthSync());

      final drive.File uploadedFile = await driveApi.files.create(driveFile, uploadMedia: media);

      // Fix: Close authClient after use
      authClient.close();
      baseClient.close();

      return "https://drive.google.com/file/d/${uploadedFile.id}/view"; // Return the file link
    } catch (e) {
      print(" Error uploading file to Google Drive: $e");
      return null;
    }
  }
}
