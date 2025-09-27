// lib/widgets/pet_form.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pet_models.dart';

typedef PetSubmitCallback = void Function(Pet petData);

class PetForm extends StatefulWidget {
  final Pet? initialPet;
  final PetSubmitCallback onSubmit;

  const PetForm({super.key, required this.onSubmit, this.initialPet});

  @override
  _PetFormState createState() => _PetFormState();
}

class _PetFormState extends State<PetForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;
  late TextEditingController _hrMinController;
  late TextEditingController _hrMaxController;
  late TextEditingController _tempMinController;
  late TextEditingController _tempMaxController;
  late TextEditingController _spo2MinController;

  Species _selectedSpecies = Species.dog;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final pet = widget.initialPet;
    _nameController = TextEditingController(text: pet?.name ?? '');
    _breedController = TextEditingController(text: pet?.breed ?? '');
    _ageController = TextEditingController(text: pet?.age.toString() ?? '');
    _selectedSpecies = pet?.species ?? Species.dog;
    _pickedImage = pet?.avatarFile;

    // Preenche com valores padrão se for um novo pet
    _hrMinController = TextEditingController(
      text: pet?.thresholds.heartRateMin.toString() ?? '60',
    );
    _hrMaxController = TextEditingController(
      text: pet?.thresholds.heartRateMax.toString() ?? '140',
    );
    _tempMinController = TextEditingController(
      text: pet?.thresholds.temperatureMin.toString() ?? '37.5',
    );
    _tempMaxController = TextEditingController(
      text: pet?.thresholds.temperatureMax.toString() ?? '39.2',
    );
    _spo2MinController = TextEditingController(
      text: pet?.thresholds.spo2Min.toString() ?? '95',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _hrMinController.dispose();
    _hrMaxController.dispose();
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _spo2MinController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _trySubmit() {
    // Esta linha agora irá acionar os validadores e mostrar as mensagens de erro
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return; // A submissão é interrompida se o formulário não for válido
    }

    final petData = Pet(
      id: widget.initialPet?.id ?? '',
      name: _nameController.text,
      breed: _breedController.text,
      species: _selectedSpecies,
      age: int.parse(_ageController.text),
      avatarFile: _pickedImage,
      ownerId: widget.initialPet?.ownerId ?? '',
      healthStatus: widget.initialPet?.healthStatus ?? HealthStatus.unknown,
      avatarUrl: widget.initialPet?.avatarUrl,
      thresholds: VitalThresholds(
        heartRateMin: double.parse(_hrMinController.text),
        heartRateMax: double.parse(_hrMaxController.text),
        temperatureMin: double.parse(_tempMinController.text),
        temperatureMax: double.parse(_tempMaxController.text),
        spo2Min: double.parse(_spo2MinController.text),
      ),
    );

    widget.onSubmit(petData);
  }

  // Validador para campos de texto que não podem ser vazios
  String? _validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo é obrigatório.';
    }
    return null;
  }

  // Validador para campos que devem ser numéricos
  String? _validateIsNumber(String? value) {
    if (_validateNotEmpty(value) != null) {
      return 'Este campo é obrigatório.';
    }
    if (double.tryParse(value!) == null) {
      return 'Por favor, insira um número válido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (código do seletor de imagem, que está correto) ...
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _pickedImage != null
                      ? FileImage(_pickedImage!)
                      : (widget.initialPet?.avatarFile != null
                                ? FileImage(widget.initialPet!.avatarFile!)
                                : (widget.initialPet?.avatarUrl != null
                                      ? NetworkImage(
                                          widget.initialPet!.avatarUrl!,
                                        )
                                      : null))
                            as ImageProvider?,
                  child:
                      _pickedImage == null && widget.initialPet?.avatar == null
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
          Text(
            'Informações do Pet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: _validateNotEmpty, // Adicionando o validador
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _breedController,
            decoration: const InputDecoration(labelText: 'Raça'),
            validator: _validateNotEmpty, // Adicionando o validador
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Idade'),
                  keyboardType: TextInputType.number,
                  validator: _validateIsNumber, // Adicionando o validador
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<Species>(
                  value: _selectedSpecies,
                  decoration: const InputDecoration(labelText: 'Espécie'),
                  items: Species.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedSpecies = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            'Limites de Alerta',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _hrMinController,
                  decoration: const InputDecoration(labelText: 'BPM Mín.'),
                  keyboardType: TextInputType.number,
                  validator: _validateIsNumber, // Adicionando o validador
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _hrMaxController,
                  decoration: const InputDecoration(labelText: 'BPM Máx.'),
                  keyboardType: TextInputType.number,
                  validator: _validateIsNumber, // Adicionando o validador
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ... (Resto dos campos de limites com seus validadores) ...
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tempMinController,
                  decoration: const InputDecoration(
                    labelText: 'Temp. Mín. (°C)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateIsNumber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _tempMaxController,
                  decoration: const InputDecoration(
                    labelText: 'Temp. Máx. (°C)',
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateIsNumber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _spo2MinController,
            decoration: const InputDecoration(labelText: 'SpO₂ Mín. (%)'),
            keyboardType: TextInputType.number,
            validator: _validateIsNumber,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _trySubmit, // Este botão agora funciona como esperado
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              widget.initialPet == null ? 'Adicionar Pet' : 'Salvar Alterações',
            ),
          ),
        ],
      ),
    );
  }
}
// Esta classe PetForm é um formulário para adicionar ou editar informações de um pet.
// Ela inclui campos para nome, raça, idade, espécie, foto e limites de alerta de saúde.