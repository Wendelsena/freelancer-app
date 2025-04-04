class Freelancer {
  final String id;
  final String name;
  final double rating;
  final String service;
  final String bio;
  final String profileImage;
  final List<String> portfolio;
  final List<Review> reviews;
  final String location;
  final int completedJobs;

  Freelancer({
    required this.id,
    required this.name,
    required this.rating,
    required this.service,
    required this.bio,
    required this.profileImage,
    required this.portfolio,
    required this.reviews,
    required this.location,
    required this.completedJobs,
  });
}

class Review {
  final String user;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.user,
    required this.rating,
    required this.comment,
    required this.date,
  });
}