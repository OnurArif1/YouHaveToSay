import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ComparisonOptionPanel extends StatelessWidget {
  const ComparisonOptionPanel({
    super.key,
    required this.label,
    required this.onTap,
    required this.isSelected,
    required this.isDisabled,
    this.accentColor = const Color(0xFF6C63FF),
    this.alignLeft = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isDisabled;
  final Color accentColor;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: LinearGradient(
              begin: alignLeft ? Alignment.topLeft : Alignment.topRight,
              end: alignLeft ? Alignment.bottomRight : Alignment.bottomLeft,
              colors: isSelected
                  ? [accentColor, accentColor.withValues(alpha: 0.7)]
                  : [const Color(0xFF2A2A3E), const Color(0xFF1E1E2E)],
            ),
            border: Border.all(
              color: isSelected ? Colors.white : Colors.white24,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
