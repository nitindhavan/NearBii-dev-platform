// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class ServiceCustomCard extends StatelessWidget {
  ServiceCustomCard({
    Key? key,
    this.dot = false,
    this.title = '',
    this.image = '',
    this.cardPress,
  }) : super(key: key);
  bool dot;
  String title;
  String image;

  final VoidCallback? cardPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cardPress,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 7),
        margin: EdgeInsets.symmetric(horizontal: 3, vertical: 7),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 2,
                offset: Offset(2, -2),
              ),
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 2,
                offset: Offset(-2, 2),
              ),
            ]),
        child: dot
            ? Text(
                '   ...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 4,
                  ),
                  SizedBox(
                    height: 25,
                    width: 24,
                    child: Image.network(
                      image ?? 'https://firebasestorage.googleapis.com/v0/b/neabiiapp.appspot.com/o/services%2FPackers%20%26%20Movers%2Ftruck%201.png?alt=media&token=f977ec4b-febd-4458-835e-77d5905fd016',
                      height: 19,
                      width: 19,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        print(exception);
                        print(stackTrace);

                        return Text('Your error widget...');
                      },
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
        height: 40,
        //width: 110,
        width: (MediaQuery.of(context).size.width - 84) / 2,
      ),
    );
  }
}
