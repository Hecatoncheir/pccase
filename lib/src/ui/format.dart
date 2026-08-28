/// Неразрывный пробел: цена и единицы не должны разрываться переносом.
const nbsp = ' ';

/// Склеивает значение с единицей неразрывным пробелом: «616 г».
String nb(Object value, String unit) => '$value$nbsp$unit';

/// «8 609 ₽» — разряды и знак валюты держатся вместе.
String rub(num value) => nb(_grouped(value.round()), '₽');

String grams(int value) => nb(value, 'г');

String hoursMinutes(double hours) {
  final h = hours.floor();
  final m = ((hours - h) * 60).round();
  return '${nb(h, 'ч')} ${nb(m, 'мин')}';
}

String _grouped(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(nbsp);
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
