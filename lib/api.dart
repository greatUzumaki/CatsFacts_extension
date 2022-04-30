class Fact {
  final String text;

  const Fact({
    required this.text,
  });

  factory Fact.fromJson(Map<String, dynamic> json) {
    return Fact(
      text: json['text'],
    );
  }
}
