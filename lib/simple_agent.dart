import 'game_state.dart';
import 'game_actions.dart';

class SimpleAgent {

  GameAction chooseAction(GameState state) {
    if(state.ppmAnnualyAddedByFossilFuels() > 0) {
      if(state.supplyShortage() > 0) {
        return GameAction.buildSolarFactory;
      } else {
        return GameAction.educateYouth;
      }
    } else return GameAction.doNothing;
  }
}