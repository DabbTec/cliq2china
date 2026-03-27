import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';

class AppUpdateService extends GetxService {
  static AppUpdateService get to => Get.find();
  final ApiService _apiService = Get.find<ApiService>();

  Future<void> checkForUpdates({bool showNoUpdateSnackBar = false}) async {
    try {
      // 1. Get current app info
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      final int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

      // 2. Fetch latest version info from backend
      final response = await _apiService.get(ApiEndpoints.checkUpdate);

      if (response.statusCode == 200) {
        final data = response.data;
        final String latestVersion = data['latest_version'] ?? currentVersion;
        final int latestBuildNumber =
            data['build_number'] ?? currentBuildNumber;
        final String downloadUrl = data['download_url'] ?? '';
        final bool isMandatory = data['is_mandatory'] ?? false;

        // 3. Compare versions
        // We check build number first as it's more reliable for internal updates
        if (latestBuildNumber > currentBuildNumber ||
            _isNewerVersion(latestVersion, currentVersion)) {
          _showUpdateDialog(latestVersion, downloadUrl, isMandatory);
        } else if (showNoUpdateSnackBar) {
          Get.snackbar(
            'Up to Date',
            'You are running the latest version of Cliq2China.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
  }

  bool _isNewerVersion(String latest, String current) {
    List<int> latestParts = latest
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    List<int> currentParts = current
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    for (int i = 0; i < latestParts.length && i < currentParts.length; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return latestParts.length > currentParts.length;
  }

  void _showUpdateDialog(String version, String url, bool isMandatory) {
    Get.dialog(
      PopScope(
        canPop: !isMandatory,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
        },
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.system_update, color: Colors.blue),
              const SizedBox(width: 10),
              const Text('Update Available'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A new version ($version) is available.'),
              const SizedBox(height: 10),
              const Text(
                'Please update to get the latest features and improvements.',
              ),
              if (isMandatory)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'This update is required to continue using the app.',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            if (!isMandatory)
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () => _launchDownloadUrl(url),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Update Now'),
            ),
          ],
        ),
      ),
      barrierDismissible: !isMandatory,
    );
  }

  Future<void> _launchDownloadUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Could not open download link');
    }
  }
}
