import 'package:flutter/material.dart';

import 'game_state.dart';
import 'game_actions.dart';
import 'dart:async';


class SimpleAgent {
  Timer? timer;

  void start() {
    timer = Timer.periodic(
      Duration(milliseconds: 200), // 1000 milliseconds divided by 5 gives us 200 milliseconds, which is 5 times per second
      (Timer t) => chooseAction(GameState()),
    );
  }
  GameAction chooseAction(GameState state) {
    if(state.ppmAnnualyAddedByFossilFuels() > 0) {
      if(state.supplyShortage() > 0) {
        if (state.co2Level > 350) {
          if(state.solarProduction > state.windProduction) {
            return GameAction.buildWindFactory;
          } else {
            return GameAction.buildSolarFactory;
          }
          
      } else {
          if(state.solarProduction > state.windProduction) {
            return GameAction.destroySolarFactory;
          } else {
            return GameAction.destroyWindFactory;
          }
        }
      } else {
          return GameAction.educateYouth;
      }
    } else return GameAction.doNothing;
  }
  void stop() {
    timer?.cancel();
  }
}
