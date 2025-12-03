class TimeShow {
  final String id; // tid
  final DateTime time; // timestamp

  TimeShow({required this.id, required this.time});

  factory TimeShow.fromMap(Map<String, dynamic> map) {
    return TimeShow(
      id: map['id'] as String,
      time: DateTime.parse(map['time']).toLocal(),
    );
  }
}
