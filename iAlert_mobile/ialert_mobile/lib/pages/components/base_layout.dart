import 'package:flutter/material.dart';

class BaseLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? FloatingActionButton;

  const BaseLayout({
    super.key,
    required this.child,
    this.title = "iAlert Mobile",
    this.FloatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
      floatingActionButton: FloatingActionButton,
    );
  }
}
