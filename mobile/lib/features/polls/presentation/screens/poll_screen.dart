import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/poll_bloc.dart';
import '../widgets/poll_card.dart';
import '../widgets/vote_success_overlay.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({super.key});

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PollBloc>().add(const PollLoadNextRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_name'.tr()),
        actions: [
          PopupMenuButton<String>(
            onSelected: (code) => context.setLocale(Locale(code)),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'tr', child: Text('turkish'.tr())),
              PopupMenuItem(value: 'en', child: Text('english'.tr())),
            ],
            icon: const Icon(Icons.language),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'sign_out'.tr(),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<PollBloc, PollState>(
          listener: (context, state) {
            if (state.errorMessage != null &&
                state.status != PollStatus.loading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!.tr())),
              );
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: _buildBody(context, state, constraints),
                    ),
                    if (state.showSuccessAnimation)
                      const VoteSuccessOverlay(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PollState state,
    BoxConstraints constraints,
  ) {
    switch (state.status) {
      case PollStatus.initial:
      case PollStatus.loading:
      case PollStatus.voting:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text('loading'.tr()),
            ],
          ),
        );
      case PollStatus.noMorePolls:
        return _messageView(
          context,
          'no_more_polls'.tr(),
          showRetry: false,
        );
      case PollStatus.error:
        return _messageView(
          context,
          state.errorMessage?.tr() ?? 'poll_load_error'.tr(),
        );
      case PollStatus.loaded:
      case PollStatus.voteSuccess:
        final poll = state.poll;
        if (poll == null) {
          return _messageView(context, 'poll_load_error'.tr());
        }

        return Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(0.15, 0),
                end: Offset.zero,
              ).animate(animation);
              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: PollCard(
              key: ValueKey(state.slideKey),
              poll: poll,
              locale: context.locale.languageCode,
              isVoting: state.status == PollStatus.voting,
              selectedOptionId: state.selectedOptionId,
              onOptionTap: (optionId) {
                context.read<PollBloc>().add(PollVoteSubmitted(optionId: optionId));
              },
            ),
          ),
        );
    }
  }

  Widget _messageView(
    BuildContext context,
    String message, {
    bool showRetry = true,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64.sp, color: Colors.grey),
          SizedBox(height: 16.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp),
          ),
          if (showRetry) ...[
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: () =>
                  context.read<PollBloc>().add(const PollLoadNextRequested()),
              child: Text('retry'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}
