import 'dart:convert';
import 'dart:io';

import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:secure_alert/account/views/account_screen.dart';
import 'package:secure_alert/service/api.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/utils/custom_widgets.dart';
import 'package:secure_alert/utils/theme.dart';

import '../../authenticate/models/user_model.dart';
import '../../service/firebase.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  String imageURL = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT98A0_6JOy9FNLcNjipGe4xSgzGiCTfgLybw&usqp=CAU';
  User user = Global.instance.user!;

  var uID;
  String mobileNo = "";
  String address = "";
  String zipcode = "";

  File? image;

  String? countryValue;
  String? stateValue;
  String? cityValue;

  bool userImage = false;

  TextEditingController dateCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateCtl.text = user.dob!;
    if (user.avatar! != "") {
      imageURL = user.avatar!;
      userImage = true;
    }
    mobileNo = user.mobileNo!;
    address = user.address!;
    zipcode = user.pinCode!;
    countryValue = user.country!;
    cityValue = user.city!;
    stateValue = user.state!;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Edit Profile"
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(25, 50, 25, 10),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Form(key: _formKey,
                  child: Column(
                    children: [
                      getAvatarPicker(),
                      const SizedBox(height: 30,),
                      getTextField(
                        text: user.firstName!,
                        isEdit: true,
                        decoration: ThemeHelper().textInputDecoration(
                          'Full Name',
                          ' '
                        ),
                        readonly: true,
                      ),
                      getTextField(
                        text: user.iNo!,
                        isEdit: true,
                        decoration: ThemeHelper().textInputDecoration(
                          'Identity No.',
                          ' '
                        )
                      ),
                      Container(
                        decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        child: TextFormField(
                          controller: dateCtl,
                          readOnly: true,
                          decoration: ThemeHelper().textInputDecoration(
                            'Date of Birth', ' '
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0,),

                      getTextField(
                        text: user.email!,
                        isEdit: true,
                        decoration: ThemeHelper().textInputDecoration(
                          'Email address',
                          ' '
                        ),
                        valError: 'Please enter your email!',
                        readonly: true
                      ),

                      getTextField(
                        text: user.mobileNo!,
                        isEdit: true,
                        decoration: ThemeHelper().textInputDecoration(
                          'Mobile Number',
                          'Enter your mobile number'
                        ),
                        validator: (val){
                          if (val!.isEmpty) {
                            return "Please enter the mobile number!";
                          } else if((val.isNotEmpty) && !RegExp(r"^(\d+)*$").hasMatch(val) ){
                            return "Enter a valid mobile number";
                          }
                          return null;
                        },
                        onChanged: (value){
                          mobileNo = value;
                        }
                      ),

                      getTextField(
                        text: user.address!,
                        isEdit: true,
                        decoration: ThemeHelper().textInputDecoration(
                          'Address',
                          'Enter your house/flat no, and street'
                        ),
                        valError: 'Please enter your address',
                        onChanged: (value){
                          address = value;
                        }
                      ),

                      getCSCPicker(),
                      const SizedBox(height: 20.0,),

                      getTextField(
                        text: user.pinCode!,
                        isEdit: true,
                        decoration: ThemeHelper().textInputDecoration(
                          'Pincode',
                          'Enter your pincode'
                        ),
                        valError: 'Please enter your pin code',
                        onChanged: (value){
                          zipcode = value;
                        }
                      ),
                      getSubmitButton(),
                    ],
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void pickImage() async {
    PickedFile? pickedFile = await ImagePicker().getImage(source: ImageSource.gallery,
    imageQuality: 50,
    maxHeight: 500,
    maxWidth: 500);
    if(pickedFile != null){
      image = File(pickedFile.path);
      setState(() {
        print("The file name is :$image");
      });
    }
  }

  getAvatarPicker(){
    return GestureDetector(
      onTap: () {
        setState(() {
          pickImage();
        });
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                width: 5, color: Colors.white
              ),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  offset: Offset(5, 5)
                )
              ],
              image: DecorationImage(image: image != null ? FileImage(image!) : 
              NetworkImage(imageURL) as ImageProvider)
            ),
            child: Icon(
              Icons.person,
              color: Colors.grey.withOpacity(0.02),
              size: 80.0,
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(80, 80, 0, 0),
            child: Icon(
              Icons.add_circle,
              color: Colors.grey.shade700,
              size: 25.0,
            ),
          )
        ],
      ),
    );
  }

  getCSCPicker(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          CSCPicker(
            dropdownDecoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400, width: 1)
            ),
            flagState: CountryFlag.DISABLE,
            currentCountry: user.country,
            currentCity: user.city,
            currentState: user.state,

            onCountryChanged: (value) {
              setState(() {
                countryValue = value;
              });
            },
            onStateChanged: (value) {
              setState(() {
                stateValue = value;
              });
            },
            onCityChanged: (value) {
              setState(() {
                cityValue = value;
              });
            },
          )
        ],
      ),
    );
  }

  getSubmitButton(){
    return Padding(padding: const EdgeInsets.only(bottom: 10.0),
    child: Container(
      decoration: ThemeHelper().buttonBoxDecoration(context),
      child: ElevatedButton(style: ThemeHelper().buttonStyle(),
      onPressed: () async {
          if (_formKey.currentState!.validate()){
             uID = Global.instance.user!.uId;
             print(uID);
             var iURL = image != null ? await uploadImage(file: image!) : "";

              DatabaseReference databaseReference = FirebaseDatabase.instance.ref().child('users');

              await databaseReference.child(uID.toString()).update({
                'fname': user.firstName,
                'iNo': user.iNo,
                'email': user.email,
                'dob': user.dob,
                'phone': mobileNo,
                'avatar': iURL,
                'address': address,
                'country': countryValue,
                'state': stateValue,
                'city': cityValue,
                'pinCode': zipcode
              });

              //get user data
              final snapshot = await databaseReference.child(uID.toString()).get();
              if (snapshot.exists) {
                Map data = await jsonDecode(jsonEncode(snapshot.value));
                //set new data
                Global.instance.user!.setUserInfo(uID.toString(), data);
                Fluttertoast.showToast(msg: "Profile Updated Successfully");
                if (image != null) {
                  await editAvatarPostList();
                }
              } else {
                Fluttertoast.showToast(msg: 'Error Updating user details');
              }
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const AccountScreen()), (route) => false);
          }
      },
      child: Padding(padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
      child: Text(
        "Submit".toUpperCase(),
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
      ),) ),
    ),);
  }
}