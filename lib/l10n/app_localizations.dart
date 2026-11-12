import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @noRecipesFound.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get noRecipesFound;

  /// No description provided for @navRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get navRecipes;

  /// No description provided for @navMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Meal Plan'**
  String get navMealPlan;

  /// No description provided for @navShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get navShopping;

  /// No description provided for @navCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get navCharacters;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @moreDataProtection.
  ///
  /// In en, this message translates to:
  /// **'Data Protection'**
  String get moreDataProtection;

  /// No description provided for @moreImprint.
  ///
  /// In en, this message translates to:
  /// **'Imprint'**
  String get moreImprint;

  /// No description provided for @legalDataProtectionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Data protection statement coming soon.'**
  String get legalDataProtectionPlaceholder;

  /// No description provided for @legalImprintPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Imprint coming soon.'**
  String get legalImprintPlaceholder;

  /// No description provided for @browseSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes…'**
  String get browseSearchHint;

  /// No description provided for @browseFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter by tags...'**
  String get browseFilterHint;

  /// No description provided for @browseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get browseEmptyTitle;

  /// No description provided for @browseEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first recipe'**
  String get browseEmptySubtitle;

  /// No description provided for @browseSearchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes match \"{query}\"'**
  String browseSearchEmptyTitle(String query);

  /// No description provided for @browseSearchEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get browseSearchEmptySubtitle;

  /// No description provided for @browseFilterEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recipes match these filters'**
  String get browseFilterEmptyTitle;

  /// No description provided for @browseFilterEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try removing some filters'**
  String get browseFilterEmptySubtitle;

  /// No description provided for @browseNoRecipesFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try clearing the search or filters'**
  String get browseNoRecipesFoundSubtitle;

  /// No description provided for @browseClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get browseClearSearch;

  /// No description provided for @browseClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get browseClearFilters;

  /// No description provided for @browseClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get browseClearAll;

  /// No description provided for @browseExportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export full backup'**
  String get browseExportBackup;

  /// No description provided for @browseImportRecipes.
  ///
  /// In en, this message translates to:
  /// **'Import recipes'**
  String get browseImportRecipes;

  /// No description provided for @browseExportBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Export full backup'**
  String get browseExportBackupTitle;

  /// No description provided for @browseExportBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Exports all your recipes, categories, tags, and meal plan history. Use this to back up your data or migrate to a new device.'**
  String get browseExportBackupBody;

  /// No description provided for @browseExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String browseExportFailed(String error);

  /// No description provided for @browseImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed. Make sure you\'re using a .recipea or .json file exported from this app.'**
  String get browseImportFailed;

  /// No description provided for @browseImportNothingNew.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to import'**
  String get browseImportNothingNew;

  /// No description provided for @browseImportedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Imported 1 recipe} other{Imported {count} recipes}}'**
  String browseImportedCount(int count);

  /// No description provided for @browseDuplicatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate recipes'**
  String get browseDuplicatesTitle;

  /// No description provided for @browseDuplicatesExist.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe already exists:} other{{count} recipes already exist:}}'**
  String browseDuplicatesExist(int count);

  /// No description provided for @browseDuplicatesReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace them with the imported versions?'**
  String get browseDuplicatesReplace;

  /// No description provided for @sortTitleAsc.
  ///
  /// In en, this message translates to:
  /// **'A → Z'**
  String get sortTitleAsc;

  /// No description provided for @sortTitleDesc.
  ///
  /// In en, this message translates to:
  /// **'Z → A'**
  String get sortTitleDesc;

  /// No description provided for @sortNewestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sortNewestFirst;

  /// No description provided for @sortOldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldestFirst;

  /// No description provided for @sortLastCookedDesc.
  ///
  /// In en, this message translates to:
  /// **'Recently cooked'**
  String get sortLastCookedDesc;

  /// No description provided for @sortLastCookedAsc.
  ///
  /// In en, this message translates to:
  /// **'Cook next'**
  String get sortLastCookedAsc;

  /// No description provided for @goToRecipes.
  ///
  /// In en, this message translates to:
  /// **'Go to Recipes'**
  String get goToRecipes;

  /// No description provided for @detailEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get detailEditTooltip;

  /// No description provided for @detailHomeTooltip.
  ///
  /// In en, this message translates to:
  /// **'All recipes'**
  String get detailHomeTooltip;

  /// No description provided for @detailAddToMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal Plan'**
  String get detailAddToMealPlan;

  /// No description provided for @detailExportRecipe.
  ///
  /// In en, this message translates to:
  /// **'Export recipe'**
  String get detailExportRecipe;

  /// No description provided for @detailExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get detailExportPdf;

  /// No description provided for @detailDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get detailDuplicate;

  /// No description provided for @detailDeleteMenuLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get detailDeleteMenuLabel;

  /// No description provided for @detailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String detailDeleteTitle(String title);

  /// No description provided for @detailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get detailDeleteBody;

  /// No description provided for @detailExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String detailExportFailed(String error);

  /// No description provided for @detailPdfFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF export failed: {error}'**
  String detailPdfFailed(String error);

  /// No description provided for @detailPartOf.
  ///
  /// In en, this message translates to:
  /// **'PART OF'**
  String get detailPartOf;

  /// No description provided for @detailServes.
  ///
  /// In en, this message translates to:
  /// **'Serves'**
  String get detailServes;

  /// No description provided for @detailServings.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 serving} other{{count} servings}}'**
  String detailServings(int count);

  /// No description provided for @detailSeparate.
  ///
  /// In en, this message translates to:
  /// **'Separate'**
  String get detailSeparate;

  /// No description provided for @detailCombined.
  ///
  /// In en, this message translates to:
  /// **'Combined'**
  String get detailCombined;

  /// No description provided for @detailThisRecipe.
  ///
  /// In en, this message translates to:
  /// **'This recipe'**
  String get detailThisRecipe;

  /// No description provided for @detailFromComponent.
  ///
  /// In en, this message translates to:
  /// **'from {title}'**
  String detailFromComponent(String title);

  /// No description provided for @detailIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get detailIngredients;

  /// No description provided for @detailSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get detailSteps;

  /// No description provided for @detailDescription.
  ///
  /// In en, this message translates to:
  /// **'Cook\'s notes'**
  String get detailDescription;

  /// No description provided for @detailRecipeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recipe not found'**
  String get detailRecipeNotFound;

  /// No description provided for @detailDeletedComponent.
  ///
  /// In en, this message translates to:
  /// **'Deleted component'**
  String get detailDeletedComponent;

  /// No description provided for @editNewRecipe.
  ///
  /// In en, this message translates to:
  /// **'New Recipe'**
  String get editNewRecipe;

  /// No description provided for @editExistingRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editExistingRecipe;

  /// No description provided for @editTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get editTitleLabel;

  /// No description provided for @editTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Recipe name'**
  String get editTitleHint;

  /// No description provided for @editServingsLabel.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get editServingsLabel;

  /// No description provided for @editDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Special equipment, tips, anything to know before starting (optional)'**
  String get editDescriptionHint;

  /// No description provided for @editTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get editTagsLabel;

  /// No description provided for @editAddTagsButton.
  ///
  /// In en, this message translates to:
  /// **'Add tags'**
  String get editAddTagsButton;

  /// No description provided for @editNoTagsSelected.
  ///
  /// In en, this message translates to:
  /// **'No tags selected'**
  String get editNoTagsSelected;

  /// No description provided for @editFromComponents.
  ///
  /// In en, this message translates to:
  /// **'From components'**
  String get editFromComponents;

  /// No description provided for @editManageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get editManageCategories;

  /// No description provided for @editIngredientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get editIngredientsLabel;

  /// No description provided for @editStepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get editStepsLabel;

  /// No description provided for @editComponentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Components'**
  String get editComponentsLabel;

  /// No description provided for @editComponentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Link other recipes as building blocks. Their steps and ingredients will be combined into this recipe.'**
  String get editComponentsDescription;

  /// No description provided for @editAddComponent.
  ///
  /// In en, this message translates to:
  /// **'Add component recipe'**
  String get editAddComponent;

  /// No description provided for @editSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String editSaveFailed(String error);

  /// No description provided for @editUnsavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsaved changes'**
  String get editUnsavedTitle;

  /// No description provided for @editUnsavedBody.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get editUnsavedBody;

  /// No description provided for @editDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get editDiscard;

  /// No description provided for @editQtyHint.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get editQtyHint;

  /// No description provided for @editUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get editUnitHint;

  /// No description provided for @editIngredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name'**
  String get editIngredientNameHint;

  /// No description provided for @editNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Note (e.g. \"to taste\", \"finely chopped\")'**
  String get editNoteHint;

  /// No description provided for @editAddIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get editAddIngredient;

  /// No description provided for @editStepHint.
  ///
  /// In en, this message translates to:
  /// **'Step {number}...'**
  String editStepHint(int number);

  /// No description provided for @editAddStep.
  ///
  /// In en, this message translates to:
  /// **'Add step'**
  String get editAddStep;

  /// No description provided for @editNoStepsYet.
  ///
  /// In en, this message translates to:
  /// **'No steps yet'**
  String get editNoStepsYet;

  /// No description provided for @editAddStepToRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add step to this recipe'**
  String get editAddStepToRecipe;

  /// No description provided for @editComponentSelf.
  ///
  /// In en, this message translates to:
  /// **'This recipe'**
  String get editComponentSelf;

  /// No description provided for @editComponentDeleted.
  ///
  /// In en, this message translates to:
  /// **'(deleted)'**
  String get editComponentDeleted;

  /// No description provided for @editPickComponent.
  ///
  /// In en, this message translates to:
  /// **'Add component recipe'**
  String get editPickComponent;

  /// No description provided for @editSearchRecipesHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get editSearchRecipesHint;

  /// No description provided for @editNoRecipesMatch.
  ///
  /// In en, this message translates to:
  /// **'No recipes match'**
  String get editNoRecipesMatch;

  /// No description provided for @editCycleWarning.
  ///
  /// In en, this message translates to:
  /// **'Would create a cycle'**
  String get editCycleWarning;

  /// No description provided for @editNoRecipesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recipes available to link'**
  String get editNoRecipesAvailable;

  /// No description provided for @editStepsInOrder.
  ///
  /// In en, this message translates to:
  /// **'Steps within a recipe must stay in order'**
  String get editStepsInOrder;

  /// No description provided for @editStepOrderCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom step order'**
  String get editStepOrderCustom;

  /// No description provided for @editStepOrderReset.
  ///
  /// In en, this message translates to:
  /// **'Reset order'**
  String get editStepOrderReset;

  /// No description provided for @editChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editChangePhoto;

  /// No description provided for @editAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo'**
  String get editAddPhoto;

  /// No description provided for @editPleaseAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Please add a title'**
  String get editPleaseAddTitle;

  /// No description provided for @editMicTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access'**
  String get editMicTitle;

  /// No description provided for @editMicDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission was permanently denied. Enable it in Settings to use voice input while writing recipe steps.'**
  String get editMicDeniedBody;

  /// No description provided for @editVoiceInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get editVoiceInputTitle;

  /// No description provided for @editVoiceInputBody.
  ///
  /// In en, this message translates to:
  /// **'Allow microphone access so you can use voice input to dictate recipe steps and other fields.'**
  String get editVoiceInputBody;

  /// No description provided for @mealPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check days to include in shopping list'**
  String get mealPlanSubtitle;

  /// No description provided for @mealPlanClearPlan.
  ///
  /// In en, this message translates to:
  /// **'Clear plan'**
  String get mealPlanClearPlan;

  /// No description provided for @mealPlanClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear meal plan?'**
  String get mealPlanClearTitle;

  /// No description provided for @mealPlanClearBody.
  ///
  /// In en, this message translates to:
  /// **'All recipe assignments will be removed.'**
  String get mealPlanClearBody;

  /// No description provided for @mealPlanAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get mealPlanAddMeal;

  /// No description provided for @mealPlanRemoveMeal.
  ///
  /// In en, this message translates to:
  /// **'Remove meal'**
  String get mealPlanRemoveMeal;

  /// No description provided for @mealPlanChangeRecipe.
  ///
  /// In en, this message translates to:
  /// **'Change recipe'**
  String get mealPlanChangeRecipe;

  /// No description provided for @mealPlanChooseRecipe.
  ///
  /// In en, this message translates to:
  /// **'Choose a recipe'**
  String get mealPlanChooseRecipe;

  /// No description provided for @mealPlanSearchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get mealPlanSearchRecipes;

  /// No description provided for @mealPlanNoRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get mealPlanNoRecipes;

  /// No description provided for @mealPlanNoRecipesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add some recipes first, then plan your meals here'**
  String get mealPlanNoRecipesSubtitle;

  /// No description provided for @mealPlanToday.
  ///
  /// In en, this message translates to:
  /// **'Today — {date}'**
  String mealPlanToday(String date);

  /// No description provided for @mealPlanNoResults.
  ///
  /// In en, this message translates to:
  /// **'No recipes found'**
  String get mealPlanNoResults;

  /// No description provided for @mealPlanSetServings.
  ///
  /// In en, this message translates to:
  /// **'Change servings'**
  String get mealPlanSetServings;

  /// No description provided for @mealPlanResetServings.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get mealPlanResetServings;

  /// No description provided for @shoppingListTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingListTitle;

  /// No description provided for @shoppingGenerateTooltip.
  ///
  /// In en, this message translates to:
  /// **'Generate shopping list'**
  String get shoppingGenerateTooltip;

  /// No description provided for @shoppingShareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share list'**
  String get shoppingShareTooltip;

  /// No description provided for @shoppingClearCheckedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear checked'**
  String get shoppingClearCheckedTooltip;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No shopping list yet'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign recipes in the Meal Plan, then tap refresh'**
  String get shoppingEmptySubtitle;

  /// No description provided for @shoppingGeneratedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated {date}'**
  String shoppingGeneratedOn(String date);

  /// No description provided for @shoppingClearCheckedTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove checked items?'**
  String get shoppingClearCheckedTitle;

  /// No description provided for @shoppingClearCheckedBody.
  ///
  /// In en, this message translates to:
  /// **'All ticked items will be deleted.'**
  String get shoppingClearCheckedBody;

  /// No description provided for @shoppingShareCheckedOff.
  ///
  /// In en, this message translates to:
  /// **'Everything has been checked off!'**
  String get shoppingShareCheckedOff;

  /// No description provided for @shoppingShareHeader.
  ///
  /// In en, this message translates to:
  /// **'Shopping list'**
  String get shoppingShareHeader;

  /// No description provided for @shoppingRegenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate list?'**
  String get shoppingRegenerateTitle;

  /// No description provided for @shoppingRegenerateBody.
  ///
  /// In en, this message translates to:
  /// **'Your checked-off items will be lost.'**
  String get shoppingRegenerateBody;

  /// No description provided for @shoppingRegenerateAction.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get shoppingRegenerateAction;

  /// No description provided for @shoppingGoToMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Go to Meal Plan'**
  String get shoppingGoToMealPlan;

  /// No description provided for @shoppingEmptyGeneratedTitle.
  ///
  /// In en, this message translates to:
  /// **'Shopping list is empty'**
  String get shoppingEmptyGeneratedTitle;

  /// No description provided for @shoppingEmptyGeneratedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your meal plan has no ingredients to list'**
  String get shoppingEmptyGeneratedSubtitle;

  /// No description provided for @tagSelectorTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get tagSelectorTitle;

  /// No description provided for @tagSelectorTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap once to include · tap twice to exclude'**
  String get tagSelectorTapHint;

  /// No description provided for @tagSelectorSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tags...'**
  String get tagSelectorSearchHint;

  /// No description provided for @tagSelectorManage.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get tagSelectorManage;

  /// No description provided for @tagSelectorNewTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get tagSelectorNewTag;

  /// No description provided for @tagSelectorNewTagTitle.
  ///
  /// In en, this message translates to:
  /// **'New Tag'**
  String get tagSelectorNewTagTitle;

  /// No description provided for @tagSelectorTagNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagSelectorTagNameHint;

  /// No description provided for @tagSelectorCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get tagSelectorCategoryLabel;

  /// No description provided for @categoryManagerTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get categoryManagerTitle;

  /// No description provided for @categoryManagerAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoryManagerAddCategory;

  /// No description provided for @categoryManagerRenameHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryManagerRenameHint;

  /// No description provided for @categoryManagerAddTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get categoryManagerAddTag;

  /// No description provided for @categoryManagerTagHint.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get categoryManagerTagHint;

  /// No description provided for @categoryManagerNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get categoryManagerNewTitle;

  /// No description provided for @categoryManagerEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get categoryManagerEditTitle;

  /// No description provided for @categoryManagerColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryManagerColorLabel;

  /// No description provided for @categoryManagerNoCats.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoryManagerNoCats;

  /// No description provided for @categoryManagerNoTags.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get categoryManagerNoTags;

  /// No description provided for @categoryManagerDeleteCatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get categoryManagerDeleteCatTitle;

  /// No description provided for @categoryManagerDeleteCatPermanent.
  ///
  /// In en, this message translates to:
  /// **'\'{name}\' will be permanently deleted.'**
  String categoryManagerDeleteCatPermanent(String name);

  /// No description provided for @categoryManagerDeleteCatTagsLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tags will be affected.} =1{Also deletes 1 tag.} other{Also deletes {count} tags.}}'**
  String categoryManagerDeleteCatTagsLine(int count);

  /// No description provided for @categoryManagerDeleteCatRecipesLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{} =1{ And removes it from 1 recipe.} other{ And removes them from {count} recipes.}}'**
  String categoryManagerDeleteCatRecipesLine(int count);

  /// No description provided for @categoryManagerDeleteTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete tag?'**
  String get categoryManagerDeleteTagTitle;

  /// No description provided for @categoryManagerDeleteTagPermanent.
  ///
  /// In en, this message translates to:
  /// **'\'{name}\' will be permanently deleted.'**
  String categoryManagerDeleteTagPermanent(String name);

  /// No description provided for @categoryManagerDeleteTagBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{It is not used in any recipe.} =1{It will be removed from 1 recipe.} other{It will be removed from {count} recipes.}}'**
  String categoryManagerDeleteTagBody(int count);

  /// No description provided for @addToMealPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal Plan'**
  String get addToMealPlanTitle;

  /// No description provided for @addToMealPlanChooseDay.
  ///
  /// In en, this message translates to:
  /// **'Choose a day to add \"{title}\"'**
  String addToMealPlanChooseDay(String title);

  /// No description provided for @addToMealPlanToday.
  ///
  /// In en, this message translates to:
  /// **'Today — {date}'**
  String addToMealPlanToday(String date);

  /// No description provided for @addToMealPlanAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to {date}'**
  String addToMealPlanAdded(String date);

  /// No description provided for @addToMealPlanPlanned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recipe planned} other{{count} recipes planned}}'**
  String addToMealPlanPlanned(int count);

  /// No description provided for @imagePickFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get imagePickFromLibrary;

  /// No description provided for @imagePickTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get imagePickTakePhoto;

  /// No description provided for @imagePickRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get imagePickRemove;

  /// No description provided for @imagePickCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop photo'**
  String get imagePickCropTitle;

  /// No description provided for @pdfIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get pdfIngredients;

  /// No description provided for @pdfSteps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get pdfSteps;

  /// No description provided for @pdfServes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Serves 1} other{Serves {count}}}'**
  String pdfServes(int count);

  /// No description provided for @pdfFrom.
  ///
  /// In en, this message translates to:
  /// **'from {title}'**
  String pdfFrom(String title);

  /// No description provided for @pdfPageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {total}'**
  String pdfPageOf(int page, int total);

  /// No description provided for @pdfAppName.
  ///
  /// In en, this message translates to:
  /// **'Recipea'**
  String get pdfAppName;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageDe.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get settingsLanguageDe;

  /// No description provided for @browseCharacters.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get browseCharacters;

  /// No description provided for @achievementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get achievementsTitle;

  /// No description provided for @achievementsHintUnlock.
  ///
  /// In en, this message translates to:
  /// **'Complete challenges to unlock additional characters'**
  String get achievementsHintUnlock;

  /// No description provided for @achievementsFavoriteHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a revealed character to set it as your favorite'**
  String get achievementsFavoriteHint;

  /// No description provided for @unitTeaspoon.
  ///
  /// In en, this message translates to:
  /// **'tsp'**
  String get unitTeaspoon;

  /// No description provided for @unitTablespoon.
  ///
  /// In en, this message translates to:
  /// **'tbsp'**
  String get unitTablespoon;

  /// No description provided for @unitCup.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get unitCup;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get unitPiece;

  /// No description provided for @unitSlice.
  ///
  /// In en, this message translates to:
  /// **'slice'**
  String get unitSlice;

  /// No description provided for @unitClove.
  ///
  /// In en, this message translates to:
  /// **'clove'**
  String get unitClove;

  /// No description provided for @unitBunch.
  ///
  /// In en, this message translates to:
  /// **'bunch'**
  String get unitBunch;

  /// No description provided for @unitPinch.
  ///
  /// In en, this message translates to:
  /// **'pinch'**
  String get unitPinch;

  /// No description provided for @unitCan.
  ///
  /// In en, this message translates to:
  /// **'can'**
  String get unitCan;

  /// No description provided for @unitSprig.
  ///
  /// In en, this message translates to:
  /// **'sprig'**
  String get unitSprig;

  /// No description provided for @unitHead.
  ///
  /// In en, this message translates to:
  /// **'head'**
  String get unitHead;

  /// No description provided for @unitStalk.
  ///
  /// In en, this message translates to:
  /// **'stalk'**
  String get unitStalk;

  /// No description provided for @unitHandful.
  ///
  /// In en, this message translates to:
  /// **'handful'**
  String get unitHandful;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
