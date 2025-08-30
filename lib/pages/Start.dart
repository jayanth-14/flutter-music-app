import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:gaana/pages/Home.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final TextEditingController _nameController = TextEditingController();
  late Box box;

  final List<String> validLangs = [
    "hindi",
    "english",
    "punjabi",
    "tamil",
    "telugu",
    "marathi",
    "gujarati",
    "bengali",
    "kannada",
    "bhojpuri",
    "malayalam",
    "urdu",
    "haryanvi",
    "rajasthani",
    "odia",
    "assamese",
  ];

  List<String> selectedLangs = [];

  @override
  void initState() {
    super.initState();
    box = Hive.box('myBox');
    _nameController.text = box.get('username', defaultValue: '') ?? '';
    selectedLangs = List<String>.from(box.get('languages', defaultValue: []));
  }

  void _saveAndContinue() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (selectedLangs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one language')),
      );
      return;
    }

    box.put('username', _nameController.text.trim());
    box.put('languages', selectedLangs);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  Home(box: Hive.box("myBox"))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Welcome to Gaana.",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black54,
        foregroundColor: const Color(0xFF0CE6AA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Let's get started!",
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Your Name",
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Choose your preferred languages:",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: validLangs.map((lang) {
                    final isSelected = selectedLangs.contains(lang);
                    return ChoiceChip(
                      label: Text(lang),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedLangs.add(lang);
                          } else {
                            selectedLangs.remove(lang);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF0CE6AA),
                      backgroundColor: Colors.grey.shade800,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0CE6AA),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
