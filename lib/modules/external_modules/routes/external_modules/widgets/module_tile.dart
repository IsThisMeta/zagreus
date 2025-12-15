import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/database/models/external_module.dart';
import 'package:zagreus/extensions/string/links.dart';

class ExternalModulesModuleTile extends StatelessWidget {
  final ZagExternalModule? module;

  const ExternalModulesModuleTile({
    Key? key,
    required this.module,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ZagBlock(
      title: module!.displayName,
      body: [TextSpan(text: module!.host)],
      trailing: const ZagIconButton.arrow(),
      onTap: module!.host.openLink,
    );
  }
}
