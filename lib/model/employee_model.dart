class Employee {
  final String uid;
  final String name;
  final String email;

  Employee({
    required this.uid,
    required this.name,
    required this.email,
  });

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      uid: map['uid'] as String,
      name: map['name'] as String? ?? (map['email'] as String).split('@')[0],
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
    };
  }
}