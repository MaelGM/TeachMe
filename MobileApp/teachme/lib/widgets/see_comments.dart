import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SeeComments extends StatefulWidget{

  @override
  State<SeeComments> createState() => _SeeCommentsState();
}

class _SeeCommentsState extends State<SeeComments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close), color: Colors.white,),
        
      ),
    );
  }
}