import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet_models.dart';

class PetForm extends StatefulWidget {
  final Pet? initialPet;
  final Function(String name, String breed, Species species, int age,
      File? avatar, VitalThresholds thresholds) onSave;

  const PetForm({super.key, this.initialPet, required this.onSave});

  @override
  State<PetForm> createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late Species _selectedSpecies;
  File? _pickedImage;

  // Controladores para os Limites (Thresholds)
  late TextEditingController _minTempController;
  late TextEditingController _maxTempController;
  late TextEditingController _minHeartRateController;
  late TextEditingController _maxHeartRateController;
  late TextEditingController _minSpo2Controller;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialPet?.name ?? '');
    _breedController =
        TextEditingController(text: widget.initialPet?.breed ?? '');
    _ageController =
        TextEditingController(text: widget.initialPet?.age.toString() ?? '');
    _selectedSpecies = widget.initialPet?.species ?? Species.dog;

    // Inicializa com os valores existentes ou padrões
    final thresholds = widget.initialPet?.thresholds ?? VitalThresholds();
    _minTempController =
        TextEditingController(text: thresholds.minTemp.toString());
    _maxTempController =
        TextEditingController(text: thresholds.maxTemp.toString());
    _minHeartRateController =
        TextEditingController(text: thresholds.minHeartRate.toString());
    _maxHeartRateController =
        TextEditingController(text: thresholds.maxHeartRate.toString());
    _minSpo2Controller =
        TextEditingController(text: thresholds.minSpo2.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    _minHeartRateController.dispose();
    _maxHeartRateController.dispose();
    _minSpo2Controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final thresholds = VitalThresholds(
        minTemp: double.tryParse(_minTempController.text) ?? 37.5,
        maxTemp: double.tryParse(_maxTempController.text) ?? 39.5,
        minHeartRate: double.tryParse(_minHeartRateController.text) ?? 60.0,
        maxHeartRate: double.tryParse(_maxHeartRateController.text) ?? 140.0,
        minSpo2: double.tryParse(_minSpo2Controller.text) ?? 95.0,
      );

      widget.onSave(
        _nameController.text,
        _breedController.text,
        _selectedSpecies,
        int.parse(_ageController.text),
        _pickedImage, // Passa o arquivo local (pode ser null)
        thresholds,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (widget.initialPet?.avatarUrl != null &&
                              widget.initialPet!.avatarUrl!.isNotEmpty
                          ? NetworkImage(widget.initialPet!.avatarUrl!)
                          : null) as ImageProvider?,
                  child: _pickedImage == null &&
                          (widget.initialPet?.avatarUrl == null ||
                              widget.initialPet!.avatarUrl!.isEmpty)
                      ? const Icon(Icons.pets, size: 50)
                      : null,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Escolher Foto'),
                  onPressed: _pickImage,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Informe o nome' : null,
          ),
          TextFormField(
            controller: _breedController,
            decoration: const InputDecoration(labelText: 'Raça'),
            validator: (value) =>
                value == null || value.isEmpty ? 'Informe a raça' : null,
          ),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(labelText: 'Idade (anos)'),
            keyboardType: TextInputType.number,
            validator: (value) =>
                value == null || value.isEmpty ? 'Informe a idade' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Species>(
            value: _selectedSpecies,
            decoration: const InputDecoration(labelText: 'Espécie'),
            items: Species.values.map((species) {
              return DropdownMenuItem(
                value: species,
                child: Text(species.displayName),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedSpecies = value);
            },
          ),
          const SizedBox(height: 24),
          const Text("Limites de Sinais Vitais",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: _minTempController,
                decoration: const InputDecoration(labelText: 'Temp. Mín (°C)'),
                keyboardType: TextInputType.number,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: TextFormField(
                controller: _maxTempController,
                decoration: const InputDecoration(labelText: 'Temp. Máx (°C)'),
                keyboardType: TextInputType.number,
              )),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: TextFormField(
                controller: _minHeartRateController,
                decoration: const InputDecoration(labelText: 'BPM Mín'),
                keyboardType: TextInputType.number,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: TextFormField(
                controller: _maxHeartRateController,
                decoration: const InputDecoration(labelText: 'BPM Máx'),
                keyboardType: TextInputType.number,
              )),
            ],
          ),
          TextFormField(
            controller: _minSpo2Controller,
            decoration: const InputDecoration(labelText: 'SpO2 Mínimo (%)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(widget.initialPet == null
                  ? 'Adicionar Pet'
                  : 'Salvar Alterações'),
            ),
          ),
        ],
      ),
    );
  }
}
