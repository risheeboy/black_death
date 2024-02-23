# Black Death

An educational game built in Flutter about climate change and ways to prevent it

This game introduces the concepts:
1. A rule-based sidekick that you can configure to play along/for you
2. Games played cotribute to a central AI, which gets better (in solving the problem) with each game played

## Hosted

[bucky.games](https://bucky.games)

## Architecture

```mermaid
graph TD
    Player -->|Action| Game[Game Environment]
    Player -->|Sidekick Rules Setup| Setup[Setup Page]
    Setup --> Rules[Sidekick Rules]
    RulesAgent[Sidekick Rules] -->|Action| Game
    AIAgent[AI Sidekick] -->|Action| Game
    Rules -->|Player's Rules| RulesAgent
    Game -->|Batch store actions and states| Gameplay[Gameplay History]
    Timer[State Timer] -->|State Evaluation| Game
    Gameplay --> Trainer[AI Training/Q-Learning]
    Trainer --> QTable[AI Agent/Q-Table]
    QTable -->|Best Action for State| AIAgent

    subgraph Google Firestore 
    Rules
    Gameplay
    QTable
    end

    subgraph Flutter App on Firebase Hosting
    Game
    RulesAgent
    AIAgent
    Setup
    Timer
    end

    subgraph Google Cloud Functions 
    Trainer
    end
```

## Development

Pre-requisite:

- [Flutter](https://flutter.dev/docs/get-started/install) which comes with Dart
- [FlutterFire](https://firebase.flutter.dev/docs/overview#installation) to create lib/firebase_options.dart for connecting with your firebase project

To run the app in debug mode:

    flutter run

## Deployment (Firebase Hosting)

Pre-requisite:

- [Firebase CLI](https://firebase.google.com/docs/cli)

First deployment:

    flutter create --platforms=web .
    flutter build web

    firebase login
    firebase init
    firebase deploy

Subsequent deployments:

    flutter build web
    firebase deploy

## Upcoming Updates

- AI Sidekick to handle states not seen before
- Environment to be realistic (e.g. renewables maintenance/replacement)