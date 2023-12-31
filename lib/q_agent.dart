import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'game_state.dart';
import 'game_actions.dart';

class QAgent {
  GameAction chooseAction(GameState state) {
    Query query = FirebaseFirestore.instance
      .collection('qvalues')
      .where('state', isEqualTo: state.compressed())
      .orderBy('qvalue', descending: true)
      .limit(1);

    query.get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        String actionName = doc.get('action');
        print("Best action by QValue, for state $state is $actionName");
        return GameAction.values.byName(actionName);
      } else {
        print('No QValue found with state ${state.compressed()}');
      }
    });
    return GameAction.values[Random().nextInt(GameAction.values.length)];
  }
}