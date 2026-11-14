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
  String get delete => 'Löschen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get replace => 'Ersetzen';

  @override
  String get skip => 'Überspringen';

  @override
  String get clear => 'Leeren';

  @override
  String get export => 'Exportieren';

  @override
  String get import => 'Importieren';

  @override
  String get add => 'Hinzufügen';

  @override
  String get remove => 'Entfernen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get close => 'Schließen';

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
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get noRecipesFound => 'Keine Rezepte gefunden';

  @override
  String get navRecipes => 'Rezepte';

  @override
  String get navMealPlan => 'Essensplan';

  @override
  String get navShopping => 'Einkaufen';

  @override
  String get navCharacters => 'Charaktere';

  @override
  String get navMore => 'Mehr';

  @override
  String get moreDataProtection => 'Datenschutz';

  @override
  String get moreImprint => 'Impressum';

  @override
  String get legalDataProtectionPlaceholder =>
      'Datenschutzerklärung folgt in Kürze.';

  @override
  String get legalImprintPlaceholder => 'Impressum folgt in Kürze.';

  @override
  String get browseSearchHint => 'Rezepte durchsuchen…';

  @override
  String get browseFilterHint => 'Nach Tags filtern...';

  @override
  String get browseEmptyTitle => 'Noch keine Rezepte';

  @override
  String get browseEmptySubtitle =>
      'Tippe auf + um dein erstes Rezept hinzuzufügen';

  @override
  String browseSearchEmptyTitle(String query) {
    return 'Keine Rezepte für \"$query\"';
  }

  @override
  String get browseSearchEmptySubtitle => 'Anderen Suchbegriff versuchen';

  @override
  String get browseFilterEmptyTitle => 'Keine Rezepte für diese Filter';

  @override
  String get browseFilterEmptySubtitle =>
      'Versuche, einige Filter zu entfernen';

  @override
  String get browseNoRecipesFoundSubtitle => 'Suche oder Filter zurücksetzen';

  @override
  String get browseClearSearch => 'Suche zurücksetzen';

  @override
  String get browseClearFilters => 'Filter zurücksetzen';

  @override
  String get browseClearAll => 'Alles zurücksetzen';

  @override
  String get browseExportBackup => 'Vollständige Sicherung exportieren';

  @override
  String get browseImportRecipes => 'Rezepte importieren';

  @override
  String get browseExportBackupTitle => 'Vollständige Sicherung exportieren';

  @override
  String get browseExportBackupBody =>
      'Exportiert alle Rezepte, Kategorien, Tags und Essensplanverlauf. Zum Sichern oder Übertragen auf ein neues Gerät.';

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
  String get sortOldestFirst => 'Älteste zuerst';

  @override
  String get sortLastCookedDesc => 'Zuletzt gekocht';

  @override
  String get sortLastCookedAsc => 'Als nächstes kochen';

  @override
  String get goToRecipes => 'Zu den Rezepten';

  @override
  String get detailEditTooltip => 'Rezept bearbeiten';

  @override
  String get detailHomeTooltip => 'Alle Rezepte';

  @override
  String get detailAddToMealPlan => 'Zum Essensplan hinzufügen';

  @override
  String get detailExportRecipe => 'Rezept exportieren';

  @override
  String get detailExportPdf => 'Als PDF exportieren';

  @override
  String get detailDuplicate => 'Duplizieren';

  @override
  String get detailDeleteMenuLabel => 'Löschen';

  @override
  String detailDeleteTitle(String title) {
    return '\"$title\" löschen?';
  }

  @override
  String get detailDeleteBody => 'Das kann nicht rückgängig gemacht werden.';

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
  String get detailDeletedComponent => 'Gelöschte Komponente';

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
      'Spezielle Ausrüstung, Tipps, alles Wissenswerte (optional)';

  @override
  String get editTagsLabel => 'Tags';

  @override
  String get editAddTagsButton => 'Tags hinzufügen';

  @override
  String get editNoTagsSelected => 'Keine Tags ausgewählt';

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
      'Verknüpfe andere Rezepte als Bausteine. Ihre Schritte und Zutaten werden in dieses Rezept kombiniert.';

  @override
  String get editAddComponent => 'Komponente hinzufügen';

  @override
  String editSaveFailed(String error) {
    return 'Speichern fehlgeschlagen: $error';
  }

  @override
  String get editUnsavedTitle => 'Ungespeicherte Änderungen';

  @override
  String get editUnsavedBody => 'Änderungen verwerfen?';

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
  String get editAddIngredient => 'Zutat hinzufügen';

  @override
  String editStepHint(int number) {
    return 'Schritt $number...';
  }

  @override
  String get editAddStep => 'Schritt hinzufügen';

  @override
  String get editNoStepsYet => 'Noch keine Schritte';

  @override
  String get editAddStepToRecipe => 'Schritt zu diesem Rezept hinzufügen';

  @override
  String get editComponentSelf => 'Dieses Rezept';

  @override
  String get editComponentDeleted => '(gelöscht)';

  @override
  String get editPickComponent => 'Komponente auswählen';

  @override
  String get editSearchRecipesHint => 'Suchen…';

  @override
  String get editNoRecipesMatch => 'Keine Rezepte gefunden';

  @override
  String get editCycleWarning => 'Würde einen Zyklus erzeugen';

  @override
  String get editNoRecipesAvailable => 'Keine Rezepte zum Verknüpfen verfügbar';

  @override
  String get editStepsInOrder =>
      'Schritte innerhalb eines Rezepts müssen in Reihenfolge bleiben';

  @override
  String get editStepOrderCustom => 'Benutzerdefinierte Reihenfolge';

  @override
  String get editStepOrderReset => 'Reihenfolge zurücksetzen';

  @override
  String get editChangePhoto => 'Foto ändern';

  @override
  String get editAddPhoto => 'Foto hinzufügen';

  @override
  String get editStepImagesLabel => 'Schritt-Bilder';

  @override
  String get editHideImages => 'Ausblenden';

  @override
  String get editShowImages => 'Einblenden';

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
      'Erlaube Mikrofonzugriff, um Spracheingabe für Rezeptschritte zu nutzen.';

  @override
  String get mealPlanSubtitle => 'Tage für die Einkaufsliste auswählen';

  @override
  String get mealPlanClearPlan => 'Plan leeren';

  @override
  String get mealPlanClearTitle => 'Essensplan leeren?';

  @override
  String get mealPlanClearBody => 'Alle Rezeptzuweisungen werden entfernt.';

  @override
  String get mealPlanAddMeal => 'Mahlzeit hinzufügen';

  @override
  String get mealPlanRemoveMeal => 'Mahlzeit entfernen';

  @override
  String get mealPlanChangeRecipe => 'Rezept ändern';

  @override
  String get mealPlanChooseRecipe => 'Rezept auswählen';

  @override
  String get mealPlanSearchRecipes => 'Rezepte durchsuchen...';

  @override
  String get mealPlanNoRecipes => 'Noch keine Rezepte';

  @override
  String get mealPlanNoRecipesSubtitle =>
      'Füge zuerst Rezepte hinzu, dann plane deine Mahlzeiten hier';

  @override
  String mealPlanToday(String date) {
    return 'Heute — $date';
  }

  @override
  String get mealPlanNoResults => 'Keine Rezepte gefunden';

  @override
  String get mealPlanSetServings => 'Portionen ändern';

  @override
  String get mealPlanResetServings => 'Auf Standard zurücksetzen';

  @override
  String get shoppingListTitle => 'Einkaufsliste';

  @override
  String get shoppingGenerateTooltip => 'Einkaufsliste erstellen';

  @override
  String get shoppingShareTooltip => 'Liste teilen';

  @override
  String get shoppingClearCheckedTooltip => 'Erledigte löschen';

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
      'Alle abgehakten Artikel werden gelöscht.';

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
  String get tagSelectorTitle => 'Tags auswählen';

  @override
  String get tagSelectorTapHint =>
      'Einmal tippen zum Einschließen, zweimal zum Ausschließen';

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
  String get categoryManagerAddCategory => 'Kategorie hinzufügen';

  @override
  String get categoryManagerRenameHint => 'Kategoriename';

  @override
  String get categoryManagerAddTag => 'Tag hinzufügen';

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
  String get categoryManagerDeleteCatTitle => 'Kategorie löschen?';

  @override
  String categoryManagerDeleteCatPermanent(String name) {
    return '\"$name\" wird dauerhaft gelöscht.';
  }

  @override
  String categoryManagerDeleteCatTagsLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Löscht auch $count Tags.',
      one: 'Löscht auch 1 Tag.',
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
  String get categoryManagerDeleteTagTitle => 'Tag löschen?';

  @override
  String categoryManagerDeleteTagPermanent(String name) {
    return '\"$name\" wird dauerhaft gelöscht.';
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
  String get addToMealPlanTitle => 'Zum Essensplan hinzufügen';

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
    return 'Hinzugefügt zu $date';
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
  String get imagePickFromLibrary => 'Aus Bibliothek auswählen';

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

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguageLabel => 'Sprache';

  @override
  String get settingsLanguageEn => 'Englisch';

  @override
  String get settingsLanguageDe => 'Deutsch';

  @override
  String get browseCharacters => 'Charaktere';

  @override
  String get achievementsTitle => 'Charaktere';

  @override
  String get achievementsHintUnlock =>
      'Schließe Herausforderungen ab, um weitere Charaktere freizuschalten';

  @override
  String get achievementsFavoriteHint =>
      'Tippe auf einen enthüllten Charakter, um ihn als Favoriten festzulegen';

  @override
  String get unitTeaspoon => 'TL';

  @override
  String get unitTablespoon => 'EL';

  @override
  String get unitCup => 'Tasse';

  @override
  String get unitPiece => 'Stück';

  @override
  String get unitSlice => 'Scheibe';

  @override
  String get unitClove => 'Zehe';

  @override
  String get unitBunch => 'Bund';

  @override
  String get unitPinch => 'Prise';

  @override
  String get unitCan => 'Dose';

  @override
  String get unitSprig => 'Zweig';

  @override
  String get unitHead => 'Kopf';

  @override
  String get unitStalk => 'Stiel';

  @override
  String get unitHandful => 'Handvoll';
}
