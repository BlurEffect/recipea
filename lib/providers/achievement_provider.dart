import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/hive_boxes.dart';

class AchievementState {
  final Set<String> unlockedIds;
  final Set<String> revealedIds;
  final String favoriteId;

  const AchievementState({
    required this.unlockedIds,
    required this.revealedIds,
    required this.favoriteId,
  });
}

class AchievementNotifier extends StateNotifier<AchievementState> {
  AchievementNotifier() : super(_load());

  static AchievementState _load() {
    final box = Hive.box<String>(HiveBoxes.achievements);
    final rawUnlocked = box.get('unlocked');
    final Set<String> unlocked = rawUnlocked != null
        ? Set<String>.from(jsonDecode(rawUnlocked) as List)
        : {'recipea', 'carl', 'poppy'};
    final rawRevealed = box.get('revealed');
    final Set<String> revealed = rawRevealed != null
        ? Set<String>.from(jsonDecode(rawRevealed) as List)
        : {'recipea'};
    final favorite = box.get('favorite') ?? 'recipea';
    return AchievementState(
      unlockedIds: unlocked,
      revealedIds: revealed,
      favoriteId: favorite,
    );
  }

  void unlock(String id) {
    if (state.unlockedIds.contains(id)) return;
    final updated = {...state.unlockedIds, id};
    _save(updated, state.revealedIds, state.favoriteId);
    state = AchievementState(
      unlockedIds: updated,
      revealedIds: state.revealedIds,
      favoriteId: state.favoriteId,
    );
  }

  void reveal(String id) {
    if (!state.unlockedIds.contains(id) || state.revealedIds.contains(id)) return;
    final updated = {...state.revealedIds, id};
    _save(state.unlockedIds, updated, state.favoriteId);
    state = AchievementState(
      unlockedIds: state.unlockedIds,
      revealedIds: updated,
      favoriteId: state.favoriteId,
    );
  }

  void setFavorite(String id) {
    if (!state.revealedIds.contains(id)) return;
    _save(state.unlockedIds, state.revealedIds, id);
    state = AchievementState(
      unlockedIds: state.unlockedIds,
      revealedIds: state.revealedIds,
      favoriteId: id,
    );
  }

  void resetToTestDefaults() {
    const unlocked = {'recipea', 'carl', 'poppy'};
    const revealed = {'recipea'};
    const favorite = 'recipea';
    _save(unlocked, revealed, favorite);
    state = const AchievementState(
      unlockedIds: unlocked,
      revealedIds: revealed,
      favoriteId: favorite,
    );
  }

  void fullReset() {
    _save({}, {}, 'recipea');
    state = const AchievementState(
      unlockedIds: {},
      revealedIds: {},
      favoriteId: 'recipea',
    );
  }

  void _save(Set<String> unlocked, Set<String> revealed, String favorite) {
    final box = Hive.box<String>(HiveBoxes.achievements);
    box.put('unlocked', jsonEncode(unlocked.toList()));
    box.put('revealed', jsonEncode(revealed.toList()));
    box.put('favorite', favorite);
  }
}

final achievementProvider =
    StateNotifierProvider<AchievementNotifier, AchievementState>(
  (ref) => AchievementNotifier(),
);
