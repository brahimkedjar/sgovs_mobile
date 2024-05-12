import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/images/45.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.fromLTRB(5.0, 30.0, 5.0, 10.0),
                    padding: const EdgeInsets.only(left: 0.0, top: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        Image.asset(
                          'assets/images/l1.png',
                        ),
                        const Text(
                          "S G O V S",
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(250, 166, 66, 1),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "System Governance Solution",
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(28, 120, 117, 1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '   “Empowering Governance \n    Accelerate Success”',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20,
                      color: Color.fromRGBO(58, 65, 69, 1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50), // Adjust spacing here
                ],
              ),
            ),
          ),
          Padding(
  padding: const EdgeInsets.all(20.0),
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    },
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(
        const Color.fromRGBO(250, 166, 66, 1),
      ),
    ),
    child: const Text(
      'Commencer',
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
    ),
  ),
),

        ],
      ),
    );
  }
}
