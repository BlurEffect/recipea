class MealSlot {
  final String recipeId;
  final int? servings;

  const MealSlot({required this.recipeId, this.servings});

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        if (servings != null) 'servings': servings,
      };

  factory MealSlot.fromJson(dynamic json) {
    if (json is String) return MealSlot(recipeId: json);
    final map = (json as Map).cast<String, dynamic>();
    return MealSlot(
      recipeId: map['recipeId'] as String,
      servings: map['servings'] as int?,
    );
  }
}

class MealPlan {
  /// Maps date strings ("yyyy-MM-dd") to an ordered list of meal slots.
  /// A null entry in the list means an empty slot (transitional state only —
  /// the UI ensures all slots have a recipe assigned).
  final Map<String, List<MealSlot?>> daySlots;

  /// Date keys of days the user has unchecked (excluded from shopping list).
  /// Absence from this set means the day is included (checked) by default.
  final Set<String> excludedDates;

  const MealPlan({required this.daySlots, this.excludedDates = const {}});

  factory MealPlan.empty() => const MealPlan(daySlots: {});

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  List<MealSlot?> getSlotsForDay(DateTime date) =>
      daySlots[_dateKey(date)] ?? const [];

  bool isDayIncluded(DateTime date) =>
      !excludedDates.contains(_dateKey(date));

  MealPlan toggleExcludedDate(DateTime date) {
    final key = _dateKey(date);
    final updated = Set<String>.from(excludedDates);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    return MealPlan(daySlots: daySlots, excludedDates: updated);
  }

  /// Adds an empty slot to the given day.
  MealPlan addSlot(DateTime date) {
    final key = _dateKey(date);
    final slots = <MealSlot?>[...(daySlots[key] ?? []), null];
    return MealPlan(daySlots: {...daySlots, key: slots}, excludedDates: excludedDates);
  }

  /// Removes the slot at [index] for the given day.
  MealPlan removeSlot(DateTime date, int index) {
    final key = _dateKey(date);
    final slots = <MealSlot?>[...(daySlots[key] ?? [])];
    if (index < 0 || index >= slots.length) return this;
    slots.removeAt(index);
    final newDaySlots = Map<String, List<MealSlot?>>.from(daySlots);
    if (slots.isEmpty) {
      newDaySlots.remove(key);
    } else {
      newDaySlots[key] = slots;
    }
    return MealPlan(daySlots: newDaySlots, excludedDates: excludedDates);
  }

  /// Sets (or clears) the recipe assigned to slot [index] on [date].
  /// Preserves any existing serving override for that slot.
  MealPlan setSlotRecipe(DateTime date, int index, String? recipeId) {
    final key = _dateKey(date);
    final slots = <MealSlot?>[...(daySlots[key] ?? [])];
    if (index < 0 || index >= slots.length) return this;
    final existing = slots[index];
    slots[index] = recipeId == null
        ? null
        : MealSlot(recipeId: recipeId, servings: existing?.servings);
    return MealPlan(daySlots: {...daySlots, key: slots}, excludedDates: excludedDates);
  }

  /// Sets (or clears) the serving override for slot [index] on [date].
  /// Pass null to remove the override and fall back to the recipe's default.
  MealPlan setSlotServings(DateTime date, int index, int? servings) {
    final key = _dateKey(date);
    final slots = <MealSlot?>[...(daySlots[key] ?? [])];
    if (index < 0 || index >= slots.length) return this;
    final existing = slots[index];
    if (existing == null) return this;
    slots[index] = MealSlot(recipeId: existing.recipeId, servings: servings);
    return MealPlan(daySlots: {...daySlots, key: slots}, excludedDates: excludedDates);
  }

  /// Adds a new slot at the end of [date]'s list and assigns [recipeId] to it.
  MealPlan addRecipeToDay(DateTime date, String recipeId) {
    final key = _dateKey(date);
    final slots = <MealSlot?>[...(daySlots[key] ?? []), MealSlot(recipeId: recipeId)];
    return MealPlan(daySlots: {...daySlots, key: slots}, excludedDates: excludedDates);
  }

  Set<String> get assignedRecipeIds =>
      daySlots.values
          .expand((s) => s)
          .whereType<MealSlot>()
          .map((s) => s.recipeId)
          .toSet();

  MealPlan copyWith({
    Map<String, List<MealSlot?>>? daySlots,
    Set<String>? excludedDates,
  }) =>
      MealPlan(
        daySlots: daySlots ?? this.daySlots,
        excludedDates: excludedDates ?? this.excludedDates,
      );

  Map<String, dynamic> toJson() => {
        'daySlots': daySlots.map(
          (k, v) => MapEntry(k, v.map((s) => s?.toJson()).toList()),
        ),
        'excludedDates': excludedDates.toList(),
      };

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final raw = (json['daySlots'] as Map?)?.cast<String, dynamic>() ?? {};
    final excluded = (json['excludedDates'] as List?)
            ?.cast<String>()
            .toSet() ??
        const <String>{};
    return MealPlan(
      daySlots: raw.map(
        (k, v) => MapEntry(
          k,
          (v as List)
              .map((item) => item == null ? null : MealSlot.fromJson(item))
              .toList(),
        ),
      ),
      excludedDates: excluded,
    );
  }
}
