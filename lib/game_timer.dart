typedef YearCallback = void Function();
typedef AgentCallback = void Function();

class GameTimer {
  final YearCallback onYearPassed;
  final AgentCallback onAgentAction;
  bool _isActive = false;

  GameTimer({required this.onYearPassed, required this.onAgentAction});

  void start() {
    _isActive = true;
    _yearPassed();
    _agentAction();
  }

  void stop() {
    _isActive = false;
  }

  void _yearPassed() {
    if (!_isActive) return;
    Future.delayed(Duration(seconds: 1), () {
      onYearPassed();
      _yearPassed();
    });
  }

  void _agentAction() {
    if (!_isActive) return;
    Future.delayed(Duration(milliseconds: 250), () {
      onAgentAction();
      _agentAction();
    });
  }
}
