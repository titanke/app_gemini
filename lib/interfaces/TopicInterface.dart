class Topic {
  final String name;
  final String uid;
  DateTime lastInteracted; 

  Topic({
    required this.name,
    required this.uid,
    DateTime? lastInteracted,
  }) : lastInteracted = lastInteracted ?? DateTime.now();

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'uid': uid,
      'lastInteracted': lastInteracted.toIso8601String(), 
    };
  }

  factory Topic.fromFirestore(Map<String, dynamic> data) {
    return Topic(
      name: data['name'],
      uid: data['uid'],
      lastInteracted: DateTime.parse(data['lastInteracted']),
    );
  }
}
