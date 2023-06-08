List<String> _setSearchParam(String caseNumber) {
  List<String> caseSearchList = [];
  String temp = "";
  for (int i = 0; i < caseNumber.length; i++) {
    temp = temp + caseNumber[i];
    caseSearchList.add(temp);
  }
  return caseSearchList;
}

List<String> generateCaseSearches(List<String> cases) {
  List<String> result = [];
  for (var e in cases) {
    result.addAll(_setSearchParam(e.toLowerCase()));
    result.addAll(_setSearchParam(e.toUpperCase()));
  }
  return result;
}
