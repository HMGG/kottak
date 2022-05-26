import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:kottak/main.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/song/sheet_pager.dart';

import 'song_form.dart';

class SongItem extends StatelessWidget {
  const SongItem({
    required this.song,
    this.onDeleted,
    this.onUpdated,
    Key? key,
  }) : super(key: key);

  final Song song;

  final Function(Song)? onUpdated;
  final Function(int)? onDeleted;

  @override
  Widget build(BuildContext context) {
    return OpenContainer<Song>(
      closedBuilder: (context, open) => OpenContainer<Song>(
        tappable: false,
        closedColor: Theme.of(context).listTileTheme.tileColor ??
            Theme.of(context).cardColor,
        closedBuilder: (context, openEdit) => ListTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (song.favorite) const Icon(Icons.star, size: 20),
                ],
              ),
            ),
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.edit,
              size: 27,
            ),
            onPressed: () => openEdit(),
          ),
          subtitle: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: song.tags.isNotEmpty
                ? Text(
                    song.tags
                        .map((tag) => tag.name)
                        .reduce((value, element) => '$value, $element'),
                  )
                : Text(
                    'NO TAGS',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
          ),
        ),
        openColor: Theme.of(context).scaffoldBackgroundColor,
        openBuilder: (context, _) => Scaffold(
          appBar: AppBar(
            title: Text('${song.title} szerkesztése'),
            actions: [
              IconButton(
                onPressed: () => open(),
                icon: const Icon(Icons.music_video),
              )
            ],
          ),
          body: SongForm(
            song: song.copy(),
            onSave: (newSong) {
              objectbox.store.box<Song>().put(newSong..id = song.id);
              onUpdated!(newSong);
            },
            onDelete: onDeleted,
          ),
        ),
      ),
      closedColor: Theme.of(context).backgroundColor,
      openColor: Theme.of(context).backgroundColor,
      openBuilder: (context, _) => SheetPager(
        Song.filtered,
        id: song.id,
      ),
    );
  }
}
