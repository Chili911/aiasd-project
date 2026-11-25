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
  final TextEditingController countryController =
      TextEditingController();
  final TextEditingController searchController =
      TextEditingController();

  List<dynamic> countries = [];
  List<dynamic> locations = [];

  String selectedCountry = 'Worldwide';
  String countryCode = '';
  String error = '';
  String countryError = '';

  bool loadingCountries = true;
  bool loading = false;
  bool showCountries = false;

  Timer? debounce;
  int requestId = 0;

  @override
  void initState() {
    super.initState();
    countryController.text = selectedCountry;
    loadCountries();
  }

  Future<void> loadCountries() async {
    setState(() {
      loadingCountries = true;
      countryError = '';
    });

    try {
      final data = await ApiService.get('/api/countries');

      if (!mounted) return;

      setState(() {
        countries = data['countries'] ?? [];
        loadingCountries = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loadingCountries = false;
        countryError = 'Unable to load countries.';
      });
    }
  }

  List<dynamic> get filteredCountries {
    final query = countryController.text
        .trim()
        .toLowerCase();

    return [
      {'code': '', 'name': 'Worldwide'},
      ...countries,
    ].where((country) {
      return country['name']
              .toString()
              .toLowerCase()
              .contains(query) ||
          country['code']
              .toString()
              .toLowerCase() == query;
    }).toList();
  }

  void selectCountry(dynamic country) {
    debounce?.cancel();
    requestId++;

    setState(() {
      selectedCountry = country['name'].toString();
      countryCode = country['code'].toString();
      countryController.text = selectedCountry;
      showCountries = false;
      locations = [];
      loading = false;
      error = '';
      searchController.clear();
    });

    FocusScope.of(context).unfocus();

    if (countryCode.isNotEmpty) {
      onSearchChanged(selectedCountry);
    }
  }

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
      final params = Uri(queryParameters: {
        'query': query,
        'country_code': countryCode,
      }).query;

      final data = await ApiService.get(
        '/api/locations?$params',
      );

      if (!mounted || id != requestId) return;

      setState(() {
        locations = (data['locations'] as List? ?? [])
            .where((location) =>
                countryCode.isEmpty ||
                location['country_code'] == countryCode)
            .toList();

        loading = false;
      });
    } catch (_) {
      if (!mounted || id != requestId) return;

      setState(() {
        error = 'Unable to search locations. Try again.';
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
    countryController.dispose();
    searchController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(
    String hint,
    IconData icon,
    VoidCallback onClear,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFB69AFF),
      ),
      suffixIcon: IconButton(
        icon: const Icon(
          Icons.close,
          color: Colors.white54,
        ),
        onPressed: onClear,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.09),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF19152E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF19152E),
        foregroundColor: Colors.white,
        title: const Text('Choose Location'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF19152E),
              Color(0xFF302354),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find your location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discover weather anywhere in the world.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Country',
                  style: TextStyle(
                    color: Color(0xFFE4D7FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: countryController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  onTap: () {
                    setState(() {
                      showCountries = true;
                      countryController.clear();
                    });
                  },
                  onChanged: (_) {
                    setState(() {
                      showCountries = true;
                    });
                  },
                  decoration: fieldDecoration(
                    'Search country...',
                    Icons.public,
                    () {
                      selectCountry({
                        'code': '',
                        'name': 'Worldwide',
                      });
                    },
                  ),
                ),

                if (showCountries)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF33284D),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: loadingCountries
                        ? const Center(
                            child:
                                CircularProgressIndicator(),
                          )
                        : countryError.isNotEmpty
                            ? Center(
                                child: TextButton(
                                  onPressed: loadCountries,
                                  child: const Text(
                                    'Retry loading countries',
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount:
                                    filteredCountries.length,
                                itemBuilder:
                                    (context, index) {
                                  final country =
                                      filteredCountries[index];

                                  return ListTile(
                                    title: Text(
                                      country['name'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onTap: () =>
                                        selectCountry(country),
                                  );
                                },
                              ),
                  ),

                const SizedBox(height: 20),

                const Text(
                  'City or province',
                  style: TextStyle(
                    color: Color(0xFFE4D7FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: searchController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  onTap: () {
                    setState(() {
                      showCountries = false;
                      countryController.text =
                          selectedCountry;
                    });
                  },
                  onChanged: onSearchChanged,
                  decoration: fieldDecoration(
                    'Search city or province...',
                    Icons.search,
                    () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Searching in $selectedCountry',
                  style: const TextStyle(
                    color: Color(0xFFB69AFF),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 12),

                if (loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),

                if (error.isNotEmpty)
                  Text(
                    error,
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),

                if (!loading &&
                    locations.isEmpty &&
                    error.isEmpty)
                  Center(
                    child: Text(
                      searchController.text.trim().length < 2
                          ? 'Enter a city or province.'
                          : 'No matching locations found.',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),

                Expanded(
                  child: ListView.separated(
                    itemCount: locations.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final location = locations[index];

                      final country =
                          location['country_code'] == 'TR'
                              ? 'Türkiye'
                              : location['country']
                                      ?.toString() ??
                                  '';

                      return Card(
                        color: Colors.white.withValues(
                          alpha: 0.08,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Color(0xFFB69AFF),
                          ),
                          title: Text(
                            location['city'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            country,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFFB69AFF),
                          ),
                          onTap: () =>
                              chooseLocation(location),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}