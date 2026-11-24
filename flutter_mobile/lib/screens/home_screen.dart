
import 'package:material_ui/material_ui.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'location_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  dynamic weather;
  bool loading = false;
  String error = '';
  int requestId = 0;

  @override
  void initState() {
    super.initState();
    LocationService.selectedLocation.addListener(loadWeather);
    if (LocationService.currentLocation != null) {
      loadWeather();
    }
  }

  Future<void> chooseLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationSearchScreen(),
      ),
    );
  }

  Future<void> loadWeather() async {
    final location = LocationService.currentLocation;
    final id = ++requestId;

    if (location == null) {
      setState(() {
        weather = null;
        loading = false;
        error = '';
      });
      return;
    }

    final city = location['city'].toString();

    setState(() {
      loading = true;
      error = '';
      weather = null;
    });

    try {
      final query = Uri(queryParameters: {
        'city': city,
        'latitude': location['latitude'].toString(),
        'longitude': location['longitude'].toString(),
        'country': location['country']?.toString() ?? '',
      }).query;

      final data = await ApiService.get('/api/weather?$query');

      if (!mounted || id != requestId) return;
      setState(() => weather = data);
    } catch (e) {
      if (!mounted || id != requestId) return;
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted && id == requestId) {
        setState(() => loading = false);
      }
    }
  }

  IconData weatherIcon(String condition) {
    final value = condition.toLowerCase();

    if (value.contains('thunder')) return Icons.thunderstorm;
    if (value.contains('snow')) return Icons.ac_unit;
    if (value.contains('rain') || value.contains('drizzle')) {
      return Icons.water_drop;
    }
    if (value.contains('cloud')) return Icons.cloud;
    if (value.contains('fog')) return Icons.foggy;

    return Icons.wb_sunny_rounded;
  }

  String temperature(dynamic value) {
    return value == null ? '--' : '$value\u00B0C';
  }

  Widget weatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),
        Text(label, style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
        )),
      ],
    );
  }

  @override
  void dispose() {
    LocationService.selectedLocation.removeListener(loadWeather);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = LocationService.currentLocation;
    final current = weather is Map ? weather['current'] : null;
    final rawForecast = weather is Map ? weather['forecast'] : null;
    final forecast = rawForecast is List ? rawForecast : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weatherly',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading || location == null
                ? null : loadWeather,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Welcome to Weatherly!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text('Dress for the weather, every day.'),
              const SizedBox(height: 24),

              Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.primary,
                  ),
                  title: Text(
                    location == null
                        ? 'Choose your location'
                        : '${location['city']}, ${location['country']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Tap to search worldwide'),
                  trailing: const Icon(Icons.search),
                  onTap: chooseLocation,
                ),
              ),

              const SizedBox(height: 24),

              if (loading)
                const Center(child: CircularProgressIndicator()),

              if (error.isNotEmpty)
                Text(error, style: const TextStyle(color: Colors.red)),

              if (location == null)
                const Center(
                  child: Text('Select a location to see your forecast.'),
                ),

              if (current is Map)
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.secondary],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${weather['city'] ?? location?['city']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weather['country'] ?? ''}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Icon(
                        weatherIcon('${current['condition']}'),
                        size: 75,
                        color: Colors.white,
                      ),
                      Text(
                        temperature(current['temperature']),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${current['condition']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          weatherDetail(
                            Icons.thermostat,
                            'Feels like',
                            temperature(current['feels_like']),
                          ),
                          weatherDetail(
                            Icons.water_drop_outlined,
                            'Humidity',
                            '${current['humidity'] ?? '--'}%',
                          ),
                          weatherDetail(
                            Icons.air,
                            'Wind',
                            '${current['wind_speed'] ?? '--'} km/h',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              if (forecast.isNotEmpty) ...[
                const SizedBox(height: 25),
                const Text(
                  '7-Day Forecast',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              ...forecast.whereType<Map>().map((day) {
                final condition = '${day['condition'] ?? ''}';

                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Icon(
                      weatherIcon(condition),
                      color: AppTheme.primary,
                      size: 35,
                    ),
                    title: Text('${day['date'] ?? 'Forecast'}'),
                    subtitle: Text(
                      '$condition\nRain: ${day['rain_probability'] ?? '--'}%',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          temperature(day['max_temperature']),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          temperature(day['min_temperature']),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              if (weather != null)
                const Center(
                  child: Text(
                    'Weather data by Open-Meteo',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
