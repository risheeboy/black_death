import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:audioplayers/audioplayers.dart';


// Starting values
const startingMoney = 100;
const initialCo2Level = 415.0;
const yearlyCo2Increase = 2.5;
const moneyIncreasePerYear = 35;
const upperPointOfNoReturnCo2 = 550;
const lowerPointOfNoReturnCo2 = 200;
bool isGameOver = false;
var capitalExpense = {
  'solar': 100,
  'wind': 100,
  'electric': 100,
};

// Game variables
int lapsedYears = 0;
int money = startingMoney;
double co2Level = initialCo2Level;
final co2Data = [Data(0, initialCo2Level),];
final factories = [];
int education = 0;
double demand = 15; // in MWh per year of clean energy
double supply = 10; // in MWh per year of clean energy

// Timer to update game state
late Timer timer;

void playAudioButton() async {
  final player = AudioPlayer();
  await player.play(AssetSource('audio/chime1.mp3'));
}

class BlackDeath extends StatefulWidget {
  @override
  _BlackDeathAppState createState() => _BlackDeathAppState();
}

class _BlackDeathAppState extends State<BlackDeath> {
  @override
  void initState() {
    super.initState();
        // Start timer to update game state
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        lapsedYears++;
        money += moneyIncreasePerYear;
        co2Level += yearlyCo2Increase;
        co2Data.add(Data(lapsedYears, co2Level));
        for (var factory in factories) {
          //money -= 10; // Opex
          if (lapsedYears >= factory.startYear + 2) {
            // Factory is operational
            supply += 0.1;
          }
        }
        co2Level -= 0.05 * min(demand, supply);
        if (co2Level >= upperPointOfNoReturnCo2) {
          // Game over
          _gameOver("CO2 levels exceeded the point of no return. Earth is doomed.");
          timer.cancel();
        }
        else if (co2Level <= lowerPointOfNoReturnCo2) {
          // Game over
          _gameOver("CO2 levels dropped. Earth is saved.");
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  // Game over dialog
  void _gameOver(String message) {
    isGameOver = true;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
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

  void createSupply(String type) {
      playAudioButton();
      if (isGameOver) return;
      checkForTrivia();
      int cost = capitalExpense[type]!;
      if(cost <= money) {
        setState(() {
          factories.add(Factory(lapsedYears, type));
              money -= capitalExpense[type]!;// Capex
        });
      } else {
        // Show dialog to inform user that they don't have enough money
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Not enough money"),
            content: Text("You need \$$cost to create a $type factory."),
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

  void createDemand() {
      if (isGameOver || money <= 0) return;
      checkForTrivia();
      setState(() {
        demand += 1;
        education += 1;
        money -= 10;// Capex
      });
  }

  void checkForTrivia() {
  if (Random().nextInt(4) == 0) { // 1 in 4 chance
    showTriviaQuestion();
  }
}

void showTriviaQuestion() {
  var trivia = getRandomTriviaQuestion();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Trivia Question"),
      content: SingleChildScrollView( // Use SingleChildScrollView for longer content
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trivia.question, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 30), // Spacing for better readability
            // Display each option with added spacing
            ...List.generate(trivia.options.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3.0), // Vertical spacing for options
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
                        money += 1000; // Reward for correct answer
                      });
                    }
                  },
                  child: Text(trivia.options[index]),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueGrey, // Button color
                    onPrimary: Colors.white, // Text color
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
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Black Death"),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/earth_smoke.png"),
              fit: BoxFit.cover,
              // transparancy of the image
              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.dstATop),
            ),
          ),
          child: Column(
            children: [
              // Actions
              Expanded(
                child: Card(
                  color: Colors.white.withOpacity(0.6),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Use Wrap to wrap all the buttons if they don't fit in one line
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FactoryButton.CreateButton(
                              onPressed: () => createSupply("solar"),
                              text: "Solar Factory",
                              icon: Icons.solar_power,
                            ),
                            // Show icons for all Solar factories
                            ...factories.where((factory) => factory.type == "solar").map((factory) => Icon(Icons.solar_power)),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FactoryButton.CreateButton(
                              onPressed: () => createSupply("wind"),
                              text: "Wind Factory",
                              icon: Icons.air,
                            ),
                            // Show icons for all Wind factories
                            ...factories.where((factory) => factory.type == "wind").map((factory) => Icon(Icons.air)),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FactoryButton.CreateButton(
                              onPressed: () => createDemand(),
                              text: "Educate Youth",
                              icon: Icons.school,
                            ),
                            // Show education level using school icons
                            ...List.generate(education, (index) => Icon(Icons.school)),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            StatusText(title: "Demand", value: "${demand.round()}", isCritical: supply > demand + 5),
                            StatusText(title: "Supply", value: "${supply.round()}", isCritical: demand > supply + 5),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            StatusText(title: "Money", value: "\$${money.toString()} MM", isCritical: money > 1000),
                            StatusText(title: "CO2 Level", value: "${co2Level.round()} ppm", isCritical: co2Level > upperPointOfNoReturnCo2 - 50),
                            StatusText(title: "Lapsed Years", value: "$lapsedYears"),
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
                        maxX: 100,
                        minY: 100,
                        maxY: 600,
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // Hide top titles
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false), // Hide right titles
                          ),
                        ),

                        lineBarsData: _createData(),
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

  List<LineChartBarData> _createData() {
    return [
      LineChartBarData(
        spots: co2Data.map((data) => FlSpot(data.year.toDouble(), data.co2Level)).toList(),
        isCurved: true,
        barWidth: 2,
        color: Colors.blue,
      ),
    ];
  }
}

