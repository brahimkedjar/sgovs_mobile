import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Reunion extends StatefulWidget {
  const Reunion({super.key});

  @override
  State<Reunion> createState() => _ReunionState();
}

class _ReunionState extends State<Reunion> with SingleTickerProviderStateMixin {
  String MeetName = "CA24/11/24";
  List<Map<String, dynamic>> _meetings = [];
  List<Map<String, dynamic>> _preparationMeetings = [];
  List<Map<String, dynamic>>? _enCoursMeetings = [];
  List<Map<String, dynamic>> _termineesMeetings = [];

  PageController _pageController = PageController();
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _fetchMeetings();
    _pageController = PageController();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMeetings() async {
    final response = await http.get(
        Uri.parse('http://regestrationrenion.atwebpages.com/get_meetings.php'));

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> allMeetings =
          jsonDecode(response.body).cast<Map<String, dynamic>>();
      final DateTime currentDate = DateTime.now();

      setState(() {
        _meetings = allMeetings;
        _enCoursMeetings = [];
        _preparationMeetings = [];
        _termineesMeetings = [];

        for (var meeting in allMeetings) {
          final DateTime meetingDate = DateTime.parse(meeting['date']);

          if (meetingDate.isAfter(currentDate)) {
            _preparationMeetings.add(meeting);
          } else if (meetingDate.year == currentDate.year &&
              meetingDate.month == currentDate.month &&
              meetingDate.day == currentDate.day) {
            _enCoursMeetings?.add(meeting);
          } else {
            _termineesMeetings.add(meeting);
          }
        }
      });
    } else {
      throw Exception('Failed to fetch meetings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
            });
          },
          children: [
            Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    const Text(
                      "Réunions Programmées",
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      height: 200,
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 0.0,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 60,
                        right: 60,
                        top: 20,
                        bottom: 0,
                      ),
                      child: Image.asset(
                        'assets/images/v.png',
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _meetings.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(28, 120, 117, 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                              top: 0,
                              bottom: 10.0,
                            ),
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(28, 120, 117, 0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Image.asset('assets/images/pu.png'),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _meetings[index]['title'],
                                        style: const TextStyle(
                                            fontFamily: 'Sora',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.alarm,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "${_meetings[index]['date']} á ${_meetings[index]['time']}",
                                            style: const TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.place_outlined,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            _meetings[index]['location'],
                                            style: const TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(197, 131, 45, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.download,
                                          color: Colors.white),
                                      onPressed: () {},
                                    ),
                                  ),
                                ]),
                          );
                        },
                      ),
                    ),
                  ],
                )),
            Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    const Text(
                      "Réunions En cours ...",
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      height: 230,
                      margin: const EdgeInsets.only(
                        left: 5.0,
                        right: 5.0,
                        top: 10.0,
                        bottom: 0,
                      ),
                      padding: const EdgeInsets.only(
                        left: 60,
                        right: 60,
                        top: 0,
                        bottom: 10.0,
                      ),
                      child: Image.asset(
                        'assets/images/1.png',
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _enCoursMeetings?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(28, 120, 117, 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.only(
                              left: 5.0,
                              right: 5.0,
                              top: 0,
                              bottom: 10.0,
                            ),
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              top: 10,
                              bottom: 10,
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 80,
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(28, 120, 117, 0.3),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Image.asset('assets/images/pu.png'),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _enCoursMeetings?[index]['title'] ?? '',
                                        style: const TextStyle(
                                            fontFamily: 'Sora',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.alarm,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            _enCoursMeetings?[index]['date'] ??
                                                '',
                                            style: const TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.place_outlined,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            _enCoursMeetings?[index]
                                                    ['location'] ??
                                                '',
                                            style: const TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(197, 131, 45, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.download,
                                          color: Colors.white),
                                      onPressed: () {},
                                    ),
                                  ),
                                ]),
                          );
                        },
                      ),
                    ),
                  ],
                )),
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/4.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    "Réunions Terminées",
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 200,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    padding: const EdgeInsets.only(
                        left: 60, right: 60, top: 0, bottom: 10),
                    child: Image.asset(
                      'assets/images/c.png',
                      height: 150, // Adjust the height of the image
                      width: 150, // Adjust the width of the image
                    ),
                  ),
                  Expanded(
  child: ListView.builder(
    itemCount: _meetings.length,
    itemBuilder: (BuildContext context, int index) {
      if (index < _termineesMeetings.length) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(28, 120, 117, 0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(28, 120, 117, 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset('assets/images/333.png'),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _termineesMeetings[index]['title'],
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.alarm, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        "${_termineesMeetings[index]['date']}",
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        _termineesMeetings[index]['location'],
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(197, 131, 45, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.download, color: Colors.white),
                  onPressed: () {
                    // Handle download action
                  },
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(); // Return an empty container if _termineesMeetings doesn't have enough items
      }
    },
  ),
),

                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(197, 131, 45, 1),
            //color: Colors.blue,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                child: const Text(
                  "programmées",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
              TextButton(
                child: const Text(
                  "en cours",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _pageController.animateToPage(
                    1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
              TextButton(
                child: const Text(
                  "terminées",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  _pageController.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
