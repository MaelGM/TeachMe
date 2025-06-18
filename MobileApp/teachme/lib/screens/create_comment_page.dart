import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:teachme/models/rating_model.dart';
import 'package:teachme/service/course_service.dart';
import 'package:teachme/service/teacher_service.dart';
import 'package:teachme/utils/config.dart';
import 'package:teachme/utils/translate.dart';
import 'package:teachme/utils/utils.dart';

class CreateCommentPage extends StatefulWidget {
  final String? courseId;
  final String? teacherId;

  CreateCommentPage({this.courseId, this.teacherId});

  @override
  _CreateCommentPageState createState() => _CreateCommentPageState();
}

class _CreateCommentPageState extends State<CreateCommentPage> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = -1;
  bool _isLoading = false;
  List<File> _images = [];
  RatingModel comentario = RatingModel(
    id: '',
    userId: '',
    userName: '',
    userPhotoUrl: '',
    comment: '',
    date: DateTime.now(),
    score: 0,
    photos: [],
  );

  void _loadComment() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessageError(
        translate(context, 'writeSomethingComment'),
        context,
      );
      return;
    }
    if (_rating == -1) {
      ScaffoldMessageError(
        translate(context, 'scoreComment'),
        context,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    comentario.userId = currentUser.id;
    comentario.userName = currentUser.username;
    comentario.userPhotoUrl = currentUser.profilePicture;
    comentario.comment = _commentController.text;
    comentario.date = DateTime.now();
    comentario.score = _rating;
    if (widget.courseId != null) comentario.advertisementId = widget.courseId;
    if (widget.teacherId != null) comentario.teacherId = widget.teacherId;
    if (_images.isNotEmpty) {
      comentario.photos = await CourseService.uploadImagesToCloudinary(_images);
    }

    try {
      if (widget.courseId != null) {
        await CourseService.postComment(comentario);
      } else if (widget.teacherId != null) {
        await TeacherService.postComment(comentario);
      }
      
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessageInfo(translate(context, "commentDone"), context);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessageError(
        translate(context, 'errorComment'),
        context,
      );

      print(e.toString());

      setState(() {
        _isLoading = false;
      });
    }
  }

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translate(context, "createComment"))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                int starNumber = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = starNumber.toDouble();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ), // Similar a botones anteriores
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Color(0xFF3B82F6),
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 25),
            _commentField(),

            SizedBox(height: 25),
            _imageButton(),
            if (_images.isNotEmpty) _showImages(),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(width: double.infinity, child: _sendButton()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  ElevatedButton _sendButton() {
    return ElevatedButton(
      onPressed:
          _isLoading
              ? () {}
              : () {
                _loadComment();
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF3B82F6),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!_isLoading) Icon(Icons.send, color: Colors.white, size: 22),
          if (!_isLoading) SizedBox(width: 10),
          Text(
            _isLoading ? translate(context, "loading") : translate(context, "publishComment"),
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Container _showImages() {
    return Container(
      height: 200,
      margin: EdgeInsets.only(top: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:
            _images.asMap().entries.map((entry) {
              int index = entry.key;
              File img = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Stack(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 300,
                        maxHeight: 200,
                      ),
                      child: Image.file(img, fit: BoxFit.contain),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Row _imageButton() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _showImageSourceDialog,
          icon: Icon(Icons.image, size: 20, color: Colors.white),
          label: Text(translate(context, "images"), style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3B82F6),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        SizedBox(width: 10),
        Text(
          _images.isEmpty
              ? translate(context, "noImagesSelected")
              : '${_images.length} ${translate(context, "images")}',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  TextField _commentField() {
    return TextField(
      controller: _commentController,
      maxLines: null,
      minLines: 2,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: translate(context, "yourComment"),
        labelStyle: TextStyle(color: Colors.white),
        hintText: translate(context, "writeHere"),
        hintStyle: TextStyle(color: Colors.white38),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF3B82F6)),
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 35,
            top: 20,
          ),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  translate(context, "useCamera"),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  translate(context, "useGalery"),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }
}
