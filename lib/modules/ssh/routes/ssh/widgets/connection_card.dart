import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/ssh_connection.dart';

class SSHConnectionCard extends StatelessWidget {
  final SSHConnection connection;
  final VoidCallback onConnect;

  const SSHConnectionCard({
    Key? key,
    required this.connection,
    required this.onConnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: connection.name,
      body: [
        TextSpan(
          text: '${connection.username}@${connection.host}:${connection.port}',
        ),
      ],
      onTap: onConnect,
    );
  }
}
