import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/models/voted_comparison.dart';

String _yourVoteLabel(BuildContext context, String choice) {
  final template = context.tr('your_vote');
  if (template != 'your_vote') {
    return template.replaceAll('{choice}', choice);
  }
  return context.locale.languageCode == 'tr'
      ? 'Senin oyun: $choice'
      : 'Your vote: $choice';
}

class VotedComparisonTile extends StatelessWidget {
  const VotedComparisonTile({
    super.key,
    required this.item,
    required this.locale,
  });

  final VotedComparison item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final c = item.comparison;
    final result = item.voteResult;
    final leftSelected = item.selectedOptionId == c.leftOption.id;
    final leftLabel = c.leftOption.textForLocale(locale);
    final rightLabel = c.rightOption.textForLocale(locale);
    final votedAt = DateFormat.yMMMd(locale).add_Hm().format(item.votedAt.toLocal());

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (c.category.isNotEmpty)
            Text(
              'category_${c.category}'.tr(),
              style: TextStyle(
                color: const Color(0xFF7C6CFF),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (c.category.isNotEmpty) SizedBox(height: 6.h),
          Text(
            c.titleForLocale(locale),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _OptionRow(
            label: leftLabel,
            percentage: result.leftOption.percentage,
            isSelected: leftSelected,
          ),
          SizedBox(height: 8.h),
          _OptionRow(
            label: rightLabel,
            percentage: result.rightOption.percentage,
            isSelected: !leftSelected,
          ),
          SizedBox(height: 10.h),
          Text(
            _yourVoteLabel(context, leftSelected ? leftLabel : rightLabel),
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            votedAt,
            style: TextStyle(color: Colors.white38, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.percentage,
    required this.isSelected,
  });

  final String label;
  final double percentage;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isSelected)
          Icon(Icons.check_circle, color: const Color(0xFF7C6CFF), size: 18.sp),
        if (isSelected) SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14.sp,
            ),
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            color: isSelected ? const Color(0xFF7C6CFF) : Colors.white54,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
