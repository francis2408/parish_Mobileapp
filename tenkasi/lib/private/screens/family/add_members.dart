import 'dart:convert';
import 'dart:io';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenkasi/private/screens/home/home_screen.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

import '../../../widget/common/snackbar.dart';

class AddMembersForm extends StatefulWidget {
  const AddMembersForm({Key? key}) : super(key: key);

  @override
  _AddMembersFormState createState() => _AddMembersFormState();
}

class _AddMembersFormState extends State<AddMembersForm> {
  List<GlobalKey<FormState>> _formKeys = [];
  List<Map<String, dynamic>> _controllers = [];
  List<Widget> _fields = [];
  List _data = [];
  List _familyData = [];

  bool _isLoading = true;
  String blood = '';
  String relation = '';
  var bloodId;
  var relationId;
  var familyData;
  List<DropDownValueModel> bloodDropDown = [];
  List<DropDownValueModel> relationDropDown = [];

  final SingleValueDropDownController _blood = SingleValueDropDownController();
  final SingleValueDropDownController _relation = SingleValueDropDownController();

  getBloodData() async {
    var request = http.Request(
        'GET', Uri.parse('$baseUrl/public/masters/blood.group'));
    request.body = json.encode({
      "params": {
        "query": "{id,name}"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      List data = decode['result'];
      setState(() {
        _isLoading = false;
      });
      for (int i = 0; i < data.length; i++) {
        bloodDropDown.add(
            DropDownValueModel(name: data[i]['name'], value: data[i]['id']));
      }
      return bloodDropDown;
    } else {
      var message = json.decode(
          await response.stream.bytesToString())['message'];
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorAlertDialog(
              message: message,
              onOkPressed: () async {
                Navigator.pop(context);
              },
            );
          },
        );
      });
    }
  }

  getRelationData() async {
    var request = http.Request(
        'GET', Uri.parse('$baseUrl/public/masters/member.relationship'));
    request.body = json.encode({
      "params": {
        "query": "{id,name}"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      List data = decode['result'];
      setState(() {
        _isLoading = false;
      });
      for (int i = 0; i < data.length; i++) {
        relationDropDown.add(
            DropDownValueModel(name: data[i]['name'], value: data[i]['id']));
      }
      return relationDropDown;
    } else {
      var message = json.decode(
          await response.stream.bytesToString())['message'];
      setState(() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorAlertDialog(
              message: message,
              onOkPressed: () async {
                Navigator.pop(context);
              },
            );
          },
        );
      });
    }
  }

  // Function to add a new field
  void _addNewField() async {
    if (_fields.isEmpty) {
      await getBloodData();
      await getRelationData();
    }
    setState(() {
      _fields.add(_buildField(_fields.length));
    });
  }

  shared() async{
    var pref = await SharedPreferences.getInstance();
    if (pref.containsKey('isFamilyKey')) {
      var familyKey = pref.getString('isFamilyKey')!;
      familyData = jsonDecode(familyKey);
    }
  }

  createFamilyMembers() async{
    String url = '$baseUrl/public/res.family/create_family_record';
    Map data = {
      "params": {
        "args": _familyData
      }
    };
    var body = jsonEncode(data);
    var response = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: body);
    if(response.statusCode == 200) {
      final datas = json.decode(response.body)['result'];
      if(datas[0]['status'] == 'success') {
        setState(() {
          Navigator.pop(context);
          Navigator.of(context).pushReplacement(CustomRoute(widget: const HomeScreen()));
          AnimatedSnackBar.show(
              context,
              "Family data created successfully",
              Colors.green
          );
        });
      }
    } else {
      final data = json.decode(response.body)['result'];
      setState(() {
        _isLoading = false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorAlertDialog(
              message: data['message'],
              onOkPressed: () async {
                Navigator.pop(context);
              },
            );
          },
        );
      });
    }
  }

  addFamilyMembers(List formData)  {
    _familyData.clear();
    familyData[0]['child_ids'] = formData;
      var existingFamilyMember = _familyData.firstWhere((member) => member['parish_id'] == familyData[0]['parish_id'], orElse: () => null);
      if (_familyData.isNotEmpty && existingFamilyMember == null) {
        setState(() {
          familyData[0]['child_ids'] = formData;
          _familyData.add(familyData[0]);
        });
        createFamilyMembers();
      } else{
        setState(() {
          familyData[0]['child_ids'] = formData;
          _familyData.add(familyData[0]);
        });
        createFamilyMembers();
      }
  }

