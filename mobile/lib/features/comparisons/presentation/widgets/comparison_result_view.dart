import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/models/comparison.dart';
import '../../domain/models/comparison_vote_result.dart';

class ComparisonResultView extends StatefulWidget {
  const ComparisonResultView({
    super.key,
    required this.comparison,
    required this.result,
    required this.locale,
    required this.selectedOptionId,
    this.onResultSeen,
  });

  final Comparison comparison;
  final ComparisonVoteResult result;
  final String locale;
  final String selectedOptionId;
  final VoidCallback? onResultSeen;

  @override
  State<ComparisonResultView> createState() => _ComparisonResultViewState();
}

class _ComparisonResultViewState extends State<ComparisonResultView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onResultSeen?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.comparison.leftOption;
    final right = widget.comparison.rightOption;
    final leftResult = widget.result.leftOption;
    final rightResult = widget.result.rightOption;
    final leftSelected = widget.selectedOptionId == left.id;
    final rightSelected = widget.selectedOptionId == right.id;
    final leftWins = leftResult.percentage >= rightResult.percentage;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ResultRow(
              label: left.textForLocale(widget.locale),
              percentage: leftResult.percentage * t,
              voteCount: leftResult.voteCount,
              isSelected: leftSelected,
              isWinner: leftWins,
            ),
            SizedBox(height: 12.h),
            _ResultRow(
              label: right.textForLocale(widget.locale),
              percentage: rightResult.percentage * t,
              voteCount: rightResult.voteCount,
              isSelected: rightSelected,
              isWinner: !leftWins,
            ),
            SizedBox(height: 16.h),
            Text(
              'total_votes'.tr(namedArgs: {
                'count': NumberFormat.decimalPattern(widget.locale).format(
                  (widget.result.totalVotes * t).round(),
                ),
              }),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'swipe_for_next'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12.sp,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.percentage,
    required this.voteCount,
    required this.isSelected,
    required this.isWinner,
  });

  final String label;
  final double percentage;
  final int voteCount;
  final bool isSelected;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    final barColor = isSelected
        ? (isWinner ? const Color(0xFF6C63FF) : const Color(0xFF4A4A6A))
        : Colors.white24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: isWinner ? Colors.white : Colors.white70,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            minHeight: 10.h,
            backgroundColor: Colors.white12,
            color: barColor,
          ),
        ),
      ],
    );
  }
}
