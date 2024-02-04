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
