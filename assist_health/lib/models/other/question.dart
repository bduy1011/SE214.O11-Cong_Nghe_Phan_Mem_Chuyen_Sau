class Question {
  final String id;
  final String gender;
  final int age;
  final String title;
  final String content;
  final List<String> categories;
  bool isLiked;
  int likes;
  int answerCount;
  String questionUserId;
  DateTime? date;
  List<Map<String, dynamic>> answers = [];

  Question({
    required this.id,
    required this.gender,
    required this.age,
    required this.title,
    required this.content,
    this.answers = const [],
    required this.categories,
    required this.answerCount,
    this.likes = 0,
    this.isLiked = false,
    required this.questionUserId,
    this.date,
  });
}
