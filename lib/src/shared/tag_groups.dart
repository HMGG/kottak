import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class TagGroups extends StatefulWidget {
  const TagGroups(this.tags, {Key? key}) : super(key: key);

  final List<Tag> tags;

  @override
  State<TagGroups> createState() => _TagGroupsState();
}

class _TagGroupsState extends State<TagGroups> {
  final tagGroups = TagGroup.getAll();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tagGroups
          .map<Padding>(
            (group) => Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: MultiSelectChipField(
                title: Text(
                  group.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                headerColor: Colors.transparent,
                decoration: const BoxDecoration(border: null),
                chipColor: Colors.transparent,
                textStyle: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1?.color),
                selectedChipColor: Theme.of(context).colorScheme.primary,
                scroll: false,
                initialValue: group.tags
                    .where((tag) =>
                        widget.tags.any((songtag) => tag.name == songtag.name))
                    .toList(),
                items: group.tags
                    .map<MultiSelectItem<Tag?>>((tag) => MultiSelectItem<Tag>(
                          tag,
                          tag.name,
                        ))
                    .toList(),
                onTap: (newTags) => setState(() {
                  widget.tags.removeWhere(
                      (tag) => tag.tagGroup.target!.id == group.id);
                  widget.tags.addAll(newTags.map((e) => e as Tag));
                }),
              ),
            ),
          )
          .toList(),
    );
  }
}
