import 'dart:convert';

class StatusTimeModel {
  final bool success;
  final String message;
  final StatusData data;

  StatusTimeModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StatusTimeModel.fromJson(String str) =>
      StatusTimeModel.fromMap(json.decode(str));

  factory StatusTimeModel.fromMap(Map<String, dynamic> json) => StatusTimeModel(
    success: json["success"],
    message: json["message"],
    data: StatusData.fromMap(json["data"]),
  );
}

class StatusData {
  final List<DailyTotal> dailyTotals;
  final int avgThisWeek;
  final int avgLastWeek;

  StatusData({
    required this.dailyTotals,
    required this.avgThisWeek,
    required this.avgLastWeek,
  });

  factory StatusData.fromMap(Map<String, dynamic> json) => StatusData(
    dailyTotals: List<DailyTotal>.from(
      json["dailyTotals"].map((x) => DailyTotal.fromMap(x)),
    ),
    avgThisWeek: json["avgThisWeek"],
    avgLastWeek: json["avgLastWeek"],
  );
}

class DailyTotal {
  final String day;
  final int time;

  DailyTotal({required this.day, required this.time});

  factory DailyTotal.fromMap(Map<String, dynamic> json) =>
      DailyTotal(day: json["day"], time: json["time"]);
}
