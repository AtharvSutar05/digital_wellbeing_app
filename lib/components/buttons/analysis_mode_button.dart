import 'package:flutter/material.dart';
import 'package:wellbeing_app/utils/app_constants.dart';
import 'package:wellbeing_app/utils/enums.dart';

class AnalysisModeButton extends StatelessWidget {
  final Analysis analysisMode;
  final ValueChanged<Analysis> onChanged;

  const AnalysisModeButton({
    super.key,
    required this.analysisMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Analysis>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment<Analysis>(
          value: Analysis.today,
          label: Text('Today'),
        ),
        ButtonSegment<Analysis>(
          value: Analysis.week,
          label: Text('Week'),
        ),
      ],
      selected: {analysisMode},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(AppConstants.primary);
          }
          return const Color(0xFFEDEEED);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return const Color(0xFF191C1C);
        }),
        textStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        side: WidgetStateProperty.all(BorderSide.none),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}