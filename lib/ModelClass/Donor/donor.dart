class Donor {
  final String donorType;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String uid;
  final String password; // ⚠️ Dangerous if stored anywhere

  Donor({
    required this.donorType,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.uid,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'donorType': donorType,
      'name': name,
      'email': email,
      'address': address,
      'phone': phone,
      'uid': uid,
      'password': password, // ⚠️ Not safe!
    };
  }

  factory Donor.fromMap(Map<String, dynamic> map) {
    return Donor(
      donorType: map['donorType'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      uid: map['uid'] ?? '',
      password: map['password'] ?? '',
    );
  }
}
