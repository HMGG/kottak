import 'package:flutter/material.dart';
import 'package:kottak/main.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/filter/filter_and_sort.dart';
import 'package:kottak/src/settings/settings_view.dart';
import 'package:kottak/src/shared/my_list.dart';
import 'package:kottak/src/song/song_form.dart';
import 'package:kottak/src/song/song_item.dart';
import 'package:kottak/src/taggroups/tag_group_form.dart';
import 'package:kottak/src/taggroups/tag_group_item.dart';
import 'package:kottak/src/tags/tag_form.dart';
import 'package:kottak/src/tags/tag_item.dart';

final songList = GlobalKey<MyListState<Song>>();
final tagList = GlobalKey<MyListState<Tag>>();
final tagGroupList = GlobalKey<MyListState<TagGroup>>();

const noResults = Center(
  child: Text(
    '¯\\_(ツ)_/¯',
    style: TextStyle(fontSize: 48, color: Colors.grey),
  ),
);

class MainPager extends StatefulWidget {
  const MainPager({Key? key}) : super(key: key);

  static const routeName = '/';

  @override
  State<MainPager> createState() => _MainPagerState();
}

class _MainPagerState extends State<MainPager> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => const FilterAndSorting())),
            ).then((_) => songList.currentState?.refreshList(Song.filtered));
          },
          icon: const Icon(Icons.filter_list),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: PageView(
        children: [
          Song.filtered.isNotEmpty
              ? MyList<Song>(
                  Song.filtered,
                  (data, [onUpdated, onDeleted]) => SongItem(
                    song: data,
                    onUpdated: onUpdated,
                    onDeleted: onDeleted,
                    key: ValueKey(data.id),
                  ),
                  key: songList,
                )
              : noResults,
          objectbox.store.box<Tag>().count(limit: 1) > 0
              ? MyList<Tag>(
                  Tag.getAll(),
                  (data, [onUpdated, onDeleted]) => TagItem(
                    tag: data,
                    onUpdated: onUpdated,
                    onDeleted: onDeleted,
                    key: ValueKey(data.id),
                  ),
                  key: tagList,
                  axisCount: 2,
                )
              : noResults,
          objectbox.store.box<TagGroup>().count(limit: 1) > 0
              ? MyList<TagGroup>(
                  TagGroup.getAll(),
                  (data, [onUpdated, onDeleted]) => TagGroupItem(
                    tagGroup: data,
                    onUpdated: onUpdated,
                    onDeleted: onDeleted,
                    key: ValueKey(data.id),
                  ),
                  key: tagGroupList,
                  axisCount: 2,
                  reorderable: true,
                  onReorder: (tagGroups) {
                    for (final tagGroup in tagGroups) {
                      tagGroup.index = tagGroups.indexOf(tagGroup);
                    }
                    objectbox.store.box<TagGroup>().putMany(tagGroups);
                  },
                )
              : noResults,
        ],
        onPageChanged: (i) => currentPage = i,
      ),

      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            switch (currentPage) {
              case 0:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('Új dal'),
                      ),
                      body: SongForm(
                        song: Song(sheets: []),
                        onSave: (song) {
                          songList.currentState?.addItem(song);
                        },
                      ),
                    ),
                  ),
                );
                break;
              case 1:
                showDialog(
                    context: context,
                    builder: (context) => TagForm(
                          Tag(),
                          newForm: true,
                        )).then((value) {
                  if (value != null) {
                    tagList.currentState?.addItem(value);
                    objectbox.store.box<Tag>().put(value);
                  }
                });
                break;
              case 2:
                showDialog(
                    context: context,
                    builder: (context) => TagGroupForm(
                          TagGroup(),
                          newForm: true,
                        )).then((value) {
                  if (value != null) {
                    tagGroupList.currentState?.addItem(value);
                    objectbox.store.box<TagGroup>().put(value);
                  }
                });
                break;
              default:
            }
          }),
    );
  }
}
