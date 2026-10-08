import 'package:flutter/foundation.dart';

/// The Google account signed in on this device.
@immutable
class Account {
  const Account({required this.email, required this.name, this.givenName});

  factory Account.fromJson(Map<String, Object?> json) => Account(
        email: json['email']! as String,
        name: json['name'] as String? ?? json['email']! as String,
        givenName: json['givenName'] as String?,
      );

  final String email;

  /// The full name on the Google account.
  final String name;

  /// The first name on the Google account, if it has one.
  final String? givenName;

  /// What to call the person before they have chosen a name.
  String get firstName {
    final given = givenName?.trim() ?? '';
    if (given.isNotEmpty) return given;
    final first = name.trim().split(RegExp(r'\s+')).first;
    return first.isNotEmpty ? first : email.split('@').first;
  }

  Map<String, Object?> toJson() => {
        'email': email,
        'name': name,
        'givenName': givenName,
      };

  @override
  bool operator ==(Object other) =>
      other is Account &&
      other.email == email &&
      other.name == name &&
      other.givenName == givenName;

  @override
  int get hashCode => Object.hash(email, name, givenName);
}

/// A Google access token and when it stops working.
@immutable
class AccessToken {
  const AccessToken({required this.value, required this.expiresAt});

  factory AccessToken.fromJson(Map<String, Object?> json) => AccessToken(
        value: json['value']! as String,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expiresAt']! as int),
      );

  final String value;
  final DateTime expiresAt;

  /// Usable for at least [margin] more.
  bool isFreshAt(DateTime now, {Duration margin = Duration.zero}) =>
      now.add(margin).isBefore(expiresAt);

  Map<String, Object?> toJson() => {
        'value': value,
        'expiresAt': expiresAt.millisecondsSinceEpoch,
      };
}
