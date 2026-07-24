import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../data/drift/daos/photo_repository.dart';

class PhotoService {
  final PhotoRepository _photoRepository;
  final ImagePicker _imagePicker = ImagePicker();

  PhotoService(this._photoRepository);

  Future<String?> capturePhoto(String babyId) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) return null;

      return await _savePhoto(
        babyId: babyId,
        originalPath: pickedFile.path,
        captureDate: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<String?> selectPhoto(String babyId) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile == null) return null;

      return await _savePhoto(
        babyId: babyId,
        originalPath: pickedFile.path,
        captureDate: DateTime.now(),
      );
    } catch (e) {
      return null;
    }
  }

  Future<String> _savePhoto({
    required String babyId,
    required String originalPath,
    required DateTime captureDate,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'photos'));
    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }

    final fileExtension = p.extension(originalPath);
    final timestamp = captureDate.millisecondsSinceEpoch;
    final fileName = '${timestamp}${fileExtension}';
    final targetPath = p.join(photosDir.path, fileName);

    final originalFile = File(originalPath);
    await originalFile.copy(targetPath);

    final image = img.decodeImage(originalFile.readAsBytesSync());
    final width = image?.width ?? 0;
    final height = image?.height ?? 0;
    final sizeMb = originalFile.lengthSync() / (1024 * 1024);

    String? thumbnailPath;
    if (image != null) {
      final thumbnailSize = 200;
      final thumbnail = img.copyResize(
        image,
        width: thumbnailSize,
        height: thumbnailSize,
      );
      final thumbnailFileName = '${timestamp}_thumb.jpg';
      thumbnailPath = p.join(photosDir.path, thumbnailFileName);
      File(thumbnailPath).writeAsBytesSync(img.encodeJpg(thumbnail, quality: 70));
    }

    return await _photoRepository.addPhoto(
      babyId: babyId,
      filePath: targetPath,
      thumbnailPath: thumbnailPath,
      captureDate: captureDate,
      width: width,
      height: height,
      sizeMb: sizeMb,
    );
  }

  Future<void> deletePhoto(String id) async {
    final photo = await _photoRepository.getPhotoById(id);
    if (photo != null) {
      if (photo.filePath.isNotEmpty) {
        final file = File(photo.filePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      if (photo.thumbnailPath != null && photo.thumbnailPath!.isNotEmpty) {
        final thumbFile = File(photo.thumbnailPath!);
        if (thumbFile.existsSync()) {
          thumbFile.deleteSync();
        }
      }
      await _photoRepository.deletePhoto(id);
    }
  }

  Future<void> toggleFavorite(String id) async {
    await _photoRepository.toggleFavorite(id);
  }

  Future<List<dynamic>> getPhotos(String babyId) async {
    return await _photoRepository.getPhotosByBabyId(babyId);
  }

  Future<List<dynamic>> getFavoritePhotos(String babyId) async {
    return await _photoRepository.getFavoritePhotos(babyId);
  }

  Future<int> getPhotoCount(String babyId) async {
    return await _photoRepository.getPhotoCount(babyId);
  }
}