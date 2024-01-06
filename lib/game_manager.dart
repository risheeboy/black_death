import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

import 'game_actions.dart';
import 'game_state.dart';
import 'q_agent.dart';
import 'run_state.dart';
import 'simple_agent.dart';
import 'utils.dart';

class GameManager {
  GameState state;
  SimpleAgent agent;
  QAgent qagent;

  GameState _previousState = GameState();
  final List<_QAction> _qactions = [];
  final List<GameAction> _pendingActions = [];

  GameManager(this.state, this.agent, this.qagent);

  void updateGameState() {
    // GameState oldState = GameState.clone(state);
    state.lapsedYears++;
    state.money += annualBudget;
    print("Year: ${state.lapsedYears} Money: ${state.money} Demand: ${state.renewableDemand()} Supply: ${state.renewableSupply()}");
    print("PPM Added: ${state.ppmAnnualyAddedByFossilFuels()} Carbon Capture: ${state.carbonCapture}");
    if (state.money >= state.education_budget) {
      state.awareness += state.education_budget * educationBudgetFactor;
      state.money -= state.education_budget; // Capex in Billion USD
    }

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
    print("CO2: ${state.co2Level} Reward: $reward");
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
    GameAction action = agent.chooseAction(state);
    print(" Action: $action");
    // GameAction qaction = qagent.chooseAction(state);
    // print("QAction: $qaction");

    if(state.isAgentEnabled) {
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
        state.education_budget += 2;
      } else if(action == GameAction.decreaseEducationBudget) {
        state.education_budget -= 2;
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
      } else {
        // Do nothing
      }
    }
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
  await player.play(AssetSource('audio/chime1.mp3'));
}