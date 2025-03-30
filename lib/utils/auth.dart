import 'package:http/http.dart' as http;

class Auth {
  static Future<String> getApiToken() async {
    // Logic to securely retrieve the token
    // Example: Use flutter_secure_storage or environment variables to get the token
    return 'replace_with_secure_token_logic';
  }

  static Future<http.Response> getAuthorizedRequest(String url) async {
    final token = await getApiToken();
    return http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
  }
}
