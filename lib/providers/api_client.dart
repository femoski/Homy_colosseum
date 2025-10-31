import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:homy/providers/api_checker.dart';
import 'package:get/get.dart';
import 'package:homy/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart' as dio;

import '../models/users/fetch_user.dart';

class ApiClient extends GetxService {
  final String appBaseUrl;
  // final SharedPreferences sharedPreferences;
  static final String noInternetMessage = 'connection_to_api_server_failed'.tr;
  static final String connectionTimeoutMessage = 'connection_timeout'.tr;
  static final String serverErrorMessage = 'Server Error'.tr;
  static final String networkErrorMessage = 'network_error_please_check_connection'.tr;
  final int timeoutInSeconds = 40;

  final Rx<UserData> currentUser = Get.find<AuthService>().user;

  String? token;
  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl}) {
    
    token = currentUser.value.apiToken;
    if (kDebugMode) {
      print('Token: $token');
    }

    updateHeader(token, null, null, null, null, null, null);

  }

  Map<String, String> updateHeader(String? token, List<int>? zoneIDs, List<int>? operationIds, String? languageCode, int? moduleID, String? latitude, String? longitude, {bool setHeader = true}) {
    Map<String, String> header = {};

    // if(moduleID != null || sharedPreferences.getString(AppConstants.cacheModuleId) != null) {
    //   header.addAll({AppConstants.moduleId: '${moduleID ?? ModuleModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.cacheModuleId)!)).id}'});
    // }

    
    header.addAll({
      'Content-Type': 'application/json; charset=UTF-8',
       // AppConstants.zoneId: zoneIDs != null ? jsonEncode(zoneIDs) : '',
      ///this will add in ride module
      // AppConstants.operationAreaId: operationIds != null ? jsonEncode(operationIds) : '',
      'localizationKey': languageCode ?? 'en',
      'latitude': latitude != null ? jsonEncode(latitude) : '',
      'longitude': longitude != null ? jsonEncode(longitude) : '',
      'Authorization': 'Bearer $token'
    });
    if(setHeader) {
      _mainHeaders = header;
    }
    return header;
  }

  Map<String, String> getHeader() => _mainHeaders;

  Map<String, String> _getLatestHeaders({Map<String, String>? customHeaders}) {
    // Get latest token from AuthService
    final token = Get.find<AuthService>().user.value.apiToken;
    
    // Create base headers
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'localizationKey': 'en',
      'Authorization': 'Bearer $token'
    };

    // Add any custom headers
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  Future<Response> getData(String uri, {Map<String, dynamic>? query, Map<String, String>? headers, bool handleError = true}) async {
    try {
      final finalHeaders = _getLatestHeaders(customHeaders: headers);
      
      if (kDebugMode) {
        print('====> API Call: $uri\nHeader: $finalHeaders');
      }

      Uri _uri = Uri.parse(appBaseUrl+uri).replace(queryParameters: query);
      http.Response response = await http.get(
        _uri,
        headers: finalHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));

      return handleResponse(response, uri, handleError);
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('====> Socket Exception: $e');
      }
      return Response(
        statusCode: -1,
        statusText: networkErrorMessage,
        body: {'message': networkErrorMessage}
      );
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('====> Timeout Exception: $e');
      }
      return Response(
        statusCode: -2,
        statusText: connectionTimeoutMessage,
        body: {'message': connectionTimeoutMessage}
      );
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('====> Client Exception: $e');
      }
      return Response(
        statusCode: -3,
        statusText: serverErrorMessage,
        body: {'message': serverErrorMessage}
      );
    } catch (e) {
      if (kDebugMode) {
        print('====> API Error: $e');
      }
      return Response(
        statusCode: -4,
        statusText: noInternetMessage,
        body: {'message': noInternetMessage}
      );
    }
  }

  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers, int? timeout, bool handleError = true}) async {
    try {
      final finalHeaders = _getLatestHeaders(customHeaders: headers);
      
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: $finalHeaders');
        print('====> API Body: $body');
      }
      
      http.Response response = await http.post(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(body),
        headers: finalHeaders,
      ).timeout(Duration(seconds: timeout ?? timeoutInSeconds));
      
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> postMultipartData(String uri, Map<String, String> body, List<MultipartBody> multipartBody, {Map<String, String>? headers, bool handleError = true}) async {
    try {
            Get.log('Femi: ${headers ?? _mainHeaders}');

      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
        print('====> API Body: $body with ${multipartBody.length} picture');
      }
      http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(appBaseUrl+uri));
      request.headers.addAll(headers ?? _mainHeaders);
      for(MultipartBody multipart in multipartBody) {
        if(multipart.file != null) {
          Uint8List list = await multipart.file!.readAsBytes();
          request.files.add(http.MultipartFile(
            multipart.key, multipart.file!.readAsBytes().asStream(), list.length,
            filename: '${DateTime.now().toString()}.png',
          ));
        }
      }
      request.fields.addAll(body);
      http.Response response = await http.Response.fromStream(await request.send());
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
        print('====> API Body: $body');
      }
      http.Response response = await http.put(
        Uri.parse(appBaseUrl+uri),
        body: jsonEncode(body),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(String uri, {Map<String, String>? headers, bool handleError = true}) async {
    try {
      if(kDebugMode) {
        print('====> API Call: $uri\nHeader: ${headers ?? _mainHeaders}');
      }
      http.Response response = await http.delete(
        Uri.parse(appBaseUrl+uri),
        headers: headers ?? _mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri, handleError);
    } catch (e) {
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  
  Future<Response> multiPartRequest({
    required String url,
    required Map<String, List<XFile>> filesMap,
    required Map<String, dynamic> fields,
    Map<String, String>? headers,
  }) async {
    var request = http.MultipartRequest('POST', Uri.parse(appBaseUrl+url));
    
    // Get latest headers
    final finalHeaders = _getLatestHeaders(customHeaders: headers);
    request.headers.addAll(finalHeaders);

    if(kDebugMode) {
      print('====> API Call: $url\nHeader: ${finalHeaders}');
    }

    // Add all text fields
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // Add all files
    for (var entry in filesMap.entries) {
      String fieldName = entry.key;
      Get.log('Femi: ${fieldName}');
      List<XFile> files = entry.value;
      
      for (var file in files) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fieldName,
            file.path,
          ),
        );
      }
    }

    // Send the request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return handleResponse(response, url, true);
  }


  Future<Response> multiPartRequestWeb({
    required String url,
    required Map<String, List<XFile>> filesMap,
    required Map<String, dynamic> fields,
    Map<String, String>? headers,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(appBaseUrl + url));
      
      // Get latest headers
      final finalHeaders = _getLatestHeaders(customHeaders: headers);
      // Remove content-type header as it's automatically set for multipart requests
      finalHeaders.remove('Content-Type');
      request.headers.addAll(finalHeaders);

      if(kDebugMode) {
        print('====> API Call: $url\nHeader: ${finalHeaders}');
        print('====> Fields: $fields');
      }

      // Add all text fields
      fields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // Add all files
      for (var entry in filesMap.entries) {
        String fieldName = entry.key;
        List<XFile> files = entry.value;
        
        for (var file in files) {
          if (kIsWeb) {
            // Handle web file upload
            final bytes = await file.readAsBytes();
            final fileName = file.name;
            // final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
            
            if(kDebugMode) {
              // print('Adding web file: $fileName with type: $mimeType');
              print('File size: ${bytes.length} bytes');
            }
            
            final multipartFile = http.MultipartFile.fromBytes(
              fieldName,
              bytes,
              filename: fileName,
              // contentType: MediaType.parse(mimeType),
            );
            
            request.files.add(multipartFile);
            
            if(kDebugMode) {
              print('Successfully added web file to request: ${multipartFile.filename}');
            }
          } else {
            // Handle mobile file upload
            // final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
            
            // if(kDebugMode) {
            //   print('Adding mobile file: ${file.path} with type: $mimeType');
            // }
            
            final multipartFile = await http.MultipartFile.fromPath(
              fieldName,
              file.path,
              // contentType: MediaType.parse(mimeType),
            );
            
            request.files.add(multipartFile);
          }
        }
      }

      if(kDebugMode) {
        print('====> Total files in request: ${request.files.length}');
        for (var file in request.files) {
          print('File in request: ${file.filename}, Field: ${file.field}');
        }
      }

      // Send the request
      var streamedResponse = await request.send().timeout(Duration(seconds: timeoutInSeconds));
      var response = await http.Response.fromStream(streamedResponse);
      
      if(kDebugMode) {
        print('====> Response status: ${response.statusCode}');
        print('====> Response body: ${response.body}');
      }
      
      return handleResponse(response, url, true);
    } catch (e, stackTrace) {
      if(kDebugMode) {
        print('====> Error in multiPartRequest: $e');
        print('====> Stack trace: $stackTrace');
      }
      return Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> multiPartRequestWithDio({
    required String url,
    required Map<String, List<XFile>> filesMap,
    required Map<String, dynamic> fields,
    Map<String, String>? headers,
    Function(int sent, int total)? onSendProgress,
    Function(int received, int total)? onReceiveProgress,
    dio.CancelToken? cancelToken,
  }) async {
    try {
      final dioClient = dio.Dio();
      
      // Get latest headers
      final finalHeaders = _getLatestHeaders(customHeaders: headers);
      dioClient.options.headers = finalHeaders;

      if (kDebugMode) {
        print('====> API Call: $url\nHeader: ${finalHeaders}');
        print('====> Fields: $fields');
      }

      dio.FormData formData = dio.FormData();

      // Add all text fields
      fields.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add all files
      for (var entry in filesMap.entries) {
        String fieldName = entry.key;
        List<XFile> files = entry.value;

        for (var file in files) {
          if (kIsWeb) {
            // Handle web file upload
            final bytes = await file.readAsBytes();
            final fileName = file.name;
            
            formData.files.add(
              MapEntry(
                fieldName,
                dio.MultipartFile.fromBytes(
                  bytes,
                  filename: fileName,
                ),
              ),
            );
          } else {
            // Handle mobile file upload
            formData.files.add(
              MapEntry(
                fieldName,
                await dio.MultipartFile.fromFile(
                  file.path,
                  filename: file.name,
                ),
              ),
            );
          }
        }
      }

      final dioResponse = await dioClient.post(
        appBaseUrl + url,
        data: formData,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        options: dio.Options(
          followRedirects: true,
          validateStatus: (status) {
            return status! < 500;
          },
          sendTimeout: Duration(seconds: timeoutInSeconds),
          receiveTimeout: Duration(seconds: timeoutInSeconds),
        ),
      );

      // Convert Dio response to our Response format
      http.Response httpResponse = http.Response(
        dioResponse.data is String 
            ? dioResponse.data 
            : json.encode(dioResponse.data),
        dioResponse.statusCode ?? 500,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      );

      print('Femirespindddd: ${httpResponse.body}');

      return handleResponse(httpResponse, url, true);

    } on dio.DioException catch (e) {
      if (kDebugMode) {
        print('====> Dio Error: ${e.message}');
        print('====> Error Type: ${e.type}');
        print('====> Error Response: ${e.response}');
      }

      String errorMessage = noInternetMessage;
      int statusCode = 500;

      switch (e.type) {
        case dio.DioExceptionType.connectionTimeout:
          errorMessage = connectionTimeoutMessage;
          statusCode = -2;
          break;
        case dio.DioExceptionType.sendTimeout:
          errorMessage = connectionTimeoutMessage;
          statusCode = -2;
          break;
        case dio.DioExceptionType.receiveTimeout:
          errorMessage = connectionTimeoutMessage;
          statusCode = -2;
          break;
        case dio.DioExceptionType.connectionError:
          errorMessage = networkErrorMessage;
          statusCode = -1;
          break;
        case dio.DioExceptionType.cancel:
          errorMessage = 'Request was cancelled';
          statusCode = -5;
          break;
        default:
          if (e.response != null) {
            statusCode = e.response!.statusCode ?? 500;
            errorMessage = e.response!.statusMessage ?? serverErrorMessage;
          }
      }

      return Response(
        statusCode: statusCode,
        statusText: errorMessage,
        body: e.response?.data ?? {'message': errorMessage},
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('====> Error in multiPartRequestWithDio: $e');
        print('====> Stack trace: $stackTrace');
      }
      return Response(
        statusCode: -4,
        statusText: noInternetMessage,
        body: {'message': noInternetMessage},
      );
    }
  }

  Response handleResponse(http.Response response, String uri, bool handleError) {
    if (kDebugMode) {
      print('====> API Response: [${response.statusCode}] $uri');
      print('====> Response body: ${response.body}');
    }

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch(_) {
      body = response.body;
    }

    // Create base response object with null safety
    Response response0 = Response(
      body: body,
      bodyString: response.body.toString(),
      request: response.request != null ? Request(
        headers: response.request?.headers ?? {},
        method: response.request?.method ?? 'UNKNOWN',
        url: response.request?.url ?? Uri.parse(uri)
      ) : null,
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase ?? 'Unknown Status',
    );

    // Handle different error scenarios
    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = noInternetMessage;
      
      if (body != null && body is Map) {
        // Extract error message with null safety
        errorMessage = body['message']?.toString() ?? 
          (body['data']['errors'] is List && (body['data']['errors'] as List).isNotEmpty 
            ? body['data']['errors'][0]['message']?.toString() ?? noInternetMessage
            : noInternetMessage);
      }

      if (kDebugMode) {
        print('====> Error Message: $errorMessage');
      }

      // Handle specific HTTP status codes
      switch (response.statusCode) {
        case -1:
          errorMessage = networkErrorMessage;
          break;
        case -2:
          errorMessage = connectionTimeoutMessage;
          break;
        case -3:
          errorMessage = serverErrorMessage;
          break;
        case 400:
          errorMessage = 'Bad Request: $errorMessage';
          break;
        case 401:
          errorMessage = 'Unauthorized: Please login again';
          Get.find<AuthService>().removeCurrentUser();
          break;
        case 403:
          errorMessage = 'Forbidden: You don\'t have permission';
          break;
        case 404:
          errorMessage = 'Not Found: The requested resource doesn\'t exist';
          break;
        case 500:
          errorMessage = 'Internal Server Error: Please try again later';
          break;
        case 502:
          errorMessage = 'Bad Gateway: Server is temporarily unavailable';
          break;
        case 503:
          errorMessage = 'Service Unavailable: Please try again later';
          break;
      }

      response0 = Response(
        statusCode: response.statusCode,
        body: body ?? {'message': errorMessage},
        statusText: errorMessage,
      );

      if (handleError) {
        ApiChecker.checkApi(response0);
      }
    }

    return response0;
  }
}

class MultipartBody {
  String key;
  XFile? file;

  MultipartBody(this.key, this.file);
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic body;

  ApiException({
    required this.message,
    this.statusCode,
    this.body,
  });

  @override
  String toString() => message;
}