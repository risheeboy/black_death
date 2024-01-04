typedef YearCallback = void Function();
typedef PauseCheckCallback = bool Function();

class GameTimer {
  final YearCallback onYearPassed;
  bool _isActive = false;

  GameTimer({required this.onYearPassed});

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
      onYearPassed();
      _tick();
    });
  }
}
