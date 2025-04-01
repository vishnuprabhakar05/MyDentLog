import 'dart:io';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:my_dentlog_app/config/auth_config.dart';
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
    GoogleSignInAccount? googleUser;
    
    // Try silent sign-in first
    try {
      googleUser = await _googleSignIn.signInSilently();
    } catch (e) {
      if (kDebugMode) {
        print('Silent sign-in failed: $e');
      }
    }

    // If silent sign-in fails, use interactive sign-in
    if (googleUser == null) {
      googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('User canceled the sign-in process');
      }
    }

    // Get authenticated client
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) {
      throw Exception('Unable to get authenticated client');
    }

    // Handle file differently for web vs mobile
    String fileName;
    String? mimeType;
    Stream<List<int>> fileStream;
    int fileLength;

    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      fileName = file.name;
      mimeType = lookupMimeType(fileName);
      fileStream = Stream.value(bytes);
      fileLength = bytes.length;
    } else {
      fileName = path.basename(file.path);
      mimeType = lookupMimeType(file.path);
      fileStream = file.openRead();
      fileLength = await file.length();
    }

    // Upload file to the configured folder
    final driveApi = drive.DriveApi(client);
    final fileMetadata = drive.File()
      ..name = fileName
      ..mimeType = mimeType ?? 'application/octet-stream'
      ..parents = [folderId]; // Use the configured folder

    final media = drive.Media(fileStream, fileLength);
    final uploadedFile = await driveApi.files.create(
      fileMetadata,
      uploadMedia: media,
    );

    // Set public permissions
    await driveApi.permissions.create(
      drive.Permission()
        ..type = 'anyone'
        ..role = 'reader',
      uploadedFile.id!,
    );

    return "https://drive.google.com/file/d/${uploadedFile.id}/view";
  } catch (e) {
    if (kDebugMode) {
      print('Google Drive upload error: $e');
    }
    if (!kIsWeb && e is PlatformException) {
      Get.snackbar(
        "Upload Error",
        e.message ?? "Platform error during upload",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar(
        "Upload Error",
        "Failed to upload file: ${e.toString().split('\n').first}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
    return null;
  }
}

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}