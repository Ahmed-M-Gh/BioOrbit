class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;
  final String username;
  final String role;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.username = '',
    this.role = 'Astro',
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
    String? username,
    String? role,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      role: role ?? this.role,
    );
  }
}
