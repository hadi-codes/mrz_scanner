class MRZHelper {
  static List<String>? getFinalListToParse(List<String> ableToScanTextList) {
    List<String> resultList = [];
    if (ableToScanTextList.length < 2) {
      // minimum length of any MRZ format is 2 lines
      return null;
    }
    int? lineLength;
    if (ableToScanTextList.first.substring(0, 5) == "PEMNG") {
      lineLength = 44;
    } else {
      lineLength = ableToScanTextList.first.length;
      if (lineLength > 36) {
        lineLength = 44;
      } else if (lineLength > 30) {
        lineLength = 36;
      } else {
        lineLength = 30;
      }
    }

    for (var e in ableToScanTextList) {
      if (e.length > lineLength) {
        e = e.substring(0, lineLength);
      } else if (e.length < lineLength) {
        e = e + ("<" * (lineLength - e.length));
      }
      resultList.add(e);
      // to make sure that all lines are the same in length
    }
    List<String> firstLineChars = resultList.first.split('');
    List<String> supportedDocTypes = ['A', 'C', 'P', 'V', 'I'];
    String fChar = firstLineChars[0];
    if (supportedDocTypes.contains(fChar)) {
      return resultList;
    }
    return null;
  }

  static String testTextLine(String text) {
    String res = text.replaceAll(' ', '');
    List<String> list = res.split('');

    // to check if the text belongs to any MRZ format or not
    if (list.length < 30 || !list.contains('<')) {
      return '';
    }

    for (int i = 0; i < list.length; i++) {
      if (RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i])) {
        list[i] = list[i].toUpperCase();
        // to ensure that every letter is uppercase
      }
      if (double.tryParse(list[i]) == null && !(RegExp(r'^[A-Za-z0-9_.]+$').hasMatch(list[i]))) {
        list[i] = '<';
        // sometimes < sign not recognized well
      }
    }
    String result = list.join('');
    return result;
  }
}
