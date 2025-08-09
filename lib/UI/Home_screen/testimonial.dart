class Testimonial {
  final String clientName;
  final int stars;
  final String shortQuote;
  final String longReview;
  final String? clientImagePath; // Optional, for the large card

  Testimonial({
    required this.clientName,
    required this.stars,
    this.shortQuote = '',
    this.longReview = '',
    this.clientImagePath,
  });
}
