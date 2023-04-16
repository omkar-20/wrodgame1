import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:words_wave/constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin, WidgetsBindingObserver{
  late AppLifecycleState appLifecycle;
  final player1 = AudioPlayer();
  final player2 = AudioPlayer();
  final player3 = AudioPlayer();
  final player4 = AudioPlayer();
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController =
      AnimationController(vsync: this);
  late Animation _animation;
  final ValueNotifier<int> char = ValueNotifier<int>(97);
  late Timer _timer;
  bool isCharMatched = false;

  didChangeAppLifecycleState(AppLifecycleState state) {
    appLifecycle = state;

    if(state == AppLifecycleState.paused) {
      print('My app is in background');
      player1.pause();
      player2.pause();
      player3.pause();
      player4.pause();
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    player1.play(
        DeviceFileSource(Constants.defaultSound));
    setAudio();
    animationPlay();
    debugPrint(_animation.value.toString());
    player1.play(
        DeviceFileSource(Constants.defaultSound));
    _animationController.forward();
    startTimer();
  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _controller.dispose();
    player1.dispose();
    player2.dispose();
    player3.dispose();
    player4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SizedBox(
            height: size.height * 0.9,
            width: size.width,
            child: Align(
              alignment: Alignment.topCenter,
              child: ValueListenableBuilder(
                valueListenable: char,
                builder: (BuildContext context, value, Widget? child) {
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.translate(
                        offset:
                            Offset(0, _animation.value * (size.height - 75)),
                        child: Text(
                          String.fromCharCode(char.value),
                          style: const TextStyle(fontSize: 30),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: WaveWidget(
              config: CustomConfig(
                colors: [
                  Colors.blue.shade400,
                ],
                durations: [4000],
                heightPercentages: [0.25],
              ),
              waveAmplitude: 0,
              waveFrequency: 1,
              size: const Size(
                double.infinity,
                100,
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: 20,
            child: Container(
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: true,
                  showCursor: true,
                  onSubmitted: (value) async {
                    if (value == String.fromCharCode(char.value)) {
                      player1.stop();
                      _animationController.stop();
                      player3.play(DeviceFileSource(
                          Constants.charMatching));
                      await Future.delayed(const Duration(seconds: 3), () {
                        player3.stop();
                        _timer.cancel();
                        _animationController.reset();
                        char.value=char.value+1;
                        player1.play(DeviceFileSource(
                            Constants.defaultSound));
                        animationPlay();
                        _animationController.forward();
                        startTimer();
                        isCharMatched = true;

                      });
                    } else {
                      player1.stop();
                      _animationController.stop();
                      player4.play(DeviceFileSource(
                          Constants.charnotMatching));
                      await Future.delayed(const Duration(seconds: 3), () {
                        player4.stop();
                        _timer.cancel();
                        _animationController.reset();
                        char.value=char.value+1;
                        player1.play(DeviceFileSource(
                            Constants.defaultSound));
                        animationPlay();
                        _animationController.forward();
                        startTimer();
                        isCharMatched = true;
                      });
                    }
                    _controller.clear();
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search',
                    icon: Icon(Icons.search),
                  ),
                )),
          ),
        ],
      ),
    );
  }
  startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      _animationController.dispose();
      if (isCharMatched) {
        player1.play(DeviceFileSource(
            Constants.defaultSound));
        setAudio();
        isCharMatched = false;
      }
      char.value = (char.value + 1);
      if (char.value > 122) {
        char.value = 97;
      }
      animationPlay();
      await player1.play(DeviceFileSource(
          Constants.defaultSound));
      _animationController.forward();
    });
  }
  animationPlay(){
    _animationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 6));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await player1.stop();
          await player2.play(DeviceFileSource(
              Constants.aphabetFalling));
        }
        Timer(const Duration(seconds: 3), () async {
          await player2.stop();
        });
      });
  }
  Future setAudio() async {
    player1.setReleaseMode(ReleaseMode.loop);
    await player1.play(
        DeviceFileSource(Constants.defaultSound));
  }
}
