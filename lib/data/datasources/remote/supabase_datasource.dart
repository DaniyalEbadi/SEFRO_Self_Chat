class SupabaseResponse {
  final Map<String, dynamic>? data;
  final List<Map<String, dynamic>>? dataList;
  final String? error;
  final int statusCode;

  SupabaseResponse({
    this.data,
    this.dataList,
    this.error,
    this.statusCode = 200,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class SupabaseDataSource {
  SupabaseDataSource();

  SupabaseResponse _unconfigured() {
    return SupabaseResponse(
      error: 'Supabase is not configured in this local build',
      statusCode: 501,
    );
  }

  Future<SupabaseResponse> query(
    String table, {
    Map<String, dynamic>? filters,
  }) async {
    return _unconfigured();
  }

  Future<SupabaseResponse> get(String table, String id) async {
    return _unconfigured();
  }

  Future<SupabaseResponse> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    return _unconfigured();
  }

  Future<SupabaseResponse> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    return _unconfigured();
  }

  Future<SupabaseResponse> delete(String table, String id) async {
    return _unconfigured();
  }

  Future<SupabaseResponse> authSignInWithEmail(
    String email,
    String password,
  ) async {
    return _unconfigured();
  }

  Future<SupabaseResponse> authSignUpWithEmail(
    String email,
    String password,
  ) async {
    return _unconfigured();
  }

  Future<SupabaseResponse> authSignInWithGoogle() async {
    return _unconfigured();
  }

  Future<SupabaseResponse> authSignInWithApple() async {
    return _unconfigured();
  }

  Future<SupabaseResponse> authSignOut() async {
    return SupabaseResponse(statusCode: 200);
  }

  Future<SupabaseResponse> authGetUser() async {
    return SupabaseResponse(data: null, statusCode: 200);
  }
}
