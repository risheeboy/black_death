import 'package:flutter_test/flutter_test.dart';
import 'package:black_death/utils.dart';
import 'package:black_death/rule.dart';

void main() {
  group('Condition', () {
    test('can be created from JSON', () {
      var json = {
        'stateVariable': StateVariable.CO2Level.toString(),
        'comparator': Comparator.GreaterThan.toString(),
        'value': 350.0,
      };

      var condition = Condition.fromJson(json);

      expect(condition.stateVariable, StateVariable.CO2Level);
      expect(condition.comparator, Comparator.GreaterThan);
      expect(condition.value, 350.0);
    });

    test('can be converted to JSON', () {
      var condition = Condition(StateVariable.CO2Level, Comparator.GreaterThan, 350.0);

      var json = condition.toJson();

      expect(json['stateVariable'], StateVariable.CO2Level.toString());
      expect(json['comparator'], Comparator.GreaterThan.toString());
      expect(json['value'], 350.0);
    });
  });

  group('Rule', () {
    test('can be created from JSON', () {
      var json = {
        'playerAction': GameAction.buildSolarFactory.toString(),
        'conditions': [
          {
            'stateVariable': StateVariable.CO2Level.toString(),
            'comparator': Comparator.GreaterThan.toString(),
            'value': 350.0,
          },
        ],
      };

      var rule = Rule.fromJson(json);

      expect(rule.playerAction, GameAction.buildSolarFactory);
      expect(rule.conditions.length, 1);
      expect(rule.conditions[0].stateVariable, StateVariable.CO2Level);
      expect(rule.conditions[0].comparator, Comparator.GreaterThan);
      expect(rule.conditions[0].value, 350.0);
    });

    test('can be converted to JSON', () {
      var condition = Condition(StateVariable.CO2Level, Comparator.GreaterThan, 350.0);
      var rule = Rule.withConditions(GameAction.buildSolarFactory, [condition]);

      var json = rule.toJson();

      expect(json['playerAction'], GameAction.buildSolarFactory.toString());
      expect(json['conditions'].length, 1);
      expect(json['conditions'][0]['stateVariable'], StateVariable.CO2Level.toString());
      expect(json['conditions'][0]['comparator'], Comparator.GreaterThan.toString());
      expect(json['conditions'][0]['value'], 350.0);
    });
  });
}