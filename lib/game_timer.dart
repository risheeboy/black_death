typedef YearCallback = void Function();
typedef PauseCheckCallback = bool Function();

class GameTimer {
  final YearCallback onYearPassed;
  final PauseCheckCallback isGamePaused;
  bool _isActive = false;

  GameTimer({required this.onYearPassed, required this.isGamePaused});

  void start() {
    _isActive = true;
    _tick();
  }

  void stop() {
    _isActive = false;
  }

  void _tick() {
    if (!_isActive) return;
    Future.delayed(Duration(seconds: 1), () {
      if (!isGamePaused()) {
        onYearPassed();
      }
      _tick();
    });
  }
}
