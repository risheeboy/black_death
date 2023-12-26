import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:black_death/game_actions.dart';
import 'package:black_death/run_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import 'game_manager.dart';
import 'game_state.dart';
import 'game_timer.dart';
import 'q_agent.dart';
import 'simple_agent.dart';
import 'utils.dart';

final co2Data = [];

void playAudioButton() async {
  final player = AudioPlayer();
  await player.play(AssetSource('audio/chime1.mp3'));
}

class BlackDeath extends StatefulWidget {
  @override
  _BlackDeathAppState createState() => _BlackDeathAppState();
}

class _BlackDeathAppState extends State<BlackDeath> {
  late GameManager gameManager;
  late GameTimer gameTimer;

  @override
  void initState() {
    super.initState();
    GameState state = GameState();
    gameManager = GameManager(state, SimpleAgent(), QAgent());
    gameTimer = GameTimer(onYearPassed: () {
      setState(() {
        gameManager.updateGameState();
        if (state.isGameOver()) {
          _gameOver(state);
          gameTimer.stop();
        }
        co2Data.add(ChartPoint(state.lapsedYears, state.co2Level));
      });
    });
    gameTimer.start();
  }

  @override
  void dispose() {
    gameTimer.stop();
    super.dispose();
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

  void createSupply(GameState state, GameAction action) {
    if (state.runState != RunState.Running) return;
    playAudioButton();
    double cost = capitalExpense[action] ?? 0;
    if (cost <= state.money) {
      setState(() {
        switch (action) {
          case GameAction.buildSolarFactory:
            state.solarProduction++;
            state.money -= cost;
            break;
          case GameAction.buildWindFactory:
            state.windProduction++;
            state.money -= cost;
            break;
          case GameAction.destroySolarFactory:
            if(state.solarProduction > 0)
              state.solarProduction--;
            break;
          case GameAction.destroyWindFactory:
            if(state.windProduction > 0)
              state.windProduction--;
            break;
          default:
            // do nothing
            break;
        }
      });
    } else {
      showTriviaQuestion(state);
    }
  }

  void createDemand(GameState state) {
    if (state.runState != RunState.Running || state.money <= 0) {
      showTriviaQuestion(state);
    } else {
      setState(() {
        state.awareness += 1;
        state.money -= 1; // Capex in Billion USD
      });
    }
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
              Text(trivia.question,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 30), 
              ...List.generate(trivia.options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 3.0), // Vertical spacing for options
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close trivia dialog
                      if (index == trivia.correctAnswerIndex) {
                        // Correct answer logic
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Correct!"),
                            content: Text("You earned \$1000 MM."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK"),
                              ),
                            ],
                          ),
                        );
                        setState(() {
                          state.money += 10; // Reward for correct answer in Billion USD
                        });
                      }
                    },
                    child: Text(trivia.options[index]),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blueGrey, // Text color
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

  @override
  Widget build(BuildContext context) {
    GameState state = gameManager.state;
    return Scaffold(
      appBar: AppBar(
        title: Text("Black Death",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        //change the background color of the app bar and make it semi transparent
        backgroundColor: Colors.black.withOpacity(0.6),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/earth_smoke.png"),
            fit: BoxFit.cover,
            // transparancy of the image
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              color: Colors.transparent,
              child: Marquee(
                text:
                    "the CO2 level is ${(state.co2Level - co2LevelIdeal).round()} ppm above the ideal level of $co2LevelIdeal ppm",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey),
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: 1000.0,
                velocity: 100.0,
                startPadding: 10.0,
                accelerationCurve: Curves.linear,
                decelerationCurve: Curves.easeOut,
              ),
            ),
            // Actions
            Expanded(
              child: Card(
                color: Colors.white.withOpacity(0.4),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Use Wrap to wrap all the buttons if they don't fit in one line
                      Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 1,
                            runSpacing: 1,
                            children: [
                              Text("Solar Production",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black)),
                              IconButton(
                                onPressed: () => createSupply(
                                    state, GameAction.buildSolarFactory),
                                icon: Icon(Icons.add, size: 18),
                              ),
                              IconButton(
                                onPressed: () => createSupply(
                                    state, GameAction.destroySolarFactory),
                                icon: Icon(Icons.remove, size: 18),
                              ),
                              // Show icons for Solar production
                              ...List.generate(state.solarProduction.toInt(),
                                  (index) => Icon(Icons.solar_power, size: 18)),
                            ],
                          ),
                        ),
                      ),
                      Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 1,
                            runSpacing: 1,
                            children: [
                              Text("Wind Production",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.black)),
                            // doing the same thing but for wind factories
                              IconButton(
                                onPressed: () => createSupply(
                                    state, GameAction.buildWindFactory),
                                icon: Icon(Icons.add, size: 18),
                              ),
                              IconButton(
                                onPressed: () => createSupply(
                                    state, GameAction.destroyWindFactory),
                                icon: Icon(Icons.remove, size: 18),
                              ),
                              // Show icons for Wind production
                              ...List.generate(state.windProduction.toInt(),
                                  (index) => Icon(Icons.air, size: 18)),                              

                            ],
                          ),
                        ),
                      ),
                      Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 1,
                            runSpacing: 1,
                            children: [
                              FactoryButton.CreateButton(
                                onPressed: () => createDemand(state),
                                text: "Educate Youth",
                                icon: Icons.school,
                              ),
                              // Show education level using school icons
                              ...List.generate(state.awareness.toInt(),
                                  (index) => Icon(Icons.school, size: 18)),
                            ],
                          ),
                        ),
                      ),
                      Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 1,
                            runSpacing: 1,
                            children: [
                              FactoryButton.CreateButton(
                                onPressed: () => increaseResearch(state),
                                text: "Increase Research",
                                icon: Icons.science,
                              ),
                              ...List.generate(state.researchLevel.toInt(),
                                  (index) => Icon(Icons.science, size: 18)),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Wrap(
                              spacing: 2,
                              runSpacing: 2,
                              children: [
                                StatusText(
                                    title: "Demand",
                                    value: "${state.renewableDemand().round()}",
                                    isCritical: state.renewableSupply() >
                                        state.renewableDemand() + 5),
                                StatusText(
                                    title: "Supply",
                                    value: "${state.renewableSupply().round()}",
                                    isCritical: state.renewableDemand() >
                                        state.renewableSupply() + 5),
                                StatusText(
                                    title: "Money",
                                    value: "\$${state.money.toString()} B",
                                    isCritical: state.money > 1000),
                                StatusText(
                                    title: "CO2 Level",
                                    value: "${state.co2Level.round()} ppm",
                                    isCritical:
                                        state.co2Level > co2LevelMax - 50),
                                StatusText(
                                    title: "Lapsed Years",
                                    value: "${state.lapsedYears}"),
                              ],
                            ),
                          ),
                          // add a switch widget to enable/diable the agent
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
                    ],
                  ),
                ),
              ),
            ),

            // Chart
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
                          sideTitles:
                              SideTitles(showTitles: false), // Hide top titles
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: false), // Hide right titles
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
    );
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
      ["Carbon dioxide", "Methane", "Nitrous oxide", "water vapour"], 3),
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
