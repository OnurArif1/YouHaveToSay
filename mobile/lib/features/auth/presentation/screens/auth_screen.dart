import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showEmailLogin = false;

  @override
  void initState() {
    super.initState();
    // Firebase yoksa e-posta girişi doğrudan göster
    if (_useDevAuth) {
      _showEmailLogin = true;
    }
  }
  bool _isSignUp = false;
  bool _obscurePassword = true;

  bool get _useDevAuth => getIt<AppConfig>().useDevAuth;

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
    context.read<AuthBloc>().add(const AuthGoogleSignInRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state.errorMessage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.errorMessage!.tr())),
                        );
                      }
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
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'auth_subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 48.h),
                          if (!_useDevAuth) ...[
                            _GoogleSignInButton(
                              isLoading: state.isLoading,
                              onPressed: _signInWithGoogle,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'google_auth_hint'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey.shade400)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                                  child: Text(
                                    'or'.tr(),
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey.shade400)),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                          TextButton(
                            onPressed: state.isLoading
                                ? null
                                : () => setState(
                                      () => _showEmailLogin = !_showEmailLogin,
                                    ),
                            child: Text(
                              _showEmailLogin
                                  ? 'hide_email_login'.tr()
                                  : 'email_login_option'.tr(),
                            ),
                          ),
                          if (_showEmailLogin || _useDevAuth) ...[
                            SizedBox(height: 8.h),
                            if (_useDevAuth)
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: Text(
                                  'dev_auth_notice'.tr(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.orange.shade800,
                                  ),
                                ),
                              ),
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
                              Text('language'.tr()),
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
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(52.h),
        backgroundColor: Colors.white,
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
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
                  Icons.mail_outline,
                  size: 24.sp,
                  color: Colors.red.shade600,
                ),
                SizedBox(width: 12.w),
                Text(
                  'continue_with_google'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
    );
  }
}
