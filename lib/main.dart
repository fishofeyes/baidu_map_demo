import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_baidu_mapapi_map/flutter_baidu_mapapi_map.dart';
import 'package:flutter_baidu_mapapi_base/flutter_baidu_mapapi_base.dart' show BMFCoordinate, BMFMapSDK, BMF_COORD_TYPE;

import 'gesture_animate_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 设置用户是否同意SDK隐私协议
  BMFMapSDK.setAgreePrivacy(true);

  // 百度地图sdk初始化鉴权
  if (Platform.isIOS) {
    BMFMapSDK.setApiKeyAndCoordType('rNmS0A3er0Ci7fL6Emd18YesHomT5NL1', BMF_COORD_TYPE.BD09LL);
  } else if (Platform.isAndroid) {
    /// 初始化获取Android 系统版本号
    await BMFAndroidVersion.initAndroidVersion();
    // Android 目前不支持接口设置Apikey,
    // 请在主工程的Manifest文件里设置，详细配置方法请参考官网(https://lbsyun.baidu.com/)demo
    BMFMapSDK.setCoordType(BMF_COORD_TYPE.BD09LL);
  }
  Map? map = await BMFMapVersion.nativeMapVersion;
  print('获取原生地图版本号：$map');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          BMFMapWidget(
            onBMFMapCreated: (controller) {},
            mapOptions: BMFMapOptions(
              center: BMFCoordinate(39.917215, 116.380341),
              zoomLevel: 12,
            ),
          ),
          // Container(
          //   color: Colors.white,
          // ),
          GestureAnimateView(
            child: Container(
              color: Colors.white,
              height: 500,
              child: Column(
                children: [
                  Container(
                    color: Colors.red,
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(
                          text: "Tab1",
                        ),
                        Tab(
                          text: "Tab2",
                        ),
                        Tab(
                          text: "Tab3",
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Container(color: Colors.red),
                        Container(color: Colors.blue),
                        Container(color: Colors.pink),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            headView: Container(
              height: 40,
              width: double.infinity,
              alignment: Alignment.center,
              color: Colors.yellow,
              child: Text("----拖拽头-----"),
            ),
          ),
        ],
      ),
    );
  }
}
