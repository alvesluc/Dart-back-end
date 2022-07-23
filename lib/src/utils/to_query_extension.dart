extension ToQuery on String {
  String toQuery() => replaceAll("\n", " ");
}
