import 'package:flutter/material.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(alignment: Alignment.bottomCenter, children: [
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/background.png',
                ),
                fit: BoxFit.cover,
              ),
            )),
        Container(
          height: MediaQuery.of(context).size.height / 2.5,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                const Text(
                  "Expressfull self and Chatsta",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "It's time to express yourself and chat with your friends",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                SwipeableButtonView(
                  onFinish: () {},
                  onWaitingProcess: () {},
                  activeColor: Colors.blue,
                  buttonWidget: Container(
                    child: Icon(
                      CupertinoIcons.chevron_right_2,
                      color: Colors.grey,
                    ),
                  ),
                  buttonText: "Swipe to start",
                )
              ],
            ),
          ),
        )
      ]),
    );
  }
}
