import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:secure_alert/crime_report/components/popup_form.dart';
import 'package:secure_alert/crime_report/models/crime_list.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/utils/bottom_navigation.dart';
import 'package:secure_alert/utils/custom_widgets.dart';

import '../../service/api.dart';
import '../../utils/theme.dart';
import '../models/person_model.dart';
import 'package:http/http.dart' as http;

class CrimeReportScreen extends StatefulWidget {
  const CrimeReportScreen({super.key});

  @override
  State<CrimeReportScreen> createState() => _CrimeReportScreenState();
}

const kGoogleApiKey = 'AIzaSyBZFVz_dHpmtiJbjIyipcJgiCQ173xYylE';

class _CrimeReportScreenState extends State<CrimeReportScreen> {
  final _formKey = GlobalKey<FormState>();
  bool checkedValue = false;
  bool checkboxValue = false;

  bool haveFile = false;
  bool havePerson = false;

  String evidance_list = "";
  String add_details = "";

  String? formattedDate;

  String? type;
  final Mode _mode = Mode.overlay;

  String? location;
  double? lng;
  double? lat;
  String? description;

  DateTime? pickedDate;
  TextEditingController dateCtl = TextEditingController();

  TimeOfDay? pickedTime;
  TextEditingController timeCtl = TextEditingController();

  String? reporterType;
  List selectedFiles = [];
  List<Person> personas = [];

