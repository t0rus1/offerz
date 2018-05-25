import 'package:flutter/material.dart';

import 'package:offerz/globals.dart' as globals;
import 'package:offerz/helpers/utils.dart' as utils;
import 'package:offerz/ui/primary_button.dart';
import 'package:offerz/auth.dart';
import 'package:offerz/ui/theme.dart';
import 'package:offerz/ui/gradient_appbar.dart';


typedef void VoidCallback();
typedef void VoidCallbackForString(String string);

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title, this.auth, this.onSignIn, this.onRegister }) : super(key: key);

  final String title;
  final BaseAuth auth;  
  final VoidCallback onSignIn;
  final VoidCallbackForString onRegister;

  @override
  _LoginPageState createState() => new _LoginPageState();
}

enum FormType {
  login,
  register
}

class _LoginPageState extends State<LoginPage> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();  
  static final formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  FormType _formType = FormType.login;
  String _authHint = globals.promotion;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }
  
  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        String userId = _formType == FormType.login
            ? await widget.auth.signIn(_email, _password)
            : await widget.auth.createUser(_email, _password);
        setState(() {
          ///TODO: make _authHint more user friendly
          _authHint = 'Signed In\nUser $userId';
        });
        if (_formType == FormType.login) {
          widget.onSignIn();
        } else {
          widget.onRegister(_email);
        }
      }
      catch (e) {
        setState(() {
          ///TODO: make _authHint more user friendly
          _authHint = 'Sign In Error\n\n${e.toString()}';          
        });
        print(e);
      }
    } else {
      setState(() {
        _authHint = '';
      });
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
      _authHint = '';
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
      _authHint = '';
    });
  }

  List<Widget> usernameAndPassword() {
    return [
      utils.padded(child: new TextFormField(
        key: new Key('email'),
        decoration: new InputDecoration(labelText: 'Email'),
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Email can\'t be empty.' : null,
        onSaved: (val) => _email = val.trim(),
      )),
      utils.padded(child: new TextFormField(
        key: new Key('password'),
        decoration: new InputDecoration(labelText: 'Password'),
        obscureText: true,
        autocorrect: false,
        validator: (val) => val.isEmpty ? 'Password can\'t be empty.' : null,
        onSaved: (val) => _password = val,
      )),
    ];
  }

  List<Widget> submitWidgets() {
    switch (_formType) {
      case FormType.login:
        return [
          new PrimaryButton(           
            key: new Key('login'),
            text: 'Login',
            height: 44.0,
            onPressed: validateAndSubmit,             
          ),
          new FlatButton(
            key: new Key('need-account'),
            child: new Text("Need an account? Register"),
            onPressed: moveToRegister
          ),
        ];
      case FormType.register:
        return [
          new PrimaryButton(
            key: new Key('register'),
            text: 'Create an account',
            height: 44.0,
            onPressed: validateAndSubmit
          ),
          new FlatButton(
            key: new Key('need-login'),
            child: new Text("Have an account? Login"),
            onPressed: moveToLogin
          ),
        ];
    }
    return null;
  }

  Widget hintText() {

    //transient snackbar to draw attention to a failed sign in
    if (_authHint.contains('Error')) {
      final snackbar = new SnackBar(
        content: new Text('Sign In failed'),  
      );
      scaffoldKey.currentState.showSnackBar(snackbar);      
    }

    return new Container(
        //height: 80.0,
        padding: const EdgeInsets.all(16.0),
        child: new Text(
            _authHint,
            key: new Key('hint'),
            style: new TextStyle(
              fontSize: 18.0, 
              color: Colors.yellow,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center)
    );
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(       
      key: scaffoldKey,
      backgroundColor: AppThemeColors.main[900],
      body: new SingleChildScrollView(child: new Container(
        padding: const EdgeInsets.all(0.0),
        child: new Column(
          children: [
            GradientAppBar(widget.title),            
            new Card(
              child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Container(
                    padding: const EdgeInsets.all(16.0),
                    child: new Form(
                        key: formKey,
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: usernameAndPassword() + submitWidgets(),
                        )
                    )
                ),
              ])
            ),
            hintText()
          ]
        )
      ))
    );
  }

}

