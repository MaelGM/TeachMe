import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const FullscreenImagePage({
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              tag: tag,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
