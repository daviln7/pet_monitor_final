// Importa nossos modelos de dados que criamos anteriormente.
import '../models/pet_models.dart';
import 'dart:math';

// Esta classe é responsável por fornecer dados de pets.
// No futuro, você poderia substituir a lógica aqui para fazer chamadas
// HTTP reais a uma API web, sem precisar mudar o código da sua UI.
class PetMockService {
  // Uma lista de dados falsos, diretamente no código para fins de desenvolvimento.
  // O '_' no início do nome da variável a torna "privada" para este arquivo.
  static final List<Pet> _mockPets = [
    Pet(
      id: '1',
      name: 'Bolacha',
      breed: 'Golden Retriever',
      species: Species.dog,
      age: 5,
      ownerId: 'user1',
      healthStatus: HealthStatus.stable,
      avatarUrl:
          'https://i.imgur.com/v8R3xeg.jpeg', // Usando um link direto para a imagem
      thresholds: VitalThresholds(
        heartRateMin: 60,
        heartRateMax: 140,
        temperatureMin: 37.5,
        temperatureMax: 39.2,
        spo2Min: 95,
      ),
    ),
    Pet(
      id: '2',
      name: 'Lucy',
      breed: 'Labrador',
      species: Species.dog,
      age: 3,
      ownerId: 'user1',
      healthStatus: HealthStatus.attention,
      avatarUrl: 'https://i.imgur.com/x51NnNT.jpeg',
      thresholds: VitalThresholds(
        heartRateMin: 60,
        heartRateMax: 150,
        temperatureMin: 37.5,
        temperatureMax: 39.2,
        spo2Min: 95,
      ),
    ),
    Pet(
      id: '3',
      name: 'Whiskers',
      breed: 'Siamese',
      species: Species.cat,
      age: 7,
      ownerId: 'user1',
      healthStatus: HealthStatus.stable,
      avatarUrl: 'https://i.imgur.com/yS4S0fG.jpeg',
      thresholds: VitalThresholds(
        heartRateMin: 100,
        heartRateMax: 180,
        temperatureMin: 37.8,
        temperatureMax: 39.5,
        spo2Min: 94,
      ),
    ),
  ];

  // Este método simula a busca da lista de pets de um servidor.
  // Em Dart, operações assíncronas retornam um 'Future'.
  // Um Future é uma promessa de que você receberá um valor no futuro.
  // Analogia com Python: um 'Future' em Dart é muito similar a um objeto
  // 'awaitable' que uma função 'async def' retorna em Python com asyncio.
  Future<List<Pet>> getPets(String ownerId) async {
    // A palavra-chave 'async' marca a função como assíncrona.

    // A palavra-chave 'await' pausa a execução da função até que o Future
    // seja concluído, sem bloquear o resto da aplicação.
    // Isto é idêntico ao 'await' em Python.
    // Aqui, estamos simulando um atraso de 1 segundo da rede.
    await Future.delayed(const Duration(seconds: 1));

    // Retorna a lista de pets.
    return _mockPets;
  }

  // Simula a busca de um histórico de sinais vitais para um pet.
  Future<List<VitalSign>> getVitalHistory(String petId) async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simula atraso da rede.

    final List<VitalSign> history = [];
    final random = Random();
    final now = DateTime.now();

    // Gera 50 pontos de dados históricos.
    for (int i = 50; i > 0; i--) {
      history.add(
        VitalSign(
          timestamp: now.subtract(
            Duration(minutes: i * 5),
          ), // Dados a cada 5 minutos.
          heartRate: 70 + random.nextDouble() * 20, // Variação de 70 a 90 BPM
          temperature:
              38.0 + random.nextDouble() * 1.5, // Variação de 38.0 a 39.5 °C
        ),
      );
    }
    return history;
  }
}
