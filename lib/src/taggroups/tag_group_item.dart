import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/taggroups/tag_group_form.dart';

class TagGroupItem extends StatelessWidget {
  const TagGroupItem({
    required this.tagGroup,
    this.onDeleted,
    this.onUpdated,
    Key? key,
  }) : super(key: key);

  final TagGroup tagGroup;

  final Function(TagGroup)? onUpdated;
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
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.25),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          tagGroup.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => TagGroupForm(tagGroup),
      ).then((value) {
        if (value != null) {
          if (value == 'delete') {
            onDeleted!(tagGroup.id);
          } else {
            onUpdated!(value);
          }
        }
      }),
    );
  }
}
