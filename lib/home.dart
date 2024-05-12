import 'package:sgovs/login.dart';
import 'package:sgovs/reunion.dart';
import 'package:sgovs/vote.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    setState(() {
      isLoggedIn = false;
    });
    // Navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        automaticallyImplyLeading: false, // This line removes the back button
        actions: [
          if (isLoggedIn)
            IconButton(
              onPressed: () {
                logout();
              },
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
  height: 200,
  decoration: BoxDecoration(
    image: const DecorationImage(
      image: AssetImage('assets/images/45.png'),
      fit: BoxFit.cover,
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  margin: const EdgeInsets.only(top: 30, bottom: 10),
  padding: const EdgeInsets.only(left: 100, right: 100),
  child: const Image(
    image: AssetImage('assets/images/l1.png'),
    height: 50, // Set the desired height
    width: 90, // Set the desired width
  ),
),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.46,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(28, 120, 117, 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 100,
                            child: Image.asset('assets/images/v.png'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Réunion",
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Reunion()),
                      );
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.46,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(28, 120, 117, 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 100,
                            child: Image.asset('assets/images/v2.png'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Vote",
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyApp()),
                      );
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.46,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(28, 120, 117, 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 100,
                            child: Image.asset('assets/images/b2.png'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Bibliothèque \n numérique",
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    onTap: () {},
                  ),
                  GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      height: 200,
                      width: MediaQuery.of(context).size.width * 0.46,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(28, 120, 117, 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 100,
                            child: Image.asset('assets/images/bb2.png'),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Bourse",
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
