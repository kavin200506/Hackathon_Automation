import 'member.dart';
import 'hackathon.dart';
import 'topic.dart';

class Team {
  final String id;
  final String teamName;
  final List<Member>? members;
  final Hackathon? hackathon;
  final Topic? topic;
  final String paymentStatus;
  final String? githubUrl;
  final DateTime createdAt;
  final String? status;

  Team({
    required this.id,
    required this.teamName,
    this.members,
    this.hackathon,
    this.topic,
    required this.paymentStatus,
    this.githubUrl,
    required this.createdAt,
    this.status,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id']?.toString() ?? '',
      teamName: json['team_name'] ?? '',
      members: json['members'] != null
          ? (json['members'] as List).map((m) => Member.fromJson(m)).toList()
          : null,
      hackathon: json['hackathon'] != null
          ? Hackathon.fromJson(json['hackathon'])
          : null,
      topic: json['topic'] != null
          ? Topic.fromJson(json['topic'])
          : null,
      paymentStatus: json['payment_status'] ?? 'UNPAID',
      githubUrl: json['github_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_name': teamName,
      'members': members?.map((m) => m.toJson()).toList(),
      'hackathon': hackathon?.toJson(),
      'topic': topic?.toJson(),
      'payment_status': paymentStatus,
      'github_url': githubUrl,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }
}

