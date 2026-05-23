import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:wellbeing_app/utils/app_constants.dart';

Future<void> showSetAppTimerDialog({
  required BuildContext context,
  required String appName,
  int initialHours = 0,
  int initialMinutes = 0,
  int? dailyLimit,
  Function(int totalMinutes)? onConfirm,
  VoidCallback? onDeleteTimer,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => _SetAppTimerDialog(
      appName: appName,
      initialHours: initialHours,
      initialMinutes: initialMinutes,
      dailyLimit: dailyLimit,
      onConfirm: onConfirm,
      onDeleteTimer: onDeleteTimer,
    ),
  );
}

class _SetAppTimerDialog extends StatefulWidget {
  final String appName;
  final int initialHours;
  final int initialMinutes;
  final int? dailyLimit;
  final Function(int totalMinutes)? onConfirm;
  final VoidCallback? onDeleteTimer;

  const _SetAppTimerDialog({
    required this.appName,
    required this.initialHours,
    required this.initialMinutes,
    this.dailyLimit,
    this.onConfirm,
    this.onDeleteTimer,
  });

  @override
  State<_SetAppTimerDialog> createState() => _SetAppTimerDialogState();
}

class _SetAppTimerDialogState extends State<_SetAppTimerDialog> {
  late FixedExtentScrollController _hoursController;
  late FixedExtentScrollController _minutesController;

  late int _selectedHours;
  late int _selectedMinutes;

  final List<int> _hourValues = List.generate(24, (i) => i);
  final List<int> _minuteValues = List.generate(12, (i) => i * 5);

  @override
  void initState() {
    super.initState();
    _selectedHours = widget.dailyLimit != null
        ? (widget.dailyLimit! ~/ 60).clamp(0, 23)
        : widget.initialHours.clamp(0, 23);

    _selectedMinutes = widget.dailyLimit != null
        ? _minuteValues.contains(widget.dailyLimit! % 60)
        ? widget.dailyLimit! % 60
        : 0
        : (_minuteValues.contains(widget.initialMinutes)
        ? widget.initialMinutes
        : 0);
    _hoursController = FixedExtentScrollController(
      initialItem: _hourValues.indexOf(_selectedHours),
    );
    _minutesController = FixedExtentScrollController(
      initialItem: _minuteValues.indexOf(_selectedMinutes),
    );
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final screenHeight = MediaQuery.of(context).size.height;

    // Picker height shrinks in landscape to fit screen
    final pickerHeight = isLandscape
        ? (screenHeight * 0.35).clamp(100.0, 140.0)
        : 150.0;

    return Dialog(
      backgroundColor: const Color(0xFFF8F9F8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Constrain dialog width in landscape so it doesn't stretch full width
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLandscape ? 500 : 360,
          maxHeight: screenHeight * 0.90,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              isLandscape ? 16 : 24,
              24,
              isLandscape ? 8 : 12,
            ),
            child: isLandscape
                ? _buildLandscapeLayout(pickerHeight)
                : _buildPortraitLayout(pickerHeight),
          ),
        ),
      ),
    );
  }

  // ── Portrait: stacked layout (original) ──────────────────────
  Widget _buildPortraitLayout(double pickerHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildPickers(pickerHeight),
        if (widget.dailyLimit != null) ...[
          const SizedBox(height: 20),
          _buildDeleteButton(),
        ],
        const SizedBox(height: 12),
        _buildActions(),
      ],
    );
  }

  // ── Landscape: header left, pickers right ────────────────────
  Widget _buildLandscapeLayout(double pickerHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: title + subtitle
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildHeader(),
              ),
            ),
            // Right: pickers
            Expanded(
              flex: 5,
              child: _buildPickers(pickerHeight),
            ),
          ],
        ),
        if (widget.dailyLimit != null) ...[
          const SizedBox(height: 12),
          _buildDeleteButton(),
        ],
        const SizedBox(height: 8),
        _buildActions(),
      ],
    );
  }

  // ── Shared sub-widgets ────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set limit for ${widget.appName}',
          style: const TextStyle(
            color: Color(0xFF191C1C),
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Once the daily limit is reached, the app will be blocked for the rest of the day. You can update or remove it anytime.',
          style: const TextStyle(
            color: Color(0xFF191C1C),
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            letterSpacing: 0.28,
          ),
        ),
      ],
    );
  }

  Widget _buildPickers(double height) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: _buildPicker(
              controller: _hoursController,
              values: _hourValues,
              label: (v) => '$v hrs',
              isHours: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildPicker(
              controller: _minutesController,
              values: _minuteValues,
              label: (v) => '$v mins',
              isHours: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          widget.onDeleteTimer?.call();
        },
        icon: const Icon(Icons.delete_outline, color: Colors.white),
        label: const Text(
          'DELETE TIMER',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppConstants.primary),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Color(0xFF191C1C),
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              letterSpacing: 0.28,
            ),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onConfirm?.call(_selectedHours * 60 + _selectedMinutes);
          },
          child: const Text(
            'SET',
            style: TextStyle(
              color: Color(0xFF191C1C),
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              letterSpacing: 0.28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPicker({
    required FixedExtentScrollController controller,
    required List<int> values,
    required String Function(int) label,
    required bool isHours,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 1, color: const Color(0xFF191C1C)),
            const SizedBox(height: 48),
            Container(height: 1, color: const Color(0xFF191C1C)),
          ],
        ),
        ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: 50,
          diameterRatio: 2.5,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            setState(() {
              if (isHours) {
                _selectedHours = values[index];
              } else {
                _selectedMinutes = values[index];
              }
            });
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: values.length,
            builder: (context, index) {
              final isSelected =
                  values[index] == (isHours ? _selectedHours : _selectedMinutes);
              return Center(
                child: Text(
                  label(values[index]),
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF191C1C)
                        : const Color(0xFF242828),
                    fontSize: isSelected ? 16 : 14,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.w300,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}