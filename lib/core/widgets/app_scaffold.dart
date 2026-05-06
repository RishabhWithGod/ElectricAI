import 'package:ai_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.automaticallyImplyLeading = true,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.pageGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: title == null
            ? null
            : AppBar(
                title: Text(title!),
                actions: actions,
                automaticallyImplyLeading: automaticallyImplyLeading,
              ),
        body: SafeArea(
          top: title == null,
          bottom: bottomNavigationBar == null,
          child: body,
        ),
        bottomNavigationBar: bottomNavigationBar == null
            ? null
            : SafeArea(top: false, child: bottomNavigationBar!),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
