import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/models/comparison.dart';
import '../../domain/models/comparison_vote_result.dart';
import 'comparison_option_panel.dart';
import 'comparison_result_view.dart';

class ComparisonCard extends StatelessWidget {
  const ComparisonCard({
    super.key,
    required this.comparison,
    required this.locale,
    required this.isVoting,
    required this.selectedOptionId,
    required this.voteResult,
    required this.onOptionTap,
    this.onResultSeen,
  });

  final Comparison comparison;
  final String locale;
  final bool isVoting;
  final String? selectedOptionId;
  final ComparisonVoteResult? voteResult;
  final ValueChanged<String> onOptionTap;
  final VoidCallback? onResultSeen;

  bool get _hasVoted => voteResult != null;

  @override
  Widget build(BuildContext context) {
    final categoryLabel = _categoryLabel(comparison.category);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (categoryLabel.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFF6C63FF)),
                    ),
                    child: Text(
                      categoryLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 12.h),
              Text(
                comparison.titleForLocale(locale),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              if (!_hasVoted)
                Text(
                  'tap_to_vote'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13.sp),
                ),
              SizedBox(height: 16.h),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: ComparisonOptionPanel(
                        label: comparison.leftOption.textForLocale(locale),
                        alignLeft: true,
                        isSelected: selectedOptionId == comparison.leftOption.id,
                        isDisabled: _hasVoted || isVoting,
                        onTap: () => onOptionTap(comparison.leftOption.id),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ComparisonOptionPanel(
                        label: comparison.rightOption.textForLocale(locale),
                        alignLeft: false,
                        accentColor: const Color(0xFFFF6584),
                        isSelected: selectedOptionId == comparison.rightOption.id,
                        isDisabled: _hasVoted || isVoting,
                        onTap: () => onOptionTap(comparison.rightOption.id),
                      ),
                    ),
                  ],
                ),
              ),
              if (isVoting)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              if (_hasVoted && voteResult != null) ...[
                SizedBox(height: 16.h),
                ComparisonResultView(
                  comparison: comparison,
                  result: voteResult!,
                  locale: locale,
                  selectedOptionId: selectedOptionId ?? voteResult!.selectedOptionId,
                  onResultSeen: onResultSeen,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _categoryLabel(String category) {
    if (category.isEmpty) return '';
    return 'category_$category'.tr();
  }
}
