import 'package:equatable/equatable.dart';

class PromoModel extends Equatable {
  const PromoModel({
    required this.code,
    this.description,
    this.discountType = 'fixed',
    required this.discountValue,
    this.maxDiscount,
    this.minFare,
    this.isValid = true,
    this.discountAmount,
  });

  final String code;
  final String? description;
  final String discountType;
  final double discountValue;
  final double? maxDiscount;
  final double? minFare;
  final bool isValid;
  final double? discountAmount;

  @override
  List<Object?> get props => [
        code,
        description,
        discountType,
        discountValue,
        maxDiscount,
        minFare,
        isValid,
        discountAmount,
      ];
}