class Data {
  final int year;
  final double co2Level;

  const Data(this.year, this.co2Level);
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
  TriviaQuestion("What is the main cause of climate change?", ["Deforestation", "Fossil fuels", "Agriculture", "Volcanic activity"], 1),
  TriviaQuestion("Which renewable energy source is most widely used worldwide?", ["Solar", "Wind", "Hydroelectric", "Geothermal"], 2),
  TriviaQuestion("What year was the Paris Agreement signed?", ["2012", "2015", "2018", "2020"], 1),
  TriviaQuestion("Which country emits the most carbon dioxide?", ["USA", "China", "India", "Russia"], 1),
  TriviaQuestion("What is the primary cause of rising sea levels?", ["Melting glaciers", "Deforestation", "Urbanization", "Desertification"], 0),
  TriviaQuestion("Which of the following is not a greenhouse gas?", ["Carbon dioxide", "Methane", "Nitrous oxide", "water vapour"], 3),
  TriviaQuestion("What percentage of the global greenhouse gas emissions does the transportation sector emit?", ["10%", "20%", "33%", "70%"], 1),
  TriviaQuestion("Which of these countries emits the most carbon dioxide?", ["USA", "China", "India", "Russia"], 1),
  TriviaQuestion("What is the Greenhouse effect?", ["The name of climate change legislation that was passed by Congress", "When you paint your house green to become an environmentalist", "When the gasses in our atmosphere trap heat and block it from escaping our planet", "When you build a greenhouse"], 2),
  TriviaQuestion("Which of the following is NOT a consequence associated with climate change?", ["The ice sheets are declining, glaciers are in retreat globally, and our oceans are more acidic than ever", "Decrease in widespread migration of people across the globe.", "More extreme weather like droughts, heat waves, and hurricanes", "Global sea levels are rising at an alarmingly fast rate - 17 centimeters (6.7 inches) in the last century alone and going higher"], 1),
  TriviaQuestion("What can you do to help fight climate change?", ["Utilize public transit", "Consume less meat products", "Vote for political candidates who will advocate for climate-related legislation and policy improvements", "All of the above"], 3),
  TriviaQuestion("True or False: The overwhelming majority of scientists agree that climate change is real and caused by humans.", ["True", "False"], 0),
  TriviaQuestion("True or False: Wasting less food is a way to reduce greenhouse gas emissions.", ["True", "False"], 0),
  TriviaQuestion("Which years have been the hottest on record?", ["2013 and 2019", "2016 and 2020", "2015 and 2022", "2005 and 2014"], 1),
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
