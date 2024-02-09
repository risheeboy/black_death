import 'package:flutter/material.dart';

import 'game_manager.dart';
import 'rule.dart';
import 'utils.dart';


// Lists for Dropdown component menu-items
final List<DropdownMenuItem<GameAction>> _playerActions = GameAction.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList();
final List<DropdownMenuItem<Comparator>> _comparators = Comparator.values.map((v) => DropdownMenuItem(value: v, child: Text(v.formattedName))).toList();
final List<DropdownMenuItem<StateVariable>> _stateVariables = StateVariable.values.map((v) => DropdownMenuItem(value: v, child: Text(v.name))).toList();

class AgentScreen extends StatefulWidget {
const AgentScreen({Key? key, required this.gameManager}) : super(key: key);
  final GameManager gameManager;

  @override
  _AgentScreenState createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  List<Rule> rules = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      rules = widget.gameManager.customSidekick.rules ?? [];
    });
  }

  void saveRules() {
    widget.gameManager.customSidekick.saveRules(rules);
  }

  void loadDefaultRules() {
    setState(() {
      rules = widget.gameManager.customSidekick.loadDefaultRules()!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configure Agent'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadDefaultRules,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView.builder(
          itemCount: rules.length + 1,
          itemBuilder: (context, index) {
            if (index < rules.length) {
              return RuleWidget(
                  rule: rules[index],
                  onMoveUp: () => setState(() => rules.insert(index - 1, rules.removeAt(index))),
                  onMoveDown: () => setState(() => rules.insert(index + 1, rules.removeAt(index))),
                  onAddCondition: () => setState(() => rules[index].conditions.add(Condition(StateVariable.CO2Level, Comparator.GreaterThan, 350))),
                  onDelete: () => setState(() => rules.removeAt(index)),
              );
            } else {
              return AddRuleButton(
                  onAdd: () =>
                    setState(() => rules.add(Rule.withConditions(GameAction.buildSolarFactory, 
                    [Condition(StateVariable.CO2Level, Comparator.GreaterThan, 350)]))));
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            saveRules();
            //Navigator.pop(context);
          }
        },
        tooltip: 'Save',
        child: const Icon(Icons.save),
      ),
    );
  }
}

class RuleWidget extends StatefulWidget {
  final Rule rule;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onAddCondition;
  final VoidCallback onDelete;

  const RuleWidget(
      {Key? key, required this.rule, required this.onMoveUp, required this.onMoveDown, required this.onAddCondition, required this.onDelete})
      : super(key: key);

  @override
  _RuleWidgetState createState() => _RuleWidgetState();
}

class _RuleWidgetState extends State<RuleWidget> {

  late TextEditingController valueController;

  @override
  void initState() {
    super.initState();
    valueController = TextEditingController(text: widget.rule.playerAction.name);
  }

  @override
  void dispose() {
    valueController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Conditions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(onPressed: widget.onAddCondition, icon: const Icon(Icons.add), tooltip: 'Add Condition',),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete), tooltip: 'Delete Rule',),
                  IconButton(onPressed: widget.onMoveUp, icon: const Icon(Icons.arrow_upward_rounded), tooltip: 'Move Up',),
                  IconButton(onPressed: widget.onMoveDown, icon: const Icon(Icons.arrow_downward_rounded), tooltip: 'Move Down',),
                ],
              ),
            ),
            for (Condition condition in widget.rule.conditions)
              ConditionWidget(condition: condition),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '  Action:  ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Set color to white
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xABABABAB), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5), // Add left padding of 5px
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<GameAction>(
                          value: widget.rule.playerAction,
                          
                          onChanged: (v) => setState(() => widget.rule.playerAction = v!),
                          items: _playerActions,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class ConditionWidget extends StatefulWidget {
  final Condition condition;

  const ConditionWidget({Key? key, required this.condition}) : super(key: key);

  @override
  _ConditionWidgetState createState() => _ConditionWidgetState();
}

class _ConditionWidgetState extends State<ConditionWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Set color to white
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xABABABAB), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<StateVariable>(
                        value: widget.condition.stateVariable,
                        onChanged: (v) => setState(() => widget.condition.stateVariable = v!),
                        items: _stateVariables,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Set color to white
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xABABABAB), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5), // Add left padding of 5px
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Comparator>(
                        value: widget.condition.comparator,
                        onChanged: (v) => setState(() => widget.condition.comparator = v!),
                        items: _comparators,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  width: 60,
                  child: TextFormField(
                    initialValue: widget.condition.value.toString(),
                    onChanged: (value) {
                      setState(() {
                        widget.condition.value = double.parse(value);
                      });
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white, // Set text field color to white
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5), // Adjust height to match dropdowns
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xABABABAB), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xABABABAB), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xABABABAB), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xABABABAB), width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddRuleButton extends StatelessWidget {
  final VoidCallback onAdd;

  const AddRuleButton({Key? key, required this.onAdd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(5), // Add 5px padding around the button
        child: ElevatedButton(
          onPressed: onAdd,
          child: const Text('Add Rule', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 60, 118, 180),
          ),
        ),
      ),
    );
  }
}
