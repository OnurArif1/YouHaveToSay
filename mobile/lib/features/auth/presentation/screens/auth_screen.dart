import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../comparisons/presentation/widgets/feed_background.dart';
import '../bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmailLogin = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;

  AppConfig get _config => getIt<AppConfig>();

  bool get _useDevAuth => _config.useDevAuth;

  bool get _canUseGoogle => _config.canUseGoogleSignIn;

  @override
  void initState() {
    super.initState();
    if (_useDevAuth) {
      _showEmailLogin = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitEmail() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      context.read<AuthBloc>().add(
            AuthSignUpRequested(email: email, password: password),
          );
    } else {
      context.read<AuthBloc>().add(
            AuthSignInRequested(email: email, password: password),
          );
    }
  }

  void _signInWithGoogle() {
    if (!_canUseGoogle) {
      _showFirebaseSetupDialog();
      return;
    }
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  void _showFirebaseSetupDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('firebase_setup_title'.tr()),
        content: SingleChildScrollView(
          child: Text('firebase_setup_steps'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                const ClipboardData(
                  text: 'export PATH="\$PATH:\$HOME/.pub-cache/bin"\n'
                      'cd mobile && flutterfire configure\n'
                      '../scripts/apply-ios-google-url-scheme.sh\n'
                      'flutter run',
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('firebase_setup_copied'.tr())),
              );
            },
            child: Text('firebase_setup_copy'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ok'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FeedBackground(
        child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state.errorMessage == null) return;
                      if (state.errorMessage == 'firebase_not_configured' ||
                          state.errorMessage == 'google_auth_not_enabled') {
                        _showFirebaseSetupDialog();
                        return;
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage!.tr())),
                      );
                    },
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 56.h),
                          Text(
                            'app_name'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.title,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'auth_subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: AppColors.subtitle,
                            ),
                          ),
                          SizedBox(height: 48.h),
                          _GoogleSignInButton(
                            isLoading: state.isLoading,
                            onPressed: _signInWithGoogle,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            _canUseGoogle
                                ? 'google_auth_hint'.tr()
                                : 'firebase_setup_hint'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: _canUseGoogle
                                  ? AppColors.muted
                                  : AppColors.accentPink,
                            ),
                          ),
                          if (!_useDevAuth) ...[
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  child: Text(
                                    'or'.tr(),
                                    style: const TextStyle(color: AppColors.muted),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                          if (_useDevAuth)
                            Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: Text(
                                'dev_auth_notice'.tr(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.accentPink,
                                ),
                              ),
                            ),
                          if (!_useDevAuth)
                            TextButton(
                              onPressed: state.isLoading
                                  ? null
                                  : () => setState(
                                        () =>
                                            _showEmailLogin = !_showEmailLogin,
                                      ),
                              child: Text(
                                _showEmailLogin
                                    ? 'hide_email_login'.tr()
                                    : 'email_login_option'.tr(),
                              ),
                            ),
                          if (_showEmailLogin || _useDevAuth) ...[
                            SizedBox(height: 8.h),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'email'.tr(),
                                      prefixIcon:
                                          const Icon(Icons.email_outlined),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'email_required'.tr();
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 16.h),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      labelText: 'password'.tr(),
                                      prefixIcon:
                                          const Icon(Icons.lock_outline),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'password_required'.tr();
                                      }
                                      if (value.length < 6) {
                                        return 'password_min_length'.tr();
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20.h),
                                  FilledButton(
                                    onPressed:
                                        state.isLoading ? null : _submitEmail,
                                    child: state.isLoading
                                        ? SizedBox(
                                            height: 22.h,
                                            width: 22.h,
                                            child:
                                                const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _isSignUp
                                                ? 'sign_up'.tr()
                                                : 'sign_in'.tr(),
                                          ),
                                  ),
                                  TextButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : () => setState(
                                              () => _isSignUp = !_isSignUp,
                                            ),
                                    child: Text(
                                      _isSignUp
                                          ? 'sign_in'.tr()
                                          : 'sign_up'.tr(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'language'.tr(),
                                style: const TextStyle(color: AppColors.subtitle),
                              ),
                              SizedBox(width: 8.w),
                              DropdownButton<String>(
                                value: context.locale.languageCode,
                                underline: const SizedBox.shrink(),
                                items: [
                                  DropdownMenuItem(
                                    value: 'tr',
                                    child: Text('turkish'.tr()),
                                  ),
                                  DropdownMenuItem(
                                    value: 'en',
                                    child: Text('english'.tr()),
                                  ),
                                ],
                                onChanged: (code) {
                                  if (code != null) {
                                    context.setLocale(Locale(code));
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22.h,
              width: 22.h,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.g_mobiledata,
                  size: 28.sp,
                  color: AppColors.accentPink,
                ),
                SizedBox(width: 12.w),
                Text(
                  'continue_with_google'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.title,
                  ),
                ),
              ],
            ),
    );
  }
}
