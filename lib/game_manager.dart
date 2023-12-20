import 'game_state.dart';
import 'game_actions.dart';
import 'utils.dart';
import 'q_learning_agent.dart';
import 'simple_agent.dart';

class GameManager {
  GameState state;
  SimpleAgent agent;
  QLearningAgent qagent;

  GameManager(this.state, this.agent, this.qagent);

  void performAction(GameAction action) {
    double availableMoney = state.money;
    double capex = capitalExpense[action]!;
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
    print("Year: ${state.lapsedYears}");
    state.money += annualBudget;
    print("Money available: ${state.money}");
    print("Renewable Demand: ${state.renewableDemand()}");
    print("Renewable Supply: ${state.renewableSupply()}");
    print("Supply Shortage: ${state.supplyShortage()}");
    print("Future Supply Shortage: ${state.futureSupplyShortage(5)}");
    GameAction action = agent.chooseAction(state);
    print("Action: $action");
    if(state.isAgentEnabled)
      performAction(action);
    GameAction qaction = agent.chooseAction(state);
    print("QAction: $qaction");
    print("Solar: ${state.solarProduction}");
    print("Wind: ${state.windProduction}");
    print("Awareness: ${state.awareness}");
    print("Carbon Capture: ${state.carbonCapture}");
    print("Research Level: ${state.researchLevel}");
    print("Money after action: ${state.money}");
    print("PPM Added by Fossil Fuels: ${state.ppmAnnualyAddedByFossilFuels()}");
    print("Annual Carbon Capture: ${state.carbonCapture}");
    double increaseInPpm = state.ppmAnnualyAddedByFossilFuels() - state.carbonCapture;
    state.co2Level += increaseInPpm;
    print("CO2: ${state.co2Level}");
    double reward = -increaseInPpm;
    print("Reward: $reward");
    qagent.learn(oldState, action, reward, state);
    print("------------------------------------------------------");
  }
}