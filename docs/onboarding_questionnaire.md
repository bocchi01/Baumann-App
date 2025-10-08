# Onboarding Questionnaire

## Panoramica

Sistema di onboarding multi-step con 4 domande per personalizzare l'esperienza utente e assegnare il percorso più adatto.

## Struttura

### 📂 File Principali

- **`models/onboarding_data.dart`**: Modelli dati (enums + OnboardingData)
- **`onboarding/onboarding_controller.dart`**: Controller Riverpod per gestire stato e logica
- **`onboarding/onboarding_questionnaire_screen.dart`**: Container principale con PageView e navigation
- **`onboarding/steps/*.dart`**: Singoli step del questionario

### 🎯 Steps del Questionario

1. **Goal (Obiettivo)**
   - Prevenzione 🛡️
   - Correzione 🔧
   - Performance 🏃
   
2. **Lifestyle (Stile di Vita)**
   - Sedentario 💻
   - Moderato 🚶
   - Attivo 🏋️

3. **Time Availability (Tempo Disponibile)**
   - 5 minuti
   - 10 minuti (consigliato)
   - 15 minuti
   - 30+ minuti

4. **Pain Conditions (Condizioni di Dolore)** - Multi-select opzionale
   - Nessuno
   - Collo e Spalle
   - Zona Lombare
   - Zona Dorsale
   - Dolore Cronico

## Logica di Assegnazione Percorso

Il metodo `OnboardingData.determinePathId()` assegna il percorso basandosi su:

```dart
// Priorità:
1. Dolore cronico → path_chronic_pain
2. Sedentario + prevenzione → path_office_worker
3. Attivo + performance → path_athlete_performance
4. Dolore lombare → path_lower_back_focus
5. Dolore collo/spalle → path_neck_shoulder_focus
6. Default → path_balanced_general
```

**⚠️ Nota**: I percorsi sono attualmente ID testuali. Dovrai crearli in Firestore o nel tuo sistema backend.

## Features

### ✅ Implementato

- ✅ 4 step con validazione
- ✅ Progress bar animato
- ✅ Navigation avanti/indietro
- ✅ Multi-select per condizioni dolore
- ✅ Salvataggio su Firestore tramite PatientRepository
- ✅ Integrazione con AuthGate
- ✅ Loading states
- ✅ Error handling con dialog
- ✅ Design Cupertino nativo iOS

### 🔜 Future Enhancements

- [ ] Skip onboarding (per utenti esperti)
- [ ] Edit risposte post-onboarding
- [ ] Animazioni di transizione più fluide
- [ ] Tips/suggerimenti per ogni step
- [ ] A/B testing su ordine domande
- [ ] Campo "Note aggiuntive" per info custom

## Utilizzo

### Accesso dallo State

```dart
// In un ConsumerWidget
final state = ref.watch(onboardingControllerProvider);
final controller = ref.read(onboardingControllerProvider.notifier);

// Leggi dati
final goal = state.data.goal;
final isComplete = state.data.isComplete;

// Modifica stato
controller.setGoal(OnboardingGoal.prevention);
controller.togglePainCondition(PainCondition.lowerBack);

// Completa onboarding
final success = await controller.completeOnboarding();
```

### Flusso Completo

1. Utente registra account → AuthGate rileva `onboardingCompleted = false`
2. Mostra `OnboardingQuestionnaireScreen`
3. Utente risponde alle 4 domande
4. Click su "Completa" → `controller.completeOnboarding()`
5. Salvataggio su Firestore: `patients/{uid}` con campi:
   - `onboardingCompleted: true`
   - `onboardingData: { goal, lifestyle, timeAvailability, painConditions }`
   - `assignedPathId: "path_xxx"`
6. Navigazione automatica a `MainScreen`

## Firestore Schema

```json
{
  "patients": {
    "{uid}": {
      "onboardingCompleted": true,
      "email": "user@example.com",
      "onboardingData": {
        "goal": "prevention",
        "lifestyle": "sedentary",
        "timeAvailability": "ten",
        "painConditions": ["lowerBack"]
      },
      "assignedPathId": "path_office_worker",
      "createdAt": 1704672000000,
      "updatedAt": 1704672000000
    }
  }
}
```

## Testing

1. Logout dall'app
2. Registra nuovo account
3. Verifica che appaia il questionario
4. Completa tutti gli step
5. Verifica salvataggio su Firestore
6. Verifica navigazione a MainScreen

## Customizzazione

### Aggiungere una Domanda

1. Aggiungi enum in `models/onboarding_data.dart`
2. Aggiungi campo in `OnboardingData`
3. Crea nuovo step in `onboarding/steps/`
4. Aggiungi al `PageView` in `onboarding_questionnaire_screen.dart`
5. Incrementa `OnboardingState.totalSteps`
6. Aggiorna `canProceedToNext` per validazione

### Modificare Logica Assegnazione

Edita `OnboardingData.determinePathId()` con la tua logica custom.

## UI/UX

- **Design**: Cupertino iOS native
- **Colori**: Blu primario `#0A84FF`
- **Animazioni**: 200-300ms duration
- **Accessibilità**: Label semantici, checkmark visibili
- **Feedback**: Validazione immediata, loading states chiari

---

**Domande?** Apri un issue o contatta il team! 🚀
