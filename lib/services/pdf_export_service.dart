import 'dart:io';
import 'dart:ui' show Color;

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/seed_data.dart';
import '../data/tag_definitions.dart';
import '../models/category_definition.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../utils/recipe_graph.dart';

// ── Color constants ───────────────────────────────────────────────────────────

const _green = PdfColor(0.180, 0.490, 0.196);       // #2E7D32
const _textDark = PdfColor(0.102, 0.102, 0.102);    // #1A1A1A
const _textGray = PdfColor(0.400, 0.400, 0.400);    // #666666

// ── Public entry point ────────────────────────────────────────────────────────

Future<File> exportRecipeToPdf(
  Recipe recipe,
  List<Recipe> allRecipes,
  List<TagDefinition> allTags,
  List<CategoryDefinition> allCategories,
) async {
  final doc = pw.Document();

  final categoryColorMap = {for (final c in allCategories) c.id: c.color};
  final tagMap = {for (final t in allTags) t.id: t};
  final recipeMap = {for (final r in allRecipes) r.id: r};

  // Load recipe image
  pw.MemoryImage? heroImage;
  if (recipe.imagePath != null) {
    try {
      heroImage = pw.MemoryImage(await File(recipe.imagePath!).readAsBytes());
    } catch (_) {}
  }

  final content = <pw.Widget>[
    ..._buildHeader(recipe, heroImage),
    ..._buildComponentChips(recipe, recipeMap),
    ..._buildTags(recipe, allRecipes, allTags, tagMap, categoryColorMap),
    _buildServings(recipe),
    if (recipe.description != null && recipe.description!.isNotEmpty)
      _buildDescription(recipe.description!),
    pw.SizedBox(height: 12),
    pw.Divider(color: _green, thickness: 0.5),
    pw.SizedBox(height: 12),
    ..._buildIngredients(recipe, allRecipes),
    ..._buildSteps(recipe, allRecipes, recipeMap),
  ];

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 60),
    footer: _buildFooter,
    build: (_) => content,
  ));

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/recipea_recipe.pdf');
  await file.writeAsBytes(await doc.save());
  return file;
}

// ── Section builders ──────────────────────────────────────────────────────────

List<pw.Widget> _buildHeader(Recipe recipe, pw.MemoryImage? heroImage) {
  return [
    if (heroImage != null) ...[
      pw.SizedBox(
        width: double.infinity,
        height: 180,
        child: pw.Image(heroImage, fit: pw.BoxFit.cover),
      ),
      pw.SizedBox(height: 12),
    ],
    pw.Text(
      recipe.title,
      style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: _textDark),
    ),
    pw.SizedBox(height: 8),
  ];
}

List<pw.Widget> _buildComponentChips(
    Recipe recipe, Map<String, Recipe> recipeMap) {
  if (!recipe.isComposite) return [];
  final linkedIds = recipe.linkedRecipeIds;
  final chips = <pw.Widget>[];
  for (int i = 0; i < linkedIds.length; i++) {
    final linked = recipeMap[linkedIds[i]];
    if (linked == null) continue;
    final color = _toPdfColor(componentColors[i % componentColors.length]);
    chips.add(pw.Container(
      margin: const pw.EdgeInsets.only(right: 6, bottom: 4),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
      ),
      child: pw.Text(linked.title,
          style: pw.TextStyle(fontSize: 10, color: _textDark)),
    ));
  }
  if (chips.isEmpty) return [];
  return [pw.Wrap(children: chips), pw.SizedBox(height: 8)];
}

List<pw.Widget> _buildTags(
  Recipe recipe,
  List<Recipe> allRecipes,
  List<TagDefinition> allTags,
  Map<String, TagDefinition> tagMap,
  Map<String, Color> categoryColorMap,
) {
  final tagIds = allTagIds(recipe, allRecipes);
  if (tagIds.isEmpty) return [];

  final chips = <pw.Widget>[];
  for (final id in tagIds) {
    final tag = tagMap[id];
    if (tag == null) continue;
    final catColor = categoryColorMap[tag.category];
    final tagColor = catColor != null ? _toPdfColor(catColor) : _green;
    chips.add(pw.Container(
      margin: const pw.EdgeInsets.only(right: 6, bottom: 4),
      decoration: pw.BoxDecoration(
        color: tagColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      padding: const pw.EdgeInsets.all(1),
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: const pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(9)),
        ),
        child: pw.Text(tag.label,
            style: pw.TextStyle(fontSize: 9, color: _textDark)),
      ),
    ));
  }
  return [pw.Wrap(children: chips), pw.SizedBox(height: 8)];
}

pw.Widget _buildDescription(String text) => pw.Padding(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _green, width: 0.5),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Text(
          text,
          style: pw.TextStyle(
              fontSize: 10,
              color: _textDark,
              fontStyle: pw.FontStyle.italic),
        ),
      ),
    );

pw.Widget _buildServings(Recipe recipe) => pw.Text(
      'Serves ${recipe.servings}',
      style: pw.TextStyle(fontSize: 11, color: _textGray),
    );

