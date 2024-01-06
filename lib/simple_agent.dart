import 'dart:math';

import 'game_actions.dart';
import 'game_state.dart';
import 'utils.dart';

class SimpleAgent {

  GameAction chooseAction(GameState state) {
    double ppmToChange = co2LevelIdeal - state.co2Level;
    // double relativeChangeRate = state.lastPpmIncrease / ppmToChange; // TODO handle divide by zero
    // print("PPM to change: $ppmToChange. Relative Change Rate: $relativeChangeRate");
    // if(0.1 < relativeChangeRate) {
    //   print("On track, with last increase: ${state.lastPpmIncrease} and ppm to change: $ppmToChange");
    //   return GameAction.doNothing;
    // }
    if(ppmToChange < -70) {
      if(state.ppmAnnualyAddedByFossilFuels() > 0) {
        if(state.supplyShortage() > 0) {
          return pickRandomAction([
            GameAction.buildSolarFactory, 
            GameAction.increaseResearch,
            //GameAction.buildWindFactory,
            //GameAction.carbonCapture,
            ]);
        } else { // Demand shortage
          return pickRandomAction([
            GameAction.increaseEducationBudget,
            GameAction.decreaseFossilFuelUsage
            ]);
        }
      } else // No fossil fuel used anymore
      return pickRandomAction([
        GameAction.carbonCapture, 
        GameAction.increaseResearch
        ]);
    } else { // reduction is too fast
      return pickRandomAction([
        GameAction.destroySolarFactory, 
        GameAction.increaseFossilFuelUsage,
        ]);
    }
  }
  // function to pick one of the given list of actions randomly
  GameAction pickRandomAction(List<GameAction> actions) {
    return actions[Random().nextInt(actions.length)];
  }
}
