import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/manual_match_details.dart';

class BackendApiService {
  BackendApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  String get _baseUrl {
    final configured = dotenv.env['BACKEND_BASE_URL'];
    if (configured != null && configured.trim().isNotEmpty) {
      return configured.trim().replaceFirst(RegExp(r'/$'), '');
    }
    return 'http://10.0.2.2:5000';
  }

  Future<List<FantasyGroupDto>> getMyGroups() async {
    final response = await _send('GET', '/api/groups/mine');
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => FantasyGroupDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FantasyGroupDto> createGroup(String name) async {
    final response = await _send(
      'POST',
      '/api/groups/create',
      body: {'name': name, 'maxMembers': 7},
    );
    return FantasyGroupDto.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<FantasyGroupDto> joinGroup(String code) async {
    final response = await _send(
      'POST',
      '/api/groups/join',
      body: {'code': code},
    );
    return FantasyGroupDto.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> calculateFantasyPoints({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _send(
      'POST',
      '/api/fantasy/calculate-points',
      body: payload,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> calculateStandings({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _send(
      'POST',
      '/api/standings/calculate',
      body: payload,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<ManualMatchDetails> getManualMatchDetails(String matchId) async {
    final response = await _send('GET', '/api/matches/$matchId/manual');
    return ManualMatchDetails.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final uri = Uri.parse('$_baseUrl$path');

    final response = switch (method) {
      'GET' => await _client.get(uri, headers: headers),
      'POST' => await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(body ?? const {}),
      ),
      _ => throw UnsupportedError('Unsupported method $method'),
    };

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BackendApiException(response.statusCode, response.body);
    }

    return response;
  }
}

class FantasyGroupDto {
  final String id;
  final String code;
  final String name;
  final String ownerUserId;
  final int members;
  final int maxMembers;
  final DateTime createdAt;

  const FantasyGroupDto({
    required this.id,
    required this.code,
    required this.name,
    required this.ownerUserId,
    required this.members,
    required this.maxMembers,
    required this.createdAt,
  });

  factory FantasyGroupDto.fromJson(Map<String, dynamic> json) {
    return FantasyGroupDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      ownerUserId: json['ownerUserId'] as String,
      members: json['members'] as int,
      maxMembers: json['maxMembers'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class BackendApiException implements Exception {
  final int statusCode;
  final String body;

  const BackendApiException(this.statusCode, this.body);

  @override
  String toString() => 'BackendApiException($statusCode): $body';
}
