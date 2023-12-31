import 'dart:math';

import 'package:black_death/game_actions.dart';

// Constants that define the game engine behaviour 
const double annualBudget = 4; // Budget in billion USD/year. 
const double energyDemand = 160; // Energy demand by humans in PWh/year
const double co2LevelIdeal = 350; 
const double co2LevelMax = 450; 
const double co2LevelMin = 250; 
const double otherRenewableSources = 20; // Energy from other sources like hydro, geothermal etc
const double awarenessIndependentDemand = 20; // Independent demand, like grid
const double awarenessDemandFactor = 2; // Factor for calculating renewable demand
const double fossilFuelCO2Factor = 0.1; // Factor for calculating CO2 from fossil fuels
const double ppmCO2Factor = 0.5; // Factor for calculating PPM CO2 added to atmosphere
const double educationBudgetFactor = 0.1; // Factor for calculating education budget
const double yearsToWin = 200; // Years to win the game
final int gameInstance = Random().nextInt(1000000000);

const Map<GameAction, double> capitalExpense = {
  GameAction.buildSolarFactory: 2,
  GameAction.increaseFossilFuelUsage: 1,
  GameAction.carbonCapture: 8,
  GameAction.increaseResearch: 5,
  GameAction.destroySolarFactory: 1,
  GameAction.decreaseFossilFuelUsage: 1,
  GameAction.doNothing: 0,
};