import 'dart:ffi';// 
import 'package:cloud_firestore/cloud_firestore.dart';// Firestore framework
import 'package:flutter/material.dart';// Flutter framework
import 'package:provider/provider.dart';// provider package
import 'package:table_calendar/table_calendar.dart';// calendar widget for displaying the dates
import 'package:myapp/models/tasks.dart';// models for task class
import 'package:myapp/services/task_service.dart';// service for tasks
import 'package:myapp/providers/task_provider.dart';// provider class for managing tasks

// It is a main home page screen of my app
class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();//Creating the state object for Home_Page
}
// State class for home page
class _Home_PageState extends State<Home_Page> {
  // so this is cotroller for the text field to add new tasks
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // It helps to load task so that the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();// call provider to fetch the task
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(// Scaffold provides app structure (AppBar, Drawer, Body, etc.)
      appBar: AppBar(// top  aap bar
        backgroundColor: Colors.blue,// it is setting the background color of app bar
        title: Row(// tittle row with logo and text
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,// space elements
          children: [
            // it is a app logo on the left side
            Expanded(child: Image.asset('assets/rdplogo.png', height: 80)),// shoews about app logo
            // it is a app tittle in the middle
            const Text(
              'Daily Planner',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 32,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(// main content of the screen
        children: [
          // This is the calendar widget at the top of the page
          Expanded(
            child: SingleChildScrollView(// it allows to scroll when the content overflows
              child: Column(
                children: [
                  TableCalendar(
                    calendarFormat: CalendarFormat.month,// displaying monthly format
                    focusedDay: DateTime.now(),// set the current day
                    firstDay: DateTime(2025),// selectable earliest date
                    lastDay: DateTime(2026),// newest selectable date
                  ),
                  //Consumer widget listens to changes in TaskProvider for task list
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      return buildTaskItem(// it builds and all the task items
                        taskProvider.tasks,
                        taskProvider.removeTask,
                        taskProvider.updateTask,
                      );
                    },
                  ),

                  // consumer widget for adding new  tasks
                  Consumer<TaskProvider>(
                    builder: (context, taskProvider, child) {
                      return buildAddTaskSection(nameController, () async {
                        // Asynchronous function: adds new task to provider and Firestore
                        await taskProvider.addTask(nameController.text);
                        // Clear the text field after task is added
                        nameController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(),
    );
  }
}

// it is a Regular function which Builds the UI section where user can add new tasks
Widget buildAddTaskSection(nameController, addTask) {
  return Container(
    decoration: BoxDecoration(color: Colors.white),// background color white
    child: Row(
      children: [
        Expanded(
          child: Container(
            child: TextField(
              // It helps to keep task name short
              maxLength: 32,// helps to restrict task name length
              controller: nameController,// Attach controller to input field
              decoration: const InputDecoration(
                labelText: 'Add Task',// label in text field
                border: OutlineInputBorder(),// outside border style
              ),
            ),
          ),
        ),
        ElevatedButton(onPressed: addTask, child: Text('Add Task')),//it is an onPressed callback that executes addTask function when button is tapped
      ],
    ),
  );
}

// it is a Regular function: Builds and returns a widget that displays the list of tasks
Widget buildTaskItem(
  List<Task> tasks,// list of each task
  Function(int) removeTasks,// to delete task
  Function(int, bool) updateTask,// to update task status
) {
  return ListView.builder(// scrollable list of tasks
    shrinkWrap: true,// prevents to take infinite height
    physics: const NeverScrollableScrollPhysics(),// Disable scrolling
    itemCount: tasks.length,// number of tasks
    itemBuilder: (context, index) {
      final task = tasks[index];// current
      // this one is alternative colors for rows
      final isEven = index % 2 == 0;// alternative colors for rows

      return Padding(
        padding: EdgeInsets.all(1.0),// padding around each
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),// Rounded corners for task tile
          ),
          tileColor: isEven ? Colors.blue : Colors.green,// title color
          leading: Icon(
            task.completed ? Icons.check_circle : Icons.circle_outlined,// icon based on task status
          ),
          title: Text(
            task.name,// displaying name of task
            style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null,// strike-through complete
              fontSize: 22,
            ),
          ),
          trailing: Row(// Keeps row compact
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                // That one is checkbox to mark task as completed 
                value: task.completed,// current state
                onChanged: (value) => {updateTask(index, value!)},
              ),
              // That one is delete button to remove task
              IconButton(
                icon: Icon(Icons.delete),// deletes icon
                onPressed: () => removeTasks(index),
              ),
            ],
          ),
        ),
      );
    },
  );
}
