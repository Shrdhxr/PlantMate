import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantmate/models/plant.dart';
import 'package:plantmate/providers/plants_provider.dart';

class AddPlantScreen extends ConsumerStatefulWidget {
  const AddPlantScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends ConsumerState<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _minTempController = TextEditingController(text: '15');
  final _maxTempController = TextEditingController(text: '25');
  final _wateringFrequencyController = TextEditingController(text: '7');
  final _fertilizingFrequencyController = TextEditingController(text: '30');
  final _repottingFrequencyController = TextEditingController(text: '12');
  final _tagsController = TextEditingController();
  
  SunlightPreference _sunlightPreference = SunlightPreference.medium;
  final Set<PlantCategory> _selectedCategories = {PlantCategory.indoor};
  String? _imagePath;
  
  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    _wateringFrequencyController.dispose();
    _fertilizingFrequencyController.dispose();
    _repottingFrequencyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Plant'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plant Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Species (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildSunlightPreference(),
              const SizedBox(height: 16),
              _buildTemperatureRange(),
              const SizedBox(height: 16),
              _buildCareFrequency(),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. gift, favorite, kitchen',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePlant,
                  child: const Text('Save Plant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: _imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imagePath!),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text('Add Photo'),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _pickImage,
            child: const Text('Choose Image'),
          ),
        ],
      ),
    );
  }

  Widget _buildSunlightPreference() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sunlight Preference',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<SunlightPreference>(
          segments: const [
            ButtonSegment(
              value: SunlightPreference.low,
              label: Text('Low'),
              icon: Icon(Icons.wb_sunny_outlined),
            ),
            ButtonSegment(
              value: SunlightPreference.medium,
              label: Text('Medium'),
              icon: Icon(Icons.wb_sunny),
            ),
            ButtonSegment(
              value: SunlightPreference.high,
              label: Text('High'),
              icon: Icon(Icons.wb_sunny),
            ),
          ],
          selected: {_sunlightPreference},
          onSelectionChanged: (Set<SunlightPreference> selection) {
            setState(() {
              _sunlightPreference = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTemperatureRange() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temperature Range (°C)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minTempController,
                decoration: const InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                  suffixText: '°C',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxTempController,
                decoration: const InputDecoration(
                  labelText: 'Max',
                  border: OutlineInputBorder(),
                  suffixText: '°C',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCareFrequency() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Care Frequency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _wateringFrequencyController,
                decoration: const InputDecoration(
                  labelText: 'Watering (days)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fertilizingFrequencyController,
                decoration: const InputDecoration(
                  labelText: 'Fertilizing (days)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _repottingFrequencyController,
                decoration: const InputDecoration(
                  labelText: 'Repotting (months)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PlantCategory.values.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(Plant.categoryToString(category)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _savePlant() {
    if (_formKey.currentState!.validate()) {
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an image')),
        );
        return;
      }
      
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one category')),
        );
        return;
      }
      
      final plant = Plant(
        id: '',
        name: _nameController.text,
        species: _speciesController.text,
        imagePath: _imagePath!,
        sunlightPreference: _sunlightPreference,
        minTemperature: double.parse(_minTempController.text),
        maxTemperature: double.parse(_maxTempController.text),
        wateringFrequencyDays: int.parse(_wateringFrequencyController.text),
        fertilizingFrequencyDays: int.parse(_fertilizingFrequencyController.text),
        repottingFrequencyMonths: int.parse(_repottingFrequencyController.text),
        categories: _selectedCategories.toList(),
        tags: _tagsController.text.isEmpty
            ? []
            : _tagsController.text.split(',').map((tag) => tag.trim()).toList(),
        dateAdded: DateTime.now(),
      );
      
      ref.read(plantsProvider.notifier).addPlant(plant);
      Navigator.pop(context);
    }
  }
}
