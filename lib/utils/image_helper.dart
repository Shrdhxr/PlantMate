import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageHelper {
  static const String _webImagesKey = 'web_images';

  static Future<String?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) {
      return null;
    }
    
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);
      final imageName = DateTime.now().millisecondsSinceEpoch.toString();
      
      final prefs = await SharedPreferences.getInstance();
      final webImages = prefs.getStringList(_webImagesKey) ?? [];
      
      final imageData = jsonEncode({
        'name': imageName,
        'data': base64Image
      });
      
      webImages.add(imageData);
      await prefs.setStringList(_webImagesKey, webImages);
      
      return 'web_image:$imageName';
    } else {
      return image.path;
    }
  }

  static Widget buildImage(String imagePath, {BoxFit fit = BoxFit.cover}) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      );
    } else if (imagePath.startsWith('web_image:')) {
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
      if (kIsWeb) {
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
