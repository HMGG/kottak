import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:kottak/main.dart';

class MyList<T> extends StatefulWidget {
  MyList(
    this.items,
    this.itemConstructor, {
    Key? key,
    this.axisCount = 1,
    this.aspectRatio = 4,
    this.reorderable = false,
    this.onReorder,
  }) : super(key: key);

  final List<T> items;

  final Widget Function(T data,
      [void Function(T)? onUpdated,
      void Function(int)? onDeleted]) itemConstructor;

  final list = GlobalKey<AnimatedListState>();

  final int axisCount;

  final double aspectRatio;

  final bool reorderable;

  final void Function(List<T> newOrder)? onReorder;

  @override
  State<MyList<T>> createState() => MyListState<T>();
}

class MyListState<T> extends State<MyList<T>> {
  refreshList(List<T> newList) {
    for (int i = widget.items.length; i > 0; i--) {
      var item = widget.items.removeLast();
      widget.list.currentState
          ?.removeItem(i - 1, ((_, __) => widget.itemConstructor(item)));
    }
    for (int i = 0; i < newList.length; i++) {
      widget.items.add(newList[i]);
      widget.list.currentState?.insertItem(i);
    }
  }

  addItem(T item) {
    objectbox.store.box<T>().put(item);
    widget.items.insert(0, item);
    widget.list.currentState?.insertItem(0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: widget.axisCount > 1 || widget.reorderable
          ? ReorderableBuilder(
              initDelay: widget.reorderable
                  ? Duration(milliseconds: widget.items.length * 100)
                  : null,
              enableDraggable: widget.reorderable,
              onReorder: (orderUpdates) {
                for (final update in orderUpdates) {
                  widget.items.insert(
                    update.newIndex,
                    widget.items.removeAt(update.oldIndex),
                  );
                  if (widget.onReorder != null) widget.onReorder!(widget.items);
                }
              },
              children: widget.items.map((item) {
                int index = widget.items.indexOf(item);
                return widget.itemConstructor(
                  item,
                  (updatedItem) => setState(
                    () {
                      widget.items[index] = updatedItem;
                      objectbox.store.box<T>().put(updatedItem);
                    },
                  ),
                  (id) {
                    if (objectbox.store.box<T>().remove(id)) {
                      setState(() => widget.items.removeAt(index));
                    }
                  },
                );
              }).toList(),
              builder: (children, scrollContainer) => GridView(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 90),
                controller: scrollContainer,
                children: children,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.axisCount,
                  childAspectRatio: widget.aspectRatio,
                ),
              ),
            )
          : AnimatedList(
              key: widget.list,
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 90),
              initialItemCount: widget.items.length,
              itemBuilder: (context, index, animation) => FadeTransition(
                opacity: animation,
                child: widget.itemConstructor(
                  widget.items[index],
                  (updatedItem) {
                    setState(() {
                      widget.items[index] = updatedItem;
                      objectbox.store.box<T>().put(widget.items[index]);
                    });
                  },
                  (id) {
                    if (objectbox.store.box<T>().remove(id)) {
                      setState(() {
                        AnimatedList.of(context).removeItem(
                          index,
                          (context, animation) => FadeTransition(
                            opacity: animation,
                            child: widget
                                .itemConstructor(widget.items.removeAt(index)),
                          ),
                        );
                      });
                    }
                  },
                ),
              ),
            ),
    );
  }
}
