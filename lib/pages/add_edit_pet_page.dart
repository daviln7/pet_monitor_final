// lib/pages/add_edit_pet_page.dart
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
    final isEditing = pet != null;
    final title = isEditing ? 'Editar Pet' : 'Adicionar Pet';
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    // Esta função agora espera (await) a conclusão da operação no provider
    // antes de fechar a tela.
    void handleSubmit(Pet petData) async {
      // Mostra um indicador de carregamento para o usuário saber que algo está acontecendo
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      try {
        if (isEditing) {
          await petProvider.updatePet(petData);
        } else {
          await petProvider.addPet(
            name: petData.name,
            breed: petData.breed,
            species: petData.species,
            age: petData.age,
            avatarFile: petData.avatarFile,
            thresholds: petData.thresholds,
          );
        }

        // Se a operação foi bem-sucedida, fecha o loading e a tela do formulário
        if (context.mounted) {
          Navigator.of(context).pop(); // Fecha o loading
          Navigator.of(context).pop(); // Fecha a página do formulário
        }
      } catch (error) {
        // Se der algum erro, fecha o loading e mostra uma mensagem
        if (context.mounted) {
          Navigator.of(context).pop(); // Fecha o loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao salvar o pet: $error')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: PetForm(initialPet: pet, onSubmit: handleSubmit),
      ),
    );
  }
}
// Esta página permite adicionar ou editar informações de um pet.
// Ela usa o PetProvider para adicionar ou atualizar os dados do pet no banco de dados.