import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'game_state.dart';
import 'rule.dart';
import 'utils.dart';

class CustomSidekick {

  List<Rule>? rules;
  late String _sessionId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CustomSidekick() {
    SharedPreferences.getInstance().then((prefs) {
      String? retrieved = prefs.getString('sessionId');
      if (retrieved == null) {
        _sessionId = const Uuid().v4();
        prefs.setString('sessionId', _sessionId);
        print('New sessionId: $_sessionId');
      } else {
        _sessionId = retrieved;
        print('Retrieved sessionId: $_sessionId');
        rules = loadRules();
      }
    });
  }

  GameAction chooseAction(GameState state) {
    Map<StateVariable, double> stateVariables = {
      StateVariable.CO2Level: state.co2Level,
      StateVariable.Budget: state.money,
      StateVariable.CarbonCapture: state.carbonCapture,
      StateVariable.RenewableProduction: state.renewableSupply(),
      StateVariable.FossilFuelConsumption: state.fossilFuelProduction,
    };
    return executeRules(stateVariables);
  }

  GameAction executeRules(Map<StateVariable, double> stateVariables) {
    for (var rule in rules ?? []) {
      bool conditionsMet = true;

      for (var condition in rule.conditions) {
        double? stateVariableValue = stateVariables[condition.stateVariable];
        if(stateVariableValue == null) {
          conditionsMet = false;
          break;
        }
        switch (condition.comparator) {
          case Comparator.LessThan:
            conditionsMet = stateVariableValue < condition.value;
            break;
          case Comparator.LessThanOrEqual:
            conditionsMet = stateVariableValue <= condition.value;
            break;
          case Comparator.Equal:
            conditionsMet = stateVariableValue == condition.value;
            break;
          case Comparator.GreaterThan:
            conditionsMet = stateVariableValue > condition.value;
            break;
          case Comparator.GreaterThanOrEqual:
            conditionsMet = stateVariableValue >= condition.value;
            break;
        }
        if (!conditionsMet)
          break;
      }

      if (conditionsMet) {
        return rule.playerAction;
      }
    }
    return GameAction.doNothing;
  }

  List<Rule>? loadRules() {
    _firestore.collection('rules').where('sessionId', isEqualTo: _sessionId).orderBy('currentTime', descending: true).limit(1).get().then((snapshot) {
      if (snapshot.docs.isEmpty) {
        print('No existing rules for sessionId: $_sessionId');
      } else {
        List<dynamic> rulesData = snapshot.docs.first.data()['rules'];
        print('Found rules: $rulesData');
        rules = rulesData.map((json) => Rule.fromJson(json)).toList();
      }
    });
    return rules;
  }
  
  void saveRules(List<Rule> ruleList) {
    print('Saving rules');
    this.rules = ruleList;
    final rulesJson = ruleList.map((rule) => rule.toJson()).toList();
    final currentTime = DateTime.now();
    final newRecord = _firestore.collection('rules').doc();
    newRecord.set({
      'rules': rulesJson,
      'sessionId': _sessionId,
      'currentTime': currentTime,
    });
  }
}
