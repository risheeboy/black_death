import 'package:black_death/game_actions.dart';

// Constants that define the game engine behaviour 
const double energyDemand = 160; // Energy demand by humans in PWh/year
const double annualBudget = 15; // Budget in billion USD/year. 
const double co2LevelIdeal = 350; 
const double co2LevelMax = 450; 
const double annualCarbonCapture = 2; // PPM CO2 reduced due to carbon capture by nature
const double otherRenewableSources = 20; // Energy from other sources like hydro, geothermal etc
const double awarenessIndependentDemand = 50; // Independent demand, like grid
const double awarenessDemandFactor = 2; // Factor for calculating renewable demand
const double fossilFuelCO2Factor = 0.1; // Factor for calculating CO2 from fossil fuels
const double ppmCO2Factor = 0.5; // Factor for calculating PPM CO2 added to atmosphere
const Map<GameAction, double> capitalExpense = {
  GameAction.buildSolarFactory: 2,
  GameAction.buildWindFactory: 5,
  GameAction.educateYouth: 2,
  GameAction.doNothing: 0,
};