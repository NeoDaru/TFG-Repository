String formatAccessCode(String code) {
  if (code.length != 12) return code;
  return '${code.substring(0, 4)}-${code.substring(4, 8)}-${code.substring(8)}';
}