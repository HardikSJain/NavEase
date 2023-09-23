import 'package:flutter/material.dart';
import 'package:frontend/constants/routes.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/inclusify.png',
              width: 150,
              height: 150,
            ),
            Image.asset(
              'assets/images/no-wifi.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            const Text('No Internet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Retry the network connectivity check
                retryConnectivity(context);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void retryConnectivity(BuildContext context) async {
    bool isConnected = await checkInternetConnectivity();
    if (isConnected) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        homeRoute,
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<bool> checkInternetConnectivity() async {
    final isConnected = await InternetConnectionChecker().hasConnection;

    return isConnected;
  }
}
