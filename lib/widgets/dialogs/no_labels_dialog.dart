import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'alert_error_dialog.dart';
import '../../models/label.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../data/labels_database.dart';
import '../../session/user_session.dart';

class NoLabelsDialog extends StatelessWidget {
  final int projectId;
  final String projectType;
  final void Function(List<Label>) onLabelsImported;

  const NoLabelsDialog({
    required this.projectId,
    required this.projectType,
    required this.onLabelsImported,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final smallScreen = (screenWidth < 700) || (screenHeight < 750);

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: RepaintBoundary(
              child: _LabelsStickersBackground(),
            ),
          ),
        ),
        SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
                padding: EdgeInsets.all(smallScreen ? 12 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: smallScreen ? 7 : 24),
                    Text(
                      l10n.noLabelsTitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth > 1450 ? 24 : smallScreen ? 14 : 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _importLabelsFromFile(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.lightGreenAccent, width: 1),
                        ),
                      ),
                      child: Text(
                        l10n.buttonImportLabels,
                        style: TextStyle(
                          color: Colors.lightGreenAccent,
                          fontSize: smallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                    ),
                    SizedBox(height: screenWidth > 1450 ? 24 : smallScreen ? 14 : 20),
                    Text(
                      l10n.noLabelsExplain1,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: screenWidth > 640 ? 18 : 14,
                        fontFamily: 'CascadiaCode',
                      ),
                    ),
                    Text(
                      l10n.noLabelsExplain2,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: smallScreen ? 14 : 18,
                        fontFamily: 'CascadiaCode',
                      ),
                    ),
                    Text(
                      l10n.noLabelsExplain3,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: smallScreen ? 14 : 18,
                        fontFamily: 'CascadiaCode',
                      ),
                    ),
                    SizedBox(
                      height: screenWidth > 1450 ? 300 : smallScreen ? 140 : 200,
                      child: Padding(
                        padding: EdgeInsets.all(
                          screenWidth > 1450 ? 45 : smallScreen ? 6 : 20,
                        ),
                        child: Image.asset(
                          'assets/images/no_labels.png',
                          fit: BoxFit.contain,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    if (!smallScreen) ...[
                      const SizedBox(height: 24),
                      Text(
                        l10n.noLabelsExplain4,
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'CascadiaCode',
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        l10n.noLabelsExplain5,
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'CascadiaCode',
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        l10n.noLabelsExplain6,
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'CascadiaCode',
                          fontSize: 18,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLabelImportPreviewDialog(
    BuildContext context,
    List<Label> labels,
    dynamic rawJson,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final isBinary = projectType.toLowerCase().contains('binary');
    final showWarning = isBinary && labels.length > 2;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.lightGreenAccent, width: 1),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.importLabelsPreviewTitle,
              style: const TextStyle(
                color: Colors.lightGreenAccent,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showWarning) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent, width: 1),
                ),
                child: const Text(
                  'Only the first 2 labels will be imported for binary classification.',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'CascadiaCode',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(rawJson),
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'CascadiaCode',
                fontSize: 14,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.buttonCancel,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final labelsToImport = showWarning ? labels.take(2).toList() : labels;
                // Check if we should set the first label as default
                final setFirstLabelAsDefault = UserSession.instance.getUser().labelsSetFirstAsDefault;
                
                if (setFirstLabelAsDefault && labelsToImport.isNotEmpty) {
                  // Get the first label
                  final firstLabel = labelsToImport.first;
                  
                  // If the label has a valid ID (not -1), set it as default
                  if (firstLabel.id != -1) {
                    try {
                      await LabelsDatabase.instance.setLabelAsDefault(firstLabel.id, projectId);
                      
                      // Update the label in the list to reflect it's the default
                      final updatedLabels = labelsToImport.map((label) {
                        if (label.id == firstLabel.id) {
                          return label.copyWith(isDefault: true);
                        }
                        return label;
                      }).toList();
                      
                      // Notify parent with updated labels
                      onLabelsImported(updatedLabels);
                    } catch (e) {
                      if (kDebugMode) print('Failed to set default label: ${e.toString()}');
                      // Still notify parent with original labels if setting default fails
                      onLabelsImported(labelsToImport);
                    }
                  } else {
                    // If the label doesn't have a valid ID yet, we'll handle setting it as default
                    // after it's inserted into the database (in the parent component)
                    onLabelsImported(labelsToImport);
                  }
                } else {
                  // No preference for default label, just notify parent
                  onLabelsImported(labelsToImport);
                }
                
                // close ONLY import labels preview dialog
                Navigator.pop(context);

              } catch (e) {
                Navigator.pop(context);
                AlertErrorDialog.show(
                  context,
                  l10n.importLabelsFailedTitle,
                  '${l10n.importLabelsDatabaseError} ${e.toString()}',
                  tips: l10n.importLabelsDatabaseErrorTips,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.lightGreenAccent, width: 1),
              ),
            ),
            child: Text(
              l10n.buttonImport,
              style: const TextStyle(
                color: Colors.lightGreenAccent,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importLabelsFromFile(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return;
    try {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      dynamic decoded;
      try {
        decoded = jsonDecode(jsonString);
      } catch (e) {
        return AlertErrorDialog.show(
          context,
          l10n.importLabelsFailedTitle,
          '${l10n.importLabelsJsonParseError} ${e.toString()}',
          tips: l10n.importLabelsJsonParseTips,
        );
      }

      if (decoded is! List) {
        return AlertErrorDialog.show(
          context,
          l10n.importLabelsFailedTitle,
          l10n.importLabelsJsonNotList(decoded.runtimeType),
          tips: l10n.importLabelsJsonNotListTips,
        );
      }

      final List<Label> labels = [];
      int fallbackOrder = 0;

      for (final item in decoded) {
        if (item is! Map) {
          return AlertErrorDialog.show(
            context,
            l10n.importLabelsFailedTitle,
            l10n.importLabelsJsonItemNotMap(item.runtimeType),
            tips: l10n.importLabelsJsonItemNotMapTips,
          );
        }

        try {
          final map = Map<String, dynamic>.from(item);

          // Validate name
          final name = map['name'];
          if (name == null || name is! String || name.trim().isEmpty) {
            return AlertErrorDialog.show(
              context,
              l10n.importLabelsFailedTitle,
              l10n.importLabelsNameMissingOrEmpty,
              tips: l10n.importLabelsNameMissingOrEmptyTips,
            );
          }

          final int labelOrder = map.containsKey('label_order') && map['label_order'] is int
            ? map['label_order']
            : fallbackOrder++;

          final parsed = Label.fromJsonForImport(map, projectId, labelOrder);
          labels.add(parsed);

        } catch (e) {
          return AlertErrorDialog.show(
            context,
            l10n.importLabelsFailedTitle,
            '${l10n.importLabelsJsonLabelParseError} ${e.toString()}',
            tips: l10n.importLabelsJsonLabelParseTips,
          );
        }
      }

      await _showLabelImportPreviewDialog(context, labels, decoded);
    } catch (e) {
      await AlertErrorDialog.show(
        context,
        l10n.importLabelsFailedTitle,
        '${l10n.importLabelsUnexpectedError} ${e.toString()}',
        tips: l10n.importLabelsUnexpectedErrorTip,
      );
    }
  }
}


class _LabelsStickersBackground extends StatefulWidget {
  @override
  State<_LabelsStickersBackground> createState() => _LabelsStickersBackgroundState();
}

class _LabelsStickersBackgroundState extends State<_LabelsStickersBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final math.Random _rand = math.Random();
  List<_Sticker> _stickers = [];
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _countFor(Size size) {
    final area = size.width * size.height;
    if (area < 600 * 700) return 10; // very small
    if (area < 1200 * 900) return 16; // medium
    return 26; // large
  }

  void _ensureStickers(Size size) {
    if (size == _lastSize && _stickers.isNotEmpty) return;
    _lastSize = size;
    final count = _countFor(size);
    _stickers = List.generate(count, (_) => _randomSticker());
  }

  _Sticker _randomSticker() {
    // Base sticker sizes in logical px, will be scaled slightly during paint
    final baseW = _rand.nextDouble() * 120 + 60; // 60..180
    final baseH = _rand.nextDouble() * 40 + 20; // 20..60 (label-like)

    // Palette with soft accents
    final colors = <Color>[
      Colors.lightGreenAccent,
      Colors.cyanAccent,
      Colors.amberAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
    ];

    final color = colors[_rand.nextInt(colors.length)];

    return _Sticker(
      nx: _rand.nextDouble(),
      nyStart: _rand.nextDouble(),
      width: baseW,
      height: baseH,
      rotation: (_rand.nextDouble() - 0.5) * 0.6, // -0.3..0.3 rad ~ -17..17 deg
      speed: 0.2 + _rand.nextDouble() * 0.6, // fraction of screen per cycle
      lifeOffset: _rand.nextDouble(),
      color: color,
      phase: _rand.nextDouble() * math.pi * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        _ensureStickers(size);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _StickersPainter(
                stickers: _stickers,
                tick: _controller.value,
              ),
            );
          },
        );
      },
    );
  }
}

