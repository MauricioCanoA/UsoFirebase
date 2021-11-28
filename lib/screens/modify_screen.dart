import 'dart:io';

import 'package:firebase/models/product_dao.dart';
import 'package:firebase/providers/firebase_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ModifyScreen extends StatefulWidget {
  ModifyScreen({Key? key}) : super(key: key);

  @override
  _ModifyScreenState createState() => _ModifyScreenState();
}

class _ModifyScreenState extends State<ModifyScreen> {
  File? imageTemp;
  String? url;
  final controllercveprod = TextEditingController();
  final controllerdescprod = TextEditingController();

  Future imageGallery() async {
    try {
      final imageGallery =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (imageGallery == null) return;
      final imageTemp = File(imageGallery.path);
      setState(() => this.imageTemp = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future imageCamera() async {
    try {
      final imageCamera =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (imageCamera == null) return;
      final imageTemp = File(imageCamera.path);
      setState(() => this.imageTemp = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future uploadFile() async {
    if (imageTemp == null) return;
    final imageName = imageTemp!.path;
    final destination = 'files/$imageName';
    final reference = FirebaseStorage.instance.ref(destination);

    UploadTask uploadTask = reference.putFile(imageTemp!);
    uploadTask.whenComplete(() async {
      url = await reference.getDownloadURL();
      ProductDAO product = ProductDAO(
          cveprod: controllercveprod.text,
          descprod: controllerdescprod.text,
          imgprod: url);

      FirebaseProvider firebaseProvider = new FirebaseProvider();
      firebaseProvider.saveProduct(product);
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    CircleAvatar avatar = CircleAvatar(radius: 80);

    TextField tfcveprod = TextField(
      controller: controllercveprod,
      maxLines: 1,
      maxLength: 20,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
          icon: Icon(Icons.card_membership, color: Colors.white),
          hintText: 'Clave Producto',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red, width: 2.0))),
    );

    TextField tfdescprod = TextField(
      controller: controllerdescprod,
      maxLength: 20,
      maxLines: 1,
      keyboardType: TextInputType.name,
      decoration: InputDecoration(
          icon: Icon(Icons.card_membership, color: Colors.white),
          hintText: 'Descripcion Producto',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.red, width: 2.0))),
    );

    ElevatedButton btnGuardarPerf = ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.blueAccent,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        onPressed: () {
          uploadFile();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.save_rounded), Text(' Guardar')],
        ));

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/fondo.jpg'), fit: BoxFit.fill),
          ),
        ),
        Card(
          elevation: 3,
          margin: EdgeInsets.only(left: 50, right: 50, top: 70, bottom: 70),
          color: Colors.transparent,
          child: Padding(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 60, bottom: 30),
              child: ListView(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                          child: ClipOval(
                            child: imageTemp == null
                                ? avatar
                                : Image.file(imageTemp!,
                                    width: 160, height: 160, fit: BoxFit.cover),
                          ),
                          alignment: Alignment.center),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blueAccent,
                              child: IconButton(
                                  onPressed: () {
                                    imageCamera();
                                  },
                                  icon: Icon(Icons.camera_enhance),
                                  color: Colors.white)),
                          SizedBox(width: 20),
                          CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.blueAccent,
                              child: IconButton(
                                  onPressed: () {
                                    imageGallery();
                                  },
                                  icon: Icon(Icons.photo),
                                  color: Colors.white))
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 30, width: 10),
                  SizedBox(child: tfcveprod, height: 70),
                  SizedBox(height: 10, width: 10),
                  SizedBox(child: tfdescprod, height: 70),
                  SizedBox(height: 10, width: 10),
                  SizedBox(child: btnGuardarPerf, width: 40)
                ],
              )),
        )
      ],
    );
  }
}
