import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
    ],
  );

  static Future<String?> uploadFile(File file, {String? folderId}) async {
    try {
      // 1. Authenticate the user
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('User not authenticated');
      }

      // 2. Get authenticated HTTP client
      final client = await _googleSignIn.authenticatedClient();
      if (client == null) {
        throw Exception('Unable to get authenticated client');
      }

      // 3. Initialize Drive API
      final driveApi = drive.DriveApi(client);

      // 4. Prepare file metadata
      final fileMetadata = drive.File()
        ..name = path.basename(file.path)
        ..mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      // Add parent folder if specified
      if (folderId != null && folderId.isNotEmpty) {
        fileMetadata.parents = [folderId];
      }

      // 5. Create media object
      final media = drive.Media(
        file.openRead(),
        file.lengthSync(),
      );

      // 6. Upload the file
      final uploadedFile = await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
      );

      // 7. Set permissions to make the file accessible
      await driveApi.permissions.create(
        drive.Permission()
          ..type = 'anyone'
          ..role = 'reader',
        uploadedFile.id!,
      );

      // 8. Return the web view link
      return "https://drive.google.com/file/d/${uploadedFile.id}/view";
    } catch (e) {
      print('Error uploading to Google Drive: $e');
      rethrow;
    }
  }

  // Helper method to extract folder ID from Google Drive URL
  static String? extractFolderIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.pathSegments.contains('folders')) {
        return uri.pathSegments[uri.pathSegments.indexOf('folders') + 1];
      }
      return uri.queryParameters['id'];
    } catch (e) {
      return null;
    }
  }
}