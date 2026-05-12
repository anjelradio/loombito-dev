import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/shared/widgets/ui/custom_filled_button.dart';

class SlideInfo {
  final String title;
  final String caption;
  final String imageUrl;

  SlideInfo(this.title, this.caption, this.imageUrl);
}

final slides = <SlideInfo>[
  SlideInfo(
    'Todo el control académico en un solo lugar',
    'Supervisa el rendimiento de tus hijos o estudiantes de forma simple y rápida.',
    'assets/images/app_introduction/1.png',
  ),
  SlideInfo(
    'Conecta con un solo código',
    'Vincula un estudiante o colegio fácilmente usando un ID único.',
    'assets/images/app_introduction/2.png',
  ),
  SlideInfo(
    'Monitorea el progreso',
    'Consulta notas, asistencia y desempeño en tiempo real.',
    'assets/images/app_introduction/3.png',
  ),
  SlideInfo(
    'Predicciones inteligentes',
    'Anticipa el rendimiento académico con análisis predictivo.',
    'assets/images/app_introduction/4.png',
  ),
  SlideInfo(
    'Diseñado para padres y docentes',
    'Cada usuario tiene herramientas adaptadas a sus necesidades.',
    'assets/images/app_introduction/5.png',
  ),
  SlideInfo(
    'Empieza ahora',
    'Conecta tu cuenta y comienza a mejorar el aprendizaje.',
    'assets/images/app_introduction/6.png',
  ),
];

class AppIntroductionScreen extends StatefulWidget {
  const AppIntroductionScreen({super.key});

  @override
  State<AppIntroductionScreen> createState() => _AppIntroductionScreenState();
}

class _AppIntroductionScreenState extends State<AppIntroductionScreen> {
  final PageController pageViewController = PageController();
  double currentPage = 0;

  bool get isLastSlide => currentPage >= slides.length - 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Column(
            children: [
              _IntroductionHeader(onSkipPressed: _onSkipPressed),
              const SizedBox(height: 8),
              Expanded(
                child: PageView.builder(
                  controller: pageViewController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index.toDouble();
                    });
                  },
                  itemBuilder: (context, index) {
                    final slideData = slides[index];
                    return _Slide(
                      title: slideData.title,
                      caption: slideData.caption,
                      imageUrl: slideData.imageUrl,
                    );
                  },
                ),
              ),
              _DotsIndicator(
                totalDots: slides.length,
                currentPage: currentPage,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FadeInUp(
                  from: 8,
                  duration: const Duration(milliseconds: 350),
                  child: CustomFilledButton(
                    text: isLastSlide ? 'Comenzar ahora' : 'Siguiente',
                    borderRadius: 14,
                    onPressed: _onMainButtonPressed,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _onSkipPressed() {
    pageViewController.animateToPage(
      slides.length - 1,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _onMainButtonPressed() {
    if (isLastSlide) context.push('/login');

    pageViewController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String caption;
  final String imageUrl;
  const _Slide({
    required this.title,
    required this.caption,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF183A5A),
      height: 1.2,
    );
    final bodySmall = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF546171),
      height: 1.45,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: Center(child: Image.asset(imageUrl, fit: BoxFit.contain)),
          ),
          const SizedBox(height: 26),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(title, textAlign: TextAlign.center, style: titleStyle),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(caption, textAlign: TextAlign.center, style: bodySmall),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _IntroductionHeader extends StatelessWidget {
  final VoidCallback onSkipPressed;

  const _IntroductionHeader({required this.onSkipPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Image.asset('assets/images/logo/loombo-blue.png', height: 50),
            const SizedBox(width: 5),
            Text(
              'LoomBo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CustomFilledButton.defaultButtonColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: onSkipPressed,
          child: Text(
            'Saltar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              color: const Color(0xFF3F4E5E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int totalDots;
  final double currentPage;

  const _DotsIndicator({required this.totalDots, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        final isActive = currentPage.round() == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1F476E) : const Color(0xFFD5DEE8),
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }
}