  void selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf', 'mp3', 'mp4', 'jpeg'],
        allowMultiple: true);
    if (result == null) return;

    selectedFiles = result.files;

    setState(() {
      haveFile = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Crime Report'),
      body: Global.instance.user!.isLoggedIn
          ? ListView(
              children: [
                SafeArea(
                    child: Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getLocationField(),
                              getDateTimeField(),
                              selectCrimeTypeField(),
                              getCrimeDescField(),
                              ThemeHelper().getCustomButton(
                                  text: "Add Evidence Media / Files",
                                  background: Colors.black,
                                  fontSize: 15,
                                  padding: 45,
                                  icon: const Icon(Icons.camera_alt),
                                  onPressed: () {
                                    selectFiles();
                                  }),
                              getShowSelectedImages(),
                              getRadioButton(),
                              Container(
                                child: ThemeHelper().getCustomButton(
                                    text:
                                        "Additional Perpetrator / Victim / Witness Details",
                                    background: Colors.black,
                                    padding: 10,
                                    fontSize: 12,
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      getPopUp();
                                    }),
                              ),
                              getAddedList(),
                              getTermCheckBox(),
                              getSubmitCancelButton()
                            ],
                          ),
                        )))
              ],
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: const Text(
                      "Please LogIn or Register to Continue!",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  Container(
                    child: ThemeHelper().getCustomButton(
                      text: "Sign In",
                      padding: 100,
                      background: Colors.black,
                      fontSize: 20,
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ),
                  Container(
                    child: ThemeHelper().getCustomButton(
                      text: "Register",
                      padding: 100,
                      background: Colors.red.shade900,
                      fontSize: 20,
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                    ),
                  )
                ],
              ),
            ),
      bottomNavigationBar:
          const CustomBottomNavigationBar(defaultSelectedIndex: 1),
    );
  }

  getPopUp() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopUpForm(onAdd: (value) {
            setState(() {
              personas.add(value);
              print(personas);
              havePerson = true;
            });
          });
        });
  }

  getAddedList() {
    return Visibility(
        visible: havePerson,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 90,
            color: Colors.white,
            child: ListView.builder(
              itemCount: personas.length,
                itemBuilder: (BuildContext context, int index) {
              return Card(
                child: ListTile(
                  title: Text(personas[index].type!),
                  subtitle: Text(personas[index].description!),
                  trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          personas.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.cancel_outlined)),
                ),
              );
            }),
          ),
        ));
  }

  getLocationField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.grey.shade900))),
              backgroundColor: MaterialStateProperty.all(Colors.white),
              padding: MaterialStateProperty.all(const EdgeInsets.all(15))),
          onPressed: _handlePressButton,
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.red.shade900,
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                width: 250,
                height: 18,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Text(
                      location ?? "Enter the Location of the incident",
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    )
                  ],
                ),
              )
            ],
          )),
    );
  }

  Future<void> _handlePressButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        language: 'en',
        mode: _mode,
        strictbounds: false,
        types: [""],
        logo: Container(
          height: 1,
        ),
        decoration: InputDecoration(
            hintText: 'Enter the Location of the Incidents',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [
          Component(Component.country, "usa"),
          Component(Component.country, "in")
        ]);
    displayPrediction(p!);
    setState(() {
      location = p!.terms[0].value + " " + p!.terms[1].value;
    });
  }

  Future<void> displayPrediction(Prediction p) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detailsResponse =
        await places.getDetailsByPlaceId(p.placeId!);
    lat = detailsResponse.result.geometry!.location.lat;
    lng = detailsResponse.result.geometry!.location.lng;
  }

  getDateTimeField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 10),
          width: 165,
          decoration: ThemeHelper().inputBoxDecorationShaddow(),
          child: TextFormField(
            controller: dateCtl,
            readOnly: true,
            decoration: ThemeHelper().textInputDecoReport(
                'Select Date',
                Icon(
                  Icons.calendar_today,
                  color: Colors.red.shade900,
                )),
            onTap: () async {
              pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                      data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Colors.black,
                            onPrimary: Colors.white,
                            onSurface: Colors.grey[900]!,
                          ),
                          textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red))),
                      child: child!);
                },
              );
              formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate!);
              dateCtl.text = formattedDate!;
            },
            validator: (val) {
              if (val!.isEmpty) {
                return "Please select a date";
              }
              return null;
            },
          ),
        ),
        Container(
          width: 155,
          padding: const EdgeInsets.only(bottom: 10),
          decoration: ThemeHelper().inputBoxDecorationShaddow(),
          child: TextFormField(
            controller: timeCtl,
            readOnly: true,
            decoration: ThemeHelper().textInputDecoReport(
                'select Time',
                Icon(
                  Icons.watch_later_outlined,
                  color: Colors.red.shade900,
                )),
            onTap: () async {
              pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                      data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                              primary: Colors.red,
                              onPrimary: Colors.white,
                              onSurface: Colors.grey[900]!),
                          textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red))),
                      child: child!);
                },
              );
              timeCtl.text = formatTimeOfDay(pickedTime!);
            },
            validator: (val) {
              if (val!.isEmpty) {
                return "Please enter a time";
              }
              return null;
            },
          ),
        )
      ],
    );
  }

  selectCrimeTypeField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: 400,
        padding: const EdgeInsets.only(left: 20, right: 20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.grey.shade400)),
        child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedBorder: InputBorder.none),
                isExpanded: true,
                hint: const Text("Select Type of Crime"),
                items: crimes.map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                validator: (value) {
                  if (type == null) {
                    return "Please select the type of crime";
                  }
                  return null;
                },
                onChanged: (value) {
                  type = value.toString();
                })),
      ),
    );
  }

  getCrimeDescField() {
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      decoration: ThemeHelper().inputBoxDecorationShaddow(),
      child: TextFormField(
        minLines: 3,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: ThemeHelper()
            .textInputDecoReport("Enter the description of the incident"),
        onChanged: (value) {
          setState(() {
            description = value;
          });
        },
        validator: (value) {
          if (value!.isEmpty) {
            return "Description of the incident is required";
          }
          return null;
        },
      ),
    );
  }

  getShowSelectedImages() {
    return Visibility(
        visible: haveFile,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 150,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                  itemCount: selectedFiles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) {
                    final extension = selectedFiles[index].extension ?? 'none';
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade500,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          child: Text(
                            '.$extension',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                        Text(selectedFiles[index].name),
                      ],
                    );
                  }),
            ),
          ),
        ));
  }

  getRadioButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Text(
          "Please Select, I am the",
          style: TextStyle(fontSize: 16),
        ),
        RadioListTile(
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            activeColor: Colors.red.shade900,
            title: const Text("Victim"),
            value: "Victim",
            groupValue: reporterType,
            onChanged: (value) {
              setState(() {
                reporterType = value.toString();
              });
            }),
        RadioListTile(
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            activeColor: Colors.red.shade900,
            title: const Text("Witness"),
            value: "Witness",
            groupValue: reporterType,
            onChanged: (value) {
              setState(() {
                reporterType = value.toString();
              });
            }),
        RadioListTile(
            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
            contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
            activeColor: Colors.red.shade900,
            title: const Text("Anonymous"),
            value: "Anonymous",
            groupValue: reporterType,
            onChanged: (value) {
              setState(() {
                reporterType = value.toString();
              });
            })
      ],
    );
  }

  getTermCheckBox() {
    return FormField<bool>(
      builder: (state) {
        return Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Checkbox(
                      activeColor: Colors.red.shade900,
                      value: checkboxValue,
                      onChanged: (value) {
                        setState(() {
                          checkboxValue = value!;
                          state.didChange(value);
                        });
                      }),
                  RichText(
                      text: TextSpan(children: <TextSpan>[
                    const TextSpan(
                        text: "By submitting this form I acknowledge the"
                            "\ninformation entered is true and I have read"
                            "\nand agree to the",
                        style: TextStyle(color: Colors.grey)),
                    TextSpan(
                        text: ' Term and Condition.',
                        style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold))
                  ]))
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  state.errorText ?? '',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              )
            ],
          ),
        );
      },
      validator: (value) {
        if (!checkboxValue) {
          return 'You need to accept terms and condition';
        } else {
          return null;
        }
      },
    );
  }

  getSubmitCancelButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ThemeHelper().getCustomButton(
          text: "Cancel",
          padding: 45,
          background: Colors.black,
          fontSize: 16,
          onPressed: () {
            Navigator.pushNamed(context, '/crimeReport');
          },
        ),
        ThemeHelper().getCustomButton(
          text: "Submit",
          padding: 45,
          background: Colors.red.shade900,
          fontSize: 16,
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              String uID = Global.instance.user!.uId!;

              DatabaseReference reportRef =
                  FirebaseDatabase.instance.ref().child('reports');

              String reportID = reportRef.push().key!;

              //upload new report data to database
              reportRef.child(reportID).set({
                'location': location,
                'longitude': lng!.toStringAsFixed(6),
                'userID': uID,
                'latitude': lat!.toStringAsFixed(6),
                'date': formattedDate,
                'time': formatTimeOfDay(pickedTime!),
                'type': type,
                'descr': description,
                'persona': reporterType
              });

              //add person list
              if (personas.isNotEmpty) {
                add_details =
                    "The following are additional details of people involved:";
                DatabaseReference addRef =
                    reportRef.child(reportID).child('addDetails');
                int index = 1;
                for (var element in personas) {
                  addRef.child('detailNo $index').set(
                      {'persona': element.type, 'desc': element.description});
                  add_details += "\n$index Person Involved: ${element.type}"
                      "\n Person Description: ${element.description}";
                  index++;
                }
              }

              if (selectedFiles.isNotEmpty) {
                evidance_list =
                    "The following are links to evidance media attached:";
                DatabaseReference mediaRef =
                    reportRef.child(reportID).child('media');
                var url;
                int index = 1;
                selectedFiles.forEach((file) async {
                  url = await uploadFile(file: file!);
                  mediaRef.child(index.toString()).set({'file': url});
                  evidance_list += "\n$index File link: $url";
                  index++;
                });
              }

              //send email to official services and auto-reply to user
              sendEmail(reportID).whenComplete(() {
                Fluttertoast.showToast(
                    msg:
                        "Report Submitted and Emailed to Respected Officials Successfully");
                Navigator.pushReplacementNamed(context, '/home');
              });
            }
          },
        )
      ],
    );
  }

  Future sendEmail(String id) async {
    final user = Global.instance.user!;
    const serviceId = 'service_binbp9m';
    const templateId = 'template_nl89id2';
    const userId = 'cvUBBusapxR-eqeJG';

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(url,
        headers: {
          'origin':'http:localhost',
          'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'subject': '$id - $type Case at $formattedDate',
            'user_contact': user.mobileNo,
            'user_name': user.firstName,
            'user_email': user.email,
            'address': '${user.address}, ${user.zipcode}, ${user.city}, '
                '${user.state}, ${user.country}',
            'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
            'crime': type,
            'persona': reporterType,
            'in_date': formattedDate,
            'in_time': formatTimeOfDay(pickedTime!),
            'in_location': location,
            'description': description,
            'evidance_list': evidance_list,
            'add_details': add_details,
          }
        }));
    print(response.body);
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(date);
  }
}
