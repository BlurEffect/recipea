// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get update => 'Update';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get replace => 'Replace';

  @override
  String get skip => 'Skip';

  @override
  String get clear => 'Clear';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get create => 'Create';

  @override
  String get notNow => 'Not now';

  @override
  String get allow => 'Allow';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get noRecipesFound => 'No recipes found';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navMealPlan => 'Meal Plan';

  @override
  String get navShopping => 'Shopping';

  @override
  String get navCharacters => 'Characters';

  @override
  String get navMore => 'More';

  @override
  String get moreDataProtection => 'Data Protection';

  @override
  String get moreImprint => 'Imprint';

  @override
  String get legalDataProtectionPlaceholder =>
      'Data protection statement coming soon.';

  @override
  String get legalImprintPlaceholder => 'Imprint coming soon.';

  @override
  String get browseSearchHint => 'Search recipes…';

  @override
  String get browseFilterHint => 'Filter by tags...';

  @override
  String get browseEmptyTitle => 'No recipes yet';

  @override
  String get browseEmptySubtitle => 'Tap the + button to add your first recipe';

  @override
  String browseSearchEmptyTitle(String query) {
    return 'No recipes match \"$query\"';
  }

  @override
  String get browseSearchEmptySubtitle => 'Try a different search term';

  @override
  String get browseFilterEmptyTitle => 'No recipes match these filters';

  @override
  String get browseFilterEmptySubtitle => 'Try removing some filters';

  @override
  String get browseNoRecipesFoundSubtitle =>
      'Try clearing the search or filters';

  @override
  String get browseClearSearch => 'Clear search';

  @override
  String get browseClearFilters => 'Clear filters';

  @override
  String get browseClearAll => 'Clear all';

  @override
  String get browseExportBackup => 'Export full backup';

  @override
  String get browseImportRecipes => 'Import recipes';

  @override
  String get browseExportBackupTitle => 'Export full backup';

  @override
  String get browseExportBackupBody =>
      'Exports all your recipes, categories, tags, and meal plan history. Use this to back up your data or migrate to a new device.';

  @override
  String browseExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get browseImportFailed =>
      'Import failed. Make sure you\'re using a .recipea or .json file exported from this app.';

  @override
  String get browseImportNothingNew => 'Nothing new to import';

  @override
  String browseImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Imported $count recipes',
      one: 'Imported 1 recipe',
    );
    return '$_temp0';
  }

  @override
  String get browseDuplicatesTitle => 'Duplicate recipes';

  @override
  String browseDuplicatesExist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes already exist:',
      one: '1 recipe already exists:',
    );
    return '$_temp0';
  }

  @override
  String get browseDuplicatesReplace =>
      'Replace them with the imported versions?';

  @override
  String get sortTitleAsc => 'A → Z';

  @override
  String get sortTitleDesc => 'Z → A';

  @override
  String get sortNewestFirst => 'Newest first';

  @override
  String get sortOldestFirst => 'Oldest first';

  @override
  String get sortLastCookedDesc => 'Recently cooked';

  @override
  String get sortLastCookedAsc => 'Cook next';

  @override
  String get goToRecipes => 'Go to Recipes';

  @override
  String get detailEditTooltip => 'Edit recipe';

  @override
  String get detailHomeTooltip => 'All recipes';

  @override
  String get detailAddToMealPlan => 'Add to Meal Plan';

  @override
  String get detailExportRecipe => 'Export recipe';

  @override
  String get detailExportPdf => 'Export as PDF';

  @override
  String get detailDuplicate => 'Duplicate';

  @override
  String get detailDeleteMenuLabel => 'Delete';

  @override
  String detailDeleteTitle(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get detailDeleteBody => 'This cannot be undone.';

  @override
  String detailExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String detailPdfFailed(String error) {
    return 'PDF export failed: $error';
  }

  @override
  String get detailPartOf => 'PART OF';

  @override
  String get detailServes => 'Serves';

  @override
  String detailServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servings',
      one: '1 serving',
    );
    return '$_temp0';
  }

  @override
  String get detailSeparate => 'Separate';

  @override
  String get detailCombined => 'Combined';

  @override
  String get detailThisRecipe => 'This recipe';

  @override
  String detailFromComponent(String title) {
    return 'from $title';
  }

  @override
  String get detailIngredients => 'Ingredients';

  @override
  String get detailSteps => 'Steps';

  @override
  String get detailDescription => 'Cook\'s notes';

  @override
  String get detailRecipeNotFound => 'Recipe not found';

  @override
  String get detailDeletedComponent => 'Deleted component';

  @override
  String get editNewRecipe => 'New Recipe';

  @override
  String get editExistingRecipe => 'Edit Recipe';

  @override
  String get editTitleLabel => 'Title';

  @override
  String get editTitleHint => 'Recipe name';

  @override
  String get editServingsLabel => 'Servings';

  @override
  String get editDescriptionHint =>
      'Special equipment, tips, anything to know before starting (optional)';

  @override
  String get editTagsLabel => 'Tags';

  @override
  String get editAddTagsButton => 'Add tags';

  @override
  String get editNoTagsSelected => 'No tags selected';

  @override
  String get editFromComponents => 'From components';

  @override
  String get editManageCategories => 'Manage categories';

  @override
  String get editIngredientsLabel => 'Ingredients';

  @override
  String get editStepsLabel => 'Steps';

  @override
  String get editComponentsLabel => 'Components';

  @override
  String get editComponentsDescription =>
      'Link other recipes as building blocks. Their steps and ingredients will be combined into this recipe.';

  @override
  String get editAddComponent => 'Add component recipe';

  @override
  String editSaveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get editUnsavedTitle => 'Unsaved changes';

  @override
  String get editUnsavedBody => 'Discard your changes?';

  @override
  String get editDiscard => 'Discard';

  @override
  String get editQtyHint => 'Qty';

  @override
  String get editUnitHint => 'Unit';

  @override
  String get editIngredientNameHint => 'Ingredient name';

  @override
  String get editNoteHint => 'Note (e.g. \"to taste\", \"finely chopped\")';

  @override
  String get editAddIngredient => 'Add ingredient';

  @override
  String editStepHint(int number) {
    return 'Step $number...';
  }

  @override
  String get editAddStep => 'Add step';

  @override
  String get editNoStepsYet => 'No steps yet';

  @override
  String get editAddStepToRecipe => 'Add step to this recipe';

  @override
  String get editComponentSelf => 'This recipe';

  @override
  String get editComponentDeleted => '(deleted)';

  @override
  String get editPickComponent => 'Add component recipe';

  @override
  String get editSearchRecipesHint => 'Search…';

  @override
  String get editNoRecipesMatch => 'No recipes match';

  @override
  String get editCycleWarning => 'Would create a cycle';

  @override
  String get editNoRecipesAvailable => 'No recipes available to link';

  @override
  String get editStepsInOrder => 'Steps within a recipe must stay in order';

  @override
  String get editStepOrderCustom => 'Custom step order';

  @override
  String get editStepOrderReset => 'Reset order';

  @override
  String get editChangePhoto => 'Change photo';

  @override
  String get editAddPhoto => 'Add a photo';

  @override
  String get editStepImagesLabel => 'Step images';

  @override
  String get editHideImages => 'Hide';

  @override
  String get editShowImages => 'Show';

  @override
  String get editPleaseAddTitle => 'Please add a title';

  @override
  String get editMicTitle => 'Microphone access';

  @override
  String get editMicDeniedBody =>
      'Microphone permission was permanently denied. Enable it in Settings to use voice input while writing recipe steps.';

  @override
  String get editVoiceInputTitle => 'Voice input';

  @override
  String get editVoiceInputBody =>
      'Allow microphone access so you can use voice input to dictate recipe steps and other fields.';

  @override
  String get mealPlanSubtitle => 'Check days to include in shopping list';

  @override
  String get mealPlanClearPlan => 'Clear plan';

  @override
  String get mealPlanClearTitle => 'Clear meal plan?';

  @override
  String get mealPlanClearBody => 'All recipe assignments will be removed.';

  @override
  String get mealPlanAddMeal => 'Add meal';

  @override
  String get mealPlanRemoveMeal => 'Remove meal';

  @override
  String get mealPlanChangeRecipe => 'Change recipe';

  @override
  String get mealPlanChooseRecipe => 'Choose a recipe';

  @override
  String get mealPlanSearchRecipes => 'Search recipes...';

  @override
  String get mealPlanNoRecipes => 'No recipes yet';

  @override
  String get mealPlanNoRecipesSubtitle =>
      'Add some recipes first, then plan your meals here';

  @override
  String mealPlanToday(String date) {
    return 'Today — $date';
  }

  @override
  String get mealPlanNoResults => 'No recipes found';

  @override
  String get mealPlanSetServings => 'Change servings';

  @override
  String get mealPlanResetServings => 'Reset to default';

  @override
  String get shoppingListTitle => 'Shopping List';

  @override
  String get shoppingGenerateTooltip => 'Generate shopping list';

  @override
  String get shoppingShareTooltip => 'Share list';

  @override
  String get shoppingClearCheckedTooltip => 'Clear checked';

  @override
  String get shoppingEmptyTitle => 'No shopping list yet';

  @override
  String get shoppingEmptySubtitle =>
      'Assign recipes in the Meal Plan, then tap refresh';

  @override
  String shoppingGeneratedOn(String date) {
    return 'Generated $date';
  }

  @override
  String get shoppingClearCheckedTitle => 'Remove checked items?';

  @override
  String get shoppingClearCheckedBody => 'All ticked items will be deleted.';

  @override
  String get shoppingShareCheckedOff => 'Everything has been checked off!';

  @override
  String get shoppingShareHeader => 'Shopping list';

  @override
  String get shoppingRegenerateTitle => 'Regenerate list?';

  @override
  String get shoppingRegenerateBody => 'Your checked-off items will be lost.';

  @override
  String get shoppingRegenerateAction => 'Regenerate';

  @override
  String get shoppingGoToMealPlan => 'Go to Meal Plan';

  @override
  String get shoppingEmptyGeneratedTitle => 'Shopping list is empty';

  @override
  String get shoppingEmptyGeneratedSubtitle =>
      'Your meal plan has no ingredients to list';

  @override
  String get tagSelectorTitle => 'Select Tags';

  @override
  String get tagSelectorTapHint => 'Tap once to include · tap twice to exclude';

  @override
  String get tagSelectorSearchHint => 'Search tags...';

  @override
  String get tagSelectorManage => 'Manage categories';

  @override
  String get tagSelectorNewTag => 'New tag';

  @override
  String get tagSelectorNewTagTitle => 'New Tag';

  @override
  String get tagSelectorTagNameHint => 'Tag name';

  @override
  String get tagSelectorCategoryLabel => 'Category';

  @override
  String get categoryManagerTitle => 'Manage Categories';

  @override
  String get categoryManagerAddCategory => 'Add category';

  @override
  String get categoryManagerRenameHint => 'Category name';

  @override
  String get categoryManagerAddTag => 'Add tag';

  @override
  String get categoryManagerTagHint => 'Tag name';

  @override
  String get categoryManagerNewTitle => 'New Category';

  @override
  String get categoryManagerEditTitle => 'Edit Category';

  @override
  String get categoryManagerColorLabel => 'Color';

  @override
  String get categoryManagerNoCats => 'No categories yet';

  @override
  String get categoryManagerNoTags => 'No tags';

  @override
  String get categoryManagerDeleteCatTitle => 'Delete category?';

  @override
  String categoryManagerDeleteCatPermanent(String name) {
    return '\'$name\' will be permanently deleted.';
  }

  @override
  String categoryManagerDeleteCatTagsLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Also deletes $count tags.',
      one: 'Also deletes 1 tag.',
      zero: 'No tags will be affected.',
    );
    return '$_temp0';
  }

  @override
  String categoryManagerDeleteCatRecipesLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' And removes them from $count recipes.',
      one: ' And removes it from 1 recipe.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get categoryManagerDeleteTagTitle => 'Delete tag?';

  @override
  String categoryManagerDeleteTagPermanent(String name) {
    return '\'$name\' will be permanently deleted.';
  }

  @override
  String categoryManagerDeleteTagBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'It will be removed from $count recipes.',
      one: 'It will be removed from 1 recipe.',
      zero: 'It is not used in any recipe.',
    );
    return '$_temp0';
  }

  @override
  String get addToMealPlanTitle => 'Add to Meal Plan';

  @override
  String addToMealPlanChooseDay(String title) {
    return 'Choose a day to add \"$title\"';
  }

  @override
  String addToMealPlanToday(String date) {
    return 'Today — $date';
  }

  @override
  String addToMealPlanAdded(String date) {
    return 'Added to $date';
  }

  @override
  String addToMealPlanPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes planned',
      one: '1 recipe planned',
    );
    return '$_temp0';
  }

  @override
  String get imagePickFromLibrary => 'Choose from library';

  @override
  String get imagePickTakePhoto => 'Take a photo';

  @override
  String get imagePickRemove => 'Remove photo';

  @override
  String get imagePickCropTitle => 'Crop photo';

  @override
  String get pdfIngredients => 'Ingredients';

  @override
  String get pdfSteps => 'Steps';

  @override
  String pdfServes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Serves $count',
      one: 'Serves 1',
    );
    return '$_temp0';
  }

  @override
  String pdfFrom(String title) {
    return 'from $title';
  }

  @override
  String pdfPageOf(int page, int total) {
    return 'Page $page of $total';
  }

  @override
  String get pdfAppName => 'Recipea';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageDe => 'German';

  @override
  String get browseCharacters => 'Characters';

  @override
  String get achievementsTitle => 'Characters';

  @override
  String get achievementsHintUnlock =>
      'Complete challenges to unlock additional characters';

  @override
  String get achievementsFavoriteHint =>
      'Tap a revealed character to set it as your favorite';

  @override
  String get unitTeaspoon => 'tsp';

  @override
  String get unitTablespoon => 'tbsp';

  @override
  String get unitCup => 'cup';

  @override
  String get unitPiece => 'piece';

  @override
  String get unitSlice => 'slice';

  @override
  String get unitClove => 'clove';

  @override
  String get unitBunch => 'bunch';

  @override
  String get unitPinch => 'pinch';

  @override
  String get unitCan => 'can';

  @override
  String get unitSprig => 'sprig';

  @override
  String get unitHead => 'head';

  @override
  String get unitStalk => 'stalk';

  @override
  String get unitHandful => 'handful';
}
