import 'package:flutter/cupertino.dart';

extension Margin on num {
  SizedBox get h => SizedBox(
        height: toDouble(),
      );

  SizedBox get w => SizedBox(
        width: toDouble(),
      );
}