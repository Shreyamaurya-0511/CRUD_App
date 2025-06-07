//LOGIN PAGE
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task1/account.dart';
import 'package:task1/main.dart';


class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}
class _loginState extends State<login> {

  final FirebaseAuthService _auth = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
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
            backgroundColor: Colors.blue,
            leading: IconButton(icon: Icon(Icons.arrow_back, size: 30, color: Colors.white,), onPressed: () {
              Navigator.pop(context);
            },),
            title:
            Text("Login", style: TextStyle(fontSize: 28, color: Colors.white),)

        ),
        body:SingleChildScrollView(
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
                            )
                            ,
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
                          obscureText: true,
                          cursorColor: Colors.black,
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
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.red, width: 1),
                            ),

                          ),
                          validator: (value) {
                            if (value == null||value.isEmpty) return 'Please enter Password';
                            return null;
                          } ,
                        ),

                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.blue), fixedSize: WidgetStatePropertyAll(Size.fromWidth(320)), padding: WidgetStatePropertyAll(EdgeInsets.all(8))),
                        onPressed: _signIn, child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 23)) ,
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Don't have an account?",style: TextStyle(fontSize: 18,),),
                          TextButton(onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => signup()));
                          },
                              child: Text("Create an account", style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),))

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
  void _signIn() async{

    String email = _emailController.text;
    String password = _passwordController.text;
    User? user = await _auth.signInWithEmailAndPassword(email, password);
    if(_formKey.currentState!.validate()) {
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => account()));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("User does not exist or an unknown error occurred!")));
      }
    }
  }

}
