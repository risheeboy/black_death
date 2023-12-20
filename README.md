# Black Death

An educational game built in Flutter about climate change and ways to prevent it.

## Development

Pre-requisites:

- [Flutter](https://flutter.dev/docs/get-started/install)

To run the app in debug mode:

    flutter run

### Deployment (Firebase Hosting)

First deployment:

    flutter create --platforms=web .
    flutter build web

    firebase login
    firebase init
    firebase deploy

Subsequent deployments:

    flutter build web
    firebase deploy
