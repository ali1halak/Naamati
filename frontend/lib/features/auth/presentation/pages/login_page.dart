import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../bloc/login_cubit.dart';
import '../bloc/login_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LoginCubit>(),
      child: const _LoginPageView(),
    );
  }
}

class _LoginPageView extends StatefulWidget {
  const _LoginPageView();

  @override
  State<_LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<_LoginPageView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text(
          'نعمتي',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            if (state.isSuccess) {
              context.go(RouteNames.home);
            } else if (state.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'فشل تسجيل الدخول'),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.all(AppConstants.paddingLG.w),
            child: Column(
              children: [
                SizedBox(height: AppConstants.paddingXL.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.paddingLG.w),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: AppConstants.paddingMD.h),
                          Text(
                            'تسجيل الدخول',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(color: colorScheme.primary),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.paddingSM.h),
                          Text(
                            'مرحباً بك مجدداً في منصة نعمتي',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.paddingXL.h),

                          CustomTextField(
                            label: 'البريد الإلكتروني',
                            hint: 'user@example.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: emailValidator,
                            prefixIcon: Icons.email_outlined,
                          ),
                          SizedBox(height: AppConstants.paddingLG.h),

                          CustomTextField(
                            label: 'كلمة المرور',
                            controller: _passwordController,
                            obscureText: true,
                            validator: passwordValidator,
                            prefixIcon: Icons.lock_outline,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onLoginPressed(),
                          ),
                          SizedBox(height: AppConstants.paddingXL.h),

                          BlocBuilder<LoginCubit, LoginState>(
                            builder: (context, state) {
                              return CustomButton(
                                label: 'تسجيل الدخول',
                                onPressed: _onLoginPressed,
                                isLoading: state.isLoading,
                                leadingIcon: Icon(
                                  Icons.login,
                                  size: AppConstants.iconSizeSM.r,
                                  color: colorScheme.onPrimary,
                                ),
                              );
                            },
                          ),
                          SizedBox(height: AppConstants.paddingMD.h),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.paddingXL.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟ ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.register),
                      child: Text(
                        'إنشاء حساب جديد',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
