import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task1/login.dart';
import 'package:task1/account.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Important
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: signup(),
    );
  }
}

//authentication
class FirebaseAuthService{
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User?> signUpWithEmailAndPassword(String email, String password) async{

    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }
    catch(e){
      ScaffoldMessenger(child: Text("Error"));
    }

    return null;

  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async{

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password,);
      return credential.user;
    }
    catch(e){
      ScaffoldMessenger(child: Text("Error"));
    }

    return null;

  }



}



class signup extends StatefulWidget {
  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back, size: 30,), onPressed: () {

          },),
        title:
        Text("Sign Up", style: TextStyle(fontSize: 28),)

      ),
      body:
      SingleChildScrollView(

        child: Form(
          key: _formKey,
          child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(

              height: MediaQuery.of(context).size.height,
              width: double.infinity,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  Text("Welcome Students!", style: TextStyle(color: Colors.red, fontSize: 40, fontWeight: FontWeight.bold),),
                  SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.black,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(20),
                            prefixIcon: Icon(Icons.email_rounded, color: Colors.blue, size: 30),
                            labelText: ("Email Address"),
                            labelStyle: TextStyle(fontSize: 20,),
                            floatingLabelStyle: TextStyle(fontSize: 20, color: Colors.blue),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.black, width: 1,),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.blue, width: 1),
                            ),
                        ),
                        validator: (value) {
                          if (value == null||value.isEmpty) return 'Please enter Email';
                          return null;
                        }
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                          controller: _passwordController,
                          cursorColor: Colors.black,
                          obscureText: true,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.black, width: 1),
                            ),
                            contentPadding: EdgeInsets.all(20),
                            prefixIcon: Icon(Icons.lock, color: Colors.red, size: 30),
                            labelText: ("Password"),
                            labelStyle: TextStyle(fontSize: 20,),
                            floatingLabelStyle: TextStyle(fontSize: 20, color: Colors.red),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.red, width: 1),

                            ),

                          )
                          ,
                          validator: (value) {
                            if (value == null||value.isEmpty) return 'Please enter Password';
                            return null;
                          }
                      )
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue), fixedSize: WidgetStatePropertyAll(Size.fromWidth(320)), padding: WidgetStatePropertyAll(EdgeInsets.all(8))),
                    onPressed:
                      _signUp,child: Text("Sign Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23)) ,
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text("Already have an account?", style: TextStyle(fontSize: 20),),
                      TextButton(onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => login()));
                      },
                          child: Text("Login", style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),))
                    ],
                  )
                ],
              )
          ),
        ),
        ),

      )

    );
  }

  void _signUp() async{
    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signUpWithEmailAndPassword(email, password);
   if(_formKey.currentState!.validate()) {
     if (user != null) {
       Navigator.push(
           context, MaterialPageRoute(builder: (context) => login()));
       print("signup successfull");
     }
     else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
           content: Text("User already exists or an unknown error occurred!")));
     }
   }
   else{
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: Text("Please fill in all fields!")));
   }

  }

}


