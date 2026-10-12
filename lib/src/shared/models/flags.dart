enum Flag {
  isDraft(number: 1, color: 4287646528), // context.colors.primary
  needsReviewOne(number: 2, color: 4286010961), // context.colors.secondary
  needsReviewTwo(number: 3, color: 4282607667); // context.colors.tertiary

  final int number;
  final int color;
  const Flag({required this.number, required this.color});

  static Flag fromNumber(int number) {
    return switch (number) {
      1 => isDraft,
      2 => needsReviewOne,
      3 => needsReviewTwo,
      _ => isDraft,
    };
  }
}
