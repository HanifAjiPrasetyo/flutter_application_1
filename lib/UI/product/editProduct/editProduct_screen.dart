import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/Models/Product/product.dart';
import 'package:flutter_application_1/Models/errormsg.dart';
import 'package:flutter_application_1/Service/apiService.dart';
import 'package:flutter_application_1/UI/main/main.dart';
import 'package:flutter_application_1/UI/product/product_screen.dart';
import 'package:flutter_application_1/Widget/Components/rounded_button.dart';
import 'package:image_picker/image_picker.dart';

import '../../../constants.dart';

class EditProduct extends StatefulWidget {
  final Product product;
  const EditProduct({ Key? key, required this.product }) : super(key: key);

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formProductKey=GlobalKey<FormState>();
  late TextEditingController   nama, kategori, deskripsi, harga, stok;
  late ErrorMSG response;
  late bool _success=false;
  late String _imagePath="";
  late String _imageURL="";

   void initState() {
    nama = TextEditingController(text: widget.product.nama);
    kategori= TextEditingController(text: widget.product.idKategori.toString());
    deskripsi= TextEditingController(text: widget.product.deskripsi);
    harga= TextEditingController(text: widget.product.harga.toString());
    stok= TextEditingController(text: widget.product.stok.toString());
    _imageURL=widget.product.gambar;
  }

  final ImagePicker _picker = ImagePicker();
  XFile? img;
  gallery() async{
    final XFile? _image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imagePath = _image!.path;
      img=_image;
    });
  }

  // validasi
  String? validator(String value) {
    if (value.isEmpty){
      return "tidak boleh kosong";
    }else {
      return null;
    }
  }

  Future save() async{
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title: Text("Proccessing"),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 4,),
                Text("Loading..."),
              ],
            ),
          ),
        );
      }
    );

    if(_formProductKey.currentState!.validate()){      
      _formProductKey.currentState!.save();
      var params =  {
          'id':widget.product.id,
          'nama':nama.text.toString(),
          'kategori':kategori.text,
          'deskripsi' : deskripsi.text.toString(),
          'harga' : harga.text,
          'stok' : stok.text,
        }; 
        response=await APIService.updateProduct(params,_imagePath);
        _success=response.success;
        final snackBar = SnackBar(content: Text(response.message),);        
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (_success) {
          Navigator.push(context,MaterialPageRoute(
              builder: (context) => MainScreen(),
              ));
        }
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product"),
        backgroundColor: kPrimaryColor,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Form(
          key: _formProductKey,
          child: ListView(
            children: [
              TextField(
                controller: nama,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Product Name"
                ),
              ),
              TextField(
                controller: kategori,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Category"
                ),
              ),
              TextField(
                controller: deskripsi,
                keyboardType: TextInputType.multiline,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Product Description"
                ),
              ),
              TextField(
                controller: harga,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Price"
                ),
              ),
              TextField(
                controller: stok,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Stock"
                ),
              ),
              SizedBox(height: 16,),
              InkWell(
                onTap: gallery,
                child: img==null ? Image.network(
                  APIService.hostStorage+widget.product.gambar,
                  fit: BoxFit.cover,
                ) : Image.file(
                  File(_imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16,),
              RoundedButton(
                text: "Save Product", 
                press: (){
                  save();
                }, 
                color: kPrimaryColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}