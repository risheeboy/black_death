import 'dart:async';
import 'dart:math';

import 'game_actions.dart';
import 'game_state.dart';
import 'utils.dart';

class SimpleAgent {
  Timer? timer;

  void start() {
    timer = Timer.periodic(
      Duration(milliseconds: 200), // 1000 milliseconds divided by 5 gives us 200 milliseconds, which is 5 times per second
      (Timer t) => chooseAction(GameState()),
    );
  }
  GameAction chooseAction(GameState state) {
    double ppmToChange = co2LevelIdeal - state.co2Level;
    print("PPM to change: $ppmToChange");
    double relativeChangeRate = state.lastPpmIncrease / ppmToChange; // TODO handle divide by zero
    print("Relative Change Rate: $relativeChangeRate");
    // if(0.1 < relativeChangeRate) {
    //   print("On track, with last increase: ${state.lastPpmIncrease} and ppm to change: $ppmToChange");
    //   return GameAction.doNothing;
    // }
    if(ppmToChange < -50) {
      if(state.ppmAnnualyAddedByFossilFuels() > 0) {
        if(state.supplyShortage() > 0) {
          return pickRandomAction([
            GameAction.buildSolarFactory, 
            GameAction.buildWindFactory,
            ]);
        } else {
          return GameAction.educateYouth;
        }
      } else 
      return pickRandomAction([GameAction.carbonCapture, GameAction.increaseResearch]);
    } else {
      return pickRandomAction([GameAction.destroySolarFactory, GameAction.destroyWindFactory]);
    }
  }
  // function to pick one of the given list of actions randomly
  GameAction pickRandomAction(List<GameAction> actions) {
    return actions[Random().nextInt(actions.length)];
  }
  void stop() {
    timer?.cancel();
  }
}
