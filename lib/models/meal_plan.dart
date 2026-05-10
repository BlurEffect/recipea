class MealPlan {
  /// Maps date strings ("yyyy-MM-dd") to an ordered list of recipe IDs.
  /// A null entry in the list means an empty slot (user added it but hasn't
  /// picked a recipe yet).
  final Map<String, List<String?>> daySlots;

  const MealPlan({required this.daySlots});

  factory MealPlan.empty() => const MealPlan(daySlots: {});

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<String?> getSlotsForDay(DateTime date) =>
      daySlots[_dateKey(date)] ?? const [];

  /// Adds an empty slot to the given day.
  MealPlan addSlot(DateTime date) {
    final key = _dateKey(date);
    final slots = <String?>[...(daySlots[key] ?? []), null];
    return MealPlan(daySlots: {...daySlots, key: slots});
  }

  /// Removes the slot at [index] for the given day.
  MealPlan removeSlot(DateTime date, int index) {
    final key = _dateKey(date);
    final slots = <String?>[...(daySlots[key] ?? [])];
    if (index < 0 || index >= slots.length) return this;
    slots.removeAt(index);
    final newDaySlots = Map<String, List<String?>>.from(daySlots);
    if (slots.isEmpty) {
      newDaySlots.remove(key);
    } else {
      newDaySlots[key] = slots;
    }
    return MealPlan(daySlots: newDaySlots);
  }

  /// Sets (or clears) the recipe assigned to slot [index] on [date].
  MealPlan setSlotRecipe(DateTime date, int index, String? recipeId) {
    final key = _dateKey(date);
    final slots = <String?>[...(daySlots[key] ?? [])];
    if (index < 0 || index >= slots.length) return this;
    slots[index] = recipeId;
    return MealPlan(daySlots: {...daySlots, key: slots});
  }

  /// Adds a new slot at the end of [date]'s list and assigns [recipeId] to it.
  MealPlan addRecipeToDay(DateTime date, String recipeId) {
    final key = _dateKey(date);
    final slots = <String?>[...(daySlots[key] ?? []), recipeId];
    return MealPlan(daySlots: {...daySlots, key: slots});
  }

  Set<String> get assignedRecipeIds =>
      daySlots.values.expand((s) => s).whereType<String>().toSet();

  Map<String, dynamic> toJson() => {
        'daySlots': daySlots.map(
          (k, v) => MapEntry(k, v.toList()),
        ),
      };

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final raw = (json['daySlots'] as Map?)?.cast<String, dynamic>() ?? {};
    return MealPlan(
      daySlots: raw.map(
        (k, v) => MapEntry(
          k,
          (v as List).map((id) => id as String?).toList(),
        ),
      ),
    );
  }
}
