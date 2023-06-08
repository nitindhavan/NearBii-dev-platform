// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  bool isActive;

  Color activeColor;

  Color inActiveColor;
  final Function? onTap;

  CustomSwitch({
    Key? key,
    required this.isActive,
    required this.activeColor,
    required this.inActiveColor,
    this.onTap,
  }) : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  static late bool _isActive;

  @override
  void initState() {
    _isActive = widget.isActive;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: _isActive ? Alignment.centerRight : Alignment.centerLeft,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(2),
            ),
          ),
          height: 13,
          width: 33,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isActive = !_isActive;
              widget.onTap!(_isActive);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: _isActive ? widget.activeColor : widget.inActiveColor,
              border: Border.all(
                color: _isActive ? widget.activeColor : widget.inActiveColor,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(2),
              ),
            ),
            height: 20,
            width: 20,
          ),
        )
      ],
    );
  }
}