List<pw.Widget> _buildIngredients(Recipe recipe, List<Recipe> allRecipes) {
  final ingredients = recipe.isComposite
      ? allIngredients(recipe, allRecipes)
      : recipe.ingredients;
  if (ingredients.isEmpty) return [];

  return [
    pw.Text('Ingredients',
        style: pw.TextStyle(
            fontSize: 14, fontWeight: pw.FontWeight.bold, color: _green)),
    pw.SizedBox(height: 8),
    ...ingredients.map(_buildIngredientRow),
    pw.SizedBox(height: 12),
    pw.Divider(color: _green, thickness: 0.5),
    pw.SizedBox(height: 12),
  ];
}

List<pw.Widget> _buildSteps(
    Recipe recipe, List<Recipe> allRecipes, Map<String, Recipe> recipeMap) {
  if (recipe.isComposite) {
    final ordered = resolveStepOrder(recipe, allRecipes);
    if (ordered.isEmpty) return [];
    final linkedIds = recipe.linkedRecipeIds;
    return [
      pw.Text('Steps',
          style: pw.TextStyle(
              fontSize: 14, fontWeight: pw.FontWeight.bold, color: _green)),
      pw.SizedBox(height: 8),
      for (int i = 0; i < ordered.length; i++)
        _buildCompositeStepRow(
          i + 1,
          ordered[i].step.instruction,
          ordered[i].sourceRecipeId,
          linkedIds,
          recipeMap,
        ),
    ];
  } else {
    if (recipe.steps.isEmpty) return [];
    final sorted = [...recipe.steps]..sort((a, b) => a.order.compareTo(b.order));
    return [
      pw.Text('Steps',
          style: pw.TextStyle(
              fontSize: 14, fontWeight: pw.FontWeight.bold, color: _green)),
      pw.SizedBox(height: 8),
      for (int i = 0; i < sorted.length; i++)
        _buildStepRow(i + 1, sorted[i].instruction),
    ];
  }
}

// ── Row widgets ───────────────────────────────────────────────────────────────

pw.Widget _buildIngredientRow(Ingredient ing) {
  final amountStr = _formatAmount(ing);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 5, right: 8),
          child: pw.Container(
            width: 5,
            height: 5,
            decoration: const pw.BoxDecoration(
              color: _green,
              shape: pw.BoxShape.circle,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.RichText(
                text: pw.TextSpan(children: [
                  if (amountStr.isNotEmpty)
                    pw.TextSpan(
                      text: '$amountStr  ',
                      style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: _green),
                    ),
                  pw.TextSpan(
                    text: ing.name,
                    style: const pw.TextStyle(fontSize: 11, color: _textDark),
                  ),
                ]),
              ),
              if (ing.note != null && ing.note!.isNotEmpty)
                pw.Text(
                  ing.note!,
                  style: pw.TextStyle(
                      fontSize: 9,
                      color: _textGray,
                      fontStyle: pw.FontStyle.italic),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildStepRow(int number, String instruction) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 22,
          height: 22,
          margin: const pw.EdgeInsets.only(right: 10, top: 1),
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(color: _green, width: 1),
          ),
          child: pw.Center(
            child: pw.Text('$number',
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: _green)),
          ),
        ),
        pw.Expanded(
          child: pw.Text(instruction,
              style: const pw.TextStyle(fontSize: 11, color: _textDark)),
        ),
      ],
    ),
  );
}

pw.Widget _buildCompositeStepRow(
  int number,
  String instruction,
  String sourceRecipeId,
  List<String> linkedIds,
  Map<String, Recipe> recipeMap,
) {
  final isOwn = sourceRecipeId == 'self';
  final colorIdx = isOwn ? -1 : linkedIds.indexOf(sourceRecipeId);
  final stepColor = colorIdx >= 0
      ? _toPdfColor(componentColors[colorIdx % componentColors.length])
      : _green;
  final sourceTitle = isOwn ? null : recipeMap[sourceRecipeId]?.title;

  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: stepColor, width: 3)),
      ),
      padding: const pw.EdgeInsets.only(left: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 22,
            height: 22,
            margin: const pw.EdgeInsets.only(right: 10, top: 1),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: stepColor, width: 1),
            ),
            child: pw.Center(
              child: pw.Text('$number',
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: stepColor)),
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(instruction,
                    style: const pw.TextStyle(fontSize: 11, color: _textDark)),
                if (sourceTitle != null)
                  pw.Text('from $sourceTitle',
                      style: pw.TextStyle(
                          fontSize: 9,
                          color: _textGray,
                          fontStyle: pw.FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

pw.Widget _buildFooter(pw.Context context) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(children: [
          pw.Container(
            width: 14,
            height: 14,
            decoration: const pw.BoxDecoration(
              color: _green,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Text('Recipea',
              style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: _green)),
        ]),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9, color: _textGray),
        ),
      ],
    ),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _formatAmount(Ingredient ing) {
  if (ing.quantity == null) return '';
  final v = ing.quantity!;
  final s = v == v.truncateToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  return ing.unit != null ? '$s ${ing.unit}' : s;
}

PdfColor _toPdfColor(Color color) =>
    PdfColor(color.r, color.g, color.b, color.a);
