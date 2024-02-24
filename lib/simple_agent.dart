import 'dart:math';

import 'game_state.dart';
import 'utils.dart';

class SimpleAgent {

  GameAction chooseAction(GameState state) {
    double ppmToChange = co2LevelIdeal - state.co2Level;
    if(ppmToChange < -70) {
      if(state.ppmAnnualyAddedByFossilFuels() > 0) {
        if(state.supplyShortage() >= 0) {
          return pickRandomAction([
            GameAction.buildSolarFactory, 
            GameAction.buildSolarFactory, 
            GameAction.increaseResearch,
            //GameAction.carbonCapture,
            ]);
        } else { // Demand shortage
          return pickRandomAction([
            GameAction.increaseEducationBudget,
            //GameAction.decreaseFossilFuelUsage
            ]);
        }
      } else // No fossil fuel used anymore
      return pickRandomAction([
        GameAction.carbonCapture, 
        GameAction.increaseResearch,
        GameAction.decreaseEducationBudget,
        ]);
    } else { // reduction is too fast
      return pickRandomAction([
        GameAction.destroySolarFactory, 
        GameAction.increaseFossilFuelUsage,
        GameAction.decreaseEducationBudget,
        ]);
    }
  }
  // function to pick one of the given list of actions randomly
  GameAction pickRandomAction(List<GameAction> actions) {
    return actions[Random().nextInt(actions.length)];
  }
}
