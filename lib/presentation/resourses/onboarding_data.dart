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

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Always stay informed about new features and services",
    image: "asset/screen1.png",
    desc: "Remember to keep track of your professional accomplishments.",
  ),
  OnboardingContents(
    title: "Always stay informed about new features and services",
    image: "asset/screen2.png",
    desc:
        "But understanding the contributions our colleagues make to our teams and companies.",
  ),
  OnboardingContents(
    title: "Always stay informed about new features and services",
    image: "asset/screen3.png",
    desc:
        "Take control of notifications, collaborate live or on your own time.",
  ),
];
