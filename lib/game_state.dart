import 'dart:math';
import 'utils.dart';

class GameState {
  double co2Level; // PPM (parts per million) CO2 in atmosphere
  int lapsedYears; // Years passed since start of game
  double solarProduction; // Solar panel and battery production for additional energy in PWh/year
  double windProduction; // Wind turbines and battery production for additional energy in PWh/year
  double awareness; // Million people fully aware of what needs to be done
  double money; // Budget in billion USD/year
  bool isGameOn;

  GameState({
    this.co2Level = 420,
    this.lapsedYears = 0,
    this.solarProduction = 2,
    this.windProduction = 1,
    this.awareness = 1,
    this.money = annualBudget,
    this.isGameOn = true,
  });

  double renewableSupply() {
    return solarProduction + windProduction + otherRenewableSources; 
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
      futureSupply += windProduction;
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
}