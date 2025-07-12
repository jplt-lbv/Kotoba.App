import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/src/core/routing/app_router.dart';
import 'package:flutter_kit/src/core/theme/dimens.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.router.push(const ProfileRoute());
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(Dimens.spacing),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: Dimens.spacing),
              Text(
                'Welcome to the Home Screen!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Dimens.spacing),
              Text(
                'You have successfully logged in.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
