// import 'dart:convert';
// import 'package:crypto/crypto.dart';
// import 'package:dio/dio.dart';

// class CloudinaryService {
//   final Dio _dio = Dio();

//   // Credentials from CLOUDINARY_URL=cloudinary://229758938588244:ZrAjaFjVgn86pVs5yFmE3diWyzg@dskjvn72y
//   final String _cloudName = 'dskjvn72y';
//   final String _apiKey = '229758938588244';
//   final String _apiSecret = 'ZrAjaFjVgn86pVs5yFmE3diWyzg';

//   Future<String?> uploadImage(String filePath) async {
//     try {
//       final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       // Generate Signature
//       final paramsToSign = 'timestamp=$timestamp$_apiSecret';
//       final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

//       final String fileName = filePath.split('/').last;

//       final formData = FormData.fromMap({
//         'file': await MultipartFile.fromFile(filePath, filename: fileName),
//         'api_key': _apiKey,
//         'timestamp': timestamp,
//         'signature': signature,
//       });

//       final response = await _dio.post(
//         'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
//         data: formData,
//       );

//       if (response.statusCode == 200) {
//         return response.data['secure_url'] as String;
//       }
//       return null;
//     } catch (e) {
//       print('❌ Cloudinary Upload Error: $e');
//       return null;
//     }
//   }

//   Future<void> deleteImage(String imageUrl) async {
//     try {
//       // Extract public_id from Cloudinary URL
//       // URL format: https://res.cloudinary.com/{cloud_name}/image/upload/v{version}/{public_id}.{format}
//       final uri = Uri.parse(imageUrl);
//       final pathSegments = uri.pathSegments;
      
//       // Find the index of 'upload' and get everything after it
//       final uploadIndex = pathSegments.indexOf('upload');
//       if (uploadIndex == -1 || uploadIndex >= pathSegments.length - 1) {
//         throw Exception('Invalid Cloudinary URL format');
//       }
      
//       // Get the public_id (skip version if present)
//       String publicId = pathSegments.sublist(uploadIndex + 1).join('/');
      
//       // Remove version prefix (v1234567890/) if present
//       if (publicId.startsWith('v') && publicId.contains('/')) {
//         final parts = publicId.split('/');
//         if (parts[0].length > 1 && int.tryParse(parts[0].substring(1)) != null) {
//           publicId = parts.sublist(1).join('/');
//         }
//       }
      
//       // Remove file extension
//       publicId = publicId.split('.').first;

//       final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

//       // Generate signature for deletion
//       final paramsToSign = 'public_id=$publicId&timestamp=$timestamp$_apiSecret';
//       final signature = sha1.convert(utf8.encode(paramsToSign)).toString();

//       final formData = FormData.fromMap({
//         'public_id': publicId,
//         'api_key': _apiKey,
//         'timestamp': timestamp,
//         'signature': signature,
//       });

//       final response = await _dio.post(
//         'https://api.cloudinary.com/v1_1/$_cloudName/image/destroy',
//         data: formData,
//       );

//       if (response.statusCode == 200 && response.data['result'] == 'ok') {
//         print('✅ Image deleted from Cloudinary: $publicId');
//       } else {
//         print('⚠️ Cloudinary delete response: ${response.data}');
//       }
//     } catch (e) {
//       print('❌ Cloudinary Delete Error: $e');
//       rethrow;
//     }
//   }
// }
