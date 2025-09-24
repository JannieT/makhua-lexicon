enum Flag {
  isDraft(number: 1, color: 4287646528, label: 'Draft'), // context.colors.primary
  needsReviewOne(
    number: 2,
    color: 4286010961,
    label: 'Needs Review One',
  ), // context.colors.secondary
  needsReviewTwo(
    number: 3,
    color: 4282607667,
    label: 'Needs Review Two',
  ); // context.colors.tertiary

  final int number;
  final int color;
  final String label;
  const Flag({required this.number, required this.color, required this.label});

  static Flag fromNumber(int number) {
    return switch (number) {
      1 => isDraft,
      2 => needsReviewOne,
      3 => needsReviewTwo,
      _ => isDraft,
    };
  }
}
