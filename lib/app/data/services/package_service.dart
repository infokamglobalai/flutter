import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/services/api_service.dart';
import 'package:najahapp/app/data/models/package_model.dart';

class PackageService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Fetch all public packages
  Future<List<PackageModel>> getPublicPackages() async {
    try {
      final response = await _apiService.get(ApiConstants.packagesPublic);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final packagesData = data['data'] as List<dynamic>;
          return packagesData
              .map(
                (json) => PackageModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();
        } else {
          throw Exception('Failed to load packages: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load packages: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to load packages');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Fetch package by ID
  Future<PackageModel> getPackageById(String packageId) async {
    try {
      final response = await _apiService.get(ApiConstants.packageById(packageId));

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return PackageModel.fromJson(data['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Failed to load package: ${data['message']}');
        }
      } else {
        throw Exception('Failed to load package: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to load package');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Initiate payment through Ottu
  Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.post(
        ApiConstants.paymentOttuInitiate,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to initiate payment: ${response.data['message']}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Payment failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
