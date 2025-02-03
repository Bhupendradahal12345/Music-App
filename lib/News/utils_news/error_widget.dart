import 'package:flutter/material.dart';

class ErrorItem extends StatelessWidget {
  const ErrorItem({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 80.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 50,

          ),
          Text(
            'इन्टरनेट चलेको छैन\n App Develop by Bhupendra Dahal',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
