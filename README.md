# Black Death

An educational game built in Flutter about climate change and ways to prevent it.

## Development

To run the app in debug mode:

    flutter run

## Deployment (Firebase Hosting)

First time:

    flutter create --platforms=web .
    flutter build web

    firebase login
    firebase init
    firebase deploy

Subsequent times:

    flutter build web
    firebase deploy
