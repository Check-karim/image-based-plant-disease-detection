import 'package:http/http.dart' as http;

class CustomHttpClient {
  String? _cookie;

  Future<http.Response> post(String url,
      {Map<String, String>? headers, dynamic body}) async {
    final client = http.Client();
    final response = await client.post(
      Uri.parse(url),
      headers: {
        if (_cookie != null) 'Cookie': _cookie!,
        ...?headers,
      },
      body: body,
    );

    _cookie = response.headers['set-cookie'];
    return response;
  }

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    final client = http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {
        if (_cookie != null) 'Cookie': _cookie!,
        ...?headers,
      },
    );

    _cookie = response.headers['set-cookie'];
    return response;
  }
}
