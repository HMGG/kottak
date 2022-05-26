final charList = [
  'a',
  'á',
  'b',
  'c',
  'd',
  'e',
  'é',
  'f',
  'g',
  'h',
  'i',
  'í',
  'j',
  'k',
  'l',
  'm',
  'n',
  'o',
  'ó',
  'ö',
  'ő',
  'p',
  'q',
  'r',
  's',
  't',
  'u',
  'ú',
  'ü',
  'ű',
  'v',
  'w',
  'x',
  'y',
  'z',
];

int myCompare(String a, String b) {
  if (a.isEmpty || b.isEmpty) {
    return a.isEmpty ? -1 : 1;
  }
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a.length < i + 2 || b.length < i + 2) {
      return a.length < i + 2 ? -1 : 1;
    }
    var compare = charList.indexOf(a.toLowerCase()[i]) -
        charList.indexOf(b.toLowerCase()[i]);
    if (compare != 0) {
      return compare;
    }
  }
  return 0;
}
