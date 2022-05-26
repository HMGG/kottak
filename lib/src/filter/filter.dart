import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/shared/tag_groups.dart';

final filterState = GlobalKey<_FilterState>();

List<SongFilter> filters = [];

List<bool> chaining = [];

class SongFilter {
  bool exclude;
  List<Tag> tags;
  String searchString;
  bool? favorite;

  SongFilter({
    this.exclude = false,
    this.searchString = '',
    this.favorite,
    this.tags = const [],
  });
}

class Filter extends StatefulWidget {
  const Filter({Key? key}) : super(key: key);

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  bool exclude = false;
  var searchControl = TextEditingController();
  bool? favorite;
  List<Tag> editedTags = [];
  late TagGroups tagGroups;

  addFilter(bool andOr) {
    setState(() {
      if (favorite != null ||
          editedTags.isNotEmpty ||
          searchControl.text.isNotEmpty) {
        filters.add(SongFilter(
          exclude: exclude,
          searchString: searchControl.text.toLowerCase(),
          favorite: favorite,
          tags: [...editedTags],
        ));
        searchControl.text = '';
        favorite = null;
        editedTags = [];
        chaining.add(andOr);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    tagGroups = TagGroups(editedTags);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...filters.map(
                  (filter) => Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: filter.tags.isEmpty ? 8 : 0,
                          horizontal: 8,
                        ),
                        margin: const EdgeInsets.all(8),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width,
                          minWidth: 0,
                        ),
                        decoration: BoxDecoration(
                          color: filter.exclude
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer
                                  .withOpacity(0.25)
                              : Colors.transparent,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (filter.searchString.isNotEmpty)
                              Text(
                                filter.searchString,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            if (filter.favorite != null)
                              Icon(
                                filter.favorite!
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ...filter.tags.map(
                              (tag) => Chip(
                                label: Text(tag.name),
                              ),
                            )
                          ],
                        ),
                      ),
                      Text(
                        chaining[filters.indexOf(filter)] ? 'és' : 'vagy',
                      ),
                    ],
                  ),
                ),
                ...[
                  Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Kivéve'),
                        value: exclude,
                        onChanged: (value) => setState(() => exclude = value),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextFormField(
                          controller: searchControl,
                          decoration: const InputDecoration(
                            labelText: 'Cím/szöveg/szerző...',
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        tristate: true,
                        title: const Text('Kedvenc'),
                        value: favorite,
                        onChanged: (value) => setState(() => favorite = value),
                      ),
                      tagGroups,
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => addFilter(false),
              child: const Text('VAGY'),
            ),
            TextButton(
              onPressed: () => addFilter(true),
              child: const Text('ÉS'),
            ),
          ],
        ),
      ],
    );
  }
}
