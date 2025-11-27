import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrReleasesSearchBar extends StatefulWidget
    implements PreferredSizeWidget {
  final ScrollController scrollController;

  const ReadarrReleasesSearchBar({
    Key? key,
    required this.scrollController,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(ZagTextInputBar.defaultAppBarHeight);

  @override
  State<ReadarrReleasesSearchBar> createState() => _State();
}

class _State extends State<ReadarrReleasesSearchBar> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Consumer<ReadarrState>(
              builder: (context, state, _) => ZagTextInputBar(
                controller: _controller,
                scrollController: widget.scrollController,
                autofocus: false,
                onChanged: (value) =>
                    context.read<ReadarrState>().searchReleasesFilter = value,
                margin: ZagTextInputBar.appBarMargin,
              ),
            ),
          ),
          ReadarrReleasesHideButton(controller: widget.scrollController),
          ReadarrReleasesSortButton(controller: widget.scrollController),
        ],
      ),
      height: ZagTextInputBar.defaultAppBarHeight,
    );
  }
}
