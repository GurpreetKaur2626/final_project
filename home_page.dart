import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/models/tasks.dart';
import 'package:myapp/services/task_service.dart';
 
class Home_Page extends StatefulWidget {
  const Home_Page({super.key});
  @override
  State<Home_Page> createState() => _Home_PageState();
}
class _Home_PageState extends State<Home_Page> {
final TextEditingController nameController = TextEditingController();
@override
void initState(){
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
}
 @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
         title:Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(child: Image.asset('assets/rdplogo.png', height:80)),
            const Text('Daily Planner',
            style:TextStyle(
              fontFamily: 'Caveat',
              fontSize: 32,
              color: Colors.white,
            ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarFormat: CalendarFormat.month,
            focusedDay: DateTime.now(),
            firstDay: DateTime(2025),
            lastDay: DateTime(2026),
          ),
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              return buildAddTaskSection(
                nameController,
                () async {
                  await taskProvider.addTask(nameController.text);
                  nameController.clear();
                },
              );
            }
          )
          // Consume<TaskProvider>(builder: (context, taskProvider, child) {
          //})
        ],
      ),
      drawer: Drawer(),
    );
  }
}



// Build the sections for adding tasks
Widget buildAddTaskSection(nameController, addTask){
  return Container(
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
      children: [
        Expanded(
          child: Container(
            child: TextField(
              maxLength: 32,
              controller:nameController,
              decoration: const InputDecoration(
                labelText: 'Add Task',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        ElevatedButton(onPressed: addTask, child: Text('Add Task')),
      ],
    ),
  );
}

 
