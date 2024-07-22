import 'package:campus_guide/screens/bottom_navigator.dart';
import 'package:campus_guide/screens/home_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [
    const OnboardingPage(
      title: "KAMPÜS REHBERİ'NE HOŞGELDİNİZ!",
      description: "Kampüs Rehberi, üniversite hayatınızı daha organize ve keyifli hale getirmek için tasarlanmış kapsamlı bir rehber uygulamasıdır.",
      imagePath: "img/onboarding/welcome.png",
      backgroundColor: Color(0xFFFEF9E5),
      titleBackgroundColor: Color(0xFFE85667),
      descriptionBackgroundColor: Color(0xFFE85667),
      buttonBackgroundColor: Color(0xFFE85667),
      buttonTextColor: Colors.white,
    ),
    const OnboardingPage(
      title: "ÖĞRENCİ KULÜPLERİ",
      description: "Kampüs Rehberi ile öğrenci kulüplerini keşfedin! İlgi alanlarınıza uygun kulüpleri görün, etkinlikleri takip edin ve yeni arkadaşlar edinin.",
      imagePath: "img/onboarding/student.png",
      backgroundColor: Color(0xFFCDC9BD),
      titleBackgroundColor: Color(0xFF70321C),
      descriptionBackgroundColor: Color(0xFF70321C),
      buttonBackgroundColor: Color(0xFF70321C),
      buttonTextColor: Colors.white,
    ),
    const OnboardingPage(
      title: "KAMPÜS HARİTALARI",
      description: "Kaybolmak yok! Kampüs Rehberi ile kampüs haritalarınız her zaman yanınızda.",
      imagePath: "img/onboarding/campus.png",
      backgroundColor: Color(0xFF90D4C4),
      titleBackgroundColor: Color(0xFF57795A),
      descriptionBackgroundColor: Color(0xFF57795A),
      buttonBackgroundColor: Color(0xFF57795A),
      buttonTextColor: Colors.white,
    ),
    const OnboardingPage(
      title: "DERS PROGRAMLARI",
      description: "Ders programınızı düzenleyin, ödevlerinizi takip edin ve sınavlarınızı planlayın. Kampüs Rehberi ile her şey kontrol altında!",
      imagePath: "img/onboarding/schedule.png",
      backgroundColor: Color(0xFF5A9EB1),
      titleBackgroundColor: Color(0xFFFCF4E5),
      descriptionBackgroundColor: Color(0xFFFCF4E5),
      buttonBackgroundColor: Color(0xFFFCF4E5),
      buttonTextColor: Color(0xFF5A9EB1),
    ),
    const OnboardingPage(
      title: "DİJİTAL KÜTÜPHANE",
      description: "Ders notlarından oluşan bir dijital kütüphane! En son notları inceleyin, ihtiyacınız olan dersleri aratabilir, beğenebilir ve indirebilirsiniz.",
      imagePath: "img/onboarding/library.png",
      backgroundColor: Color(0xFFA3BCC0),
      titleBackgroundColor: Color(0xFF4A2E26),
      descriptionBackgroundColor: Color(0xFF4A2E26),
      buttonBackgroundColor: Color(0xFF4A2E26),
      buttonTextColor: Colors.white,
    ),
    const OnboardingPage(
      title: "FORUM",
      description: "Kampüs hayatı hakkında tartışın, bilgi paylaşın ve diğer öğrencilerle bağlantı kurun. Kampüs Rehberi’nde herkes bir arada!",
      imagePath: "img/onboarding/forum.png",
      backgroundColor: Color(0xFFF2FCFE),
      titleBackgroundColor: Color(0xFF459F7C),
      descriptionBackgroundColor: Color(0xFF459F7C),
      buttonBackgroundColor: Color(0xFF459F7C),
      buttonTextColor: Colors.white,
    ),
    const OnboardingPage(
      title: "AI MENTOR",
      description: "AI Mentor ile 7/24 destek! Sorularınızı sorun, öneriler alın ve kampüs hayatınızı daha iyi hale getirin.",
      imagePath: "img/onboarding/ai_mentor.png",
      backgroundColor: Color(0xFFFDFFFE),
      titleBackgroundColor: Color(0xFF055593),
      descriptionBackgroundColor: Color(0xFF055593),
      buttonBackgroundColor: Color(0xFF055593),
      buttonTextColor: Colors.white,
    ),
  ];

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    _completed();
  }

  void _completed(){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavigator(homePage: HomePageScreen(),)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  _pages.length - 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text(
                "ATLA",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      height: 10.0,
                      width: _currentPage == index ? 20.0 : 10.0,
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: (_pages[_currentPage] as OnboardingPage).buttonBackgroundColor,
                      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? "BAŞLA" : "İLERİ",
                      style: TextStyle(
                        color: (_pages[_currentPage] as OnboardingPage).buttonTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;
  final Color titleBackgroundColor;
  final Color descriptionBackgroundColor;
  final Color buttonBackgroundColor;
  final Color buttonTextColor;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundColor,
    required this.titleBackgroundColor,
    required this.descriptionBackgroundColor,
    required this.buttonBackgroundColor,
    required this.buttonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: titleBackgroundColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Image.asset(imagePath, height: 300),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: descriptionBackgroundColor),
            ),
          ),
        ],
      ),
    );
  }
}
