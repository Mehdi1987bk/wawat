import '../../services/localization_service.dart';

class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

// A getter (not a top-level constant) so tr() re-runs per access and reflects
// runtime language changes instead of being evaluated once at startup.
List<OnboardingContents> get contents => [
      OnboardingContents(
        title: tr('onboarding.stay_informed_title',
            'Always stay informed about new features and services'),
        image: "asset/screen1.png",
        desc: tr('onboarding.track_accomplishments_desc',
            'Remember to keep track of your professional accomplishments.'),
      ),
      OnboardingContents(
        title: tr('onboarding.stay_informed_title',
            'Always stay informed about new features and services'),
        image: "asset/screen2.png",
        desc: tr('onboarding.colleague_contributions_desc',
            'But understanding the contributions our colleagues make to our teams and companies.'),
      ),
      OnboardingContents(
        title: tr('onboarding.stay_informed_title',
            'Always stay informed about new features and services'),
        image: "asset/screen3.png",
        desc: tr('onboarding.notifications_control_desc',
            'Take control of notifications, collaborate live or on your own time.'),
      ),
    ];
