import 'dart:math';
import 'game_state.dart';
import 'game_actions.dart';

const double alpha = 0.1; // Learning rate
const double gamma = 0.9; // Discount factor

class QLearningAgent {
  Map<String, Map<GameAction, double>> qTable; // Map<State, Map<Action, QValue>>

  QLearningAgent() : qTable = {}; //TODO persist and load qTable by game-params(costants in util.dart)

  String _stateToString(GameState state) {
    // String that represents state, that should be used to decide action
    return '${state.co2Level.round()},${state.supplyShortage().round()}';
  }

  void learn(GameState state, GameAction action, double reward, GameState nextState) {
    String stateStr = _stateToString(state);
    String nextStateStr = _stateToString(nextState);

    // initiate states and action in qTable if it is not there
    if (!qTable.containsKey(stateStr)) {
      qTable[stateStr] = {};
    }
    if (!qTable.containsKey(nextStateStr)) {
      qTable[nextStateStr] = {};
    }
    double oldQValue = qTable[stateStr]![action] ?? 0;

    // calculate new QValue for state-action pair using Bellman equation (Q-Learning)
    double nextMaxQ = qTable[nextStateStr]!.values.fold(-double.infinity, max);
    double newQValue = oldQValue + alpha * (reward + gamma * nextMaxQ - oldQValue);
    qTable[stateStr]![action] = newQValue;

    print('Learnt from: State: $stateStr, Action: $action, Reward: $reward, Next state: $nextStateStr, Old QValue: $oldQValue, New QValue: $newQValue, Next Max Q: $nextMaxQ');
  }

  GameAction chooseAction(GameState state) {
    String stateStr = _stateToString(state);
    // if no past records, choose random action
    if (!qTable.containsKey(stateStr) || qTable[stateStr]!.isEmpty) {
      return GameAction.values[Random().nextInt(GameAction.values.length)];
    }

    // choose action with highest QValue
    Map<GameAction, double> actionsQValues = qTable[stateStr]!;
    double maxQValue = actionsQValues.values.fold(-double.infinity, max);
    List<GameAction> bestActions = actionsQValues.entries
        .where((entry) => entry.value == maxQValue)
        .map((entry) => entry.key)
        .toList();

    return bestActions[Random().nextInt(bestActions.length)];
  }
}