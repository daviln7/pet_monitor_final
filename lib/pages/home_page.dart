// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/add_edit_pet_page.dart'; // Corrija a importação se necessário
import '../pages/measurements_page.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seus Pets')),
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          if (petProvider.pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum pet cadastrado ainda.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toque no botão "+" para adicionar o seu primeiro pet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: petProvider.pets.length,
            itemBuilder: (ctx, i) {
              final pet = petProvider.pets[i];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MeasurementsPage(pet: pet),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Expanded(child: PetCard(pet: pet)),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Navega para a tela de edição, passando o pet
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AddEditPetPage(pet: pet),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            Provider.of<PetProvider>(
                              context,
                              listen: false,
                            ).deletePet(pet.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Navega para a tela de adição, sem passar um pet
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditPetPage()),
          );
        },
      ),
    );
  }
}
