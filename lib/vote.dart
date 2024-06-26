import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ParticipantVotesPage extends StatefulWidget {
  const ParticipantVotesPage({Key? key}) : super(key: key);

  @override
  _ParticipantVotesPageState createState() => _ParticipantVotesPageState();
}

class _ParticipantVotesPageState extends State<ParticipantVotesPage> {
  List<Map<String, dynamic>> _votes = [];
  late Timer _timer;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _fetchVotes();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _votes.forEach((vote) {
          if (vote['remaining_time'] != null) {
            if (vote['remaining_time'].compareTo(Duration.zero) <= 0) {
              vote['remaining_time'] = Duration.zero;
              timer.cancel();
            } else {
              vote['remaining_time'] -= const Duration(seconds: 1);
            }
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer
    super.dispose();
  }

  Future<void> _fetchVotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('participant_id') ?? 0;

    final response = await http.post(
      Uri.parse(
          'http://regestrationrenion.atwebpages.com/participant_votes.php'),
      body: {'user_id': userId.toString()},
    );

    if (response.statusCode == 200) {
      setState(() {
        _votes = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _votes.forEach((vote) {
          DateTime closingDate = DateTime.parse(vote['closing_date']);
          Duration difference = closingDate.difference(DateTime.now());
          vote['remaining_time'] = difference;
        });
      });
    } else {
      print('Failed to fetch votes: ${response.statusCode}');
    }
  }

  Future<void> _submitVote(
      String voteId, String optionId, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('participant_id') ?? 0;

    final response = await http.post(
      Uri.parse('http://regestrationrenion.atwebpages.com/submit_vote.php'),
      body: {
        'user_id': userId.toString(),
        'vote_id': voteId,
        'option_id': optionId,
      },
    );

    if (response.statusCode == 200) {
      if (response.body == "AlreadyVoted") {
        _showSnackBar('You have already voted for this vote', context);
      } else {
        await _fetchVotes();
        _showSnackBar('Vote submitted successfully', context);
      }
    } else {
      print('Failed to submit vote: ${response.statusCode}');
      _showSnackBar('Failed to submit vote. Please try again.', context);
    }
  }

  void _showSnackBar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back), // Use an arrow back icon
        onPressed: () {
          Navigator.of(context).pop(); // Pop the current screen
        },
      ),
    ),
    key: _scaffoldKey,
    body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/4.png'),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _votes.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Aucun vote n\'existe 😞',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _votes.length,
                    itemBuilder: (context, index) {
                      final vote = _votes[index];
                      final List<dynamic> options = vote['options'];
                      DateTime closingDate = DateTime.parse(vote['closing_date']);
                      Duration difference = closingDate.difference(DateTime.now());
                      String remainingTime;
                      bool voteClosed = false;
                      if (difference.isNegative) {
                        remainingTime = 'Voting closed';
                        voteClosed = true;
                      } else {
                        int days = difference.inDays;
                        int hours = difference.inHours.remainder(24);
                        int minutes = difference.inMinutes.remainder(60);
                        int seconds = difference.inSeconds.remainder(60);
                        remainingTime =
                            'Remaining time: $days days, $hours hours, $minutes minutes, $seconds seconds';
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(28, 120, 117, 0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Image.asset('assets/images/pu2.png', fit: BoxFit.contain),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${vote['title']}',
                                        style: const TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Description:',
                                      style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${vote['description']}',
                                      style: const TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(28, 120, 117, 0.4),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: double.infinity,
                                        child: Image.asset('assets/images/clo.png', fit: BoxFit.contain),
                                      ),
                                      const SizedBox(height: 5),
                                      const Text(
                                        "Le dernier délai :",
                                        style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        remainingTime,
                                        style: const TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: options.map<Widget>((option) {
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(250, 166, 66, 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      option.toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Radio(
                                      value: option.toString(),
                                      groupValue: vote['selected_option'],
                                      onChanged: voteClosed
                                          ? null
                                          : (value) {
                                              setState(() {
                                                vote['selected_option'] = value;
                                              });
                                            },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          ElevatedButton(
                            onPressed: voteClosed
                                ? null
                                : () async {
                                    if (vote['selected_option'] != null) {
                                      await _submitVote(
                                          vote['id'],
                                          vote['selected_option'].toString(),
                                          context);
                                    } else {
                                      _showSnackBar(
                                          'Please select an option', context);
                                    }
                                  },
                            child: const Text('Vote'),
                          ),
                        ],
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