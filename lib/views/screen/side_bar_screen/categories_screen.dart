import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digital_mart_web_admin_pannel/views/screen/side_bar_screen/widget/category_widget.dart';
import 'package:file_picker/file_picker.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CategoriesScreen extends StatefulWidget {
  static const String routeName = '\CategoriesScreen';

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  dynamic _image;

  String? fileName;

  late String categoryName;

  _pickImage() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (result != null) {
      setState(() {
        _image = result.files.first.bytes;

        fileName = result.files.first.name;
      });
    }
  }

  _uploadCategoryBannerToStorage(dynamic image) async {
    Reference ref = _storage.ref().child('CategoryImages').child(fileName!);

    UploadTask uploadTask = ref.putData(image);

    TaskSnapshot snapshot = await uploadTask;
    String downloadurl = await snapshot.ref.getDownloadURL();
    return downloadurl;
  }

  uploadCategory() async {
    EasyLoading.show();
    if (_formKey.currentState!.validate()) {
      String imageUrl = await _uploadCategoryBannerToStorage(_image);
      await _firestore
          .collection('Categories')
          .doc(fileName)
          .set({'image': imageUrl, 'categoryName': categoryName});
      EasyLoading.dismiss();
      setState(() {
        _image = null;
        _formKey.currentState!.reset();
      });
    } else {
      print('OH Bad guy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(10),
              child: const Text(
                ' Category',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 36,
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            border: Border.all(color: Colors.grey.shade800),
                            borderRadius: BorderRadius.circular(10)),
                        child: _image != null
                            ? Image.memory(
                                _image,
                                fit: BoxFit.cover,
                              )
                            : Center(child: Text('Category')),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.yellow),
                        onPressed: () {
                          _pickImage();
                        },
                        child: Text('Upload Image'),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: SizedBox(
                    width: 180,
                    child: TextFormField(
                      onChanged: (value) {
                        categoryName = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Category Name must not be Empty';
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          labelText: 'Enter Category Name',
                          hintText: 'Enter Category Name'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.yellow),
                  onPressed: () {
                    uploadCategory();
                  },
                  child: Text('Save'),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.topLeft,
                child: Text(
                  'Categories',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            CategoryWidget(),
          ],
        ),
      ),
    );
  }
}
