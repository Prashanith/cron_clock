import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<PermissionStatus> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }

  Future<PermissionStatus> checkPermissionStatus(Permission permission) async {
    final currentStatus = permission.status;
    return currentStatus;
  }
}