class _Sticker {
  final double nx; // normalized x 0..1
  final double nyStart; // normalized starting y 0..1
  final double width;
  final double height;
  final double rotation; // radians
  final double speed; // 0..1, fraction of screen per cycle
  final double lifeOffset; // 0..1
  final double phase; // for drift/scale
  final Color color;

  const _Sticker({
    required this.nx,
    required this.nyStart,
    required this.width,
    required this.height,
    required this.rotation,
    required this.speed,
    required this.lifeOffset,
    required this.color,
    required this.phase,
  });
}

class _StickersPainter extends CustomPainter {
  final List<_Sticker> stickers;
  final double tick; // 0..1

  _StickersPainter({required this.stickers, required this.tick});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (final s in stickers) {
      // Progress of this sticker through its life 0..1
      final p = (tick * s.speed + s.lifeOffset) % 1.0;

      // Vertical travel (wraps around)
      final y = ((s.nyStart + p) % 1.0) * size.height;
      // Subtle horizontal drift
      final drift = math.sin((p * 2 * math.pi) + s.phase) * 18.0;
      final x = s.nx * size.width + drift;

      // Scale pulsation
      final scale = 0.85 + 0.15 * math.sin((p * 2 * math.pi) + s.phase);

      // Fade in/out at start/end of life for appearance effect
      double fade;
      if (p < 0.15) {
        fade = p / 0.15;
      } else if (p > 0.85) {
        fade = (1 - p) / 0.15;
      } else {
        fade = 1.0;
      }

      final w = s.width * scale;
      final h = s.height * scale;

      // Very low opacity to keep background subtle
      final double targetOpacity = 0.11;
      paint.color = s.color.withOpacity(targetOpacity * fade);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(s.rotation);

      final rect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
      canvas.drawRRect(rrect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StickersPainter oldDelegate) {
    return oldDelegate.tick != tick || oldDelegate.stickers != stickers;
  }
}