// Function to submit the form
  void _submitForm() {
    setState(() {
      bool allValid = true;
      int familyHeadCount = 0;

      // Validate all forms
      for (var key in _formKeys) {
        if (!key.currentState!.validate()) {
          allValid = false;
        }
      }

      // Check for family head count only if there are multiple controllers
      if (_controllers.length > 1) {
        for (int i = 0; i < _controllers.length; i++) {
          var controllers = _controllers[i];
          if (controllers["Family Head"] == 'Yes') {
            familyHeadCount++;
          }
        }

        // If there are more than one family head, set allValid to false
        if (familyHeadCount > 1) {
          allValid = false;
          AnimatedSnackBar.show(
            context,
            "Only one Family Head is allowed",
            redColor,
          );
        }
      }

      // Proceed if all forms are valid and only one family head is present
      if (allValid) {
        for (int i = 0; i < _controllers.length; i++) {
          var controllers = _controllers[i];
          Map<String, dynamic> fieldData = {
            'name': controllers["name"]!.text,
            'email': controllers["email"]!.text,
            'mobile': controllers["mobile"]!.text,
            'dob': controllers["dob"]!.text,
            'gender': controllers["gender"]!,
            'is_family_head': controllers["Family Head"] == 'Yes',
            'relationship_id': controllers["relation_id"] ?? "",
            'blood_group_id': controllers["blood_group"] ?? "",
          };

          // Check for duplicate data
          bool isDuplicate = _data.any((data) =>
          data['email'] == fieldData['email'] &&
              data['mobile'] == fieldData['mobile'] &&
              data['dob'] == fieldData['dob'] &&
              data['gender'] == fieldData['gender'] &&
              data['is_family_head'] == fieldData['is_family_head'] &&
              data['relationship_id'] == fieldData['relationship_id'] &&
              data['blood_group_id'] == fieldData['blood_group_id']
          );

          // Add data if it's not a duplicate
          if (!isDuplicate) {
            _data.add(fieldData);
            addFamilyMembers(_data);
          }
        }
        // Process _data or do something with it
      } else {
        AnimatedSnackBar.show(
          context,
          "Please fill the required fields",
          redColor,
        );
      }
    });
  }

  internetCheck() {
    CheckInternetConnection.checkInternet().then((value) {
      if (value) {
        return null;
      } else {
        showDialogBox();
      }
    });
  }

  showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WarningAlertDialog(
          message: 'Please check your internet connection.',
          onOkPressed: () {
            Navigator.pop(context);
            CheckInternetConnection.checkInternet().then((value) {
              if (value) {
                return null;
              } else {
                showDialogBox();
              }
            });
          },
        );
      },
    );
  }

  @override
  void initState() {
    _data.clear();
    internetCheck();
    super.initState();
    shared();
    _addNewField();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery
        .of(context)
        .size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(CustomRoute(widget: const HomeScreen()));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Family Members'),
          backgroundColor: primaryColor,
        ),
        body: _isLoading ? Center(
          child: SizedBox(
            height: size.height * 0.06,
            child: const LoadingIndicator(
              indicatorType: Indicator.ballSpinFadeLoader,
              colors: [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ],
            ),
          ),
        ) : Padding(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._fields,
                SizedBox(height: size.height * 0.1),
              ],
            ),
          ),
        ),
        bottomSheet: Container(
          padding: EdgeInsets.only(
              top: size.height * 0.01, bottom: size.height * 0.01),
          decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                  top: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ElevatedButton(
                  onPressed: _addNewField,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Add Members'),
                  // icon: svg,
                ),
              ),
              Container(
                width: size.width * 0.4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('Submit'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Function to build a single field
  Widget _buildField(int index) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController dobController = TextEditingController();
    String selectedGender = 'Male';
    String selectedFamilyHead = 'No';
    var selectedRelationship;
    var selectedBloodGroup;
    if (index >= _formKeys.length) {
      _formKeys.add(_formKey);
      // Initialize the _controllers list
      _controllers.add({
        "name": nameController,
        "email": emailController,
        "mobile": phoneController,
        "dob": dobController,
        "gender": selectedGender,
        "family_head": selectedFamilyHead,
        "relation_id": selectedRelationship,
        "blood_group": selectedBloodGroup,
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextField("Name", nameController),
                const SizedBox(height: 10),
                _buildDateField("DOB", dobController),
                const SizedBox(height: 10),
                _buildDropdownField("Gender", index, ['Male', 'Female']),
                const SizedBox(height: 10),
                _buildDropdownField("Family Head", index, ['Yes', 'No']),
                const SizedBox(height: 10),
                _buildDropdowns("Relationship","Select Relationship", index, relationDropDown,
                    "relation_id"),
                const SizedBox(height: 10),
                _buildDropdowns("Blood Group","Select Blood Group", index, bloodDropDown, "blood_group"),
                const SizedBox(height: 10),
                _buildTextField("Phone", phoneController),
                const SizedBox(height: 10),
                _buildTextField("Email", emailController),
                Align(
                  alignment: Alignment.centerRight,
                  child: _fields.length > 0
                      ? IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        _fields.removeAt(index);
                        _formKeys.removeAt(index);
                        _controllers.removeAt(index);
                        _data.clear();
                      });
                    },
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // Helper function to build a single text field
  Widget _buildTextField(String hintText, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hintText,
            style: GoogleFonts.breeSerif(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: inputColors,
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: hintText == "Phone"
                  ? TextInputType.phone
                  : hintText == "Email"
                  ? TextInputType.emailAddress
                  : TextInputType.text,
              autocorrect: true,
              autovalidateMode: AutovalidateMode.disabled,
              style: GoogleFonts.breeSerif(
                color: Colors.black,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintStyle: GoogleFonts.breeSerif(
                  fontStyle: FontStyle.italic,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    width: 1.0,
                    color: disableColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: enableColor,
                    width: 1.0,
                  ),
                ),
              ),
              validator: (value) {
                if (hintText == "Name" || hintText == "DOB") {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                } else if (hintText == "Email") {
                  var reg = RegExp(
                      r"^[a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                  if (value != null && value.isNotEmpty && !reg.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                } else if (hintText == "Phone") {
                  var reg = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");
                  if (value != null && value.isNotEmpty && !reg.hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build a date field
  Widget _buildDateField(String hintText, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hintText,
            style: GoogleFonts.breeSerif(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: inputColors,
            ),
            child: TextFormField(
              controller: controller,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: primaryColor,
                          onPrimary: Colors.white,
                          onSurface: Colors.black,
                        ),
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: backgroundColor,
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (pickedDate != null) {
                  setState(() {
                    controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                hintStyle: GoogleFonts.breeSerif(
                  fontStyle: FontStyle.italic,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    width: 1.0,
                    color: disableColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: enableColor,
                    width: 1.0,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String hintText, int index, List<String> items) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hintText,
            style: GoogleFonts.breeSerif(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: inputColors,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              hint: Text(
                hintText,
                style: GoogleFonts.breeSerif(fontStyle: FontStyle.italic),
              ),
              value: _controllers[index][hintText],
              onChanged: (value) {
                setState(() {
                  _controllers[index][hintText] = value;
                });
              },
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.breeSerif()),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdowns(String label,String hintText, int index, List<DropDownValueModel> items, String field) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.breeSerif(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: inputColors,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<DropDownValueModel>(
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
              hint: Text(
                hintText,
                style: GoogleFonts.breeSerif(fontStyle: FontStyle.italic),
              ),
              value: _controllers[index][field] == null
                  ? null
                  : items.firstWhere(
                      (item) => item.value == _controllers[index][field]),
              onChanged: (DropDownValueModel? newValue) {
                setState(() {
                  _controllers[index][field] = newValue!.value;
                });
              },
              items: items.map((DropDownValueModel item) {
                return DropdownMenuItem<DropDownValueModel>(
                  value: item,
                  child: Text(item.name, style: GoogleFonts.breeSerif()),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

}
