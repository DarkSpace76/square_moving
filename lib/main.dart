import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Padding(
        padding: EdgeInsets.all(32.0),
        child: SquareAnimation(),
      ),
    );
  }
}

class SquareAnimation extends StatefulWidget {
  const SquareAnimation({super.key});

  @override
  State<SquareAnimation> createState() {
    return SquareAnimationState();
  }
}

class SquareAnimationState extends State<SquareAnimation> {
  ///Ширина квадрата
  static const _squareSize = 50.0;

  ///размер шага для анимации движения
  static const step = 150;

  /// Переменная определяет движется ли квадрта в данный момент
  bool move = false;

  ///Ширина контейнера внутри которого будет анимироватся квадрат
  double? maxWidth;

  ///текущая позиция квадрата
  double? currentPos;

  ///переменные определяют границы за которые квадрат не должен выходить
  double leftEdge = 0;
  late double rightEdge;

  ///Выполняет расчет максимальной ширны и ширину правой границы контейнера
  /// согласно [BoxConstraints constraints] получаемый из LayoutBuilder
  void getSize(BoxConstraints constraints) {
    maxWidth ??= constraints.maxWidth;
    currentPos ??= maxWidth! / 2 - _squareSize / 2;

    //если размер окна изменился делаем перерасчет ширины
    if (constraints.maxWidth != maxWidth!) {
      maxWidth = constraints.maxWidth;
      currentPos = maxWidth! / 2 - _squareSize / 2;
    }

    rightEdge = maxWidth! - _squareSize;
  }

  ///Функции определяют находится ли квадрат у левой или правой границы контейнера
  ///возвращают [true] если квадрат находится возле границ
  bool isLeftEdge() => currentPos! <= leftEdge;
  bool isRight() => currentPos! >= rightEdge;

  ///Осуществляет рассчет новых координат для анимации квадрата
  ///согласно направлению движения [AxisDirection direct]
  void calcPosition(AxisDirection direct) {
    setState(() {
      move = true;
      switch (direct) {
        case AxisDirection.left:
          double newPos = currentPos! - step;
          currentPos = newPos > leftEdge ? newPos : leftEdge;
          break;

        default:
          double newPos = currentPos! + step;
          currentPos = newPos < rightEdge ? newPos : rightEdge;
          break;
      }
    });
  }

  ///Функции обработчики для кнопок "Вправо" и "Влево"
  Function()? onPressRight() =>
      move || isRight() ? null : () => calcPosition(AxisDirection.right);

  Function()? onPressLeft() =>
      move || isLeftEdge() ? null : () => calcPosition(AxisDirection.left);

  ///Функция обраотчик при завершении анимации
  ///выполняет сброс флага [move]
  void endAnimation() {
    setState(() {
      move = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        getSize(constraints);
        return Column(
          children: [
            SizedBox(
              height: 50,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(seconds: 1),
                    left: currentPos,
                    onEnd: endAnimation,
                    child: Container(
                      width: _squareSize,
                      height: _squareSize,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: onPressRight(),
                  child: const Text('Right'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onPressLeft(),
                  child: const Text('Left'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
