/// Centralized API configuration.
///
/// Change [baseUrl] here only — no other file should hardcode the API URL.
///
/// Which host to use depends on where the Flutter app runs:
///
/// | Target                    | baseUrl                              |
/// |---------------------------|--------------------------------------|
/// | Chrome / Windows desktop  | http://127.0.0.1/wishlist_api   / 'http://127.0.0.1:8080/wishlist_api'     |
/// | Android emulator          | http://10.0.2.2/wishlist_api         |
/// | Physical Android device   | http://LAN-IP-komputer/wishlist_api  |
///
/// `localhost` inside an Android emulator points at the emulator itself, not
/// the host machine, so `10.0.2.2` is the special alias for the host.
/// For a physical device both phone and PC must be on the same Wi-Fi, and
/// you must use the PC's LAN IP (find it with `ipconfig`).
class ApiConfig {
  ApiConfig._();

  /// Base URL of the PHP REST API (no trailing slash).
  static const String baseUrl = 'http://127.0.0.1/wishlist_api';

  // --- Endpoints -----------------------------------------------------------

  static Uri register() => Uri.parse('$baseUrl/auth/register.php');

  static Uri login() => Uri.parse('$baseUrl/auth/login.php');

  static Uri wishlists(int userId) =>
      Uri.parse('$baseUrl/wishlist/index.php?user_id=$userId');

  /// Pushes a wishlist item (create or update) to the server.
  static Uri wishlistSave() => Uri.parse('$baseUrl/wishlist/save.php');

  /// Deletes a wishlist item on the server.
  static Uri wishlistDelete(int userId) =>
      Uri.parse('$baseUrl/wishlist/delete.php?user_id=$userId');

  /// How long to wait before giving up on a request.
  static const Duration timeout = Duration(seconds: 15);
}
