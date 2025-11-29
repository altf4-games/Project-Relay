class ServerConfig {
  final String host;
  final String username;
  final String? privateKey;
  final String? password;
  final int agentPort;
  final String agentSecret;
  final String? label;

  ServerConfig({
    required this.host,
    required this.username,
    this.privateKey,
    this.password,
    this.agentPort = 3000,
    required this.agentSecret,
    this.label,
  }) : assert(
         privateKey != null || password != null,
         'Either privateKey or password must be provided',
       );

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'username': username,
      'privateKey': privateKey,
      'password': password,
      'agentPort': agentPort,
      'agentSecret': agentSecret,
      'label': label,
    };
  }

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      host: json['host'] as String,
      username: json['username'] as String,
      privateKey: json['privateKey'] as String?,
      password: json['password'] as String?,
      agentPort: json['agentPort'] as int? ?? 3000,
      agentSecret: json['agentSecret'] as String,
      label: json['label'] as String?,
    );
  }

  ServerConfig copyWith({
    String? host,
    String? username,
    String? privateKey,
    String? password,
    int? agentPort,
    String? agentSecret,
    String? label,
  }) {
    return ServerConfig(
      host: host ?? this.host,
      username: username ?? this.username,
      privateKey: privateKey ?? this.privateKey,
      password: password ?? this.password,
      agentPort: agentPort ?? this.agentPort,
      agentSecret: agentSecret ?? this.agentSecret,
      label: label ?? this.label,
    );
  }
}
