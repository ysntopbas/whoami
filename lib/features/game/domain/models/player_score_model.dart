class PlayerScore {
  final String name;
  int correct;
  int wrong;

  PlayerScore({
    required this.name,
    this.correct = 0,
    this.wrong = 0,
  });

  int get total => correct - wrong;
} 