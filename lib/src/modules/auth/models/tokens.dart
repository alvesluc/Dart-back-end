import 'dart:convert';

class Tokens {
  final String accessToken;
  final String refreshToken;

  Tokens({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'accessToken': accessToken});
    result.addAll({'refreshToken': refreshToken});

    return result;
  }

  factory Tokens.fromMap(Map<String, dynamic> map) {
    return Tokens(
      accessToken: map['accessToken'] ?? '',
      refreshToken: map['refreshToken'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Tokens.fromJson(String source) => Tokens.fromMap(json.decode(source));
}
