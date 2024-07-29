class OAuthProvider {
  final String name;
  const OAuthProvider._(this.name);

  static const google = OAuthProvider._('google');
  static const apple = OAuthProvider._('apple');
}
