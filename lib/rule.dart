import 'utils.dart';

class Rule {
  List<Condition> conditions = [];
  GameAction playerAction;

  Rule(this.playerAction);
  Rule.withConditions(this.playerAction, this.conditions);

  factory Rule.fromJson(Map<dynamic, dynamic> json) {
    print('Rule.fromJson: $json' );
    print(json['playerAction']);
    var playerAction = GameAction.values.firstWhere((e) => e.toString() == json['playerAction']);
    var conditionsJson = json['conditions'] as List<dynamic>;
    var conditions = conditionsJson.map((json) => Condition.fromJson(json)).toList();
    return Rule.withConditions(playerAction, conditions);
  }

  Map<String, dynamic> toJson() {
    return {
      'playerAction': playerAction.toString(),
      'conditions': conditions.map((c) => c.toJson()).toList(),
    };
  }
}

class Condition {
  StateVariable stateVariable;
  Comparator comparator;
  double value;

  Condition(this.stateVariable, this.comparator, this.value);

  factory Condition.fromJson(Map<dynamic, dynamic> json) {
    var stateVariable = StateVariable.values.firstWhere((e) => e.toString() == json['stateVariable']);
    var comparator = Comparator.values.firstWhere((e) => e.toString() == json['comparator']);
    var value = json['value'] as double;
    return Condition(stateVariable, comparator, value);
  }

  Map<String, dynamic> toJson() {
    return {
      'stateVariable': stateVariable.toString(),
      'comparator': comparator.toString(),
      'value': value,
    };
  }
}

enum StateVariable { CO2Level, FossilFuelProduction, CarbonCapture, Budget, AnnualPpmIncrease, RenewableSupplyShortage, EducationBudget }

enum Comparator { LessThanOrEqual, LessThan, Equal, GreaterThan, GreaterThanOrEqual }

extension ComparatorName on Comparator {
  String get formattedName {
    switch (this) {
      case Comparator.LessThanOrEqual:
        return '<=';
      case Comparator.LessThan:
        return '<';
      case Comparator.Equal:
        return '=';
      case Comparator.GreaterThan:
        return '>';
      case Comparator.GreaterThanOrEqual:
        return '>=';
      default:
        return '';
    }
  }
}

List<Rule> defaultRules() {
  List<Rule> defaultRules = [];
  defaultRules.add(Rule.withConditions(GameAction.buildSolarFactory, [
    Condition(StateVariable.CO2Level, Comparator.GreaterThan, 400),
    Condition(StateVariable.AnnualPpmIncrease, Comparator.GreaterThan, 0),
    Condition(StateVariable.RenewableSupplyShortage, Comparator.GreaterThan, 0),
  ]));
  defaultRules.add(Rule.withConditions(GameAction.increaseEducationBudget, [
    Condition(StateVariable.CO2Level, Comparator.GreaterThan, 400),
    Condition(StateVariable.AnnualPpmIncrease, Comparator.GreaterThan, 0),
    Condition(StateVariable.RenewableSupplyShortage, Comparator.LessThanOrEqual, 0),
  ]));
  defaultRules.add(Rule.withConditions(GameAction.decreaseEducationBudget, [
    Condition(StateVariable.CO2Level, Comparator.LessThan, 420),
    Condition(StateVariable.AnnualPpmIncrease, Comparator.LessThanOrEqual, 0),
    Condition(StateVariable.EducationBudget, Comparator.GreaterThan, 0),
  ]));
  return defaultRules;
}
