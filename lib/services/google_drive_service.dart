import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
    //clientId: AuthConfig.getClientId(),
    hostedDomain: '',
    signInOption: SignInOption.standard,
  );

  static Future<String?> uploadFile(dynamic file, {required String folderId}) async {
  try {
    GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently().catchError((e) {
      if (kDebugMode) print('Silent sign-in failed: $e');
      return null;
    });

    if (googleUser == null) {
      googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Get.snackbar("Upload Cancelled", "Sign-in was cancelled by the user.");
        return null;
      }
    }

    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw Exception('Unable to authenticate with Google Drive.');
    }

    // File handling
    String fileName;
    String? mimeType;
    Stream<List<int>> fileStream;
    int fileLength;

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      fileName = file.name;
      mimeType = file.type ?? lookupMimeType(fileName) ?? 'application/octet-stream';
      fileStream = Stream.value(bytes);
      fileLength = bytes.length;
    } else {
      fileName = path.basename(file.path);
      mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      fileStream = file.openRead();
      fileLength = await file.length();
    }

    // Upload to Drive
    final driveApi = drive.DriveApi(client);
    final fileMetadata = drive.File()
      ..name = fileName
      ..mimeType = mimeType
      ..parents = [folderId];

    final media = drive.Media(fileStream, fileLength);
    final uploadedFile = await driveApi.files.create(fileMetadata, uploadMedia: media);

    // Make file readable by anyone
    await driveApi.permissions.create(
      drive.Permission()..type = 'anyone'..role = 'reader',
      uploadedFile.id!,
    );

    return "https://drive.google.com/file/d/${uploadedFile.id}/view";
  } on PlatformException catch (e) {
    Get.snackbar("Error", e.message ?? "Platform error during upload.");
    return null;
  } catch (e) {
    Get.snackbar("Upload Failed", "Error: ${e.toString().split('\n').first}");
    return null;
  }
}

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}