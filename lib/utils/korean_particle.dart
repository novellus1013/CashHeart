/// 한글 종성(받침) 유무에 따라 조사를 고른다 — "이"/"가", "은"/"는", "을"/"를" 등에 공용.
/// 마지막 글자가 완성형 한글 음절이 아니면(영문/숫자/공백 등) 받침 없음으로 간주해
/// [withoutBatchim]을 반환한다. 존칭 토글(카드 공유)처럼 사용자가 넘긴 지인 이름에
/// "님"을 붙이거나 뗄 때 조사가 자동으로 맞도록 쓰인다.
String pickJosa(
  String word, {
  required String withBatchim,
  required String withoutBatchim,
}) {
  if (word.isEmpty) return withoutBatchim;

  final code = word.codeUnitAt(word.length - 1);
  const hangulBase = 0xAC00;
  const hangulEnd = 0xD7A3;
  if (code < hangulBase || code > hangulEnd) return withoutBatchim;

  final hasBatchim = (code - hangulBase) % 28 != 0;
  return hasBatchim ? withBatchim : withoutBatchim;
}
