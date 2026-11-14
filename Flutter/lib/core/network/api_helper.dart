import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../cache/cache_helper.dart';
import '../function/image_helper.dart';
import 'api_response.dart';
import 'endpoints.dart';

class APIHelper {
  static Map<String, String> _headers({
    bool withAuth = true,
    bool isJson = true,
  }) {
    final Map<String, String> headers = {};
    if (isJson) {
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';
    }
    if (withAuth) {
      final token = CacheHelper.accessToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Future<ApiResponse> postJson(
    String url, {
    required Map<String, dynamic> body,
    bool withAuth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: _headers(withAuth: withAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));
      return _decodeResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        errorMessage: e.toString(),
      );
    }
  }

  static Future<ApiResponse> getJson(String url, {bool withAuth = true}) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: _headers(withAuth: withAuth))
          .timeout(const Duration(seconds: 45));
      return _decodeResponse(response);
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        errorMessage: e.toString(),
      );
    }
  }

  /// PATCH /health-records/:recordId/image as multipart/form-data (`image` file + link URL)
  /// يرفع ملف صورة الوجه الفعلي للسيرفر ويرفق رابط الـ URL كما في BioOrbit_4.json
  static Future<ApiResponse> patchMultipartImage({
    required String recordId,
    required XFile imageFile,
  }) async {
    final String albumLinkUrl = ImageHelper.buildAlbumImageUrl(imageFile);
    try {
      final uri = Uri.parse(EndPoints.uploadRecordImage(recordId));
      final request = http.MultipartRequest('PATCH', uri);
      final token = CacheHelper.accessToken;
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      request.fields['image_url'] = albumLinkUrl;

      if (imageFile.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            filename: imageFile.name.isNotEmpty
                ? imageFile.name
                : 'face_scan.jpg',
          ),
        );
      } else {
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageFile.name.isNotEmpty
                ? imageFile.name
                : 'face_scan.jpg',
          ),
        );
      }

      final streamed = await request.send().timeout(
        const Duration(seconds: 50),
      );
      final response = await http.Response.fromStream(streamed);
      final decoded = _decodeResponse(response);

      final serverImgUrl =
          (decoded.data['imageUrl'] ??
                  decoded.data['image_url'] ??
                  decoded.data['image'] ??
                  decoded.data['data']?['imageUrl'] ??
                  decoded.data['data']?['image'])
              ?.toString();

      return decoded.copyWith(
        generatedImageUrl: (serverImgUrl != null && serverImgUrl.isNotEmpty)
            ? serverImgUrl
            : albumLinkUrl,
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        statusCode: 500,
        errorMessage: e.toString(),
        generatedImageUrl: albumLinkUrl,
      );
    }
  }

  static ApiResponse _decodeResponse(http.Response response) {
    final bool ok = response.statusCode >= 200 && response.statusCode < 300;
    try {
      final dynamic parsed = jsonDecode(utf8.decode(response.bodyBytes));
      if (parsed is Map<String, dynamic>) {
        return ApiResponse(
          isSuccess: ok,
          statusCode: response.statusCode,
          data: parsed,
          errorMessage: ok
              ? null
              : (parsed['message'] ?? parsed['error'])?.toString(),
        );
      } else {
        return ApiResponse(
          isSuccess: ok,
          statusCode: response.statusCode,
          data: {'items': parsed},
        );
      }
    } catch (_) {
      return ApiResponse(
        isSuccess: ok,
        statusCode: response.statusCode,
        data: {'raw': response.body},
      );
    }
  }
}
