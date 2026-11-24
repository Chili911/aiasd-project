
import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState
    extends State<LocationSearchScreen> {
  final TextEditingController searchController =
      TextEditingController();

  List<dynamic> locations = [];
  Timer? debounce;
  bool loading = false;
  String error = '';
  int requestId = 0;

  void onSearchChanged(String value) {
    debounce?.cancel();
    final id = ++requestId;

    setState(() {
      locations = [];
      error = '';
      loading = value.trim().length >= 2;
    });

    if (value.trim().length < 2) return;

    debounce = Timer(
      const Duration(milliseconds: 400),
      () => searchLocations(value.trim(), id),
    );
  }

  Future<void> searchLocations(String query, int id) async {
    try {
      final data = await ApiService.get(
        '/api/locations?query=${Uri.encodeQueryComponent(query)}',
      );

      if (!mounted || id != requestId) return;

      setState(() {
        locations = data['locations'] ?? [];
        loading = false;
      });
    } catch (e) {
      if (!mounted || id != requestId) return;

      setState(() {
        error = 'Unable to search locations. Please try again.';
        loading = false;
      });
    }
  }

  Future<void> chooseLocation(dynamic location) async {
    try {
      await LocationService.selectLocation(
        Map<String, dynamic>.from(location),
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Unable to save the selected location.';
      });
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find your location',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search for a city anywhere in the world.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              autofocus: true,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                ),
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
            if (!loading &&
                locations.isEmpty &&
                error.isEmpty)
              Center(
                child: Text(
                  searchController.text.trim().length < 2
                      ? 'Enter a city name to begin.'
                      : 'No matching locations found.',
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: locations.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final location = locations[index];

                  final subtitle = [
                    location['region'],
                    location['country'],
                  ].where(
                    (value) =>
                        value != null &&
                        value.toString().isNotEmpty,
                  ).join(', ');

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.location_on,
                        color: Color(0xFF7C3AED),
                      ),
                      title: Text(
                        location['city'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(subtitle),
                      trailing: const Icon(
                        Icons.chevron_right,
                      ),
                      onTap: () => chooseLocation(location),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
