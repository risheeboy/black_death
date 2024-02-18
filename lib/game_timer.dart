import 'utils.dart';
import 'game_manager.dart';
typedef YearCallback = void Function();
typedef AgentCallback = void Function();

class GameTimer {
  final YearCallback onYearPassed;
  final AgentCallback onAgentAction;
  GameManager gameManager;

  GameTimer({required this.onYearPassed, required this.onAgentAction, required this.gameManager});

  void start() {
    _yearPassed();
    _agentAction();
  }

  void _yearPassed() {
    if (gameManager.state.runState != RunState.Running) {
      return;
    }
    Future.delayed(Duration(seconds: 1), () {
      onYearPassed();    
      if ((gameManager.state.co2Level > 430 || gameManager.state.co2Level < 270) && 
          (gameManager.state.lapsedYears % (5-gameManager.frequencyOfNaturalDisastor)).round() == 0) {
        gameManager.takeAction(GameAction.naturalDisaster, onNaturalDisaster: () {
          gameManager.state.isDisasterHappening = true;
          
          Future.delayed(Duration(seconds: 1), () {
            gameManager.state.isDisasterHappening = false;
          });
        });
      }
      _yearPassed();
    });
  }

  void _agentAction() {
    if (gameManager.state.runState != RunState.Running) {
      return;
    }    
    Future.delayed(Duration(milliseconds: 250), () {
      onAgentAction();
      _agentAction();
    });
  }
}