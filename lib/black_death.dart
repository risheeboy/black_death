import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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
int demand = 12; // in MWh per year of clean energy
int supply = 10; // in MWh per year of clean energy

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
        for (var factory in factories) {
          //money -= 10; // Opex
          if (lapsedYears >= factory.startYear + 2) {
            // Factory is operational
            supply += 1;
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
      if (isGameOver) return;
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
      setState(() {
        demand += 1;
        money -= 10;// Capex
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
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("earth_smoke.png"),
              fit: BoxFit.cover,
              // transparancy of the image
              colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.2), BlendMode.dstATop),
            ),
          ),
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
                          onPressed: () => createSupply("solar"),
                          text: "Create Solar Factory",
                          icon: Icons.solar_power,
                        ),
                        FactoryButton(
                          onPressed: () => createSupply("wind"),
                          text: "Create Wind Factory",
                          icon: Icons.air,
                        ),
                        FactoryButton(
                          onPressed: () => createDemand(),
                          text: "Educate Youth",
                          icon: Icons.book_online_sharp,
                        ),
                        StatusText(title: "Year", value: "$lapsedYears"),
                        StatusText(title: "Money", value: "\$" + money.toString()),
                        StatusText(title: "CO2 Level", value: "$co2Level ppm", isCritical: co2Level >= upperPointOfNoReturnCo2),
                        StatusText(title: "lapsedYears", value: "$lapsedYears"),
                        StatusText(title: "demand", value: "$demand"),
                        StatusText(title: "supply", value: "$supply"),
                        StatusText(title: "factories", value: "${factories.length}"),
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
