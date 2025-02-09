import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:whoami/features/category/domain/models/category_model.dart';
import 'package:whoami/features/game/domain/models/player_score_model.dart';
import 'package:whoami/core/utils/orientation_manager.dart';
import 'package:whoami/features/game/presentation/pages/game_over_page.dart';

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
  bool _canEvaluate = true;
  bool _waitingForReset = false;
  Timer? _evaluationTimer;
  double _lastZValue = 0; //This value is used to check if the phone is in the correct position.Don't delete this.
  late List<PlayerScore> _playerScores;
  Timer? _gameTimer;  // Timer'ı tutmak için değişken ekleyelim

  @override
  void initState() {
    super.initState();
    // Oyun sayfasında yatay mod
    OrientationManager.forceLandscape();
    _remainingWords = List.from(widget.category.items);
    _currentPlayer = widget.players[_currentPlayerIndex];
    _remainingTime = widget.timePerPlayer;
    // Oyuncu skorlarını başlat
    _playerScores = widget.players
        .map((name) => PlayerScore(name: name))
        .toList();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();  // Timer'ı temizle
    _evaluationTimer?.cancel();
    _accelerometerSubscription?.cancel();
    OrientationManager.forcePortrait();
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
      _canEvaluate = true;
      _waitingForReset = false;
      _lastZValue = 0;
    });

    // Accelerometer dinlemeye başla
    _accelerometerSubscription = SensorsPlatform.instance
        .accelerometerEventStream()
        .listen((event) {
      if (!_canEvaluate || !_isPlaying) return;

      final zValue = event.z;
      
      // Eğer düz konuma dönüş bekliyorsak ve telefon düz konuma geldiyse
      if (_waitingForReset && zValue > -6 && zValue < 6) {
        setState(() {
          _waitingForReset = false;  // Düz konuma geldi, yeni değerlendirmelere hazır
          _canEvaluate = true;
        });
        return;
      }

      // Düz konuma dönüş bekliyorsak yeni değerlendirme yapma
      if (_waitingForReset) return;

      // Doğru için: Z >= 7.51
      if (zValue >= 7.51) {
        _startEvaluationTimer(() {
          _handleCorrect();
          setState(() => _waitingForReset = true);  // Düz konuma dönüş bekle
        });
      }
      // Yanlış için: Z <= -7.51
      else if (zValue <= -7.51) {
        _startEvaluationTimer(() {
          _handleWrong();
          setState(() => _waitingForReset = true);  // Düz konuma dönüş bekle
        });
      }
      
      _lastZValue = zValue;
    });

    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();  // Varsa önceki timer'ı iptal et
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          timer.cancel();
          _nextPlayer();
        }
      });
    });
  }

  void _startEvaluationTimer(VoidCallback action) {
    // Eğer timer zaten çalışıyorsa yeni timer başlatma
    if (_evaluationTimer?.isActive ?? false) return;

    _evaluationTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted && _isPlaying) {
        action();
      }
    });
  }

  void _handleCorrect() async {
    await SystemSound.play(SystemSoundType.alert);
    await HapticFeedback.lightImpact();
    setState(() {
      _playerScores[_currentPlayerIndex].correct++;
      _currentWord = _getRandomWord();
    });
  }

  void _handleWrong() async {
    await SystemSound.play(SystemSoundType.click);
    await HapticFeedback.mediumImpact();
    setState(() {
      _playerScores[_currentPlayerIndex].wrong++;
      _currentWord = _getRandomWord();
    });
  }

  String _getRandomWord() {
    if (_remainingWords.isEmpty) {
      // Kelimeler bittiyse sonraki oyuncuya geç
      _nextPlayer();
      // Kelime listesini yeniden doldur
      _remainingWords = List.from(widget.category.items);
    }
    
    final random = Random();
    final index = random.nextInt(_remainingWords.length);
    final word = _remainingWords[index];
    _remainingWords.removeAt(index);
    return word;
  }

  void _nextPlayer() {
    _gameTimer?.cancel();  // Oyuncu değişirken timer'ı durdur
    _accelerometerSubscription?.cancel();
    
    if (!mounted) return;  // mounted kontrolü ekle
    
    setState(() {
      if (_currentPlayerIndex == widget.players.length - 1) {
        _showGameResults();
      } else {
        _currentPlayerIndex = (_currentPlayerIndex + 1);
        _currentPlayer = widget.players[_currentPlayerIndex];
        _isReady = false;
        _isPlaying = false;
        _countdown = 3;
        _remainingTime = widget.timePerPlayer;
      }
    });
  }

  void _showGameResults() {
    if (!mounted) return;  // mounted kontrolü ekle
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameOverPage(
          scores: _playerScores,
          category: widget.category,
          timePerPlayer: widget.timePerPlayer,
          players: widget.players,
        ),
      ),
    );
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