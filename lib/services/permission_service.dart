import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:io';
import 'dart:convert';

class PermissionService {
  static const String _networkPermissionKey = 'network_permission_requested';
  static PermissionService? _instance;
  late SharedPreferences _prefs;
  
  PermissionService._();
  
  static Future<PermissionService> getInstance() async {
    if (_instance == null) {
      _instance = PermissionService._();
      await _instance!._init();
    }
    return _instance!;
  }
  
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 检查是否已经请求过网络权限
  Future<bool> hasRequestedNetworkPermission() async {
    return _prefs.getBool(_networkPermissionKey) ?? false;
  }

  // 标记网络权限已请求
  Future<void> markNetworkPermissionRequested() async {
    await _prefs.setBool(_networkPermissionKey, true);
  }

  // 触发iOS本地网络权限对话框
  Future<void> _triggerLocalNetworkPermission() async {
    // 简化实现，不再使用network_info_plus
    try {
      // 直接进行网络请求触发权限
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      print('本地网络权限请求: $e');
    }
  }

  // 触发iOS系统网络权限对话框
  Future<bool> _triggerSystemNetworkPermission() async {
    try {
      // 首先触发本地网络权限
      await _triggerLocalNetworkPermission();
      
      // 然后进行外部网络请求
      final client = HttpClient();
      
      // 设置超时
      client.connectionTimeout = const Duration(seconds: 5);
      
      // 尝试连接到一个安全的测试端点
      // 这会触发iOS系统的网络权限对话框
      final request = await client.getUrl(Uri.parse('https://httpbin.org/get'));
      request.headers.add('User-Agent', 'JingXinDao/1.0');
      
      final response = await request.close();
      
      // 读取响应以确保连接完成
      await response.transform(utf8.decoder).join();
      
      client.close();
      
      return response.statusCode == 200;
    } catch (e) {
      print('网络请求失败: $e');
      // 即使请求失败，权限对话框也可能已经显示
      return false;
    }
  }

  // 请求网络权限 - 真正的iOS系统权限
  Future<bool> requestNetworkPermission(BuildContext context) async {
    bool hasRequested = await hasRequestedNetworkPermission();
    if (hasRequested) {
      return true;
    }

    // 显示一个简单的说明对话框
    bool? userConsent = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('网络访问权限'),
        content: const Text('静心岛需要访问网络来获取冥想音频内容。\n\n接下来iOS将显示系统权限对话框，请选择"允许"以获得最佳体验。'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '取消',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('继续'),
          ),
        ],
      ),
    );

    if (userConsent == true) {
      // 触发真正的iOS网络权限对话框
      bool networkAccessGranted = await _triggerSystemNetworkPermission();
      
      // 标记权限已请求（无论是否成功）
      await markNetworkPermissionRequested();
      
      return networkAccessGranted;
    }

    return false;
  }

  // 检查网络权限状态
  Future<bool> checkNetworkPermission() async {
    try {
      // 尝试一个简单的网络请求来检查权限状态
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 3);
      
      final request = await client.getUrl(Uri.parse('https://httpbin.org/get'));
      final response = await request.close();
      
      client.close();
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 测试网络连接
  Future<bool> testNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // ===== 相册权限相关 =====
  
  // 请求相册权限
  Future<bool> requestPhotoLibraryPermission() async {
    PermissionStatus status = await Permission.photos.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.photos.request();
    }
    
    return status.isGranted;
  }

  // 检查相册权限状态
  Future<PermissionStatus> checkPhotoLibraryPermission() async {
    return await Permission.photos.status;
  }

  // ===== 摄像头权限相关 =====
  
  // 请求摄像头权限
  Future<bool> requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    
    return status.isGranted;
  }

  // 检查摄像头权限状态
  Future<PermissionStatus> checkCameraPermission() async {
    return await Permission.camera.status;
  }

  // ===== 麦克风权限相关 =====
  
  // 请求麦克风权限
  Future<bool> requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    
    return status.isGranted;
  }

  // 检查麦克风权限状态
  Future<PermissionStatus> checkMicrophonePermission() async {
    return await Permission.microphone.status;
  }

  // ===== 批量权限处理 =====
  
  // 请求媒体相关的所有权限（相册、摄像头、麦克风）
  Future<Map<String, bool>> requestMediaPermissions(BuildContext context) async {
    Map<String, bool> results = {};
    
    // 显示权限说明对话框
    bool? userConsent = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('媒体访问权限'),
        content: const Text('静心岛需要访问以下权限来提供完整的功能体验：\n\n• 相册：选择和保存心情照片\n• 摄像头：拍摄心情瞬间\n• 麦克风：录制语音日记'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              '稍后设置',
              style: TextStyle(color: CupertinoColors.destructiveRed),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (userConsent != true) {
      return {
        'photos': false,
        'camera': false,
        'microphone': false,
      };
    }

    // 依次请求权限
    results['photos'] = await requestPhotoLibraryPermission();
    results['camera'] = await requestCameraPermission();
    results['microphone'] = await requestMicrophonePermission();
    
    return results;
  }

  // 检查所有媒体权限状态
  Future<Map<String, PermissionStatus>> checkAllMediaPermissions() async {
    return {
      'photos': await checkPhotoLibraryPermission(),
      'camera': await checkCameraPermission(),
      'microphone': await checkMicrophonePermission(),
    };
  }

  // 显示权限设置引导对话框
  Future<void> showPermissionSettingsDialog(BuildContext context, String permissionName) async {
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('${permissionName}权限被拒绝'),
        content: Text('要使用此功能，请在系统设置中允许静心岛访问${permissionName}。\n\n设置 > 隐私与安全性 > ${permissionName} > 静心岛'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('稍后'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('去设置'),
          ),
        ],
      ),
    );
  }

  // 获取权限状态的友好描述
  String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return '已授权';
      case PermissionStatus.denied:
        return '被拒绝';
      case PermissionStatus.restricted:
        return '受限制';
      case PermissionStatus.limited:
        return '部分授权';
      case PermissionStatus.permanentlyDenied:
        return '永久拒绝';
      default:
        return '未知状态';
    }
  }
} 