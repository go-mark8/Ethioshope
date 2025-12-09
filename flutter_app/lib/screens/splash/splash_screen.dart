import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  bool _online = true;

  @override
  void initState() {
    super.initState();
    _check();
    Future.delayed(const Duration(seconds:3), () {
      if(_online) Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text("Home"))))
      );
    });
  }

  Future<void> _check() async {
    final c = await Connectivity().checkConnectivity();
    _online = c != ConnectivityResult.none;
    if(!_online) _dialog();
  }

  void _dialog() {
    showDialog(context: context, builder: (ctx){
      return AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text("No Network", style: TextStyle(color: Colors.white)),
        content: const Text("☎️ 0942303002\n📧 Ethiopianmark8@gmail.com",
          style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: (){ Navigator.pop(ctx); _check(); }, child: const Text("Retry")),
          TextButton(onPressed: (){ Navigator.pop(ctx); }, child: const Text("Close"))
        ],
      );
    });
  }

  @override
  Widget build(context) => Scaffold(
    body: Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Lottie.asset("assets/lottie/splash.json"),
        const SizedBox(height: 12),
        const LinearProgressIndicator(),
        const SizedBox(height: 8),
        const Text("0941090959", style: TextStyle(fontSize: 12))
      ]),
    ),
  );
}
