import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;

  CustomButton({
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
    this.textColor = Colors.white
  });

  @override
  Widget build(BuildContext context){
    return Container(
  height: 40,
  width: double.infinity,
  decoration: BoxDecoration(
    color: Colors.blue, // Background color for the container
    borderRadius: BorderRadius.circular(8), // Optional rounded corners
  ),
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.purple, // Match container color
      foregroundColor: Colors.white, // Text color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
      ),
    ),
    child: Text(text),
  ),
);

  }
}