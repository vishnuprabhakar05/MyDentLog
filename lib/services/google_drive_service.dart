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

 
  static Future<String?> uploadFile(File file) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

     
      final http.Client baseClient = http.Client();
      final AuthClient authClient = authenticatedClient(
        baseClient,
        AccessCredentials(
          AccessToken('Bearer', googleAuth.accessToken!, DateTime.now().toUtc().add(Duration(hours: 1))),
          null,
          [drive.DriveApi.driveFileScope],
        ),
      );

      final drive.DriveApi driveApi = drive.DriveApi(authClient);

      final drive.File driveFile = drive.File()
        ..name = path.basename(file.path)
        ..parents = ["root"]; 

      final drive.Media media = drive.Media(file.openRead(), file.lengthSync());

      final drive.File uploadedFile = await driveApi.files.create(driveFile, uploadMedia: media);

     
      authClient.close();
      baseClient.close();

      return "https://drive.google.com/file/d/${uploadedFile.id}/view"; 
    } catch (e) {
      print(" Error uploading file to Google Drive: $e");
      return null;
    }
  }
}
