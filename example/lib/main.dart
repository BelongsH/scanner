import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:scanner_view/scanner_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  MethodChannel methodChannel = MethodChannel("com.vv.scanner.scanner_view");

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // try {
    //   platformVersion =
    //       await ScannerView.platformVersion ?? 'Unknown platform version';
    // } on PlatformException {
    //   platformVersion = 'Failed to get platform version.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // setState(() {
    //   _platformVersion = platformVersion;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            const NavitiveView(),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [ScannerBox(), Text("我是测试数据")],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 50,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                  color: Colors.red,
                ),
                width: 60,
                height: 60,
              ),
            ),
            Positioned(
              bottom: 50,
              right: 50,
              child: GestureDetector(
                // 开启有关闭手电筒
                onTap: () async {
                  await methodChannel.invokeMethod('OPEN_FLASH');
                },
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                    color: Colors.red,
                  ),
                  width: 60,
                  height: 60,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NavitiveView extends StatefulWidget {
  const NavitiveView({Key? key}) : super(key: key);

  @override
  State<NavitiveView> createState() => _NavitiveViewState();
}

class _NavitiveViewState extends State<NavitiveView> {
  MethodChannel methodChannel = MethodChannel("com.vv.scanner.scanner_view");

  @override
  void initState() {
    super.initState();
    methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'ON_NOTIFY_QR_CODE':
          final args = call.arguments as String;
          Fluttertoast.showToast(
              msg: "${args}",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String viewType = 'DEMO';
    // final Map<String, dynamic> creationParams = <String, dynamic>{};
    // return AndroidView(
    //   viewType: viewType,
    //   layoutDirection: TextDirection.ltr,
    //   creationParams: creationParams,
    //   creationParamsCodec: const StandardMessageCodec(),
    //   onPlatformViewCreated: (viewId) {
    //     _methodChannel = MethodChannel("scanner_view");
    //     _onPlatformViewCreated(viewId);
    //   },
    // );

    final Map<String, dynamic> creationParams = <String, dynamic>{};
    return PlatformViewLink(
      viewType: 'DEMO',
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: Set.from([]),
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: 'DEMO',
          layoutDirection: TextDirection.rtl,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener((id) {})
          ..create();
      },
    );
  }
}

class ScannerBox extends StatefulWidget {
  const ScannerBox({Key? key}) : super(key: key);

  @override
  _ScannerBoxState createState() => _ScannerBoxState();
}

class _ScannerBoxState extends State<ScannerBox> with TickerProviderStateMixin {
  late AnimationController controller = AnimationController(
      duration: const Duration(milliseconds: 2000), vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

  late Animation<Offset> animation =
      Tween(begin: Offset.zero, end: const Offset(0, 1)).animate(controller);

  @override
  void initState() {
    super.initState();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 210,
        width: double.infinity,
        color: Colors.black38,
        child: SlideTransition(
          position: animation,
          child: Container(
            alignment: Alignment.topLeft,
            height: double.infinity,
            width: double.infinity,
            child: Container(
              height: 5,
              color: Colors.red,
            ),
          ),
        ));
  }
}
