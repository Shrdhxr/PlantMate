import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for handling images across platforms
class ImageHelper {
  static const String _webImagesKey = 'web_images';

  /// Picks an image from gallery and returns the path
  /// Works on both web and mobile
  static Future<String?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) {
      return null;
    }
    
    if (kIsWeb) {
      // For web, we need to store the image data in shared preferences
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final imageName = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Store the image in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final webImages = prefs.getStringList(_webImagesKey) ?? [];
      
      // Create a map with image name and data
      final imageData = jsonEncode({
        'name': imageName,
        'data': base64Image
      });
      
      webImages.add(imageData);
      await prefs.setStringList(_webImagesKey, webImages);
      
      // Return a special path for web images
      return 'web_image:$imageName';
    } else {
      // For mobile, we can use the file path directly
      return image.path;
    }
  }

  /// Builds an image widget based on the image path
  /// Works with both web and mobile paths
  static Widget buildImage(String imagePath, {BoxFit fit = BoxFit.cover}) {
    if (imagePath.startsWith('assets/')) {
      // Asset image
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else if (imagePath.startsWith('web_image:')) {
      // Web image stored in shared preferences
      return FutureBuilder<Uint8List?>(
        future: _getWebImageBytes(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || snapshot.data == null) {
            return _buildErrorWidget();
          }
          
          return Image.memory(
            snapshot.data!,
            fit: fit,
          );
        },
      );
    } else {
      // Regular file path (mobile)
      if (kIsWeb) {
        // Fallback for web if a regular path is provided
        return _buildErrorWidget();
      }
      
      return Image.file(
        File(imagePath),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    }
  }

  /// Gets the bytes of a web image from shared preferences
  static Future<Uint8List?> _getWebImageBytes(String webImagePath) async {
    try {
      final imageName = webImagePath.replaceFirst('web_image:', '');
      final prefs = await SharedPreferences.getInstance();
      final webImages = prefs.getStringList(_webImagesKey) ?? [];
      
      for (final imageData in webImages) {
        final Map<String, dynamic> data = jsonDecode(imageData);
        if (data['name'] == imageName) {
          final base64Image = data['data'];
          return base64Decode(base64Image);
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting web image: $e');
      return null;
    }
  }
  
  /// Builds a widget to display when an image fails to load
  static Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.broken_image,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}
