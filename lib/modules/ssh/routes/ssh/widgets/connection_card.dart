import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/ssh_connection.dart';
import 'package:zagreus/modules.dart';

class SSHConnectionCard extends StatelessWidget {
  final SSHConnection connection;
  final VoidCallback onConnect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SSHConnectionCard({
    Key? key,
    required this.connection,
    required this.onConnect,
    required this.onEdit,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZagIconButton(
            icon: Icons.edit_rounded,
            onPressed: onEdit,
          ),
          ZagIconButton(
            icon: Icons.delete_rounded,
            onPressed: onDelete,
          ),
        ],
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: ZagModule.SSH.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          connection.authType == SSHAuthType.password
              ? Icons.password_rounded
              : Icons.key_rounded,
          color: ZagModule.SSH.color,
          size: 20,
        ),
      ),
      onTap: onConnect,
    );
  }
}
