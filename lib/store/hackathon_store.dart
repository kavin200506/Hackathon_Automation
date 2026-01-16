import 'package:flutter/material.dart';
import '../models/hackathon.dart';
import '../models/topic.dart';

class HackathonStore extends ChangeNotifier {
  List<Hackathon> _hackathons = [];
  Hackathon? _selectedHackathon;
  List<Topic> _topics = [];

  List<Hackathon> get hackathons => _hackathons;
  Hackathon? get selectedHackathon => _selectedHackathon;
  List<Topic> get topics => _topics;

  void setHackathons(List<Hackathon> hackathons) {
    _hackathons = hackathons;
    notifyListeners();
  }

  void setSelectedHackathon(Hackathon? hackathon) {
    _selectedHackathon = hackathon;
    notifyListeners();
  }

  void setTopics(List<Topic> topics) {
    _topics = topics;
    notifyListeners();
  }

  void addHackathon(Hackathon hackathon) {
    _hackathons.add(hackathon);
    notifyListeners();
  }

  void clearHackathons() {
    _hackathons = [];
    _selectedHackathon = null;
    _topics = [];
    notifyListeners();
  }
}




