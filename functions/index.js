// Ficheiro: functions/index.js

// Importa as bibliotecas necessárias do Firebase
const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Inicializa a ligação com o seu projeto Firebase
admin.initializeApp();

/**
 * Esta é a nossa Cloud Function.
 * Ela é acionada (dispara) sempre que um documento na coleção 'vitals'
 * é ATUALIZADO.
 */
exports.checkVitalsAndSendAlert = functions.firestore
  .document("vitals/{petId}")
  .onUpdate(async (change, context) => {
    
    // Obtém o ID do pet a partir do documento que foi alterado (ex: "petId123")
    const petId = context.params.petId;
    
    // Obtém os novos dados que o sensor acabou de enviar
    const newVitals = change.after.data();

    console.log(`Verificando sinais vitais para o pet: ${petId}`);

    // --- Passo 1: Obter os dados do pet para saber os seus limites de alerta ---
    const petDocRef = admin.firestore().collection("pets").doc(petId);
    const petDoc = await petDocRef.get();

    if (!petDoc.exists) {
      console.log(`Pet com ID ${petId} não foi encontrado na coleção 'pets'.`);
      return null; // A função termina aqui se o pet não for encontrado
    }
    
    const petData = petDoc.data();
    const ownerId = petData.ownerId;
    
    let alertMessage = "";
    let severity = "low"; // Define a gravidade padrão

    // --- Passo 2: Lógica de verificação dos sinais vitais ---
    // Verifique se os novos dados do sensor estão fora dos limites definidos para este pet.
    
    // Exemplo para Temperatura
    if (newVitals.temperature > petData.temperatureMax) {
      alertMessage = `${petData.name} está com febre! Temperatura atual: ${newVitals.temperature.toFixed(1)}°C`;
      severity = "high";
    } else if (newVitals.temperature < petData.temperatureMin) {
      alertMessage = `${petData.name} está com hipotermia. Temperatura atual: ${newVitals.temperature.toFixed(1)}°C`;
      severity = "high";
    }

    // Adicione aqui outras lógicas. Exemplo para Frequência Cardíaca:
    if (newVitals.heartRate > petData.heartRateMax) {
        alertMessage = `${petData.name} está com taquicardia! BPM: ${newVitals.heartRate.toFixed(0)}`;
        severity = "medium";
    }

    // --- Passo 3: Se um alerta for gerado, enviar a notificação ---
    if (alertMessage) {
      console.log(`ALERTA GERADO para ${petData.name}: ${alertMessage}`);

      // 3a. Obter o token de notificação do telemóvel do dono
      const userDoc = await admin.firestore().collection("users").doc(ownerId).get();
      if (!userDoc.exists || !userDoc.data().fcmToken) {
        console.log(`Token de notificação (FCM Token) para o utilizador ${ownerId} não encontrado.`);
        return null; // Termina se não souber para onde enviar
      }
      const fcmToken = userDoc.data().fcmToken;

      // 3b. Criar o documento de alerta na coleção 'alerts' (que o seu app já lê!)
      const alertsCollection = admin.firestore().collection("alerts");
      await alertsCollection.add({
        petId: petId,
        petName: petData.name,
        timestamp: admin.firestore.FieldValue.serverTimestamp(), // Usa a hora do servidor
        message: alertMessage,
        severity: severity,
        acknowledged: false,
      });

      // 3c. Preparar a notificação push
      const payload = {
        notification: {
          title: `Alerta de Saúde para ${petData.name}!`,
          body: alertMessage,
          sound: "default" // Adiciona um som padrão
        },
        token: fcmToken,
      };

      // 3d. Enviar a notificação
      try {
        await admin.messaging().send(payload);
        console.log("Notificação push enviada com sucesso!");
      } catch (error) {
        console.error("Erro ao enviar notificação push:", error);
      }
    } else {
        console.log(`Sinais vitais para ${petData.name} estão normais.`);
    }

    return null; // Termina a função com sucesso
  });