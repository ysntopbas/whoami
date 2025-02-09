import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whoami/core/utils/orientation_manager.dart';
import 'package:whoami/features/category/domain/models/category_model.dart';
import 'package:whoami/features/game/presentation/pages/game_play_page.dart';

final playerListProvider = StateNotifierProvider<PlayerListNotifier, List<String>>((ref) {
  return PlayerListNotifier();
});

class PlayerListNotifier extends StateNotifier<List<String>> {
  PlayerListNotifier() : super([]) {
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final players = prefs.getStringList('players') ?? [];
    state = players;
  }

  Future<void> _savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('players', state);
  }

  void addPlayer(String name) {
    if (!state.contains(name)) {
      state = [...state, name];
      _savePlayers();
    }
  }

  void removePlayer(String name) {
    state = state.where((player) => player != name).toList();
    _savePlayers();
  }
}

class GameSettingsPage extends ConsumerStatefulWidget {
  final CategoryModel category;

  const GameSettingsPage({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends ConsumerState<GameSettingsPage> {
  final _playerController = TextEditingController();
  int _timePerPlayer = 60; // Varsayılan süre: 60 saniye

  @override
  void initState() {
    super.initState();
    OrientationManager.forcePortrait();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    OrientationManager.forcePortrait();
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final name = _playerController.text.trim();
    if (name.isNotEmpty) {
      ref.read(playerListProvider.notifier).addPlayer(name);
      _playerController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playerListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('game_settings'.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kategori Bilgisi
            Card(
              child: ListTile(
                leading: Text(
                  widget.category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(widget.category.name),
                subtitle: Text(
                  '${widget.category.items.length} ${"word".tr()}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Oyuncu Ekleme
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _playerController,
                    decoration: InputDecoration(
                      labelText: 'player_name'.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addPlayer,
                  child: Text('add_player'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Oyuncu Listesi
            Expanded(
              child: Card(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(player),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          ref.read(playerListProvider.notifier).removePlayer(player);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Süre Ayarı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'time_per_player'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _timePerPlayer.toDouble(),
                            min: 30,
                            max: 180,
                            divisions: 15,
                            label: '$_timePerPlayer ${"seconds".tr()}',
                            onChanged: (value) {
                              setState(() {
                                _timePerPlayer = value.round();
                              });
                            },
                          ),
                        ),
                        Text('$_timePerPlayer ${"seconds".tr()}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Başlat Butonu
            ElevatedButton(
              onPressed: players.length >= 2
                  ? () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePlayPage(
                            category: widget.category,
                            players: players,
                            timePerPlayer: _timePerPlayer,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text('start_game'.tr()),
            ),
          ],
        ),
      ),
    );
  }
} 