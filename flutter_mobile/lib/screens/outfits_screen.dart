
import 'package:material_ui/material_ui.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'location_search_screen.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  dynamic outfits;
  bool loading = false;
  String error = '';
  int selectedDay = 0;
  int requestId = 0;

  @override
  void initState() {
    super.initState();
    LocationService.selectedLocation.addListener(loadOutfits);
    loadOutfits();
  }

  Future<void> loadOutfits() async {
    final location = LocationService.currentLocation;
    final id = ++requestId;

    setState(() {
      outfits = null;
      error = '';
      selectedDay = 0;
      loading = location != null;
    });

    if (location == null) return;

    try {
      final query = Uri(queryParameters: {
        'city': location['city'].toString(),
        'country': location['country']?.toString() ?? '',
        'latitude': location['latitude'].toString(),
        'longitude': location['longitude'].toString(),
      }).query;

      final data = await ApiService.get('/api/outfits?$query');

      if (!mounted || id != requestId) return;

      setState(() => outfits = data);
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

  Future<void> chooseLocation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationSearchScreen(),
      ),
    );
  }

  IconData clothingIcon(String item) {
    final value = item.toLowerCase();

    if (value.contains('umbrella')) return Icons.umbrella;
    if (value.contains('boots') ||
        value.contains('shoes') ||
        value.contains('footwear') ||
        value.contains('sneakers')) {
      return Icons.directions_walk;
    }
    if (value.contains('gloves')) return Icons.back_hand_outlined;
    if (value.contains('sunglasses')) return Icons.wb_sunny;
    if (value.contains('hat')) return Icons.wb_sunny_outlined;
    if (value.contains('scarf')) return Icons.ac_unit;
    if (value.contains('layer')) return Icons.layers_outlined;

    return Icons.checkroom;
  }

  IconData weatherIcon(String condition) {
    final value = condition.toLowerCase();

    if (value.contains('snow')) return Icons.ac_unit;
    if (value.contains('thunder')) return Icons.thunderstorm;
    if (value.contains('rain') || value.contains('drizzle')) {
      return Icons.water_drop;
    }
    if (value.contains('cloud')) return Icons.cloud;

    return Icons.wb_sunny;
  }

  String dayLabel(int index, dynamic date) {
    if (index == 0) return 'Today';
    if (index == 1) return 'Tomorrow';

    final parsed = DateTime.tryParse(date.toString());

    if (parsed == null) return 'Day ${index + 1}';

    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
    ];

    return weekdays[parsed.weekday - 1];
  }

  @override
  void dispose() {
    LocationService.selectedLocation.removeListener(loadOutfits);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final location = LocationService.currentLocation;

    final rawForecast = outfits is Map ? outfits['forecast'] : null;
    final forecast = rawForecast is List ? rawForecast : [];

    final day = forecast.isNotEmpty && selectedDay < forecast.length
        ? forecast[selectedDay]
        : null;

    final recommendations =
        day is Map && day['outfits'] is List
            ? day['outfits'] as List
            : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Outfit Recommendations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading || location == null
                ? null
                : loadOutfits,
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
                'Dress for your day',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Personal clothing suggestions based on the weather.',
              ),
              const SizedBox(height: 20),

              Card(
                color: Colors.white,
                child: ListTile(
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
                  trailing: const Icon(Icons.search),
                  onTap: chooseLocation,
                ),
              ),

              const SizedBox(height: 20),

              if (loading)
                const Center(
                  child: CircularProgressIndicator(),
                ),

              if (error.isNotEmpty)
                Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),

              if (location == null)
                const Text(
                  'Select a location to get outfit recommendations.',
                ),

              if (forecast.isNotEmpty) ...[
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: forecast.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ChoiceChip(
                        label: Text(
                          dayLabel(index, forecast[index]['date']),
                        ),
                        selected: selectedDay == index,
                        selectedColor: AppTheme.primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selectedDay == index
                              ? Colors.white
                              : AppTheme.textColor,
                        ),
                        onSelected: (_) {
                          setState(() => selectedDay = index);
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],

              if (day is Map) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        weatherIcon('${day['condition']}'),
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${day['condition']}',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Low: ${day['min_temperature']}\u00B0C'
                        '  |  High: ${day['max_temperature']}\u00B0C',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Precipitation: ${day['rain_probability'] ?? '--'}%',
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'What to wear',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...recommendations.map((item) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.background,
                        child: Icon(
                          clothingIcon(item.toString()),
                          color: AppTheme.primary,
                        ),
                      ),
                      title: Text(
                        item.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.check_circle_outline,
                        color: AppTheme.primary,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 15),

                const Center(
                  child: Text(
                    'Recommendations consider daily temperatures '
                    'and weather conditions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
