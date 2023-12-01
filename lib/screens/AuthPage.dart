import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mycamerafilter/auth.dart';
import 'package:video_player/video_player.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLogin = true;

  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    isLogin;
    _controller = VideoPlayerController.asset("assets/LoginPage.mp4")
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    Future<void> singIn() async {
      try {
        await Auth()
            .singWithEmailPassword(email: _email.text, password: _password.text)
            .whenComplete(() => showSnackBoxLogin());
      } on FirebaseAuthException catch (error) {
        print(error);
      }
    }

    Future<void> createUser() async {
      try {
        await Auth()
            .createWithEmailPassword(
                email: _email.text, password: _password.text)
            .whenComplete(() => showSnackBoxCreate());
      } on FirebaseAuthException catch (error) {
        print(error);
      }
    }

    @override
    void initState() {
      super.initState();
    }

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _email,
                  cursorColor: Colors.red,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      label: Text("Email"),
                      icon: Icon(Icons.email),
                      labelStyle: TextStyle(color: Colors.white),
                      floatingLabelStyle: TextStyle(
                        color: Colors.red,
                        fontSize: 25,
                        height: -0.5,
                      ),
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      iconColor: Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _password,
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      label: Text("Password"),
                      labelStyle: TextStyle(color: Colors.white),
                      icon: Icon(Icons.password),
                      floatingLabelStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 25,
                        height: -0.5,
                      ),
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      iconColor: Colors.blue),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    isLogin ? singIn() : createUser();
                  },
                  child: Text(isLogin ? "Accedi" : "Registrati")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(isLogin
                      ? "non hai un account? Registrati"
                      : "Non hai un account accedi"))
            ],
          ),
        ],
      ),
    );
  }

  showSnackBoxLogin() {
    AnimatedSnackBar.rectangle("Success", "Benvenuto: ${Auth().getEmail()}",
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 4),
            animationDuration: Duration(milliseconds: 500),
            animationCurve: Curves.easeIn,
            mobileSnackBarPosition: MobileSnackBarPosition.top,
            brightness: Brightness.dark)
        .show(context);
  }

  showSnackBoxCreate() {
    AnimatedSnackBar.rectangle("Success", "Utente Creato con successo!",
            type: AnimatedSnackBarType.success,
            duration: const Duration(seconds: 4),
            animationDuration: Duration(milliseconds: 500),
            animationCurve: Curves.easeIn,
            mobileSnackBarPosition: MobileSnackBarPosition.top,
            brightness: Brightness.dark)
        .show(context);
  }
}
