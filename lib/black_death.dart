import 'dart:math';

import 'package:black_death/game_actions.dart';
import 'package:black_death/run_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'game_manager.dart';
import 'game_state.dart';
import 'game_timer.dart';
import 'q_agent.dart';
import 'simple_agent.dart';
import 'utils.dart';
import 'agent_screen.dart';

final co2Data = [];



class BlackDeath extends StatefulWidget {
  @override
  _BlackDeathAppState createState() => _BlackDeathAppState();
}

class StartScreen extends StatelessWidget {
  final VoidCallback onStartGame;

  const StartScreen({Key? key, required this.onStartGame}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue[50], // Light background color
          image: DecorationImage(
            image: AssetImage('images/background.jpg'), // Background image
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.5), BlendMode.dstATop), // Transparancy of the image
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // For scrolling
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '''How to Play:
Start and Progression:

Engage in a real-time strategy experience where every decision impacts the game world.
Your primary objective is to balance CO2 levels.

Decision-Making:
Choose from a range of actions: build renewable energy factories, manage fossil fuel usage, and allocate funds for climate education.
Every action has a direct effect on resources, CO2 levels, and the game's environment.

Resource Allocation:
Strategically allocate your budget between various environmental actions.
Balancing your budget is crucial for sustainable progress.

Research and Development:
Invest in research to unlock new capabilities and enhance your strategy.
Research decisions impact your budget and environmental outcomes.

Real-Time Feedback:
Watch the immediate impact of your decisions through visual indicators like charts and progress bars.
Adapt your strategy based on ongoing feedback from the game environment.

Interactive Learning:
Engage with trivia questions throughout the game to earn rewards and enhance your understanding of climate issues.

End Game:
The game concludes based on your ability to stabilize CO2 levels over a period.
Different endings reflect the success or failure of your environmental strategies.

Why Play Black Death?
Educational and Fun: Learn about climate management while enjoying a strategic gaming experience.
Real-World Application: Gain insights into real-world environmental challenges and management strategies.''', // Instructions
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87, // Text color
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onStartGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 97, 160, 94), // Button color
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text('Start Game', style: TextStyle(fontSize: 16, color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BlackDeathAppState extends State<BlackDeath> {
  late GameManager gameManager;
  late GameTimer gameTimer;
  bool isGameStarted = false;
  bool isGamePaused = false;

  void startGame() {
    setState(() {
      isGameStarted = true;
      GameState state = GameState();
      gameManager = GameManager(state, SimpleAgent(), QAgent());
      gameTimer = GameTimer(
        onYearPassed: () {
          // Timer logic here
          setState(() {
            gameManager.updateGameState();
            if (state.isGameOver()) {
              _gameOver(state);
              gameTimer.stop();
            }
            co2Data.add(ChartPoint(state.lapsedYears, state.co2Level));
          });
        },
        onAgentAction: () {
          setState(() {
            gameManager.agentAction();
          });
        },
        gameManager: gameManager,
      );
      gameTimer.start();
    });
  }


  @override
  Widget build(BuildContext context) {
    return isGameStarted ? buildGameScreen() : StartScreen(onStartGame: startGame);
  }

  Widget buildGameScreen() {
    GameState state = gameManager.state;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isGamePaused ? Icons.play_arrow : Icons.pause),
            iconSize: 50,
            color: Color(0xFF858585),
            onPressed: () {
              if (isGamePaused) {
                resumeGame();
              } else {
                pauseGame();
              }
            },
          ),
        ],
        backgroundColor: Color.fromARGB(255, 75, 57, 239),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '🗲 Black Death 🗲',
                textAlign: TextAlign.start,
                style: TextStyle(
                      fontFamily: 'Outfit',
                      color: Colors.white,
                      fontSize: 22,
                    ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.smart_toy),
              color: Color(0xFF858585),
              onPressed: () {
                pauseGame(); // Pause the game timer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AgentScreen(title: 'Configure Agent',)),
                );
              },
              iconSize: 35,
            ),
            Switch(
              value: state.isAgentEnabled,
              onChanged: (value) {
                setState(() {
                  state.isAgentEnabled = value;
                });
              },
            ),
          ],
        ),
        centerTitle: false,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/earth_smoke.png"),
            fit: BoxFit.cover,
            // transparancy of the image
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.2), BlendMode.dstATop),
          )
        ),
      child: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Wrap(
              spacing: 0,
              runSpacing: 0,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              direction: Axis.horizontal,
              runAlignment: WrapAlignment.start,
              verticalDirection: VerticalDirection.down,
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.solar_power_rounded,
                        color: Color.fromARGB(255, 149, 161, 172),
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Renewable Energy Production',
                              child: Text('Renewable', style: TextStyle(fontSize: 14)),
                            ),
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: IconButton(
                                padding: EdgeInsets.zero, // remove default padding
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Renewable Energy Production", style: TextStyle(fontSize: 14)),
                                      content: Text(
                                          "Renewable energy production is the process of generating electricity from renewable energy sources. It is a key action to reduce CO2 levels.", 
                                          style: TextStyle(fontSize: 12),
                                          ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: Icon(Icons.info_outline, size: 20), // you can also adjust the size of the icon here
                              ),
                            )                                                                                                                                                                                                                                                 ,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: IconButton.filledTonal(
                          padding: EdgeInsets.zero,
                          color: Color.fromARGB(255, 75, 57, 239),
                          icon: Icon(
                            Icons.remove,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 15,
                          ),
                          onPressed: () => gameManager.takeAction(GameAction.destroySolarFactory)
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                        child: Text(
                          state.solarProduction.toString(),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: IconButton.filledTonal(
                          padding: EdgeInsets.zero,
                          color: Color.fromARGB(255, 75, 57, 239),
                          icon: Icon(
                            Icons.add,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 15,
                          ),
                          onPressed: () => gameManager.takeAction(GameAction.buildSolarFactory)
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.factory_rounded,
                        color: Color.fromARGB(255, 149, 161, 172),
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Fossil Fuel Usage',
                              child: Text('Fossil Fuel', style: TextStyle(fontSize: 14)),
                            ),
                            SizedBox(
                              height: 30,
                              width: 30,
                              child: IconButton(
                                padding: EdgeInsets.zero, // remove default padding
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Fossil Fuel Usage", style: TextStyle(fontSize: 14)),
                                      content: Text(
                                          "Renewable energy production is the process of generating electricity from renewable energy sources. It is a key action to reduce CO2 levels.", 
                                          style: TextStyle(fontSize: 12),
                                          ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: Icon(Icons.info_outline, size: 20), // you can also adjust the size of the icon here
                              ),
                            )                                                                                                                                                                                                                                                 ,
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: IconButton.filledTonal(
                          padding: EdgeInsets.zero,
                          color: Color.fromARGB(255, 75, 57, 239),
                          icon: Icon(
                            Icons.remove,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 15,
                          ),
                          onPressed: () => gameManager.takeAction(GameAction.decreaseFossilFuelUsage)
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                        child: Text(
                          state.fossilFuelProduction.toString(),
                          style: TextStyle(  fontSize: 14),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: IconButton.filledTonal(
                          padding: EdgeInsets.zero,
                          color: Color.fromARGB(255, 75, 57, 239),
                          icon: Icon(
                            Icons.add,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 15,
                          ),
                          onPressed: () => gameManager.takeAction(GameAction.increaseFossilFuelUsage)
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        color: Color.fromARGB(255, 149, 161, 172),
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 12, 0),
                        child: Text(
                          'Climate Education Budget',
                          style: TextStyle(  fontSize: 14),
                        ),
                      ),
                      IconButton.filledTonal(
                        color: Color.fromARGB(255, 75, 57, 239),
                        icon: Icon(
                          Icons.remove,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 15,
                        ),
                        onPressed: () => gameManager.takeAction(GameAction.decreaseEducationBudget), 
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                        child: Text(
                          state.education_budget.toString(),
                          style: TextStyle(  fontSize: 14),
                        ),
                      ),
                      IconButton.filledTonal(
                        color: Color.fromARGB(255, 75, 57, 239),
                        icon: Icon(
                          Icons.add,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 15,
                        ),
                        onPressed: () => gameManager.takeAction(GameAction.increaseEducationBudget),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 5, 20, 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.science_outlined,
                        color: Color.fromARGB(255, 149, 161, 172),
                        size: 24,
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 12, 0),
                        child: Text(
                          'Climate Research',
                          style: TextStyle(  fontSize: 14),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                        child: Text(
                          '4',
                          style: TextStyle(  fontSize: 14),
                        ),
                      ),
                      IconButton.filledTonal(
                        color: Color.fromARGB(255, 75, 57, 239),
                        icon: Icon(
                          Icons.add,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 15,
                        ),
                        onPressed: () => gameManager.takeAction(GameAction.increaseResearch),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 1,
              color: Color.fromARGB(204, 255, 255, 255),
            ),
            Align(
              alignment: AlignmentDirectional(0, 0),
              child: Card(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                color: Color.fromARGB(255, 254, 255, 255),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Wrap(
                    spacing: 0,
                    runSpacing: 0,
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    direction: Axis.horizontal,
                    runAlignment: WrapAlignment.start,
                    verticalDirection: VerticalDirection.down,
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Icon(
                                Icons.co2,
                                color: Color.fromARGB(255, 149, 161, 172),
                                size: 24,
                              ),
                            ),
                            Text(
                              state.co2Level.round().toString(),
                              style: TextStyle(fontSize: 14),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                'PPM',
                                style:
                                    TextStyle(fontSize: 14),
                              ),
                            ),
                            LinearPercentIndicator(
                              percent: min(state.co2Level, co2LevelMax)/(co2LevelMax),
                              width: 80,
                              lineHeight: 6,
                              animation: true,
                              animateFromLastPercent: true,
                              progressColor: Color(0xFF02AB00),
                              backgroundColor: Color.fromARGB(181, 255, 255, 255),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Icon(
                                Icons.timer_sharp,
                                color: Color.fromARGB(255, 149, 161, 172),
                                size: 24,
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                'Year',
                                style:
                                    TextStyle(  fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                state.lapsedYears.toString(),
                                style:
                                    TextStyle(  fontSize: 14),
                              ),
                            ),
                            LinearPercentIndicator(
                              percent: min(state.lapsedYears, yearsToWin)/yearsToWin, //TODO set gameover when passed yeards
                              width: 80,
                              lineHeight: 6,
                              animation: true,
                              animateFromLastPercent: true,
                              progressColor: Color(0xFF02AB00),
                              backgroundColor: Color(0xB5ADADAD),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Icon(
                                Icons.solar_power_rounded,
                                color: Color.fromARGB(255, 149, 161, 172),
                                size: 24,
                              ),
                            ),
                            LinearPercentIndicator(
                              percent: state.solarProduction/(state.solarProduction + state.fossilFuelProduction),
                              width: 80,
                              lineHeight: 6,
                              animation: true,
                              animateFromLastPercent: true,
                              progressColor: Color(0xFF02AB00),
                              backgroundColor: Color(0xB5ADADAD),
                              padding: EdgeInsets.zero,
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                              child: Icon(
                                Icons.factory_rounded,
                                color: Color.fromARGB(255, 149, 161, 172),
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                'Budget',
                                style:
                                    TextStyle(  fontSize: 14),
                              ),
                            ),
                            Icon(
                              Icons.attach_money_sharp,
                              color:
                                  Color.fromARGB(255, 149, 161, 172),
                              size: 20,
                            ),
                            Text(
                              state.money.toStringAsFixed(2),
                              style: TextStyle(  fontSize: 14),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                ' B',
                                style:
                                    TextStyle(  fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.electrical_services,
                              color:
                                Color.fromARGB(255, 149, 161, 172),
                              size: 20,
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                'Demand',
                                style:
                                    TextStyle(  fontSize: 14),
                              ),
                            ),
                            Text(
                              state.renewableDemand().toStringAsFixed(2),
                              style: TextStyle(  fontSize: 14),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                ' TWh',
                                style:
                                    TextStyle(  fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.energy_savings_leaf_outlined,
                              color:
                                Color.fromARGB(255, 149, 161, 172),
                              size: 20,
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                'Supply',
                                style:
                                    TextStyle(  fontSize: 14),
                              ),
                            ),
                            Text(
                              state.renewableSupply().toStringAsFixed(2),
                              style: TextStyle(  fontSize: 14),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                              child: Text(
                                ' TWh',
                                style:
                                    TextStyle(  fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: Color.fromARGB(204, 255, 255, 255),
            ),
            Expanded(
              child: Card(
                color: Colors.white.withOpacity(0.4),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 200,
                      minY: 250,
                      maxY: 450,
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 23),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 33),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hide top titles
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false), // Hide right titles
                        ),
                      ),

                      lineBarsData: _createData(state),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  @override
  void dispose() {
    gameTimer.stop();
    super.dispose();
  }
  void pauseGame() {
    setState(() {
      isGamePaused = true;
      gameTimer.stop(); // Stop the game timer
      showTriviaQuestion(gameManager.state); // Show trivia question
    });
  }

  void resumeGame() {
    setState(() {
      isGamePaused = false;
      gameTimer.start(); // Resume the game timer
    });
  }
  void increaseResearch(GameState state) {
    if (state.runState != RunState.Running) return;
    // Define the cost for research
    double researchCost = calculateResearchCost(state);
    if (state.money >= researchCost) {
      setState(() {
        state.researchLevel += 0.1; //TODO define research relationships with others
        state.money -= researchCost;
      });
    } else {
      // Show a dialog if not enough money
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Not enough money"),
          content: Text("You need \$$researchCost to invest in research."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  double calculateResearchCost(GameState state) {
    // Logic to calculate research cost, potentially based on the current research level
    return 100 * state.researchLevel; // Example calculation
  }

  // Game over dialog
  void _gameOver(GameState state) {
    double money = state.money;
    // populate the message based on the run state
    String message = "";
    switch (state.runState) {
      case RunState.LostTooHigh:
        message = "CO2 levels exceeded the point of no return. Earth is doomed.";
        break;
      case RunState.LostTooLow:
        message = "CO2 levels dropped too low. Earth is doomed.";
        break;
      case RunState.LostNotStable:
        message = "CO2 levels are not stable. Earth is doomed.";
        break;
      case RunState.Won:
        message = "CO2 levels stabilized for 10 years! You saved the Earth!";
        break;
      default:
        message = "Game over";
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Game Over \n Your score is $money"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }




  void showTriviaQuestion(GameState state) {
    var trivia = getRandomTriviaQuestion();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Trivia Question"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(trivia.question, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 30),
              ...List.generate(trivia.options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close trivia dialog
                    if (index == trivia.correctAnswerIndex) {
                        // Correct answer logic
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Correct!"),
                            content: Text("You earned \$10 B."),
                            actions: [
                              TextButton(
                                onPressed: () { Navigator.pop(context); resumeGame(); },
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                        setState(() {
                          state.runState = RunState.Running; // Resume the game
                        });
                      } else {showTriviaQuestion(gameManager.state);}// Additional logic for correct/incorrect answer
                    },
                    child: Text(trivia.options[index]),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }


  }

  List<LineChartBarData> _createData(GameState state) {
    return [
      LineChartBarData(
        spots: co2Data
            .map((data) => FlSpot(data.year.toDouble(), data.co2Level))
            .toList(),
        isCurved: true,
        barWidth: 2,
        color: Colors.blue,
      ),
    ];
  }


class ChartPoint {
  final int year;
  final double co2Level;

  const ChartPoint(this.year, this.co2Level);
}

class Factory {
  final int startYear;
  final String type;
  const Factory(this.startYear, this.type);
}

class FactoryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const FactoryButton.CreateButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// Define a trivia question structure
class TriviaQuestion {
  String question;
  List<String> options;
  int correctAnswerIndex;

  TriviaQuestion(this.question, this.options, this.correctAnswerIndex);
}

// Sample trivia questions
List<TriviaQuestion> triviaQuestions = [
  TriviaQuestion("What is the main cause of climate change?",
      ["Deforestation", "Fossil fuels", "Agriculture", "Volcanic activity"], 1),
  TriviaQuestion("Which renewable energy source is most widely used worldwide?",
      ["Solar", "Wind", "Hydroelectric", "Geothermal"], 2),
  TriviaQuestion("What year was the Paris Agreement signed?",
      ["2012", "2015", "2018", "2020"], 1),
  TriviaQuestion("Which country emits the most carbon dioxide?",
      ["USA", "China", "India", "Russia"], 1),
  TriviaQuestion(
      "What is the primary cause of rising sea levels?",
      ["Melting glaciers", "Deforestation", "Urbanization", "Desertification"],
      0),
  TriviaQuestion("Which of the following is not a greenhouse gas?",
      ["Carbon dioxide", "Methane", "Nitrous oxide", "water vapour"], 2),
  TriviaQuestion(
      "What percentage of the global greenhouse gas emissions does the transportation sector emit?",
      ["10%", "20%", "33%", "70%"],
      1),
  TriviaQuestion("Which of these countries emits the most carbon dioxide?",
      ["USA", "China", "India", "Russia"], 1),
  TriviaQuestion(
      "What is the Greenhouse effect?",
      [
        "The name of climate change legislation that was passed by Congress",
        "When you paint your house green to become an environmentalist",
        "When the gasses in our atmosphere trap heat and block it from escaping our planet",
        "When you build a greenhouse"
      ],
      2),
  TriviaQuestion(
      "Which of the following is NOT a consequence associated with climate change?",
      [
        "The ice sheets are declining, glaciers are in retreat globally, and our oceans are more acidic than ever",
        "Decrease in widespread migration of people across the globe.",
        "More extreme weather like droughts, heat waves, and hurricanes",
        "Global sea levels are rising at an alarmingly fast rate - 17 centimeters (6.7 inches) in the last century alone and going higher"
      ],
      1),
  TriviaQuestion(
      "What can you do to help fight climate change?",
      [
        "Utilize public transit",
        "Consume less meat products",
        "Vote for political candidates who will advocate for climate-related legislation and policy improvements",
        "All of the above"
      ],
      3),
  TriviaQuestion(
      "True or False: The overwhelming majority of scientists agree that climate change is real and caused by humans.",
      ["True", "False"],
      0),
  TriviaQuestion(
      "True or False: Wasting less food is a way to reduce greenhouse gas emissions.",
      ["True", "False"],
      0),
  TriviaQuestion("Which years have been the hottest on record?",
      ["2013 and 2019", "2016 and 2020", "2015 and 2022", "2005 and 2014"], 1),
  // Add more questions here
];

// Function to randomly select a trivia question
TriviaQuestion getRandomTriviaQuestion() {
  var randomIndex = Random().nextInt(triviaQuestions.length);
  return triviaQuestions[randomIndex];
}

class StatusText extends StatelessWidget {
  final String title;
  final String value;
  final bool isCritical;

  const StatusText({
    Key? key,
    required this.title,
    required this.value,
    this.isCritical = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use Text widget inside a Card, to display the title and value
    return Card(
      color: isCritical ? Colors.amber : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      ),
    );
  }
}
