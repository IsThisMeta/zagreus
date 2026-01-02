import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/ssh_connection.dart';

class SSHConnectionCard extends StatelessWidget {
  final SSHConnection connection;
  final VoidCallback onConnect;
  final VoidCallback onDelete;

  const SSHConnectionCard({
    Key? key,
    required this.connection,
    required this.onConnect,
    required this.onDelete,
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
      trailing: ZagIconButton(
        icon: Icons.delete_rounded,
        onPressed: onDelete,
      ),
      onTap: onConnect,
    );
  }
}
