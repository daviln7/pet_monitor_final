import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_models.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_form.dart';

class AddEditPetPage extends StatelessWidget {
  final Pet? pet;

  const AddEditPetPage({super.key, this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pet == null ? 'Adicionar Pet' : 'Editar Pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PetForm(
          initialPet: pet,
          // AQUI: Alterado de onSubmit para onSave para combinar com o novo PetForm
          onSave: (name, breed, species, age, avatar, thresholds) async {
            try {
              final provider = Provider.of<PetProvider>(context, listen: false);

              if (pet == null) {
                // Adicionando novo pet
                await provider.addPet(
                  name: name,
                  breed: breed,
                  species: species,
                  age: age,
                  avatarFile: avatar,
                  thresholds: thresholds,
                );
              } else {
                // Editando pet existente
                final updatedPet = pet!.copyWith(
                  name: name,
                  breed: breed,
                  species: species,
                  age: age,
                  avatarFile: avatar,
                  thresholds: thresholds,
                );
                await provider.updatePet(updatedPet);
              }

              if (context.mounted) {
                Navigator.pop(context);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao salvar: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
