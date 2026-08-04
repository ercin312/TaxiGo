import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:taxigo_core/taxigo_core.dart';



import '../../../../app/router.dart';



class OnboardingPage extends StatefulWidget {

  const OnboardingPage({super.key});



  @override

  State<OnboardingPage> createState() => _OnboardingPageState();

}



class _OnboardingPageState extends State<OnboardingPage> {

  final _controller = PageController();

  int _currentPage = 0;



  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  Future<void> _finish() async {

    await markOnboardingComplete();

    if (!mounted) return;

    context.go('/login');

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    final size = MediaQuery.sizeOf(context);

    final slides = [

      _SlideData(

        l10n.onboardingTitle1,

        l10n.onboardingDesc1,

        AppImages.taxi,

      ),

      _SlideData(

        l10n.onboardingTitle2,

        l10n.onboardingDesc2,

        AppImages.pickLocation,

      ),

      _SlideData(

        l10n.onboardingTitle3,

        l10n.onboardingDesc3,

        AppImages.sos,

      ),

    ];



    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(

        children: [

          Positioned.fill(

            child: Image.asset(

              AppImages.background,

              fit: BoxFit.cover,

              errorBuilder: (_, __, ___) =>

                  const ColoredBox(color: AppColors.backgroundLight),

            ),

          ),

          SafeArea(

            child: Column(

              children: [

                Align(

                  alignment: Alignment.centerRight,

                  child: TextButton(

                    onPressed: _finish,

                    child: Text(

                      l10n.skip,

                      style: const TextStyle(color: AppColors.primary),

                    ),

                  ),

                ),

                Expanded(

                  child: PageView.builder(

                    controller: _controller,

                    itemCount: slides.length,

                    onPageChanged: (index) => setState(() => _currentPage = index),

                    itemBuilder: (context, index) {

                      final slide = slides[index];

                      return Padding(

                        padding: const EdgeInsets.symmetric(horizontal: 32),

                        child: Column(

                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [

                            Image.asset(

                              slide.imagePath,

                              height: size.height * 0.28,

                              fit: BoxFit.contain,

                              errorBuilder: (_, __, ___) => Icon(

                                Icons.directions_car,

                                size: size.height * 0.2,

                                color: AppColors.primary,

                              ),

                            ),

                            const SizedBox(height: 32),

                            Text(

                              slide.title,

                              textAlign: TextAlign.center,

                              style: Theme.of(context)

                                  .textTheme

                                  .headlineSmall

                                  ?.copyWith(

                                    fontWeight: FontWeight.bold,

                                    color: AppColors.primary,

                                  ),

                            ),

                            const SizedBox(height: 16),

                            Text(

                              slide.description,

                              textAlign: TextAlign.center,

                              style: Theme.of(context)

                                  .textTheme

                                  .bodyLarge

                                  ?.copyWith(

                                    color: AppColors.textSecondaryLight,

                                  ),

                            ),

                          ],

                        ),

                      );

                    },

                  ),

                ),

                Row(

                  mainAxisAlignment: MainAxisAlignment.center,

                  children: List.generate(

                    slides.length,

                    (index) => Container(

                      margin: const EdgeInsets.symmetric(horizontal: 4),

                      width: _currentPage == index ? 24 : 8,

                      height: 8,

                      decoration: BoxDecoration(

                        color: _currentPage == index

                            ? AppColors.primary

                            : AppColors.dividerLight,

                        borderRadius: BorderRadius.circular(4),

                      ),

                    ),

                  ),

                ),

                Padding(

                  padding: const EdgeInsets.all(24),

                  child: PrimaryButton(

                    label: _currentPage == slides.length - 1

                        ? l10n.getStarted

                        : l10n.next,

                    onPressed: () {

                      if (_currentPage == slides.length - 1) {

                        _finish();

                      } else {

                        _controller.nextPage(

                          duration: const Duration(milliseconds: 300),

                          curve: Curves.easeInOut,

                        );

                      }

                    },

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}



class _SlideData {

  const _SlideData(this.title, this.description, this.imagePath);



  final String title;

  final String description;

  final String imagePath;

}


