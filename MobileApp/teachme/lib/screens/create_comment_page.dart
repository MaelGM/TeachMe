import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateCommentPage extends StatefulWidget {
  final String courseId;

  CreateCommentPage({required this.courseId});

  @override
  _CreateCommentPageState createState() => _CreateCommentPageState();
}

class _CreateCommentPageState extends State<CreateCommentPage> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 3;  // Cambiado a double para permitir decimales
  List<File> _images = [];

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF121212),
        title: Text('Crear Comentario'),
      ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8), // Similar a botones anteriores
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
            TextField(
              controller: _commentController,
              maxLines: null,
              minLines: 2,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Tu comentario',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Escribe aquí...',
                hintStyle: TextStyle(color: Colors.white38),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF3B82F6)),
                ),
              ),
            ),
            
            SizedBox(height: 25),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _showImageSourceDialog,
                  icon: Icon(Icons.image, size: 20, color: Colors.white),
                  label: Text(
                    'Imagenes',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B82F6),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  _images.isEmpty
                      ? 'No se han seleccionado imágenes'
                      : '${_images.length} imagen(es)',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            if (_images.isNotEmpty)
              Container(
                height: 200,
                margin: EdgeInsets.only(top: 10),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _images
                      .asMap()
                      .entries
                      .map((entry) {
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
                                child: Image.file(
                                  img,
                                  fit: BoxFit.contain,
                                ),
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
                                    child: Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                      .toList(),
                ),
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              print('publicar');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3B82F6),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'Publicar comentario',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
                  'Usar cámara',
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
                  'Elegir de galería',
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
