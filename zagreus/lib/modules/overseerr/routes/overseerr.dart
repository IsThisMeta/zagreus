import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';

class OverseerrRoute extends StatelessWidget {
  const OverseerrRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overseerr'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Overseerr',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Request Management Coming Soon'),
          ],
        ),
      ),
    );
  }
}
