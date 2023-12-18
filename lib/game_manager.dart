import 'game_state.dart';
import 'game_actions.dart';
import 'utils.dart';
//import 'q_learning_agent.dart';
import 'simple_agent.dart';

class GameManager {
  GameState state;
  //QLearningAgent agent;
  SimpleAgent agent;

  GameManager(this.state, this.agent);

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
      // TODO - Implement carbon capture
    } else {
      // Do nothing
    }
  }

  void updateGameState() {
    state.lapsedYears++;
    print("Year: ${state.lapsedYears}");
    state.money += annualBudget;
    print("Money: ${state.money}");
    if(state.isAgentEnabled) {
      GameAction action = agent.chooseAction(state);
      print("Action: $action");
      performAction(action);
    }
    print("Solar: ${state.solarProduction}");
    print("Wind: ${state.windProduction}");
    print("Awareness: ${state.awareness}");
    print("Money: ${state.money}");
    print("------------");
    print("PPM Added by Fossil Fuels: ${state.ppmAnnualyAddedByFossilFuels()}");
    print("Annual Carbon Capture: $annualCarbonCapture");
    state.co2Level += state.ppmAnnualyAddedByFossilFuels() - annualCarbonCapture;
    print("CO2: ${state.co2Level}");
    print("------------");
    print("Renewable Demand: ${state.renewableDemand()}");
    print("Renewable Supply: ${state.renewableSupply()}");
    print("Supply Shortage: ${state.supplyShortage()}");
    print("Future Supply Shortage: ${state.futureSupplyShortage(5)}");
    print("------------------------------------------------------");

  }
}