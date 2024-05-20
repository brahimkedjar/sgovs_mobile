import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Bourse extends StatelessWidget {
  const Bourse({Key? key}) : super(key: key);

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        shrinkWrap: true,
        children: [
          GestureDetector(
            onTap: () {
              _launchURL('https://www.sgbv.dz/');
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(28, 120, 117, 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "SGBV Actualités",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _launchURL('https://www.sgbv.dz/?page=boc&lang=fr');
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(28, 120, 117, 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  "consulter les bulteins de cotations",
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
