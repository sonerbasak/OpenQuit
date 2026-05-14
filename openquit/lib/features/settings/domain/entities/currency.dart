/// Desteklenen para birimleri kataloğu.
class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static const List<Currency> all = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'TRY', symbol: '₺', name: 'Turkish Lira'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    Currency(code: 'CAD', symbol: 'CA\$', name: 'Canadian Dollar'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    Currency(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'),
    Currency(code: 'CNY', symbol: '¥', name: 'Chinese Yuan'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    Currency(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real'),
    Currency(code: 'MXN', symbol: 'MX\$', name: 'Mexican Peso'),
    Currency(code: 'KRW', symbol: '₩', name: 'South Korean Won'),
    Currency(code: 'RUB', symbol: '₽', name: 'Russian Ruble'),
    Currency(code: 'SAR', symbol: '﷼', name: 'Saudi Riyal'),
    Currency(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
  ];

  static Currency fromCode(String code) =>
      all.firstWhere((c) => c.code == code, orElse: () => all.first);
}
