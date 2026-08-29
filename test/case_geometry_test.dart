import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pccase/src/ui/widgets/case_geometry.dart';

/// Угол, под которым корпус стоит по умолчанию.
CaseGeometry _rest() =>
    CaseGeometry(rx: -12 * math.pi / 180, ry: -28 * math.pi / 180);

void main() {
  group('геометрия корпуса', () {
    test('грани идут от дальней к ближней', () {
      final faces = _rest().facesByDepth();
      for (var i = 1; i < faces.length; i++) {
        expect(
          faces[i].depth,
          greaterThanOrEqualTo(faces[i - 1].depth),
          reason: 'порядок отрисовки нарушен — коробка развалится',
        );
      }
    });

    test('с рабочего ракурса видны передняя, правая и верхняя грани', () {
      final faces = _rest().facesByDepth();
      final visible = faces.where((f) => f.depth > 0).map((f) => f.facet);
      expect(
        visible,
        containsAll([CaseFacet.front, CaseFacet.right, CaseFacet.top]),
      );
      expect(visible, isNot(contains(CaseFacet.back)));
    });

    test('стык передней и боковой грани сходится в одну точку', () {
      final geometry = _rest();
      // Правое ребро передней панели и переднее ребро бокового окна —
      // одна и та же линия в пространстве, значит две вершины обязаны
      // спроецироваться в одни и те же точки.
      final faces = {for (final f in geometry.facesByDepth()) f.facet: f};
      final frontCorners = faces[CaseFacet.front]!.points.map((p) => p.at);
      final rightCorners = faces[CaseFacet.right]!.points.map((p) => p.at);
      final shared = frontCorners
          .where((a) => rightCorners.any((b) => (a - b).distance < 0.001))
          .length;
      expect(shared, 2, reason: 'грани обязаны делить ровно одно ребро');
    });

    test('перспектива увеличивает ближнее и уменьшает дальнее', () {
      final geometry = _rest();
      final near = geometry.project(0, 0, CaseGeometry.d);
      final far = geometry.project(0, 0, -CaseGeometry.d);
      expect(near.z, greaterThan(far.z));
      expect(near.scale, greaterThan(far.scale));
      expect(far.scale, lessThan(1));
    });

    test('без поворота коробка проецируется симметрично', () {
      final geometry = CaseGeometry(rx: 0, ry: 0);
      final left = geometry.project(-CaseGeometry.w, 0, 0);
      final right = geometry.project(CaseGeometry.w, 0, 0);
      expect(left.at.dx, closeTo(-right.at.dx, 0.001));
      expect(left.z, closeTo(right.z, 0.001));
      // Передняя грань смотрит прямо на зрителя.
      final faces = geometry.facesByDepth();
      expect(faces.last.facet, CaseFacet.front);
    });

    test('масштаб и смещение сцены применяются к проекции', () {
      final geometry = CaseGeometry(
        rx: 0,
        ry: 0,
        fit: 0.5,
        origin: const Offset(100, 200),
      );
      final point = geometry.project(CaseGeometry.w, 0, 0);
      expect(point.at.dx, greaterThan(100));
      expect(point.at.dy, closeTo(200, 0.001));
    });
  });
}
