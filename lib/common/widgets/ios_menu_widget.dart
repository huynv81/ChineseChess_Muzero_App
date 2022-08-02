import 'package:flutter/cupertino.dart';
// TODO：这个文件块是否还有用？

getIosPopUpMenu(BuildContext context) {
  // I can do with this widget
  return showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {},
            child: Text('自定义引擎'),
          ),
        ],
      );
    },
  );

  // but I can't do with this widget, which I prefer
  // return CupertinoContextMenu(
  //   actions: [
  //     CupertinoContextMenuAction(
  //       child: const Text('Add to Favorites'),
  //       onPressed: () {
  //         // Implement your logic here
  //         debugPrint('Added to Favorites');

  //         // Then close the context menu
  //         Navigator.of(context).pop();
  //       },
  //     ),
  //     CupertinoContextMenuAction(
  //       child: const Text('Download'),
  //       onPressed: () {
  //         // Implement your logic here
  //         debugPrint('Downloaded');

  //         // Then close the context menu
  //         Navigator.of(context).pop();
  //       },
  //     ),
  //   ],
  //   child: const SizedBox(),
  // );
}
