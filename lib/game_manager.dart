import 'package:cloud_firestore/cloud_firestore.dart';
import 'game_state.dart';
import 'game_actions.dart';
import 'utils.dart';
import 'q_agent.dart';
import 'run_state.dart';
import 'simple_agent.dart';

class GameManager {
  GameState state;
  SimpleAgent agent;
  QAgent qagent;

  final List<_QAction> actions = [];

  GameManager(this.state, this.agent, this.qagent);

  void performAction(GameAction action) {
    double availableMoney = state.money;
    double capex = capitalExpense[action] ?? 0;
    if(action == GameAction.buildSolarFactory) {
      state.solarProduction += availableMoney/capex;
      state.money -= availableMoney;
    } else if(action == GameAction.buildWindFactory) {
      state.windProduction += availableMoney/capex;
      state.money -= availableMoney;
    } else if(action == GameAction.educateYouth) {
      state.awareness += availableMoney/capex;
      state.money -= availableMoney;
    } else if(action == GameAction.carbonCapture) {
      state.carbonCapture += availableMoney/capex;
      state.money -= availableMoney;
    } else if(action == GameAction.increaseResearch) {
      state.researchLevel += availableMoney/capex;
      state.money -= availableMoney;
    } else {
      // Do nothing
    }
  }

  void updateGameState() {
    GameState oldState = GameState.clone(state);
    state.lapsedYears++;
    state.money += annualBudget;
    print("Year: ${state.lapsedYears} Money: ${state.money} Demand: ${state.renewableDemand()} Supply: ${state.renewableSupply()}");
    print("Supply Shortage: ${state.supplyShortage()} Future Supply Shortage: ${state.futureSupplyShortage(5)}");
    GameAction action = agent.chooseAction(state);
    print(" Action: $action");
    if(state.isAgentEnabled)
      performAction(action);
    GameAction qaction = qagent.chooseAction(state);
    print("QAction: $qaction");
    print("Solar: ${state.solarProduction} Wind: ${state.windProduction} Awareness: ${state.awareness} Money: ${state.money}");
    print("Carbon Capture: ${state.carbonCapture} Research: ${state.researchLevel}");
    print("PPM Added: ${state.ppmAnnualyAddedByFossilFuels()} Carbon Capture: ${state.carbonCapture}");
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
    state.co2Level += increaseInPpm;
    double reward = -increaseInPpm;
    print("CO2: ${state.co2Level} Reward: $reward");
    actions.add(_QAction(gameInstance, action, oldState, state, reward));
    print("Actions Registered: ${actions.length}");
    if(state.isGameOver()) {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      WriteBatch batch = _firestore.batch();
      actions.forEach((action) {
        batch.set(_firestore.collection('actions').doc(), action.toFireStoreDoc());
      }); 
      batch.commit();
      print("-- *Sent to Firebase!* --");
    }
    print("----------------");
    //qagent.learn(oldState, action, reward, state);
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
