import 'dart:io';

import 'package:flutter/material.dart';
import 'package:invert_colors/invert_colors.dart';
import 'package:kottak/src/data/models.dart';


class SheetPager extends StatefulWidget {
  SheetPager(this.songs, {Key? key, int? id}) : super(key: key) {
    int index = songs.indexWhere((song) => song.id == id);
    if (index == -1) {
      index = 0;
    }
    controller = PageController(initialPage: index);
  }

  static const routeName = 'pager';

  late final PageController controller;

  final List<Song> songs;

  final transformationController = TransformationController();

  @override
  State<SheetPager> createState() => _SheetPagerState();
}

class _SheetPagerState extends State<SheetPager> {
  bool pagingEnabled = true;

  @override
  Widget build(BuildContext context) {
    var view = SafeArea(
      child: PageView.builder(
        restorationId: SheetPager.routeName,
        physics: pagingEnabled
            ? const PageScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        controller: widget.controller,
        itemCount: widget.songs.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            transformationController: widget.transformationController,
            onInteractionEnd: (_) {
              setState(() {
                pagingEnabled =
                    widget.transformationController.value.getMaxScaleOnAxis() <=
                        1;
              });
            },
            maxScale: 10,
            child: FittedBox(
              child: Column(
                children: widget.songs[index].sheets
                    .map((sheet) => Image.file(
                          File(sheet),
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
    return Theme.of(context).brightness == Brightness.light
        ? view
        : InvertColors(
            child: view,
          );
  }
}
