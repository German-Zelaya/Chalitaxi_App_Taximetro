import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'local_places_database.dart';

/// Resultado de una búsqueda de geocodificación
class GeocodingResult {
  final String displayName;
  final LatLng coordinates;
  final String type;
  final bool isLocalResult;

  GeocodingResult({
    required this.displayName,
    required this.coordinates,
    required this.type,
    this.isLocalResult = false,
  });
}

/// Servicio de geocodificación usando Nominatim (API gratuita de OpenStreetMap)
class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Busca lugares por texto
  ///
  /// [query] - Texto a buscar (ej: "Hospital", "Mercado Central")
  ///
  /// Retorna una lista de resultados encontrados
  /// PRIMERO busca en base de datos local (instantáneo, garantizado)
  /// LUEGO complementa con Nominatim si es necesario
  Future<List<GeocodingResult>> searchPlace(
    String query, {
    bool limitToSucre = true,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      List<GeocodingResult> allResults = [];

      // 1. BÚSQUEDA LOCAL (prioritaria, instantánea)
      print('🔍 Buscando en base de datos local: "$query"');
      final localPlaces = SucreLocalPlaces.search(query);

      for (var place in localPlaces) {
        allResults.add(GeocodingResult(
          displayName: '${place.name} (${place.category}) - Sucre, Bolivia',
          coordinates: place.coordinates,
          type: place.category.toLowerCase(),
          isLocalResult: true,
        ));
      }

      print('✅ Encontrados ${localPlaces.length} resultados locales');

      // 2. BÚSQUEDA EN NOMINATIM (complementaria)
      // Solo si hay menos de 5 resultados locales
      if (allResults.length < 5) {
        print('🌐 Complementando con Nominatim...');
        final nominatimResults = await _searchNominatim(query);

        // Agregar resultados de Nominatim que no estén duplicados
        for (var result in nominatimResults) {
          // Evitar duplicados comparando coordenadas cercanas
          bool isDuplicate = allResults.any((existing) {
            double distance = _calculateDistance(
              existing.coordinates,
              result.coordinates,
            );
            return distance < 100; // menos de 100 metros = duplicado
          });

          if (!isDuplicate && allResults.length < 10) {
            allResults.add(result);
          }
        }
      }

      print('📊 Total de resultados: ${allResults.length}');
      return allResults;
    } catch (e) {
      print('❌ Error en búsqueda: $e');
      return [];
    }
  }

  /// Búsqueda en Nominatim (solo como complemento)
  Future<List<GeocodingResult>> _searchNominatim(String query) async {
    try {
      String searchQuery = '$query, Sucre, Bolivia';

      final url = Uri.parse(
        '$_baseUrl/search?'
        'q=${Uri.encodeComponent(searchQuery)}&'
        'format=json&'
        'limit=5&'
        'addressdetails=1&'
        'countrycodes=bo&'
        'dedupe=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ChaliTaxi/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<GeocodingResult> results = [];
        for (var item in data) {
          double lat = double.parse(item['lat']);
          double lon = double.parse(item['lon']);

          // Área de Sucre
          bool isInSucre = lat >= -19.1 && lat <= -18.9 &&
                          lon >= -65.4 && lon <= -65.1;

          if (isInSucre) {
            results.add(GeocodingResult(
              displayName: item['display_name'] ?? 'Lugar sin nombre',
              coordinates: LatLng(lat, lon),
              type: item['type'] ?? 'unknown',
              isLocalResult: false,
            ));
          }
        }

        return results;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Calcula distancia entre dos puntos en metros
  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros

    double lat1Rad = point1.latitude * (3.14159265359 / 180);
    double lat2Rad = point2.latitude * (3.14159265359 / 180);
    double deltaLat = (point2.latitude - point1.latitude) * (3.14159265359 / 180);
    double deltaLon = (point2.longitude - point1.longitude) * (3.14159265359 / 180);

    double a = (deltaLat / 2) * (deltaLat / 2) +
        lat1Rad.cos() * lat2Rad.cos() * (deltaLon / 2) * (deltaLon / 2);
    double c = 2 * a.sqrt().atan2((1 - a).sqrt());

    return earthRadius * c;
  }

  /// Obtiene el nombre de un lugar a partir de coordenadas (geocodificación inversa)
  ///
  /// [coordinates] - Coordenadas GPS del lugar
  ///
  /// Retorna el nombre del lugar o null si hay error
  Future<String?> getPlaceName(LatLng coordinates) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?'
        'lat=${coordinates.latitude}&'
        'lon=${coordinates.longitude}&'
        'format=json&'
        'addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'ChaliTaxi/1.0',
        },
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error en geocodificación inversa: $e');
      return null;
    }
  }
}
