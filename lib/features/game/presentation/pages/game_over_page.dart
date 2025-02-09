import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:whoami/core/utils/orientation_manager.dart';
import 'package:whoami/features/category/domain/models/category_model.dart';
import 'package:whoami/features/game/domain/models/player_score_model.dart';
import 'package:whoami/features/game/presentation/pages/game_results_page.dart';

class GameOverPage extends StatefulWidget {
  final List<PlayerScore> scores;
  final CategoryModel category;
  final int timePerPlayer;
  final List<String> players;

  const GameOverPage({
    super.key,
    required this.scores,
    required this.category,
    required this.timePerPlayer,
    required this.players,
  });

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage> {
  @override
  void initState() {
    super.initState();
    OrientationManager.forcePortrait();
    
    // 2 saniye sonra otomatik olarak sonuç sayfasına git
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => GameResultsPage(
              scores: widget.scores,
              category: widget.category,
              timePerPlayer: widget.timePerPlayer,
              players: widget.players,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              // Game Over Text
              Text(
                'game_over'.tr(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),
              
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 