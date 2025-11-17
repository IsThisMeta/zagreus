import 'package:flutter/material.dart';
import 'package:zagreus/core.dart';
import 'package:zagreus/modules/readarr.dart';

class ReadarrAddSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  final Function callback;

  const ReadarrAddSearchBar({
    Key? key,
    required this.scrollController,
    required this.callback,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      const Size.fromHeight(ZagTextInputBar.defaultAppBarHeight);

  @override
  State<ReadarrAddSearchBar> createState() => _State();
}

class _State extends State<ReadarrAddSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final model = Provider.of<ReadarrState>(context, listen: false);
    _controller.text = model.addSearchQuery;
  }

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
                    context.read<ReadarrState>().addSearchQuery = value,
                onSubmitted: (value) {
                  if (value.isNotEmpty) widget.callback();
                },
                margin: ZagTextInputBar.appBarMargin,
              ),
            ),
          ),
        ],
      ),
      height: ZagTextInputBar.defaultAppBarHeight,
    );
  }
}
