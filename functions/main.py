from firebase_functions.https_fn import (
  on_request,
  Request,
  Response,
)
from firebase_admin import initialize_app, firestore

initialize_app()

# http request for training the agent
@on_request()
def qvalues(req: Request) -> Response:
  db = firestore.client()
  alpha = 0.1 # learning rate
  gamma = 0.9 # discount factor

  q_table = {}
  for a in db.collection("actions").stream(): # TODO filter by version
    action = a.get('actionName')
    state = _compressed_state(a.get('onState'))
    next_state = _compressed_state(a.get('nextState'))
    reward = a.get('reward')

    # initialize q_table
    if state not in q_table:
      q_table[state] = {}
    if action not in q_table[state]:
      q_table[state][action] = float('-inf')
    if next_state not in q_table:
      q_table[next_state] = {}
    if action not in q_table[next_state]:
      q_table[next_state][action] = float('-inf')

    # Q-learning
    old_value = q_table[state][action]
    next_max = max(q_table[next_state].values())
    new_value = (1 - alpha) * old_value + alpha * (reward + gamma * next_max)
    q_table[state][action] = new_value

  # batch commit QValues to firestore
  batch = db.batch()
  for state, actions in q_table.items():
    for action, value in actions.items():
      batch.set(db.collection("qvalues").document(
        f"{state}_{action}"), {"state": state, "action": action, "qvalue": value})
  batch.commit()
  print("Q-values stored in Firestore.")
  return Response(status=200)

# helper function to compressed state
def _compressed_state(state_map):
  # Compress state (reduce the number of combinations) by dividing floats by 10 and rounding
  co2 = round(state_map.get('co2Level') / 10)
  demand = round(state_map.get('renewableDemand') / 10)
  supply = round(state_map.get('renewableSupply') / 10)
  return f"{co2}_{supply}_{demand}"
