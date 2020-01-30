import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:flutter/cupertino.dart';

main() {
  runApp(MaterialApp(
    title: "ToDo",
    initialRoute: '/',
    routes: {
      '/': (context) => ListScreen(),
      '/adScreen': (context) => AddScreen()
    },
  ));
}

class AddScreen extends StatefulWidget {
  @override
  AddScreenState createState() => AddScreenState();
}

class AddScreenState extends State<AddScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter a New Task"),
      ),
      body: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Enter Something To Do'
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pop(context, _controller.value.text);
        },
        child: Icon(Icons.save),
      ),
    );
  }

  @override
  void initState(){
    _controller.addListener(() {});
    super.initState();
  }
}

class ListScreen extends StatefulWidget{
  @override
  ListScreenState createState() => ListScreenState();
}

class ListScreenState extends State<ListScreen>{
  Future<List<Task>> tasks;

  get database async {
    return openDatabase(path.join(await getDatabasesPath(), 'tasks.db'),
        onCreate: (db, version){
      return db.execute(
        "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, task TEXT)");
    }, version: 1);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Data'),
      ),
      body: FutureBuilder<List<Task>>(
        future: tasks,
        builder: (context, snapshot){
          if (snapshot.hasData){
            if (snapshot.data.length == 0){
              return Center(child: Text('No Data Yet'));
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  final item = snapshot.data[index].task;
                  return ListTile(
                    title: Text(item),
                  );
                },
            );
          }
          return Center(child: Text('No Data Yet'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_comment),
        onPressed: (){
          _gotoAddScreen(context);
        },
      ),
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query("tasks");

    return List.generate(maps.length, (index) {
      return Task(maps[index]["task"]);
    });
  }

  @override
  void initState(){
    super.initState();
    _loadTasks();
  }

  Future<void> insertTask(Task task) async{
    final db = await database;
    db.insert("tasks", task.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);
  }

  _gotoAddScreen(BuildContext context) async{
    final result = await Navigator.pushNamed(context, '/addScreen');
    await insertTask(Task(result));
    _loadTasks();
  }

  _loadTasks() {
    setState(() {
      tasks = getTasks();
    });
  }
}

class Task{
  final String task;

  Task(this.task);

  Map<String, dynamic> toMap(){
    return {"task": task};
  }
}