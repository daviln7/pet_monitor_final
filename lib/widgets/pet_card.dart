import 'package:flutter/material.dart';
import '../models/pet_models.dart';
import 'package:pet_monitor_final/pages/measurements_page.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    // 1. Usamos um Card como base para o layout visual.
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      // 2. Envolvemos o conteúdo com InkWell para adicionar o efeito de clique (ripple) e a ação 'onTap'.
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MeasurementsPage(pet: pet)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: pet.avatar,
                backgroundColor: Colors.grey[300], // MUDANÇA AQUI
                // O 'child' só aparece se 'backgroundImage' for nulo.
                child: pet.avatar == null
                    ? const Icon(Icons.pets, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              // Expanded garante que a coluna de texto ocupe o espaço restante, evitando overflow.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.breed}, ${pet.age} anos',
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// O PetCard é um widget que representa um cartão visual para exibir informações de um animal de estimação.
// Ele inclui uma imagem de avatar, nome, raça e idade do pet.
// O cartão é clicável e, ao ser tocado, navega para a página de medições do pet,
// onde o usuário pode ver detalhes adicionais e histórico de sinais vitais.
