import 'dart:async';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

// Starting values
const startingMoney = 100;
const initialCo2Level = 415.0;
const yearlyCo2Increase = 2.5;
const moneyIncreasePerYear = 35;
const upperPointOfNoReturnCo2 = 550;
const lowerPointOfNoReturnCo2 = 200;
bool isGameOver = false;


// Game variables
int lapsedYears = 0;
int money = startingMoney;
double co2Level = initialCo2Level;
final co2Data = [Data(0, initialCo2Level),];

// Timer to update game state
late Timer timer;
void main() => runApp(BlackDeath());

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
        if (co2Level >= upperPointOfNoReturnCo2) {
          // Game over
          _gameOver("CO2 levels exceeded the point of no return. Earth is doomed.");
          timer.cancel();
        }
        else if (co2Level <= lowerPointOfNoReturnCo2) {
          // Game over
          _gameOver("CO2 levels dropped below the point of no return. Earth is doomed.");
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

  void createFactory(String type) {
    if (isGameOver) return;
    setState(() {
      if (type == "solar") {
        money -= 10;
        co2Level -= 10;
      } else if (type == "wind") {
        money -= 10;
        co2Level -= 10;
        // Logic for creating a wind factory
      } else if (type == "electric") {
        money -= 10;
        co2Level -= 10;
        // Logic for creating an electric vehicle factory
      }
      // Update money and CO2 level accordingly
    });
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Actions Column
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FactoryButton(
                          onPressed: () => createFactory("solar"),
                          text: "Create Solar Factory",
                          icon: Icons.solar_power,
                        ),
                        FactoryButton(
                          onPressed: () => createFactory("wind"),
                          text: "Create Wind Factory",
                          icon: Icons.air,
                        ),
                        FactoryButton(
                          onPressed: () => createFactory("electric"),
                          text: "Create EV Factory",
                          icon: Icons.electric_car,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Chart Column
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: charts.LineChart(
                      _createData(),
                      animate: false,
                    ),
                  ),
                ),
              ),

              // Status Column
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StatusText(title: "Year", value: "$lapsedYears"),
                        StatusText(title: "Money", value: "\$" + money.toString()),
                        StatusText(title: "CO2 Level", value: "$co2Level ppm", isCritical: co2Level >= upperPointOfNoReturnCo2),
                      ],
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

  List<charts.Series<dynamic, int>> _createData() {
    return [
      charts.Series<Data, int>(
        id: 'CO2 Level',
        domainFn: (Data data, _) => data.year,
        measureFn: (Data data, _) => data.co2Level,
        data: co2Data,
      ),
    ];
  }
}

class Data {
  final int year;
  final double co2Level;

  const Data(this.year, this.co2Level);
  }

class FactoryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const FactoryButton({
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
        primary: Colors.blue,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
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
    return Text(
      "$title: $value",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isCritical ? Colors.red : Colors.black,
      ),
    );
  }
}
