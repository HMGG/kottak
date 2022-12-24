import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kottak/main.dart';
import 'package:kottak/src/data/models.dart';
import 'package:kottak/src/shared/confirm_dialog.dart';
import 'package:path_provider/path_provider.dart';

final filesList = GlobalKey<AnimatedListState>();

class PersistanceDialog extends StatefulWidget {
  PersistanceDialog({Key? key}) : super(key: key);

  final TextEditingController exportControl = TextEditingController();

  @override
  State<PersistanceDialog> createState() => _PersistanceDialogState();
}

class _PersistanceDialogState extends State<PersistanceDialog> {
  List<File> files = [];
  bool exportNameExists = false;

  @override
  void initState() {
    super.initState();
    getDirectory().then(
      (dir) => Directory(dir).list().toList().then((list) => setState(() {
            int index = 0;
            list
              ..retainWhere((element) => element.path.endsWith('.sheets'))
              ..forEach((element) {
                files.add(File(element.path));
                filesList.currentState?.insertItem(index++);
              });
          })),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor.withAlpha(128),
        body: Column(
          children: [
            Expanded(
              child: AnimatedList(
                key: filesList,
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 50),
                initialItemCount: files.length,
                itemBuilder: (context, index, animation) => FadeTransition(
                  opacity: animation,
                  child: ListTile(
                    title: Text(files[index].uri.pathSegments.last),
                    leading: IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.input),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            'Import',
                            '${files[index].uri.pathSegments.last} importálása felülírhatja a meglévő adatokat!',
                          ),
                        ).then((result) {
                          if (result) {
                            importData(files[index]).then(
                              (_) => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Import kész, indítsd újra az alkalmazást!'),
                                ),
                              ),
                            );
                          }
                        });
                      },
                    ),
                    trailing: IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            'Törlés',
                            '${files[index].uri.pathSegments.last} mentés törlése',
                          ),
                        ).then((result) {
                          if (result) {
                            setState(() {
                              files[index].deleteSync();
                              AnimatedList.of(context).removeItem(
                                index,
                                (context, animation) => FadeTransition(
                                  opacity: animation,
                                  child: ListTile(
                                    title: Text(files
                                        .removeAt(index)
                                        .uri
                                        .pathSegments
                                        .last),
                                    leading: IconButton(
                                      icon: const Icon(Icons.input),
                                      onPressed: () {},
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              );
                            });
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Export file név',
                      ),
                      controller: widget.exportControl,
                      onChanged: (value) {
                        if (value.isEmpty && exportNameExists) {
                          setState(() {
                            exportNameExists = false;
                          });
                        } else if (value.isNotEmpty && !exportNameExists) {
                          setState(() {
                            exportNameExists = true;
                          });
                        }
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: exportNameExists
                      ? () {
                          exportData(widget.exportControl.text).then((file) {
                            setState(() {
                              files.add(file);
                              filesList.currentState
                                  ?.insertItem(files.length - 1);
                              widget.exportControl.text = '';
                            });
                          });
                        }
                      : null,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

Future<String> getDirectory() async {
  return '${(await getExternalStorageDirectory())?.parent.parent.parent.parent.path}/Kottak';
  // return '${(await getExternalStorageDirectory())?.path}';
}

String intFixed(int n, int count) => n.toString().padLeft(count, "0");

Future<File> exportData(String fileName) async {
  final date = DateTime.now();
  final String fileNameWithDate =
      '$fileName-${date.year}-${intFixed(date.month, 2)}-${intFixed(date.day, 2)} ${intFixed(date.hour, 2)}:${intFixed(date.minute, 2)}.sheets';

  return File('${await getDirectory()}/$fileNameWithDate')
      .writeAsString(jsonEncode({
    'songs': Song.getAll()
        .map((song) => {
              'id': song.id,
              'title': song.title,
              'lyrics': song.lyrics,
              'author': song.author,
              'originalTitle': song.originalTitle,
              'translator': song.translator,
              'favorite': song.favorite,
              'sheets': song.sheets,
              'tags': song.tags.map((tag) => tag.id).toList()
            })
        .toList(),
    'tags': Tag.getAll()
        .map((tag) => {
              'id': tag.id,
              'name': tag.name,
              'tagGroup': tag.tagGroup.targetId,
            })
        .toList(),
    'tagGroups': TagGroup.getAll()
        .map((tagGroup) => {
              'id': tagGroup.id,
              'name': tagGroup.name,
              'index': tagGroup.index,
            })
        .toList()
  }));
}

Future<void> importData(File file) async {
  final data = jsonDecode(await file.readAsString());

  final tagGroupBox = objectbox.store.box<TagGroup>();
  for (var tagGroup in (data['tagGroups'] as List<dynamic>)) {
    tagGroupBox.put(TagGroup(
      id: tagGroup['id'],
      name: tagGroup['name'],
      index: tagGroup['index'],
    ));
  }
  final tagBox = objectbox.store.box<Tag>();
  for (var tag in (data['tags'] as List<dynamic>)) {
    tagBox.put(
      Tag(
        id: tag['id'],
        name: tag['name'],
      )..tagGroup.targetId = tag['tagGroup'],
    );
  }
  final songBox = objectbox.store.box<Song>();
  for (var song in (data['songs'] as List<dynamic>)) {
    songBox.put(
      Song(
        id: song['id'],
        title: song['title'],
        lyrics: song['lyrics'],
        author: song['author'],
        originalTitle: song['originalTitle'],
        translator: song['translator'],
        favorite: song['favorite'],
        sheets: (song['sheets'] as List<dynamic>)
            .map((sheet) => sheet as String)
            .toList(),
      )..tags.addAll((song['tags'] as List<dynamic>)
          .map((tag) => tagBox.get(tag as int)!)),
    );
  }
}
