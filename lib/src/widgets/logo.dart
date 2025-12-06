import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Positioned(
            top: 0,
            left: 8,
            child: Icon(
              Icons.minimize,
              weight: 10,
              fontWeight: FontWeight.w900,
              size: 12,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Icon(
              Icons.arrow_forward_ios,
              weight: 10,
              fontWeight: FontWeight.w900,
              size: 12,
            ),
          ),
          Icon(Icons.timelapse_rounded, size: 40),
        ],
      ),
    );
  }
}
