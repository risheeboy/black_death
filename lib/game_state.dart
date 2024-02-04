import 'dart:math';
import 'run_state.dart';
import 'utils.dart';

class GameState {
  double co2Level; // PPM (parts per million) CO2 in atmosphere
  int lapsedYears; // Years passed since start of game
  int solarProduction; // Solar panel and battery production for additional energy in PWh/year
  double awareness; // Million people fully aware of what needs to be done
  double carbonCapture; // PPM CO2 reduced due to carbon capture by nature
  double money; // Budget in billion USD/year
  RunState runState;
  int consecutiveYearsInRange;
  double researchLevel;
  double lastPpmIncrease;
  int education_budget;
  double fossilFuelProduction; // Fossil fuel production in PWh/year

  GameState({
    this.co2Level = 420,
    this.lapsedYears = 0,
    this.solarProduction = 2,
    this.fossilFuelProduction = 131,
    this.awareness = 1,
    this.carbonCapture = 6,
    this.money = annualBudget,
    this.runState = RunState.Running,
    this.researchLevel = 1.0,
    this.consecutiveYearsInRange = 0,
    this.lastPpmIncrease = 0,
    this.education_budget = 0,
  });

  GameState.clone(GameState source)
    : co2Level = source.co2Level,
      lapsedYears = source.lapsedYears,
      solarProduction = source.solarProduction,
      awareness = source.awareness,
      carbonCapture = source.carbonCapture,
      money = source.money,
      runState = source.runState,
      researchLevel = source.researchLevel,
      fossilFuelProduction = source.fossilFuelProduction,
      consecutiveYearsInRange = source.consecutiveYearsInRange,
      lastPpmIncrease = source.lastPpmIncrease,
      education_budget = source.education_budget;


  bool isGameOver() {
    return runState.index > RunState.Paused.index;
  }
  double renewableSupply() {
    return solarProduction + otherRenewableSources; 
  }

  double renewableDemand() {
    return (awareness * awarenessDemandFactor) + awarenessIndependentDemand; 
  }

  double supplyShortage() {// Current supply shortage in PWh/year
    return renewableDemand() - renewableSupply();
  }

  double futureSupplyShortage(int years) { // Future supply shortage in PWh/year
    double futureDemand = renewableDemand();
    double futureSupply = renewableSupply();
    for (int i = 0; i < years; i++) {
      // TODO consider the time it takes to build factories / educate
      futureSupply += solarProduction;
      futureDemand += awareness * awarenessDemandFactor;
    }
    return futureDemand - futureSupply;
  }

  double ppmAnnualyAddedByFossilFuels() { 
    double renewableUse = max(renewableSupply() , renewableDemand()); // PWh/year (Petawatt hours
    double energyFromFossilFuels = max(energyDemand - renewableUse, 0); // Energy supply required by fossil fuels in PWh/year
    double addedToAtmosphere = energyFromFossilFuels * fossilFuelCO2Factor; // CO2 in billion metric tons/year 
    return addedToAtmosphere * ppmCO2Factor; // PPM CO2 added to atmosphere
  }

  Map<String, dynamic> toFireStoreDoc() => {
    'co2Level': co2Level,
    'renewableSupply': renewableSupply(),
    'renewableDemand': renewableDemand(),
  };

  String compressed() {
    return "${(co2Level/10).round()}_${(renewableDemand()/10).round()}_${(renewableSupply()/10).round()}";
  }
}