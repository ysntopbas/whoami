import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:confetti/confetti.dart';
import 'package:whoami/features/category/domain/models/category_model.dart';
import 'package:whoami/features/game/domain/models/player_score_model.dart';
import 'package:whoami/features/home/presentation/pages/home_page.dart';
import 'package:whoami/features/game/presentation/pages/game_play_page.dart';

class GameResultsPage extends StatefulWidget {
  final List<PlayerScore> scores;
  final CategoryModel category;
  final int timePerPlayer;
  final List<String> players;

  const GameResultsPage({
    super.key,
    required this.scores,
    required this.category,
    required this.timePerPlayer,
    required this.players,
  });

  @override
  State<GameResultsPage> createState() => _GameResultsPageState();
}

class _GameResultsPageState extends State<GameResultsPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    // Ekranı dikey moda zorla
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    // Konfeti efektini başlat
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    // Tüm yönleri serbest bırak
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedScores = List<PlayerScore>.from(widget.scores)
      ..sort((a, b) => b.total.compareTo(a.total));
    
    final winner = sortedScores.first;

    return Scaffold(
      body: Stack(
        children: [
          // Konfeti efekti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.2,
              shouldLoop: true,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
          
          // Ana içerik
          SafeArea(
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
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Game Over başlığı
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'game_over'.tr(),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Kazanan başlığı
                  Text(
                    'winner'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Kazanan kartı
                  Card(
                    color: Colors.green.shade100,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.emoji_events, color: Colors.white),
                      ),
                      title: Text(
                        winner.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      subtitle: Text(
                        '${'correct'.tr()}: ${winner.correct} | ${'wrong'.tr()}: ${winner.wrong}',
                      ),
                      trailing: Text(
                        'total'.tr(args: [winner.total.toString()]),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Diğer oyuncular
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: sortedScores.length - 1,
                      itemBuilder: (context, index) {
                        final score = sortedScores[index + 1];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 2}'),
                            ),
                            title: Text(score.name),
                            subtitle: Text(
                              '${'correct'.tr()}: ${score.correct} | ${'wrong'.tr()}: ${score.wrong}',
                            ),
                            trailing: Text(
                              'total'.tr(args: [score.total.toString()]),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Butonlar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const HomePage()),
                              (route) => false,
                            );
                          },
                          icon: const Icon(Icons.home),
                          label: Text('main_menu'.tr()),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GamePlayPage(
                                  category: widget.category,
                                  players: widget.players,
                                  timePerPlayer: widget.timePerPlayer,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.replay),
                          label: Text('play_again'.tr()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 