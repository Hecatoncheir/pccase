import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Спроецированная точка: где на экране, насколько глубоко и с каким
/// масштабом перспективы.
typedef ProjectedPoint = ({Offset at, double z, double scale});

/// Грань коробки в порядке обхода вершин.
enum CaseFacet { back, left, bottom, top, right, front }

class CaseFace {
  const CaseFace(this.facet, this.points);

  final CaseFacet facet;
  final List<ProjectedPoint> points;

  /// Средняя глубина — по ней грани и сортируются.
  double get depth => points.fold(0.0, (sum, p) => sum + p.z) / points.length;
}

/// Геометрия корпуса: поворот, перспектива и порядок граней.
///
/// Вынесено из художника намеренно — это чистая математика без Canvas,
/// и именно она однажды разъехалась незаметно для тестов.
class CaseGeometry {
  CaseGeometry({
    required this.rx,
    required this.ry,
    this.fit = 1,
    this.origin = Offset.zero,
  }) : _cosX = math.cos(rx),
       _sinX = math.sin(rx),
       _cosY = math.cos(ry),
       _sinY = math.sin(ry);

  /// Полугабариты: ширина 210, высота 330, глубина 215.
  static const double w = 105;
  static const double h = 165;
  static const double d = 107.5;
  static const double focal = 1500;
  static const double floorY = 196;

  final double rx;
  final double ry;
  final double fit;
  final Offset origin;

  // Углы на кадр одни и те же — синусы считаются раз на сцену,
  // а не на каждую из полутысячи точек.
  final double _cosX;
  final double _sinX;
  final double _cosY;
  final double _sinY;

  ProjectedPoint project(double x, double y, double z) {
    final x1 = x * _cosY + z * _sinY;
    final z1 = -x * _sinY + z * _cosY;
    final y2 = y * _cosX - z1 * _sinX;
    final z2 = y * _sinX + z1 * _cosX;

    final s = focal / (focal - z2) * fit;
    return (at: Offset(x1 * s, y2 * s) + origin, z: z2, scale: s);
  }

  /// Грани от дальней к ближней: у Flutter нет буфера глубины, порядок
  /// отрисовки — единственное, что держит коробку целой.
  List<CaseFace> facesByDepth() {
    final faces = <CaseFace>[
      CaseFace(CaseFacet.back, [
        project(-w, -h, -d),
        project(w, -h, -d),
        project(w, h, -d),
        project(-w, h, -d),
      ]),
      CaseFace(CaseFacet.left, [
        project(-w, -h, -d),
        project(-w, -h, d),
        project(-w, h, d),
        project(-w, h, -d),
      ]),
      CaseFace(CaseFacet.bottom, [
        project(-w, h, -d),
        project(w, h, -d),
        project(w, h, d),
        project(-w, h, d),
      ]),
      CaseFace(CaseFacet.top, [
        project(-w, -h, -d),
        project(w, -h, -d),
        project(w, -h, d),
        project(-w, -h, d),
      ]),
      CaseFace(CaseFacet.right, [
        project(w, -h, d),
        project(w, -h, -d),
        project(w, h, -d),
        project(w, h, d),
      ]),
      CaseFace(CaseFacet.front, [
        project(-w, -h, d),
        project(w, -h, d),
        project(w, h, d),
        project(-w, h, d),
      ]),
    ];
    faces.sort((a, b) => a.depth.compareTo(b.depth));
    return faces;
  }
}
