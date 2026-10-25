import 'dart:convert';

import 'package:http/http.dart' as http;

class TmdbClient {
  static const String _apiKey = String.fromEnvironment('TMDB_API_KEY');
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  /// Busca una película por nombre y devuelve la URL del póster en alta calidad y la sinopsis
  static Future<Map<String, String>?> searchMovie(
    String title, {
    String language = 'es-ES',
  }) async {
    if (_apiKey.isEmpty) return null;
    final uri = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(title)}&language=$language',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && (data['results'] as List).isNotEmpty) {
          final result = data['results'][0];
          return {
            'title': result['title']?.toString() ?? title,
            'overview': result['overview']?.toString() ?? '',
            'poster_url': result['poster_path'] != null
                ? '$_imageBaseUrl${result['poster_path']}'
                : '',
            'backdrop_url': result['backdrop_path'] != null
                ? '$_imageBaseUrl${result['backdrop_path']}'
                : '',
          };
        }
      }
    } catch (e) {
      // Ignorar errores de red y continuar con los datos originales del M3U
    }
    return null;
  }
}
