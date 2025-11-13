class UserModel {
  final int id;
  final String name;
  final String email;
  final String accType;
  final String mobile;
  final String address;
  final String city;
  final String postalCode;
  final String district;
  final String state;
  final String country;
  final String lastLogin;
  final int mobileVerified;
  final String lastActivation;
  final String emailVerifiedAt;
  final int profileFill;
  final String? createdAt;
  final bool status;
  final String? accountStatus;
  final String? interviewAt;
  final String? currentAccountStage;
  final DateTime? updatedAt;
  final String? notes;
  final String? avatarUrl;
  final String? cvUrl;
  final String? referralCode;
  final String? accountMsg;

  final Map<String, dynamic>? professional;
  final List<dynamic>? subjects;
  final List<dynamic>? grades;
  final List<dynamic>? workingDays;
  final List<dynamic>? workingHours;
  final List<dynamic>? steps;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.accType,
    required this.mobile,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.district,
    required this.state,
    required this.country,
    required this.lastLogin,
    required this.mobileVerified,
    required this.lastActivation,
    required this.emailVerifiedAt,
    required this.profileFill,
    this.createdAt,
    required this.status,
    this.accountStatus,
    this.interviewAt,
    this.currentAccountStage,
    this.updatedAt,
    this.notes,
    this.avatarUrl,
    this.cvUrl,
    this.professional,
    this.subjects,
    this.grades,
    this.workingDays,
    this.workingHours,
    this.referralCode,
    this.accountMsg,
    this.steps,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      email: json["email"] ?? '',
      accType: json["acc_type"] ?? '',
      mobile: json["mobile"] ?? '',
      address: json["address"] ?? '',
      city: json["city"] ?? '',
      postalCode: json["postal_code"] ?? '',
      district: json["district"] ?? '',
      state: json["state"] ?? '',
      country: json["country"] ?? '',
      lastLogin: json["last_login"] ?? '',
      mobileVerified: json["mobile_verified"] ?? 0,
      lastActivation: json["last_activation"] ?? '',
      emailVerifiedAt: json["email_verified_at"] ?? '',
      profileFill: json["profile_fill"] ?? 0,
      createdAt: json["created_at"],
      status: json["status"] == 1 || json["status"] == true,
      accountStatus: json["account_status"],
      interviewAt: json["interview_at"],
      currentAccountStage: json["current_account_stage"],
      updatedAt: json["updated_at"] != null
          ? DateTime.tryParse(json["updated_at"])
          : null,
      notes: json["notes"],
      avatarUrl: json["avatar_url"],
      cvUrl: json["cv_url"],
      professional: json["professional"],
      subjects: json["subjects"] ?? [],
      grades: json["grades"] ?? [],
      workingDays: json["working_days"] ?? [],
      workingHours: json["working_hours"] ?? [],
      referralCode: json["referral_code"],
      accountMsg: json["account_msg"] ?? '',
      steps: json["steps"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "acc_type": accType,
      "mobile": mobile,
      "address": address,
      "city": city,
      "postal_code": postalCode,
      "district": district,
      "state": state,
      "country": country,
      "last_login": lastLogin,
      "mobile_verified": mobileVerified,
      "last_activation": lastActivation,
      "email_verified_at": emailVerifiedAt,
      "profile_fill": profileFill,
      "created_at": createdAt,
      "status": status,
      "account_status": accountStatus,
      "interview_at": interviewAt,
      "current_account_stage": currentAccountStage,
      "updated_at": updatedAt?.toIso8601String(),
      "notes": notes,
      "avatar_url": avatarUrl,
      "cv_url": cvUrl,
      "professional": professional,
      "subjects": subjects,
      "grades": grades,
      "working_days": workingDays,
      "working_hours": workingHours,
      "referral_code": referralCode,
      "account_msg": accountMsg,
      "steps": steps,
    };
  }
}
