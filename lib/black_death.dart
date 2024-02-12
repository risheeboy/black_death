import 'dart:math';

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
import 'run_state.dart';

final co2Data = [];

class BlackDeath extends StatefulWidget {
  @override
  _BlackDeathAppState createState() => _BlackDeathAppState();
}

class _BlackDeathAppState extends State<BlackDeath> {
  GameManager gameManager = GameManager(GameState(), SimpleAgent(), QAgent());
  late GameTimer gameTimer;
  bool isGameStarted = false;
  bool isGamePaused = false;
  bool showRedFlash = false;

  @override
  Widget build(BuildContext context) {
    return isGameStarted ? buildGameScreen() : buildStartScreen();
  }

  Widget buildGameScreen() {
    GameState state = gameManager.state;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBarWidget(
        onSidekickSelected: (selectedSidekick) {
          gameManager.setSidekick(selectedSidekick);
        },
        onBuildPressed: () {
          pauseGame();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgentScreen(gameManager: gameManager)),
          );
        },
        onPausePressed: () {
          if (isGamePaused) {
            resumeGame();
          } else {
            pauseGame();
          }
        },
        gameManager: gameManager,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/earth_smoke.png"),
            fit: BoxFit.cover,
            // transparancy of the image
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.2), BlendMode.dstATop),
          )
        ),

      child: SafeArea(
        top: true,
        child: Stack(
          children: [
            AnimatedContainer(
                duration: Duration(milliseconds: 500),
              color: state.isDisasterHappening ? Colors.red : Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (MediaQuery.of(context).size.width >= 600) 
                    Divider(
                      thickness: 1,
                      color: Color.fromARGB(204, 255, 255, 255),
                    ),
                  // Game Actions Section
                  Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 3), // Add top and bottom padding
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
                                            child: Text('Renewables', style: TextStyle(fontSize: 14)),
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
                                    Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.blue,
                                        shape: CircleBorder(),
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.remove,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            size: 15,
                                          ),
                                          onPressed: () => gameManager.takeAction(GameAction.destroySolarFactory)
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 20),
                                        child: Text(
                                          state.solarProduction.toString(),
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.blue,
                                        shape: CircleBorder(),
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.add,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            size: 15,
                                          ),
                                          onPressed: () => gameManager.takeAction(GameAction.buildSolarFactory)
                                        ),
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
                                              padding: EdgeInsets.zero,
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
                                    Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.blue,
                                        shape: CircleBorder(),
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          onPressed: () => gameManager.takeAction(GameAction.decreaseFossilFuelUsage),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 20),
                                        child: Text(
                                          state.fossilFuelProduction.toString(),
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.blue,
                                        shape: CircleBorder(),
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.add,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            size: 15,
                                          ),
                                          onPressed: () => gameManager.takeAction(GameAction.increaseFossilFuelUsage)
                                        ),
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
                                        'Education Budget',
                                        style: TextStyle(  fontSize: 14),
                                      ),
                                    ),

                                    Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.blue,
                                        shape: CircleBorder(),
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.remove,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            size: 15,
                                          ),
                                          onPressed: () => gameManager.takeAction(GameAction.decreaseEducationBudget), 
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 5, 0),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 20),
                                        child: Text(
                                          state.educationBudget.toString(),
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.blue,
                                        shape: CircleBorder(),
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.add,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            size: 15,
                                          ),
                                          onPressed: () => gameManager.takeAction(GameAction.increaseEducationBudget),
                                        ),
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
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 20),
                                        child: Text(
                                          state.researchLevel.toString(),
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    Ink(
                                      decoration: const ShapeDecoration(
                                        color: Colors.blue,
                                        shape: CircleBorder(),
                                      ),
                                      child: SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.add,
                                            color: Color.fromARGB(255, 255, 255, 255),
                                            size: 15,
                                          ),
                                          onPressed: () => gameManager.takeAction(GameAction.increaseResearch),
                                        ),
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
                  ),
                  if (MediaQuery.of(context).size.width >= 600) 
                    Divider(
                      thickness: 1,
                      color: Color.fromARGB(204, 255, 255, 255),
                    ),
                  // Game Status Section
                  Align(
                    alignment: AlignmentDirectional(0, 0),
                    child: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
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
                                  EdgeInsetsDirectional.fromSTEB(15, 7, 15, 7),
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
                                      progressColor: state.co2Level > 400 ? Colors.red : Color(0xFF02AB00),
                                      backgroundColor: Color.fromARGB(181, 255, 255, 255),
                                      padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(15, 7, 15, 7),
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
                                  EdgeInsetsDirectional.fromSTEB(15, 7, 15, 7),
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
                                    backgroundColor: Color.fromARGB(132, 194, 116, 0),
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
                                  EdgeInsetsDirectional.fromSTEB(15, 7, 15, 7),
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
                                  Container(
                                    constraints: BoxConstraints(minWidth: 30),
                                    child: Center(
                                      child: Text(
                                        state.money.toStringAsFixed(0) + ' B',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(15, 7, 15, 7),
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
                                  EdgeInsetsDirectional.fromSTEB(15, 7, 15, 7),
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
                  if (MediaQuery.of(context).size.width >= 600) 
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
                            lineBarsData: _createData(state).map((lineData) {
                              return lineData.copyWith(
                                dotData: FlDotData(show: false),
                              );
                            }).toList(),
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(y: 430, color: Color.fromARGB(255, 219, 177, 50), strokeWidth: 1,),
                                HorizontalLine(y: 360, color: Color.fromARGB(255, 160, 180, 130), strokeWidth: 2,),
                                HorizontalLine(y: 350, color: Color.fromARGB(255, 160, 180, 130), strokeWidth: 3,),
                                HorizontalLine(y: 340, color: Color.fromARGB(255, 160, 180, 130), strokeWidth: 2,),
                                HorizontalLine(y: 270, color: Color.fromARGB(255, 219, 188, 95), strokeWidth: 1,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget buildStartScreen() {
    return Scaffold(
      appBar: AppBarWidget(
        onSidekickSelected: (selectedSidekick) {
          print('StartScreen onSidekickSelected $selectedSidekick');
          setState(() {
            gameManager.setSidekick(selectedSidekick);
          });
          print('StartScreen sidekick ${gameManager.sidekick}');
        },
        onBuildPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AgentScreen(gameManager: gameManager)),
          );
        },
        onPausePressed: () {},
        gameManager: gameManager,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue[50],
          image: DecorationImage(
            image: AssetImage('assets/images/earth_smoke.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.1),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '''
Goal of the game is to stabilize CO2 levels to save the planet from climate disaster.

You can use a sidekick, define your own sidekick and keep trying different rules till you find an efficient solution.

Game actions and results are used to train an AI model, that learns from all users who play the game.
''',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed:() {
                    isGameStarted = true;
                    gameTimer = GameTimer(
                      onYearPassed: () {
                        setState(() {
                          gameManager.updateGameState();
                          if (gameManager.state.isGameOver()) {
                            _gameOver(gameManager.state);
                            gameTimer.stop();
                          }
                          co2Data.add(ChartPoint(gameManager.state.lapsedYears, gameManager.state.co2Level));
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
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 97, 160, 94),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: Text(
                    'Start Game',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                Text(
                  '''

How to Play:\n
Decision-Making:
Choose from a range of actions: build renewable energy factories, manage fossil fuel usage, and allocate funds for climate education.
Every action has a direct effect on resources, CO2 levels, and the game's environment.

Resource Allocation:
Strategically allocate your budget between various environmental actions.
Balancing your budget is crucial for sustainable progress.

Research and Development:
Invest in research to unlock new capabilities and enhance your strategy.
Research decisions impact your budget and environmental outcomes.


Interactive Learning:
Engage with trivia questions throughout the game to earn rewards and enhance your understanding of climate issues.

End Game:
The game concludes based on your ability to stabilize CO2 levels over a period.
Different endings reflect the success or failure of your environmental strategies.
''',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
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
        message = "CO2 levels exceeded the point of no return. Planet is doomed.";
        break;
      case RunState.LostTooLow:
        message = "CO2 levels dropped too low. Planet is doomed.";
        break;
      case RunState.LostNotStable:
        message = "CO2 levels are not stable. Planet is doomed.";
        break;
      case RunState.Won:
        message = "CO2 levels stabilized for 10 years! You saved the planet!";
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

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Function(Sidekick) onSidekickSelected;
  final VoidCallback onBuildPressed;
  final VoidCallback onPausePressed;
  final GameManager gameManager;

  const AppBarWidget({
    required this.onSidekickSelected,
    required this.onBuildPressed,
    required this.onPausePressed,
    required this.gameManager,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      centerTitle: false,
      elevation: 5,
      title: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Black Death',
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            Text(
              'Sidekick:',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            PopupMenuButton<Sidekick>(
              icon: Icon(
                sidekickIcons[gameManager.sidekick],
                color: Colors.black,
                size: 24,
              ),
              onSelected: onSidekickSelected,
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Sidekick>>[
                PopupMenuItem<Sidekick>(
                  value: Sidekick.None,
                  child: ListTile(
                    leading: Icon(
                      sidekickIcons[Sidekick.None],
                      color: Colors.black,
                      size: 24,
                    ),
                    title: Text('None'),
                    selected: gameManager.sidekick == Sidekick.None,
                  ),
                ),
                PopupMenuItem<Sidekick>(
                  value: Sidekick.System,
                  child: ListTile(
                    leading: Icon(
                      sidekickIcons[Sidekick.System],
                      color: Colors.black,
                      size: 24,
                    ),
                    title: Text('System'),
                    selected: gameManager.sidekick == Sidekick.System,
                  ),
                ),
                PopupMenuItem<Sidekick>(
                  value: Sidekick.Custom,
                  child: ListTile(
                    leading: Icon(
                      sidekickIcons[Sidekick.Custom],
                      color: Colors.black,
                      size: 24,
                    ),
                    title: Text('Custom'),
                    selected: gameManager.sidekick == Sidekick.Custom,
                  ),
                ),
                PopupMenuItem<Sidekick>(
                  value: Sidekick.AI,
                  child: ListTile(
                    leading: Icon(
                      sidekickIcons[Sidekick.AI],
                      color: Colors.black,
                      size: 24,
                    ),
                    title: Text('AI'),
                    selected: gameManager.sidekick == Sidekick.AI,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.build,
                color: Colors.black,
              ),
              onPressed: onBuildPressed,
              iconSize: 20,
            ),
            IconButton(
              icon: Icon(
                gameManager.state.runState == RunState.Paused ? Icons.play_arrow : Icons.pause,
                color: Colors.black,
              ),
              iconSize: 30,
              onPressed: onPausePressed,
            ),
          ],
        ),
      ],
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
