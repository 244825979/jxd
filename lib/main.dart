import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'services/permission_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置状态栏样式 - 统一为黑色图标
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // 黑色图标
      statusBarBrightness: Brightness.light, // iOS适配
    ),
  );

  // 强制竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '静心岛',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        // 统一配置AppBar样式，确保状态栏为黑色
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      home: SplashScreen(
        child: const PermissionWrapper(child: JXDApp()),
      ),
    );
  }
}

class PermissionWrapper extends StatefulWidget {
  final Widget child;

  const PermissionWrapper({
    super.key,
    required this.child,
  });

  @override
  State<PermissionWrapper> createState() => _PermissionWrapperState();
}

class _PermissionWrapperState extends State<PermissionWrapper> {
  late Future<void> _permissionFuture;

  @override
  void initState() {
    super.initState();
    _permissionFuture = _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final permissionService = await PermissionService.getInstance();
    
    // 等待构建完成
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 检查并请求网络权限
      if (!await permissionService.hasRequestedNetworkPermission()) {
        await permissionService.requestNetworkPermission(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _permissionFuture,
      builder: (context, snapshot) {
        // 直接返回子组件，权限检查在后台进行
        return widget.child;
      },
    );
  }
} 