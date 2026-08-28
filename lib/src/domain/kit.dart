import 'package:flutter/material.dart';

/// Готовый набор из каталога — то, что можно купить, не заходя в конструктор.
@immutable
class Kit {
  const Kit({
    required this.name,
    required this.description,
    required this.price,
    required this.tag,
    required this.from,
    required this.to,
  });

  final String name;
  final String description;
  final int price;
  final String tag;
  final Color from;
  final Color to;
}

const kKits = <Kit>[
  Kit(
    name: 'ModCase Hyper · полный набор',
    description:
        'Все шесть печатных деталей, крепёж, ножки и инструкция. '
        'Схема — любая из пресетов или своя.',
    price: 8990,
    tag: 'Хит',
    from: Color(0xFFFF4A1C),
    to: Color(0xFF2BB8FF),
  ),
  Kit(
    name: 'Airflow Front Kit',
    description:
        'Фронтальная сетка с увеличенной перфорацией и '
        'кабель-гребёнка. Для сборок с тремя вертушками.',
    price: 2690,
    tag: 'Новинка',
    from: Color(0xFFB6FF2E),
    to: Color(0xFF16F2AE),
  ),
  Kit(
    name: 'Window Side Kit',
    description:
        'Рама бокового окна под акрил 3 мм, акрил и фурнитура '
        'в комплекте.',
    price: 3190,
    tag: '−15%',
    from: Color(0xFF2BB8FF),
    to: Color(0xFFA855F7),
  ),
  Kit(
    name: 'RGB Diffuser Kit',
    description:
        'Рассеиватели подсветки и светящиеся ножки из прозрачного '
        'PETG.',
    price: 1890,
    tag: 'Под заказ',
    from: Color(0xFFFF2D8F),
    to: Color(0xFFFFB020),
  ),
];

/// Шаги от заказа до сборки — здесь порядок несёт смысл, поэтому нумеруем.
const kSteps = <(String, String)>[
  (
    'Конфигурация',
    'Собираешь набор в конструкторе или берёшь пресет. Видишь цену и время '
        'печати до оплаты.',
  ),
  (
    'Печать на ферме',
    'Задание уходит на свободный принтер с нужной катушкой. Профиль слайсера '
        'уже настроен под каждую деталь.',
  ),
  (
    'Контроль и постобработка',
    'Снимаем поддержки, проверяем посадочные размеры под БП, вентиляторы и '
        'материнскую плату, ставим фурнитуру.',
  ),
  (
    'Доставка и сборка',
    'Приезжает набор, крепёж и инструкция. Сборка отвёрткой — около часа, '
        'без клея.',
  ),
];
