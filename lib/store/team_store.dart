import 'package:flutter/material.dart';
import '../models/team.dart';

class TeamStore extends ChangeNotifier {
  List<Team> _teams = [];
  Team? _selectedTeam;

  List<Team> get teams => _teams;
  Team? get selectedTeam => _selectedTeam;

  void setTeams(List<Team> teams) {
    _teams = teams;
    notifyListeners();
  }

  void setSelectedTeam(Team? team) {
    _selectedTeam = team;
    notifyListeners();
  }

  void addTeam(Team team) {
    _teams.add(team);
    notifyListeners();
  }

  void updateTeam(String teamId, Team updatedTeam) {
    final index = _teams.indexWhere((t) => t.id == teamId);
    if (index != -1) {
      _teams[index] = updatedTeam;
      notifyListeners();
    }
  }

  void clearTeams() {
    _teams = [];
    _selectedTeam = null;
    notifyListeners();
  }
}






