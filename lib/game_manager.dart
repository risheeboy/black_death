import 'dart:math';
import 'package:black_death/rule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import 'game_state.dart';
import 'q_agent.dart';
import 'run_state.dart';
import 'custom_sidekick.dart';
import 'simple_agent.dart';
import 'utils.dart';

class GameManager {
  GameState state;
  Sidekick sidekick = Sidekick.None;
  int gameInstance = 0;
  SimpleAgent simpleAgent;
  CustomSidekick customSidekick = CustomSidekick();//TODO initialize rules
  QAgent qagent;

  GameState _previousState = GameState();//TODO check creating new GameState is correct logic
  final List<_QAction> _qactions = [];
  final List<GameAction> _pendingActions = [];

  GameManager(this.state, this.simpleAgent, this.qagent);

  double frequencyOfNaturalDisastor = (GameState().co2Level - 350).abs()/200;//TODO check creating new GameState is correct logic

  void updateGameState() {
    // GameState oldState = GameState.clone(state);
    state.lapsedYears++;
    state.money += annualBudget;
    print("Year: ${state.lapsedYears} Money: ${state.money}");
    print("Demand: ${state.renewableDemand()} Supply: ${state.renewableSupply()} Awareness: ${state.awareness.round()} solar: ${state.solarProduction.round()} fossil: ${state.fossilFuelProduction.round()}");
    //print("PPM Added: ${state.ppmAnnualyAddedByFossilFuels().round()} Carbon Capture: ${state.carbonCapture}");
    double educationSpend = min(state.money, state.education_budget.toDouble());
    state.awareness += (educationSpend * educationBudgetFactor) * (1 - annualAwarenessFractionDecline);
    state.money -= educationSpend; // Capex in Billion USD

    if (state.co2Level > co2LevelMax) {
      state.runState = RunState.LostTooHigh;
    } else if (state.co2Level < co2LevelMin) {
      state.runState = RunState.LostTooLow;
    } else if (state.co2Level >= 340 && state.co2Level <= 360) {
      state.consecutiveYearsInRange++;
      if (state.consecutiveYearsInRange >= 10) {
        state.runState = RunState.Won;
      }
    } else {// Reset counter, if out of range
      state.consecutiveYearsInRange = 0;
    }

    double increaseInPpm = state.ppmAnnualyAddedByFossilFuels() - state.carbonCapture;
    state.lastPpmIncrease = increaseInPpm;
    state.co2Level += increaseInPpm;

    // Prepare data for Q-learning agent, send data to firebase
    double reward = -increaseInPpm; //TODO should be second order PPM change in desired direction
    //print("CO2: ${state.co2Level.round()} Rewardx100: ${(reward*100).round()}");
    int actionsToAdd = _pendingActions.length;
    if(actionsToAdd > 0) {
      _pendingActions.forEach((action) {
        _qactions.add(_QAction(gameInstance, action, _previousState, state, reward));
      });
      _previousState = GameState.clone(state);
      _pendingActions.clear();
    }
    _previousState = GameState.clone(state);

    // Persist actions, when game is over
    if(state.isGameOver()) {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      WriteBatch batch = _firestore.batch();
      _qactions.forEach((action) {
        batch.set(_firestore.collection('actions').doc(), action.toFireStoreDoc());
      }); 
      batch.commit();
      print("-- *Sent to Firebase!* --");
    }
    print("----------------");
  }

  void agentAction() {
    GameAction action;
    switch(sidekick) {
      case Sidekick.None:
        action = GameAction.doNothing;
        break;
      case Sidekick.System:
        action = simpleAgent.chooseAction(state);
        break;
      case Sidekick.Custom:
        action = customSidekick.chooseAction(state);
        break;
      case Sidekick.AI:
        action = qagent.chooseAction(state);
        break;
      default:
        action = GameAction.doNothing;
        break;
    }
    print('$sidekick action $action');
    if(action != GameAction.doNothing) {
      takeAction(action);
    }
    _pendingActions.add(action);
  }

  void takeAction(GameAction action) {
    if (state.runState != RunState.Running) return;
    playAudioButton();
    double capex = capitalExpense[action] ?? 0;
    
    if (capex <= state.money) {
      if(action == GameAction.buildSolarFactory) { 
        state.solarProduction++;
        state.money -= capex;
      } else if(action == GameAction.increaseFossilFuelUsage) {
        state.fossilFuelProduction++;
        state.money -= capex;
      } else if(action == GameAction.increaseEducationBudget) {
        state.education_budget++;
      } else if(action == GameAction.decreaseEducationBudget) {
        if(state.education_budget > 0)
          state.education_budget--;
      } else if(action == GameAction.carbonCapture) {
        state.carbonCapture++;
        state.money -= capex;
      } else if(action == GameAction.increaseResearch) {
        state.researchLevel++;
        state.money -= capex;
      } else if(action == GameAction.destroySolarFactory) {
        if (state.solarProduction > 0)
          state.solarProduction--;
        state.money -= capex;
      } else if(action == GameAction.decreaseFossilFuelUsage) {
        if (state.fossilFuelProduction > 0)
          state.fossilFuelProduction--;
        state.money -= capex;
      } else if (action == GameAction.naturalDisaster) {
          var rng = new Random(10);
          if (state.solarProduction > 0) {
            int numToDestroy = rng.nextInt(state.solarProduction);
            state.solarProduction -= numToDestroy;
          }
          state.money -= capex;
        }
        state.money -= capex;
      } else {
        print('Sorry, capex $capex > available money ${state.money}');//TODO play warning sound and inform user
      }
  }

  void setSidekick(Sidekick selectedSidekick) {
    sidekick = selectedSidekick;
  }
}



// Internal class to be pushed to firestore collection 'actions' for QTable learning 
class _QAction {
  int gameInstance;
  GameAction action;
  GameState onState;
  GameState nextState;
  double reward;

  _QAction(this.gameInstance, this.action, this.onState, this.nextState, this.reward);

  Map<String, dynamic> toFireStoreDoc() => {
    'gameVersion': 1,
    'gameInstance': gameInstance,
    'actionName': action.name,
    'onState': onState.toFireStoreDoc(),
    'nextState': nextState.toFireStoreDoc(),
    'reward': reward,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

void playAudioButton() async {
  final player = AudioPlayer();
  await player.play(AssetSource('audio/chime1.wav'));
}