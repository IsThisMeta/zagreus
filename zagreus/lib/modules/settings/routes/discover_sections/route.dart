import 'package:flutter/material.dart';

import 'package:zagreus/core.dart';
import 'package:zagreus/modules/discover/widgets/discover_sections_editor.dart';

class DiscoverSectionsRoute extends StatefulWidget {
  const DiscoverSectionsRoute({Key? key}) : super(key: key);

  @override
  State<DiscoverSectionsRoute> createState() => _State();
}

class _State extends State<DiscoverSectionsRoute> {
  final _editorKey = GlobalKey<DiscoverSectionsEditorState>();
  bool _hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return ZagScaffold(
      scaffoldKey: GlobalKey<ScaffoldState>(),
      appBar: ZagAppBar(
        title: 'Discover Sections',
        actions: [
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: () => _editorKey.currentState?.saveChanges(),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'reset') {
                _editorKey.currentState?.resetToDefaults();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'reset',
                child: Text('Reset to Defaults'),
              ),
            ],
          ),
        ],
      ),
      body: DiscoverSectionsEditor(
        key: _editorKey,
        onHasChangesChanged: (value) => setState(() => _hasChanges = value),
      ),
    );
  }
}
