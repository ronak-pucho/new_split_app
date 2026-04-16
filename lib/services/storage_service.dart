import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;

  /// Uploads [image] to Firebase Storage under profiles/{uid}/avatar.jpg
  /// Returns the public download URL or null on failure.
  Future<String?> uploadProfileImage(File image, String uid) async {
    try {
      final ref = _storage.ref().child('profiles/$uid/avatar.jpg');
      final task = await ref.putFile(
        image,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await task.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Deletes the profile image for [uid].
  Future<void> deleteProfileImage(String uid) async {
    try {
      final ref = _storage.ref().child('profiles/$uid/avatar.jpg');
      await ref.delete();
    } catch (_) {
      // Ignore if no image exists
    }
  }
}
