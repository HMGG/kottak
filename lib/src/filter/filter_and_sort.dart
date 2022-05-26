import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/filter/filter.dart';
import 'package:kottak/src/filter/sorting.dart';
import 'package:kottak/src/utils.dart';

class FilterAndSorting extends StatefulWidget {
  const FilterAndSorting({Key? key}) : super(key: key);

  @override
  State<FilterAndSorting> createState() => _FilterAndSortingState();
}

class _FilterAndSortingState extends State<FilterAndSorting> {
  _FilterAndSortingState() {
    Song.filtered = Song.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              filterState.currentState?.addFilter(true);
              if (filters.isNotEmpty) {
                List<bool Function(Song)> filterFunctions = [];
                for (var filter in filters) {
                  List<bool Function(Song)> propertyFilterFunctions = [];
                  if (filter.searchString.isNotEmpty) {
                    propertyFilterFunctions.add(filter.exclude
                        ? (song) =>
                            !song.title
                                .toLowerCase()
                                .contains(filter.searchString) &&
                            !song.lyrics
                                .toLowerCase()
                                .contains(filter.searchString) &&
                            !song.author
                                .toLowerCase()
                                .contains(filter.searchString) &&
                            !song.originalTitle
                                .toLowerCase()
                                .contains(filter.searchString) &&
                            !song.translator
                                .toLowerCase()
                                .contains(filter.searchString)
                        : (song) =>
                            song.title
                                .toLowerCase()
                                .contains(filter.searchString) ||
                            song.lyrics
                                .toLowerCase()
                                .contains(filter.searchString) ||
                            song.author
                                .toLowerCase()
                                .contains(filter.searchString) ||
                            song.originalTitle
                                .toLowerCase()
                                .contains(filter.searchString) ||
                            song.translator
                                .toLowerCase()
                                .contains(filter.searchString));
                  }
                  if (filter.favorite != null) {
                    propertyFilterFunctions.add((song) =>
                        song.favorite ==
                        (filter.exclude ? !filter.favorite! : filter.favorite));
                  }
                  if (filter.tags.isNotEmpty) {
                    propertyFilterFunctions.add((song) => filter.exclude
                        ? filter.tags.every((filterTag) =>
                            song.tags.every((tag) => filterTag.id != tag.id))
                        : filter.tags.every((filterTag) =>
                            song.tags.any((tag) => filterTag.id == tag.id)));
                  }
                  filterFunctions.add((filterSong) => propertyFilterFunctions
                      .reduce((value, element) => (Song song) =>
                          value(song) && element(song))(filterSong));
                }

                var masterFilterFunction = filterFunctions.reduceIndexed(
                    (index, value, element) => chaining[index - 1]
                        ? (Song song) => value(song) && element(song)
                        : (Song song) => value(song) || element(song));

                Song.filtered.retainWhere((song) => masterFilterFunction(song));

                filters = [];
                chaining = [];
              }

              for (var sort in sorting.reversed) {
                if (sort.enabled) {
                  switch (sort.name) {
                    case 'Cím':
                      {
                        Song.filtered.sort((a, b) =>
                            myCompare(a.title, b.title) *
                            (sort.ascending ? 1 : -1));
                        break;
                      }
                    case 'Szerző':
                      {
                        Song.filtered.sort((a, b) =>
                            myCompare(a.author, b.author) *
                            (sort.ascending ? 1 : -1));
                        break;
                      }
                    case 'Eredeti cím':
                      {
                        Song.filtered.sort((a, b) =>
                            myCompare(a.originalTitle, b.originalTitle) *
                            (sort.ascending ? 1 : -1));
                        break;
                      }
                    case 'Fordító':
                      {
                        Song.filtered.sort((a, b) =>
                            myCompare(a.translator, b.translator) *
                            (sort.ascending ? 1 : -1));
                        break;
                      }
                    case 'Kedvenc':
                      {
                        Song.filtered.sort((a, b) =>
                            (a.favorite != b.favorite
                                ? a.favorite
                                    ? 1
                                    : -1
                                : 0) *
                            (sort.ascending ? 1 : -1));
                        break;
                      }
                    case 'Szöveg hossza':
                      {
                        Song.filtered.sort((a, b) =>
                            Comparable.compare(
                                a.lyrics.length, b.lyrics.length) *
                            (sort.ascending ? 1 : -1));
                        break;
                      }
                    case 'Oldalak száma':
                      {
                        Song.filtered.sort((a, b) =>
                            Comparable.compare(
                                a.sheets.length, b.sheets.length) *
                            (sort.ascending ? 1 : -1));
                        break;
                      }
                    default:
                      {
                        Song.filtered.sort((a, b) {
                          var aTags = a.tags.where(
                              (tag) => tag.tagGroup.target?.name == sort.name);
                          var bTags = b.tags.where(
                              (tag) => tag.tagGroup.target?.name == sort.name);
                          // Comapre lengths
                          int lengthCompare =
                              Comparable.compare(aTags.length, bTags.length);
                          if (lengthCompare != 0) {
                            return lengthCompare * (sort.ascending ? 1 : -1);
                          } else {
                            // Comapre tagnames
                            aTags = aTags
                                .sorted((a, b) => myCompare(a.name, b.name));
                            bTags = bTags
                                .sorted((a, b) => myCompare(a.name, b.name));
                            for (var i = 0; i < aTags.length; i++) {
                              var compare = myCompare(aTags.elementAt(i).name,
                                  bTags.elementAt(i).name);
                              // First tags that are different
                              if (compare != 0) {
                                return compare * (sort.ascending ? 1 : -1);
                              }
                            }
                            // Lists are identical
                            return 0;
                          }
                        });
                        break;
                      }
                  }
                }
              }
              resetSorting();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.done))
      ]),
      body: PageView(
        children: [
          Filter(key: filterState),
          const Sorting(),
        ],
      ),
    );
  }
}
