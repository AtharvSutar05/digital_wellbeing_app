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
    return PopupMenuButton<Analysis>(
      menuPadding: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withAlpha(30),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: onChanged,
      offset: const Offset(0, 44),
      itemBuilder: (context) => [
        _buildMenuItem(Analysis.today, 'Today'),
        _buildMenuItem(Analysis.week, 'Week'),
      ],
      child: _buildTrigger(),
    );
  }

  PopupMenuItem<Analysis> _buildMenuItem(Analysis value, String label) {
    final isSelected = analysisMode == value;
    return PopupMenuItem<Analysis>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      height: 40,
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
              color: isSelected
                  ? const Color(0xFF191C1C)
                  : const Color(0xFF7A8A89),
            ),
          ),
          const Spacer(),
          if (isSelected)
            const Icon(
              Icons.check_rounded,
              size: 15,
              color: Color(AppConstants.primary),
            ),
        ],
      ),
    );
  }

  Widget _buildTrigger() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEED),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            analysisMode == Analysis.today ? 'Today' : 'Week',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Color(0xFF191C1C),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_drop_down_rounded,
            size: 14,
            color: Color(0xFF7A8A89),
          ),
        ],
      ),
    );
  }
}