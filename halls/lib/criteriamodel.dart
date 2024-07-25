class Criteria {
  int attachmentToHall;
  int governmentStudent;
  int disabled;
  double cgpa;
  double uace;
  int continuingResident;
  int privateStudent;
  int totalPoints;

  Criteria({
    required this.attachmentToHall,
    required this.governmentStudent,
    required this.disabled,
    required this.cgpa,
    required this.uace,
    required this.continuingResident,
    required this.privateStudent,
  }) : totalPoints = 0 {
    calculateTotalPoints();
  }

  void calculateTotalPoints() {
    int cgpaPoints = (cgpa >= 3.5) ? 20 : 0;
    totalPoints = attachmentToHall + governmentStudent + disabled + cgpaPoints + continuingResident + privateStudent;
  }

  // Convert a Criteria object into a Map
  Map<String, dynamic> toMap() {
    return {
      'attachmentToHall': attachmentToHall,
      'governmentStudent': governmentStudent,
      'disabled': disabled,
      'cgpa': cgpa,
      'uace': uace,
      'continuingResident': continuingResident,
      'privateStudent': privateStudent,
      'totalPoints': totalPoints,
    };
  }

  // Create a Criteria object from a Map
  factory Criteria.fromMap(Map<String, dynamic> map) {
    Criteria criteria = Criteria(
      attachmentToHall: map['attachmentToHall'] ?? 0,
      governmentStudent: map['governmentStudent'] ?? 0,
      disabled: map['disabled'] ?? 0,
      cgpa: map['cgpa'] ?? 0.0,
      uace: map['uace'] ?? 0.0,
      continuingResident: map['continuingResident'] ?? 0,
      privateStudent: map['privateStudent'] ?? 0,
    );
    criteria.calculateTotalPoints();
    return criteria;
  }
}
