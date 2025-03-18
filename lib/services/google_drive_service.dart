import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'google_auth_service.dart';

class GoogleDriveService {
  final GoogleAuthService _authService = GoogleAuthService();

  Future<String?> uploadFile() async {
    final authClient = await _authService.getAuthClient();
    if (authClient == null) {
      print("Authentication failed");
      return null;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return null; // User canceled file selection

    drive.DriveApi driveApi = drive.DriveApi(authClient);
    drive.File driveFile = drive.File();
    driveFile.name = result.files.first.name;

    if (result.files.first.bytes != null) {
      // For Web (Uint8List-based file upload)
      Uint8List fileBytes = result.files.first.bytes!;
      var response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(Stream.value(fileBytes), fileBytes.length),
      );
      return response.id;
    } else if (result.files.first.path != null) {
      // For Android (File-based upload)
      File file = File(result.files.first.path!);
      var response = await driveApi.files.create(
        driveFile,
        uploadMedia: drive.Media(file.openRead(), file.lengthSync()),
      );
      return response.id;
    }
    return null;
  }
}
