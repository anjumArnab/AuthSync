class StoredAccount {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String customToken;
  final String label;
  final DateTime createdAt;
  final DateTime lastUsedAt;

  StoredAccount({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.customToken,
    required this.label,
    required this.createdAt,
    required this.lastUsedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'customToken': customToken,
      'label': label,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt.toIso8601String(),
    };
  }

  factory StoredAccount.fromJson(Map<String, dynamic> json) {
    return StoredAccount(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      customToken: json['customToken'],
      label: json['label'],
      createdAt: DateTime.parse(json['createdAt']),
      lastUsedAt: DateTime.parse(json['lastUsedAt']),
    );
  }

  StoredAccount copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? customToken,
    String? label,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return StoredAccount(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      customToken: customToken ?? this.customToken,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
}
