String? inferStructuredErrorCode({
  required String message,
  String? explicitErrorCode,
}) {
  if (explicitErrorCode != null && explicitErrorCode.isNotEmpty) {
    return explicitErrorCode;
  }

  final normalized = message.toLowerCase();

  if (_containsAny(normalized, const [
    'check openai_api_key',
    'codex authentication',
    'codex auth',
  ])) {
    return 'codex_auth_required';
  }

  if (_containsAny(normalized, const [
    'project path not allowed',
    'path not allowed',
    'bridge_allowed_dirs',
  ])) {
    return 'path_not_allowed';
  }

  if (_containsAny(normalized, const ['git not available', 'git features'])) {
    return 'git_not_available';
  }

  return null;
}

bool _containsAny(String haystack, List<String> needles) {
  for (final needle in needles) {
    if (haystack.contains(needle)) return true;
  }
  return false;
}
