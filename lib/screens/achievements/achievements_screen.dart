import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/character_definitions.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/achievement_provider.dart';
import '../../theme/app_colors.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(achievementProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l.achievementsTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.achievementsHintUnlock,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l.achievementsFavoriteHint,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: characters.length,
                      itemBuilder: (context, index) {
                        final character = characters[index];
                        final isUnlocked = state.unlockedIds.contains(character.id);
                        final isRevealed = state.revealedIds.contains(character.id);
                        final isFavorite = state.favoriteId == character.id;
                        return _CharacterCard(
                          character: character,
                          isUnlocked: isUnlocked,
                          isRevealed: isRevealed,
                          isFavorite: isFavorite,
                          onReveal: isUnlocked && !isRevealed
                              ? () => ref
                                  .read(achievementProvider.notifier)
                                  .reveal(character.id)
                              : null,
                          onSetFavorite: isRevealed
                              ? () => ref
                                  .read(achievementProvider.notifier)
                                  .setFavorite(character.id)
                              : null,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.deepOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bug_report, size: 14, color: Colors.deepOrange),
                            SizedBox(width: 4),
                            Text(
                              'DEBUG',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.deepOrange,
                                  side: const BorderSide(color: Colors.deepOrange),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () => ref
                                    .read(achievementProvider.notifier)
                                    .resetToTestDefaults(),
                                child: const Text('Reset to test state'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.deepOrange,
                                  side: const BorderSide(color: Colors.deepOrange),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () => ref
                                    .read(achievementProvider.notifier)
                                    .fullReset(),
                                child: const Text('Full reset'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CharacterCard extends StatefulWidget {
  final CharacterDefinition character;
  final bool isUnlocked;
  final bool isRevealed;
  final bool isFavorite;
  final VoidCallback? onReveal;
  final VoidCallback? onSetFavorite;

  const _CharacterCard({
    required this.character,
    required this.isUnlocked,
    required this.isRevealed,
    required this.isFavorite,
    required this.onReveal,
    required this.onSetFavorite,
  });

  @override
  State<_CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<_CharacterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_CharacterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.isRevealed && !widget.isRevealed) ||
        (oldWidget.isUnlocked && !widget.isUnlocked)) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFlip() {
    if (!widget.isUnlocked || widget.isRevealed || _controller.isAnimating) {
      return;
    }
    _controller.forward().then((_) {
      widget.onReveal?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Already revealed: static card, tap to set favorite
    if (widget.isRevealed) {
      return GestureDetector(
        onTap: widget.onSetFavorite,
        child: _RevealedFace(
          character: widget.character,
          isFavorite: widget.isFavorite,
        ),
      );
    }

    // Locked: static locked card, no interaction
    if (!widget.isUnlocked) {
      return _LockedFace(character: widget.character);
    }

    // Unlocked but not yet revealed: flip animation on tap
    return GestureDetector(
      onTap: _handleFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value;
          final showingBack = angle > pi / 2;

          Widget face;
          double rotateY;
          if (!showingBack) {
            rotateY = angle;
            face = _FrontFace(character: widget.character);
          } else {
            rotateY = angle - pi;
            face = _RevealedFace(character: widget.character, isFavorite: false);
          }

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotateY),
            alignment: Alignment.center,
            child: face,
          );
        },
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  final CharacterDefinition character;

  const _FrontFace({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_open_outlined, size: 28, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              character.unlockCondition,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _RevealedFace extends StatelessWidget {
  final CharacterDefinition character;
  final bool isFavorite;

  const _RevealedFace({required this.character, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: character.color,
            borderRadius: BorderRadius.circular(16),
            border: isFavorite
                ? Border.all(color: Colors.amber, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: character.color.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    character.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                child: Text(
                  character.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (isFavorite)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, size: 14, color: Colors.white),
            ),
          ),
      ],
    );
  }
}

class _LockedFace extends StatelessWidget {
  final CharacterDefinition character;

  const _LockedFace({required this.character});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 28, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              character.unlockCondition,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
