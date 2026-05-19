import 'package:equatable/equatable.dart';

import 'comparison.dart';

class ComparisonFeedResponse extends Equatable {
  const ComparisonFeedResponse({
    required this.items,
    required this.hasMore,
  });

  final List<Comparison> items;
  final bool hasMore;

  @override
  List<Object?> get props => [items, hasMore];
}
