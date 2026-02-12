import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Upload product images
  Future<List<String>> uploadProductImages(
    List<XFile> imageFiles,
    String productId,
  ) async {
    try {
      List<String> imageUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        XFile file = imageFiles[i];
        String fileName = '${productId}_${i}_${path.basename(file.path)}';
        Reference ref = _storage.ref().child('products/$fileName');

        await ref.putFile(File(file.path));
        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload product images: ${e.toString()}');
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(XFile imageFile, String userId) async {
    try {
      String fileName = 'profile_${userId}_${path.basename(imageFile.path)}';
      Reference ref = _storage.ref().child('profiles/$fileName');

      await ref.putFile(File(imageFile.path));
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  // Upload chat image
  Future<String> uploadChatImage(XFile imageFile, String messageId) async {
    try {
      String fileName = 'chat_${messageId}_${path.basename(imageFile.path)}';
      Reference ref = _storage.ref().child('chats/$fileName');

      await ref.putFile(File(imageFile.path));
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload chat image: ${e.toString()}');
    }
  }

  // Upload review images
  Future<List<String>> uploadReviewImages(
    List<XFile> imageFiles,
    String reviewId,
  ) async {
    try {
      List<String> imageUrls = [];

      for (int i = 0; i < imageFiles.length; i++) {
        XFile file = imageFiles[i];
        String fileName = '${reviewId}_${i}_${path.basename(file.path)}';
        Reference ref = _storage.ref().child('reviews/$fileName');

        await ref.putFile(File(file.path));
        String downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      return imageUrls;
    } catch (e) {
      throw Exception('Failed to upload review images: ${e.toString()}');
    }
  }

  // Delete file from storage
  Future<void> deleteFile(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }

  // Delete multiple files
  Future<void> deleteFiles(List<String> fileUrls) async {
    try {
      for (String url in fileUrls) {
        await deleteFile(url);
      }
    } catch (e) {
      throw Exception('Failed to delete files: ${e.toString()}');
    }
  }

  // Pick image from gallery
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  // Pick image from camera
  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  // Pick multiple images from gallery
  Future<List<XFile>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return images;
    } catch (e) {
      throw Exception('Failed to pick images: ${e.toString()}');
    }
  }

  // Get file size
  Future<int> getFileSize(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      FullMetadata metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      throw Exception('Failed to get file size: ${e.toString()}');
    }
  }

  // Check if file exists
  Future<bool> fileExists(String fileUrl) async {
    try {
      Reference ref = _storage.refFromURL(fileUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}