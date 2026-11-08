import '../data/models.dart';

enum PriceSource { online, manual, none }

/// Spreadsheet ROUND: half away from zero.
double roundTo(double value, int decimals) {
  var factor = 1.0;
  for (var i = 0; i < decimals; i++) {
    factor *= 10;
  }
  // Small epsilon against binary artefacts like 7.6952849999.
  final scaled = value * factor;
  final rounded = scaled >= 0 ? (scaled + 1e-9).roundToDouble() : (scaled - 1e-9).roundToDouble();
  return rounded / factor;
}

class EtfRow {
  const EtfRow({
    required this.position,
    required this.amount,
    required this.price,
    required this.source,
    required this.limit,
    required this.wholeUnits,
    required this.wholeCost,
    required this.unitsByAmount,
  });

  final EtfPosition position;

  /// "Betrag pro Jahr" = budget × share.
  final double amount;
  final double? price;
  final PriceSource source;

  /// Limit price = price × (1 + markup), 3 decimals below 10 €, else 2.
  final double? limit;
  final int? wholeUnits;
  final double? wholeCost;

  /// Fractional units when buying "by amount".
  final double? unitsByAmount;
}

class InvestmentResult {
  const InvestmentResult({
    required this.rows,
    required this.shareSum,
    required this.totalAmount,
    required this.totalWholeCost,
    required this.rest,
    required this.fees,
    required this.feeShare,
    required this.cheapest,
  });

  final List<EtfRow> rows;
  final double shareSum;
  final double totalAmount;
  final double totalWholeCost;

  /// "Rest bei ganzen Stück".
  final double rest;

  /// "Spesen gesamt": one order per position with an amount.
  final double fees;
  final double feeShare;

  /// Position with the lowest unit price – where the rest fits best.
  final EtfPosition? cheapest;

  bool get sharesValid => roundTo(shareSum, 4) == 1;
}

InvestmentResult calculateInvestments(InvestmentPlan plan, {required bool onlineEnabled}) {
  final rows = <EtfRow>[];
  for (final p in plan.positions) {
    final amount = plan.annualBudget * p.share;
    final useOnline = onlineEnabled && p.onlinePrice != null;
    final price = useOnline ? p.onlinePrice : p.manualPrice;
    final source = useOnline
        ? PriceSource.online
        : (p.manualPrice != null ? PriceSource.manual : PriceSource.none);
    if (price == null || price <= 0) {
      rows.add(EtfRow(
        position: p,
        amount: amount,
        price: null,
        source: PriceSource.none,
        limit: null,
        wholeUnits: null,
        wholeCost: null,
        unitsByAmount: null,
      ));
      continue;
    }
    final limit = roundTo(price * (1 + plan.limitMarkup), price < 10 ? 3 : 2);
    final units = (amount / limit).floor();
    rows.add(EtfRow(
      position: p,
      amount: amount,
      price: price,
      source: source,
      limit: limit,
      wholeUnits: units,
      wholeCost: units * limit,
      unitsByAmount: roundTo(amount / price, 3),
    ));
  }

  final totalWholeCost = rows.fold<double>(0, (s, r) => s + (r.wholeCost ?? 0));
  final orders = rows.where((r) => r.amount > 0).length;
  final fees = orders * plan.feePerOrder;
  final priced = rows.where((r) => r.price != null).toList()
    ..sort((a, b) => a.price!.compareTo(b.price!));

  return InvestmentResult(
    rows: rows,
    shareSum: plan.positions.fold(0, (s, p) => s + p.share),
    totalAmount: rows.fold(0, (s, r) => s + r.amount),
    totalWholeCost: totalWholeCost,
    rest: plan.annualBudget - totalWholeCost,
    fees: fees,
    feeShare: plan.annualBudget == 0 ? 0 : fees / plan.annualBudget,
    cheapest: priced.isEmpty ? null : priced.first.position,
  );
}
