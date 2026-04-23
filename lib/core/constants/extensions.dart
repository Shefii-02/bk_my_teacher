extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}


String limitString(String text, int maxLength) {
  return (text.length <= maxLength) ? text : '${text.substring(0, maxLength)}...';
}