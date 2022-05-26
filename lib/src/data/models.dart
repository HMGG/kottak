// ignore_for_file: unnecessary_import

import 'package:kottak/main.dart';
import 'package:kottak/objectbox.g.dart';
import 'package:kottak/src/utils.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class Song {
  @Id(assignable: true)
  int id;
  String title;
  String lyrics;
  String author;
  String originalTitle;
  String translator;
  bool favorite;
  List<String> sheets;

  final tags = ToMany<Tag>();

  Song({
    this.id = 0,
    this.title = '',
    this.lyrics = '',
    this.author = '',
    this.originalTitle = '',
    this.translator = '',
    this.favorite = false,
    required this.sheets,
  });

  Song copy() {
    Song newSong = Song(
      id: id,
      title: title,
      lyrics: lyrics,
      author: author,
      originalTitle: originalTitle,
      translator: translator,
      favorite: favorite,
      sheets: sheets.sublist(0),
    )..tags.addAll(tags);
    return newSong;
  }

  static List<Song> getAll() {
    return objectbox.store.box<Song>().getAll()
      ..sort((a, b) => myCompare(a.title, b.title));
  }

  static List<Song> filtered = [];
}

@Entity()
class TagGroup {
  int id;
  String name;
  int index;

  @Backlink()
  final tags = ToMany<Tag>();

  TagGroup({
    this.id = 0,
    this.name = '',
    this.index = -1,
  });

  static List<TagGroup> getAll() {
    var query = objectbox.store.box<TagGroup>().query()..order(TagGroup_.index);
    return query.build().find();
  }
}

@Entity()
class Tag {
  int id;
  String name;

  var tagGroup = ToOne<TagGroup>();

  @Backlink()
  final songs = ToMany<Song>();

  Tag({
    this.id = 0,
    required this.name,
  });

  static List<Tag> getAll() {
    var query = objectbox.store.box<Tag>().query()..order(Tag_.name);
    return query.build().find();
  }
}
