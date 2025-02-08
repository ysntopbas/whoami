import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:whoami/features/category/domain/models/category_model.dart';

class GamePlayPage extends StatefulWidget {
  final CategoryModel category;
  final List<String> players;
  final int timePerPlayer;

  const GamePlayPage({
    super.key,
    required this.category,
    required this.players,
    required this.timePerPlayer,
  });

  @override
  State<GamePlayPage> createState() => _GamePlayPageState();
}

class _GamePlayPageState extends State<GamePlayPage> {
  late List<String> _remainingWords;
  late String _currentWord;
  late String _currentPlayer;
  int _currentPlayerIndex = 0;
  bool _isReady = false;
  bool _isCountingDown = false;
  bool _isPlaying = false;
  int _countdown = 3;
  late int _remainingTime;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    _remainingWords = List.from(widget.category.items);
    _currentPlayer = widget.players[_currentPlayerIndex];
    _remainingTime = widget.timePerPlayer;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _startCountdown() async {
    setState(() {
      _isReady = true;
      _isCountingDown = true;
    });

    // Geri sayım sesi
    for (var i = _countdown; i > 0; i--) {
      if (!mounted) return;
      await SystemSound.play(SystemSoundType.click); // Basit tık sesi
      setState(() => _countdown--);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (mounted) {
      await HapticFeedback.heavyImpact(); // Başlangıç için titreşim
      _startGame();
    }
  }

  void _startGame() {
    setState(() {
      _isCountingDown = false;
      _isPlaying = true;
      _currentWord = _getRandomWord();
    });

    // İvmeölçer dinlemeye başla
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (event.z.abs() > 12) { // Telefon yukarı/aşağı hareket
        if (event.z > 0) {
          _handleCorrect();
        } else {
          _handleWrong();
        }
      }
    });

    // Zamanlayıcı başlat
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (!mounted || !_isPlaying) return false;
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
        return true;
      } else {
        _nextPlayer();
        return false;
      }
    });
  }

  void _handleCorrect() async {
    await SystemSound.play(SystemSoundType.alert); // Doğru için uyarı sesi
    await HapticFeedback.lightImpact(); // Hafif titreşim
    setState(() => _currentWord = _getRandomWord());
  }

  void _handleWrong() async {
    await SystemSound.play(SystemSoundType.click); // Yanlış için tık sesi
    await HapticFeedback.mediumImpact(); // Orta şiddette titreşim
    setState(() => _currentWord = _getRandomWord());
  }

  String _getRandomWord() {
    if (_remainingWords.isEmpty) {
      _isPlaying = false;
      return 'game_over'.tr();
    }
    
    final random = Random();
    final index = random.nextInt(_remainingWords.length);
    final word = _remainingWords[index];
    _remainingWords.removeAt(index);
    return word;
  }

  void _nextPlayer() {
    _accelerometerSubscription?.cancel();
    setState(() {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % widget.players.length;
      _currentPlayer = widget.players[_currentPlayerIndex];
      _isReady = false;
      _isPlaying = false;
      _countdown = 3;
      _remainingTime = widget.timePerPlayer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Oyuncu adı ve zamanlayıcı
                Column(
                  children: [
                    if (_isPlaying)
                      Text(
                        _remainingTime.toString(),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: _remainingTime <= 10 ? Colors.red : Colors.black,
                        ),
                      ),
                    Text(
                      _currentPlayer,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Kelime veya hazırlık durumu
                if (!_isReady)
                  ElevatedButton(
                    onPressed: _startCountdown,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      'ready'.tr(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  )
                else if (_isCountingDown)
                  Text(
                    _countdown.toString(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  Text(
                    _currentWord,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                if (_isPlaying)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'tilt_phone_hint'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 