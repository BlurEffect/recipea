// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get update => 'Aktualisieren';

  @override
  String get delete => 'Loeschen';

  @override
  String get confirm => 'Bestaetigen';

  @override
  String get replace => 'Ersetzen';

  @override
  String get skip => 'Ueberspringen';

  @override
  String get clear => 'Leeren';

  @override
  String get export => 'Exportieren';

  @override
  String get import => 'Importieren';

  @override
  String get add => 'Hinzufuegen';

  @override
  String get remove => 'Entfernen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get close => 'Schliessen';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get create => 'Erstellen';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get allow => 'Erlauben';

  @override
  String get openSettings => 'Einstellungen oeffnen';

  @override
  String get noRecipesFound => 'Keine Rezepte gefunden';

  @override
  String get navRecipes => 'Rezepte';

  @override
  String get navMealPlan => 'Essensplan';

  @override
  String get navShopping => 'Einkaufen';

  @override
  String get browseSearchHint => 'Rezepte durchsuchen…';

  @override
  String get browseFilterHint => 'Nach Tags filtern...';

  @override
  String get browseEmptyTitle => 'Noch keine Rezepte';

  @override
  String get browseEmptySubtitle =>
      'Tippe auf + um dein erstes Rezept hinzuzufuegen';

  @override
  String browseSearchEmptyTitle(String query) {
    return 'Keine Rezepte fuer \"$query\"';
  }

  @override
  String get browseSearchEmptySubtitle => 'Anderen Suchbegriff versuchen';

  @override
  String get browseFilterEmptyTitle => 'Keine Rezepte fuer diese Filter';

  @override
  String get browseFilterEmptySubtitle =>
      'Versuche, einige Filter zu entfernen';

  @override
  String get browseNoRecipesFoundSubtitle => 'Suche oder Filter zuruecksetzen';

  @override
  String get browseClearSearch => 'Suche zuruecksetzen';

  @override
  String get browseClearFilters => 'Filter zuruecksetzen';

  @override
  String get browseClearAll => 'Alles zuruecksetzen';

  @override
  String get browseExportBackup => 'Vollstaendige Sicherung exportieren';

  @override
  String get browseImportRecipes => 'Rezepte importieren';

  @override
  String get browseExportBackupTitle => 'Vollstaendige Sicherung exportieren';

  @override
  String get browseExportBackupBody =>
      'Exportiert alle Rezepte, Kategorien, Tags und Essensplanverlauf. Zum Sichern oder Uebertragen auf ein neues Geraet.';

  @override
  String browseExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get browseImportFailed =>
      'Import fehlgeschlagen. Stelle sicher, dass du eine .recipea- oder .json-Datei aus dieser App verwendest.';

  @override
  String get browseImportNothingNew => 'Nichts Neues zum Importieren';

  @override
  String browseImportedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte importiert',
      one: '1 Rezept importiert',
    );
    return '$_temp0';
  }

  @override
  String get browseDuplicatesTitle => 'Doppelte Rezepte';

  @override
  String browseDuplicatesExist(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Rezepte existieren bereits:',
      one: '1 Rezept existiert bereits:',
    );
    return '$_temp0';
  }

  @override
  String get browseDuplicatesReplace => 'Mit importierter Version ersetzen?';

  @override
  String get sortTitleAsc => 'A → Z';

  @override
  String get sortTitleDesc => 'Z → A';

  @override
  String get sortNewestFirst => 'Neueste zuerst';

  @override
  String get sortOldestFirst => 'Aelteste zuerst';

  @override
  String get sortLastCookedDesc => 'Zuletzt gekocht';

  @override
  String get sortLastCookedAsc => 'Als naechstes kochen';

  @override
  String get goToRecipes => 'Zu den Rezepten';

  @override
  String get detailEditTooltip => 'Rezept bearbeiten';

  @override
  String get detailHomeTooltip => 'Alle Rezepte';

  @override
  String get detailAddToMealPlan => 'Zum Essensplan hinzufuegen';

  @override
  String get detailExportRecipe => 'Rezept exportieren';

  @override
  String get detailExportPdf => 'Als PDF exportieren';

  @override
  String get detailDuplicate => 'Duplizieren';

  @override
  String get detailDeleteMenuLabel => 'Loeschen';

  @override
  String detailDeleteTitle(String title) {
    return '\"$title\" loeschen?';
  }

  @override
  String get detailDeleteBody => 'Das kann nicht rueckgaengig gemacht werden.';

  @override
  String detailExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String detailPdfFailed(String error) {
    return 'PDF-Export fehlgeschlagen: $error';
  }

  @override
  String get detailPartOf => 'TEIL VON';

  @override
  String get detailServes => 'Portionen';

  @override
  String detailServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Portionen',
      one: '1 Portion',
    );
    return '$_temp0';
  }

  @override
  String get detailSeparate => 'Getrennt';

  @override
  String get detailCombined => 'Kombiniert';

  @override
  String get detailThisRecipe => 'Dieses Rezept';

  @override
  String detailFromComponent(String title) {
    return 'von $title';
  }

  @override
  String get detailIngredients => 'Zutaten';

  @override
  String get detailSteps => 'Zubereitung';

  @override
  String get detailDescription => 'Kochnotizen';

  @override
  String get detailRecipeNotFound => 'Rezept nicht gefunden';

  @override
  String get detailDeletedComponent => 'Geloeschte Komponente';

  @override
  String get editNewRecipe => 'Neues Rezept';

  @override
  String get editExistingRecipe => 'Rezept bearbeiten';

  @override
  String get editTitleLabel => 'Titel';

  @override
  String get editTitleHint => 'Rezeptname';

  @override
  String get editServingsLabel => 'Portionen';

  @override
  String get editDescriptionHint =>
      'Spezielle Ausruestung, Tipps, alles Wissenswerte (optional)';

  @override
  String get editTagsLabel => 'Tags';

  @override
  String get editAddTagsButton => 'Tags hinzufuegen';

  @override
  String get editNoTagsSelected => 'Keine Tags ausgewaehlt';

  @override
  String get editFromComponents => 'Von Komponenten';

  @override
  String get editManageCategories => 'Kategorien verwalten';

  @override
  String get editIngredientsLabel => 'Zutaten';

  @override
  String get editStepsLabel => 'Zubereitung';

  @override
  String get editComponentsLabel => 'Komponenten';

  @override
  String get editComponentsDescription =>
      'Verknuepfe andere Rezepte als Bausteine. Ihre Schritte und Zutaten werden in dieses Rezept kombiniert.';

  @override
  String get editAddComponent => 'Komponente hinzufuegen';

  @override
  String editSaveFailed(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get editUnsavedTitle => 'Ungespeicherte Aenderungen';

  @override
  String get editUnsavedBody => 'Aenderungen verwerfen?';

  @override
  String get editDiscard => 'Verwerfen';

  @override
  String get editQtyHint => 'Menge';

  @override
  String get editUnitHint => 'Einheit';

  @override
  String get editIngredientNameHint => 'Zutat';

  @override
  String get editNoteHint => 'Hinweis (z. B. nach Geschmack, fein gehackt)';

  @override
  String get editAddIngredient => 'Zutat hinzufuegen';

  @override
  String editStepHint(int number) {
    return 'Schritt $number...';
  }

  @override
  String get editAddStep => 'Schritt hinzufuegen';

  @override
  String get editNoStepsYet => 'Noch keine Schritte';

  @override
  String get editAddStepToRecipe => 'Schritt zu diesem Rezept hinzufuegen';

  @override
  String get editComponentSelf => 'Dieses Rezept';

  @override
  String get editComponentDeleted => '(geloescht)';

  @override
  String get editPickComponent => 'Komponente auswaehlen';

  @override
  String get editSearchRecipesHint => 'Suchen…';

  @override
  String get editNoRecipesMatch => 'Keine Rezepte gefunden';

  @override
  String get editCycleWarning => 'Wuerde einen Zyklus erzeugen';

  @override
  String get editNoRecipesAvailable =>
      'Keine Rezepte zum Verknuepfen verfuegbar';

  @override
  String get editStepsInOrder =>
      'Schritte innerhalb eines Rezepts muessen in Reihenfolge bleiben';

  @override
  String get editChangePhoto => 'Foto aendern';

  @override
  String get editAddPhoto => 'Foto hinzufuegen';

  @override
  String get editPleaseAddTitle => 'Bitte Titel eingeben';

  @override
  String get editMicTitle => 'Mikrofonzugriff';

  @override
  String get editMicDeniedBody =>
      'Mikrofon-Berechtigung wurde dauerhaft abgelehnt. Aktiviere sie in den Einstellungen, um Spracheingabe zu nutzen.';

  @override
  String get editVoiceInputTitle => 'Spracheingabe';

  @override
  String get editVoiceInputBody =>
      'Erlaube Mikrofonzugriff, um Spracheingabe fuer Rezeptschritte zu nutzen.';

  @override
  String get mealPlanSubtitle => 'Tage fuer die Einkaufsliste auswaehlen';

  @override
  String get mealPlanClearPlan => 'Plan leeren';

  @override
  String get mealPlanClearTitle => 'Essensplan leeren?';

  @override
  String get mealPlanClearBody => 'Alle Rezeptzuweisungen werden entfernt.';

  @override
  String get mealPlanAddMeal => 'Mahlzeit hinzufuegen';

  @override
  String get mealPlanRemoveMeal => 'Mahlzeit entfernen';

  @override
  String get mealPlanChangeRecipe => 'Rezept aendern';

  @override
  String get mealPlanChooseRecipe => 'Rezept auswaehlen';

  @override
  String get mealPlanSearchRecipes => 'Rezepte durchsuchen...';

  @override
  String get mealPlanNoRecipes => 'Noch keine Rezepte';

  @override
  String get mealPlanNoRecipesSubtitle =>
      'Fuege zuerst Rezepte hinzu, dann plane deine Mahlzeiten hier';

  @override
  String mealPlanToday(String date) {
    return 'Heute — $date';
  }

  @override
  String get mealPlanNoResults => 'Keine Rezepte gefunden';

  @override
  String get shoppingListTitle => 'Einkaufsliste';

  @override
  String get shoppingGenerateTooltip => 'Einkaufsliste erstellen';

  @override
  String get shoppingShareTooltip => 'Liste teilen';

  @override
  String get shoppingClearCheckedTooltip => 'Erledigte loeschen';

  @override
  String get shoppingEmptyTitle => 'Noch keine Einkaufsliste';

  @override
  String get shoppingEmptySubtitle =>
      'Rezepte im Essensplan zuweisen, dann Aktualisieren tippen';

  @override
  String shoppingGeneratedOn(String date) {
    return 'Erstellt $date';
  }

  @override
  String get shoppingClearCheckedTitle => 'Erledigte Artikel entfernen?';

  @override
  String get shoppingClearCheckedBody =>
      'Alle abgehakten Artikel werden geloescht.';

  @override
  String get shoppingShareCheckedOff => 'Alles wurde abgehakt!';

  @override
  String get shoppingShareHeader => 'Einkaufsliste';

  @override
  String get shoppingRegenerateTitle => 'Liste neu erstellen?';

  @override
  String get shoppingRegenerateBody =>
      'Deine erledigten Artikel gehen verloren.';

  @override
  String get shoppingRegenerateAction => 'Neu erstellen';

  @override
  String get shoppingGoToMealPlan => 'Zum Essensplan';

  @override
  String get shoppingEmptyGeneratedTitle => 'Einkaufsliste ist leer';

  @override
  String get shoppingEmptyGeneratedSubtitle =>
      'Dein Essensplan hat keine Zutaten.';

  @override
  String get tagSelectorTitle => 'Tags auswaehlen';

  @override
  String get tagSelectorTapHint =>
      'Einmal tippen zum Einschliessen, zweimal zum Ausschliessen';

  @override
  String get tagSelectorSearchHint => 'Tags durchsuchen...';

  @override
  String get tagSelectorManage => 'Kategorien verwalten';

  @override
  String get tagSelectorNewTag => 'Neues Tag';

  @override
  String get tagSelectorNewTagTitle => 'Neues Tag';

  @override
  String get tagSelectorTagNameHint => 'Tag-Name';

  @override
  String get tagSelectorCategoryLabel => 'Kategorie';

  @override
  String get categoryManagerTitle => 'Kategorien verwalten';

  @override
  String get categoryManagerAddCategory => 'Kategorie hinzufuegen';

  @override
  String get categoryManagerRenameHint => 'Kategoriename';

  @override
  String get categoryManagerAddTag => 'Tag hinzufuegen';

  @override
  String get categoryManagerTagHint => 'Tag-Name';

  @override
  String get categoryManagerNewTitle => 'Neue Kategorie';

  @override
  String get categoryManagerEditTitle => 'Kategorie bearbeiten';

  @override
  String get categoryManagerColorLabel => 'Farbe';

  @override
  String get categoryManagerNoCats => 'Noch keine Kategorien';

  @override
  String get categoryManagerNoTags => 'Keine Tags';

  @override
  String get categoryManagerDeleteCatTitle => 'Kategorie loeschen?';

  @override
  String categoryManagerDeleteCatPermanent(String name) {
    return '\"$name\" wird dauerhaft geloescht.';
  }

  @override
  String categoryManagerDeleteCatTagsLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Loescht auch $count Tags.',
      one: 'Loescht auch 1 Tag.',
      zero: 'Keine Tags betroffen.',
    );
    return '$_temp0';
  }

  @override
  String categoryManagerDeleteCatRecipesLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' Und entfernt sie aus $count Rezepten.',
      one: ' Und entfernt ihn aus 1 Rezept.',
      zero: '',
    );
    return '$_temp0';
  }

  @override
  String get categoryManagerDeleteTagTitle => 'Tag loeschen?';

  @override
  String categoryManagerDeleteTagPermanent(String name) {
    return '\"$name\" wird dauerhaft geloescht.';
  }

  @override
  String categoryManagerDeleteTagBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Er wird aus $count Rezepten entfernt.',
      one: 'Er wird aus 1 Rezept entfernt.',
      zero: 'Er wird in keinem Rezept verwendet.',
    );
    return '$_temp0';
  }

  @override
  String get addToMealPlanTitle => 'Zum Essensplan hinzufuegen';

  @override
  String addToMealPlanChooseDay(String title) {
    return 'Wähle einen Tag für \"$title\"';
  }

  @override
  String addToMealPlanToday(String date) {
    return 'Heute — $date';
  }

  @override
  String addToMealPlanAdded(String date) {
    return 'Hinzugefuegt zu $date';
  }

  @override
  String addToMealPlanPlanned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mahlzeiten geplant',
      one: '1 Mahlzeit geplant',
    );
    return '$_temp0';
  }

  @override
  String get imagePickFromLibrary => 'Aus Bibliothek auswaehlen';

  @override
  String get imagePickTakePhoto => 'Foto aufnehmen';

  @override
  String get imagePickRemove => 'Foto entfernen';

  @override
  String get imagePickCropTitle => 'Foto zuschneiden';

  @override
  String get pdfIngredients => 'Zutaten';

  @override
  String get pdfSteps => 'Zubereitung';

  @override
  String pdfServes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Portionen',
      one: '1 Portion',
    );
    return '$_temp0';
  }

  @override
  String pdfFrom(String title) {
    return 'von $title';
  }

  @override
  String pdfPageOf(int page, int total) {
    return 'Seite $page von $total';
  }

  @override
  String get pdfAppName => 'Recipea';
}
