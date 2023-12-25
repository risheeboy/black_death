
from firebase_functions.firestore_fn import (
  on_document_created,
  Event,
  DocumentSnapshot,
)
from firebase_functions.https_fn import (
  on_request,
  Request,
  Response,
)
from firebase_admin import initialize_app

initialize_app()

# trigger for document created event for action collection
@on_document_created(document="actions/{actionId}")
def on_action_created(event: Event[DocumentSnapshot]) -> None:
    print(event.change)
    print(event.document)
    # do something here
    pass

# http request for training the agent
@on_request()
def train_agent(req: Request) -> Response:
    req_json = req.get_json()
    #hash = req.args.get("hash")
    print(req_json)
    # do training here
    return Response("Training Complete")
