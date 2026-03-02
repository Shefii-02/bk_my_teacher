class AppStateModel {
  final String name;
  final List<String> districts;

  AppStateModel({required this.name, required this.districts});
}

final List<AppStateModel> states = [
  AppStateModel(
    name: "Kerala",
    districts: [
      "Thiruvananthapuram",
      "Kollam",
      "Pathanamthitta",
      "Alappuzha",
      "Kottayam",
      "Idukki",
      "Ernakulam",
      "Thrissur",
      "Palakkad",
      "Malappuram",
      "Kozhikode",
      "Wayanad",
      "Kannur",
      "Kasaragod",
    ],
  ),
];