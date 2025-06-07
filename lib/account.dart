import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task1/login.dart';
import 'package:task1/main.dart';




//ACCOUNT PAGE
class account extends StatefulWidget {
  final String? documentId;

  account({this.documentId});

  @override
  _accountState createState() => _accountState();
}
class _accountState extends State<account> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController rollController;
  late TextEditingController programController;
  late TextEditingController cgpaController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late CollectionReference _students;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _students = _firestore.collection('students');
    nameController = TextEditingController();
    rollController = TextEditingController();
    programController = TextEditingController();
    cgpaController = TextEditingController();

    if (widget.documentId != null) {
      rollController.text = widget.documentId!;
      _readStudent(widget.documentId!);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    programController.dispose();
    cgpaController.dispose();
    super.dispose();
  }

  //createOperation
  Future<void> _addStudent() async {
    if (_formKey.currentState!.validate()) {
      final String rollNo = rollController.text.trim();
      if (rollNo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Roll Number cannot be empty to add a student.')),
          );
        }
        return;
      }
      setState(() {
        isLoading = true;
      }
      );
      try {
        DocumentSnapshot doc = await _students.doc(rollNo).get();
        if (doc.exists) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Student with Roll No $rollNo already exists. ')),
            );
          }
          return;
        }

        await _students.doc(rollNo).set({
          'name': nameController.text,
          'roll': rollController.text,
          'program': programController.text,
          'cgpa': cgpaController.text,
          'timestamp': Timestamp.now(),
        }
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student added')),
        );
        _clearForm();
      }
      catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding student: $e')),);
      }
      finally {
        setState(() {
          isLoading = false;
        }
        );
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  //readOperation
  Future<void> _readStudent(String rollNo) async {
    if (rollNo.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a Roll Number to read.")),
        );
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      isLoading = true;
    }
    );
    try {
      DocumentSnapshot doc = await _students.doc(rollNo).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        nameController.text = data['name'];
        programController.text = data['program'];
        cgpaController.text = data['cgpa'];
      }
      else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Student not found")));
        }
        _clearForm();
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load")));
    }
    finally {
      setState(() {
        isLoading = false;
      }
      );
    }
  }

  //updateOperation
  Future<void> _updateStudent(String rollNo) async {
    if (_formKey.currentState!.validate()) {
      if (rollNo.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Roll Number field cannot be empty to update.")),
          );
        }
        return;
      }
      if (!mounted) return;
      setState(() {
        isLoading = true;
      }
      );
      try {
        await _students.doc(rollNo).update({
          'name': nameController.text,
          'program': programController.text,
          'cgpa': cgpaController.text,
          'timestamp': Timestamp.now(),
        }
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Student Updated")));
        }
      }
      catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating student: $e')),
        );
      }
      finally {
        setState(() {
          isLoading = false;
        }
        );
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  //deleteOperation
  Future<void> _deleteStudent(String? rollNo) async {
    if(_formKey.currentState!.validate()) {
      if (rollNo == null || rollNo.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Please enter a Roll Number to delete.")),
          );
        }
        return;
      }

      if (!mounted) return;

      setState(() {
        isLoading = true;
      }
      );

      try {
        await _students.doc(rollNo).delete();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Student Deleted")));
        _clearForm();

        if (rollController.text == rollNo) {
          _clearForm();
        }
      }
      catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete student: $e")),
        );
      }
      finally {
        setState(() {
          isLoading = false;
        }
        );
      }
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  //clearform
  void _clearForm() {
    nameController.clear();
    rollController.clear();
    programController.clear();
    cgpaController.clear();
    _formKey.currentState?.reset();
  }

  Widget _studentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('students')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching students: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No students found. Add some!"));
        }

        final students = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 20.0,
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              DataColumn(
                label: Text(
                  'Roll No',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              DataColumn(
                label: Text(
                  'Program',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              DataColumn(
                label: Text(
                  'CGPA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
            ],
            rows: students.map((studentDocument) {
              Map<String, dynamic> data = studentDocument.data() as Map<String, dynamic>;

              return DataRow(
                cells: <DataCell>[
                  DataCell(Text(data['name'], style: TextStyle(fontSize: 20),)),
                  DataCell(Text(data['roll'], style: TextStyle(fontSize: 20))),
                  DataCell(Text(data['program'], style: TextStyle(fontSize: 20))),
                  DataCell(Text(data['cgpa'], style: TextStyle(fontSize: 20))),
                ],
              );
            }
            ).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellowAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30,), onPressed: () {
          Navigator.pop(context);
        },),
        title:
        Text("Student App",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body:
      isLoading
          ? Center(child: CircularProgressIndicator(),)
          : SingleChildScrollView(

        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
                height: 1000,
                width: double.infinity,
                child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          ClipRRect(child: Image.asset("assets/images/s1.webp",
                            width: 200, height: 200,),
                            borderRadius: BorderRadius.circular(100),),
                          SizedBox(height: 8,),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll(Colors.redAccent),
                                padding: WidgetStatePropertyAll(
                                    EdgeInsets.symmetric(vertical: 10, horizontal: 25))),
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => login()));
                            },
                            child: Text("Logout", style: TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20)),
                          ),
                          SizedBox(height: 8,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: nameController,
                              cursorColor: Colors.black,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    "assets/images/n1.png", width: 20, height: 20,),
                                ),
                                hintText: ("Name"),
                                hintStyle: TextStyle(fontSize: 20,),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black, width: 1,),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.blue, width: 1),
                                ),

                              ),
                              validator: (value) {
                                if (value == null||value.isEmpty) return 'Please enter a name';

                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(controller: rollController,

                              cursorColor: Colors.black,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black, width: 1),
                                ),
                                contentPadding: EdgeInsets.all(20),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    "assets/images/r1.jpg", width: 20, height: 20,),
                                ),
                                hintText: ("Roll number(UniqueID)"),
                                hintStyle: TextStyle(fontSize: 20,),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.blue, width: 1),
                                ),

                              ),
                              validator: (value) {
                                if (value == null||value.isEmpty) return 'Please enter a roll number';
                                return null;
                              } ,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(controller: programController,

                              cursorColor: Colors.black,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    "assets/images/p1.png", width: 20, height: 20,),
                                ),
                                hintText: ("Study Program"),
                                hintStyle: TextStyle(fontSize: 20,),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black, width: 1,),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.blue, width: 1),
                                ),

                              ),
                              validator: (value) {
                                if (value == null||value.isEmpty) return 'Please enter a study program';

                                return null;
                              } ,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: cgpaController,
                              cursorColor: Colors.black,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.black, width: 1),
                                ),
                                contentPadding: EdgeInsets.all(20),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Image.asset(
                                    "assets/images/c1.webp", width: 20, height: 20,),
                                ),
                                hintText: ("CGPA"),
                                hintStyle: TextStyle(fontSize: 20,),

                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.blue, width: 1),
                                ),

                              ),
                              validator: (value) {
                                if (value == null||value.isEmpty) return 'Please enter a CGPA';
                                final score = double.tryParse(value);
                                if (score == null) return 'Please enter a valid number for CGPA.';
                                if (score < 0 || score > 10) return 'CGPA must be between 0 and 10.';
                                return null;
                              },
                            ),

                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [

                              ElevatedButton(
                                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.
                                blueAccent),
                                    padding: WidgetStatePropertyAll(
                                        EdgeInsets.symmetric(vertical: 10, horizontal: 20))),
                                onPressed: () {_addStudent();
                                },
                                child: Text("Create", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),) ,
                              ),
                              SizedBox(width: 8,),
                              ElevatedButton(
                                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.yellowAccent), padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 20))),
                                onPressed: () {final String rollNo = rollController.text.trim();
                                _readStudent(rollNo);
                                }, child: Text("Read", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),) ,
                              ),
                              SizedBox(width: 8,),
                              ElevatedButton(
                                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green), padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 20))),
                                onPressed: () {final String rollNo = rollController.text.trim();
                                _updateStudent(rollNo);
                                }, child: Text("Update", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),) ,
                              ),
                              SizedBox(width: 8,),
                              ElevatedButton(
                                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.redAccent), padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 10, horizontal: 20))),
                                onPressed: () {
                                  final String rollNo = rollController.text.trim();
                                  _deleteStudent(rollNo);
                                },
                                child: Text("Delete", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),) ,
                              ),

                            ],
                          ),
                          SizedBox(height: 30),
                          // In your main build method's Column:

                          Text(
                            "Students List:",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center, // Center the title
                          ),
                          SizedBox(height: 10),
                          Expanded(child: Container(

                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _studentsList(),
                          ),)

                        ]
                    )
                )
            )
        )
        ,
      )
      ,

    );
  }
}
