
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_preview.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});

  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  String category = 'Body';
  bool loading = true;

  final Map<String, String> avatar = {
    'gender': 'Female',
    'height': 'Medium',
    'body': 'Medium',
    'skin': '#E8B894',
    'hair': 'Long',
    'hairColor': '#39251D',
    'makeup': 'None',
    'top': 'T-shirt',
    'bottom': 'Jeans',
    'shoes': 'Sneakers',
    'accessory': 'None',
    'clothingColor': '#8B5CF6',
  };

  final categories = {
    'Body': Icons.person_outline,
    'Skin': Icons.palette_outlined,
    'Hair': Icons.content_cut,
    'Makeup': Icons.brush_outlined,
    'Clothes': Icons.checkroom_outlined,
    'Extras': Icons.watch_outlined,
  };

  @override
  void initState() {
    super.initState();
    loadAvatar();
  }

  Future<void> loadAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        for (final key in avatar.keys) {
          avatar[key] = prefs.getString('weatherly_avatar_$key')
              ?? avatar[key]!;
        }
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> saveAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      for (final entry in avatar.entries) {
        await prefs.setString(
          'weatherly_avatar_${entry.key}',
          entry.value,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar saved successfully!')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save avatar.')),
      );
    }
  }

  Widget options(String title, String key, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.map((value) {
              final selected = avatar[key] == value;

              return ChoiceChip(
                label: Text(value),
                selected: selected,
                selectedColor: AppTheme.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.textColor,
                ),
                onSelected: (_) {
                  setState(() => avatar[key] = value);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget colors(String title, String key, List<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: values.map((value) {
              final selected = avatar[key] == value;
              final color = Color(
                int.parse(value.replaceFirst('#', '0xFF')),
              );

              return GestureDetector(
                onTap: () => setState(() => avatar[key] = value),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppTheme.primary
                          : Colors.white,
                      width: 3,
                    ),
                  ),
                  child: selected
                      ? Icon(Icons.check,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<Widget> categoryOptions() {
    switch (category) {
      case 'Body':
        return [
          options('Avatar type', 'gender', ['Female', 'Male']),
          options('Height', 'height', ['Short', 'Medium', 'Tall']),
          options('Body build', 'body',
              ['Slim', 'Medium', 'Broad', 'Full']),
        ];

      case 'Skin':
        return [
          colors('Skin tone', 'skin', [
            '#FFE4CC', '#F5C9A9', '#E8B894',
            '#C58C63', '#925B3C', '#603B2A',
          ]),
        ];

      case 'Hair':
        return [
          options('Hairstyle', 'hair', [
            'Short', 'Long', 'Curly', 'Bun',
            'Ponytail', 'Braids', 'Bald',
          ]),
          colors('Hair color', 'hairColor', [
            '#292524', '#39251D', '#795548',
            '#D4A017', '#A13D2D', '#9CA3AF',
          ]),
        ];

      case 'Makeup':
        return [
          options('Makeup style', 'makeup',
              ['None', 'Natural', 'Soft', 'Bold']),
        ];

      case 'Clothes':
        return [
          options('Tops', 'top',
              ['T-shirt', 'Hoodie', 'Sweater', 'Jacket', 'Coat']),
          options('Bottoms', 'bottom',
              ['Jeans', 'Trousers', 'Shorts', 'Skirt']),
          options('Shoes', 'shoes',
              ['Sneakers', 'Boots', 'Formal']),
          colors('Clothing color', 'clothingColor', [
            '#8B5CF6', '#2563EB', '#EC4899', '#16A34A',
            '#374151', '#FFFFFF', '#D97706', '#DC2626',
          ]),
        ];

      case 'Extras':
        return [
          options('Accessories', 'accessory', [
            'None', 'Glasses', 'Sunglasses',
            'Hat', 'Scarf', 'Earrings',
          ]),
        ];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Avatar', style: TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.bold,
        )),
        actions: [
          TextButton(
            onPressed: loading ? null : saveAvatar,
            child: const Text('Save'),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: AvatarPreview(
                          gender: avatar['gender']!,
                          height: avatar['height']!,
                          body: avatar['body']!,
                          skin: avatar['skin']!,
                          hair: avatar['hair']!,
                          hairColor: avatar['hairColor']!,
                          makeup: avatar['makeup']!,
                          top: avatar['top']!,
                          bottom: avatar['bottom']!,
                          shoes: avatar['shoes']!,
                          accessory: avatar['accessory']!,
                          clothingColor: avatar['clothingColor']!,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 76,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: categories.entries.map((entry) {
                          final selected = category == entry.key;

                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(
                                  () => category = entry.key),
                              child: Container(
                                width: 64,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(0xFFEDE9FE)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(entry.value, color: selected
                                        ? AppTheme.primary
                                        : Colors.grey),
                                    const SizedBox(height: 5),
                                    Text(entry.key, style: TextStyle(
                                      fontSize: 12,
                                      color: selected
                                          ? AppTheme.primary
                                          : AppTheme.textColor,
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      flex: 4,
                      child: ListView(
                        key: ValueKey(category),
                        padding: const EdgeInsets.all(20),
                        children: categoryOptions(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: ElevatedButton.icon(
                        onPressed: saveAvatar,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Avatar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
