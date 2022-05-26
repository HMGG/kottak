import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';

final List<Sort> sorting = [
  Sort(name: 'Cím', enabled: true),
  Sort(name: 'Szerző'),
  Sort(name: 'Eredeti cím'),
  Sort(name: 'Fordító'),
  Sort(name: 'Kedvenc', ascending: false),
  Sort(name: 'Szöveg hossza', ascending: false),
  Sort(name: 'Oldalak száma', ascending: false),
  ...TagGroup.getAll()
      .map((tagGroup) => Sort(name: tagGroup.name, ascending: false)),
];

resetSorting() {
  sorting.replaceRange(
    0,
    sorting.length,
    [
      Sort(name: 'Cím', enabled: true),
      Sort(name: 'Szerző'),
      Sort(name: 'Eredeti cím'),
      Sort(name: 'Fordító'),
      Sort(name: 'Kedvenc', ascending: false),
      Sort(name: 'Szöveg hossza', ascending: false),
      Sort(name: 'Oldalak száma', ascending: false),
      ...TagGroup.getAll()
          .map((tagGroup) => Sort(name: tagGroup.name, ascending: false)),
    ],
  );
}

class Sort {
  String name;
  bool ascending;
  bool enabled;

  Sort({
    required this.name,
    this.ascending = true,
    this.enabled = false,
  });
}

class Sorting extends StatefulWidget {
  const Sorting({Key? key}) : super(key: key);

  @override
  State<Sorting> createState() => _SortingState();
}

class _SortingState extends State<Sorting> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      children: sorting
          .map((sort) => CheckboxListTile(
                key: ValueKey(sort.name),
                value: sort.enabled,
                onChanged: (value) => setState(() => sort.enabled = value!),
                title: Text(sort.name),
                secondary: IconButton(
                  icon: AnimatedRotation(
                    turns: sort.ascending ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.arrow_downward),
                  ),
                  onPressed: () =>
                      setState(() => sort.ascending = !sort.ascending),
                ),
              ))
          .toList(),
      onReorder: (oldIndex, newIndex) =>
          setState(() => sorting.insert(newIndex, sorting.removeAt(oldIndex))),
    );
  }
}
