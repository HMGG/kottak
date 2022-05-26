import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/tags/tag_form.dart';

class TagItem extends StatelessWidget {
  const TagItem({
    required this.tag,
    this.onDeleted,
    this.onUpdated,
    Key? key,
  }) : super(key: key);

  final Tag tag;

  final Function(Tag)? onUpdated;
  final Function(int)? onDeleted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          minWidth: 0,
        ),
        decoration: BoxDecoration(
          color:
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          tag.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => TagForm(tag),
      ).then((value) {
        if (value != null) {
          if (value == 'delete') {
            onDeleted!(tag.id);
          } else {
            onUpdated!(value);
          }
        }
      }),
    );
  }
}
