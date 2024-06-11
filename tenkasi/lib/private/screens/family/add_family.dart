import 'dart:convert';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:tenkasi/private/screens/family/add_members.dart';
import 'package:tenkasi/widget/common/common.dart';
import 'package:tenkasi/widget/common/internet_connection_checker.dart';
import 'package:tenkasi/widget/common/snackbar.dart';
import 'package:tenkasi/widget/helper/helper_function.dart';
import 'package:tenkasi/widget/theme_color/theme_color.dart';
import 'package:tenkasi/widget/widget.dart';

class AddFamilyFormScreen extends StatefulWidget {
  const AddFamilyFormScreen({super.key});

  @override
  State<AddFamilyFormScreen> createState() => _AddFamilyFormScreenState();
}

class _AddFamilyFormScreenState extends State<AddFamilyFormScreen> {
  final formKey = GlobalKey<FormState>();

  var nameController = TextEditingController();
  var churchMarriageDateController = TextEditingController();
  var marriageDateController = TextEditingController();
  var mobileNumberController = TextEditingController();
  var emailController = TextEditingController();
  var familyCardController = TextEditingController();
  var familyIncomeController = TextEditingController();
  var familyEmailController = TextEditingController();
  var perAddressController = TextEditingController();
  var perAreaStreetController = TextEditingController();
  var perCityTownController = TextEditingController();
  var perZipController = TextEditingController();
  var resAddressController = TextEditingController();
  var resAreaStreetController = TextEditingController();
  var resCityTownController = TextEditingController();
  var resZipController = TextEditingController();

  String churchDate = '';
  String civilDate = '';
  bool civil = false;
  bool church = false;
  String houseOwner = 'Own';
  String incomeType = 'Monthly';
  var anbiyamID;
  String anbiyam = '';
  String mobile = '';
  String email = '';

  // Address
  String country = '';
  String state = '';
  String district = '';
  String asCountry = '';
  String asState = '';
  String asDistrict = '';
  var asCountryId;
  var asStateId;
  var asDistrictId;

  bool _isLoading = true;
  bool isMarriageDate = false;
  bool isChurchMarriageDate = false;
  bool _sameAs = false;
  bool isAnbiyam = false;
  bool nameValid = false;
  bool isMobile = false;
  bool isEmail = false;
  bool isValid = false;
  bool isValidPin = false;
  bool isFamilyCard = false;
  bool isFamilyIncome = false;
  bool isResAddress = false;
  bool isResArea = false;
  bool isResCity = false;
  bool isResZip = false;
  bool isResCountry = false;
  bool isResState = false;
  bool isResDistrict = false;

  List anbiyamTypeData = [];
  List<DropDownValueModel> anbiyamDropDown = [];
  List<DropDownValueModel> countryDropDown = [];
  List<DropDownValueModel> stateDropDown = [];
  List<DropDownValueModel> districtDropDown = [];
  List<DropDownValueModel> asCountryDropDown = [];
  List<DropDownValueModel> asStateDropDown = [];
  List<DropDownValueModel> asDistrictDropDown = [];

  final SingleValueDropDownController _anbiyamType = SingleValueDropDownController();
  final SingleValueDropDownController _country = SingleValueDropDownController();
  final SingleValueDropDownController _state = SingleValueDropDownController();
  final SingleValueDropDownController _district = SingleValueDropDownController();
  // final SingleValueDropDownController _asCountry = SingleValueDropDownController();
  // final SingleValueDropDownController _asState = SingleValueDropDownController();
  // final SingleValueDropDownController _asDistrict = SingleValueDropDownController();

  final format = DateFormat("dd-MM-yyyy");
  final reverse = DateFormat("yyyy-MM-dd");

  getAnbiyamData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/${int.parse(parishID)}/res.parish.bcc'));
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
      for(int i = 0; i < data.length; i++) {
        anbiyamDropDown.add(DropDownValueModel(name: data[i]['name'], value: data[i]['id']));
      }
      return anbiyamDropDown;
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
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

  getCountryData() async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/masters/res.country'));
    request.body = json.encode({
      "params": {
        "query": "{id,name,code}"
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      List data = decode['result'];
      for(int i = 0; i < data.length; i++) {
        countryDropDown.add(DropDownValueModel(name: data[i]['name'], value: data[i]['id']));
        asCountryDropDown.add(DropDownValueModel(name: data[i]['name'], value: data[i]['id']));
      }
      return {
        countryDropDown,
        asCountryDropDown
      };
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
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

  Future<void> getCountryBasedState(int country) async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/masters/res.country.state'));
    request.body = json.encode({
      "params": {
        "filter": "[['country_id', '=', $country]]",
        "query": "{id,name,code,country_id}"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      List data = decode['result'];
      List<DropDownValueModel> newStateDropDown = [];
      for (int i = 0; i < data.length; i++) {
        newStateDropDown.add(DropDownValueModel(name: data[i]['name'], value: data[i]['id']));
      }
      setState(() {
        stateDropDown = newStateDropDown;
        _state.clearDropDown();
        districtDropDown = []; // Clear district dropdown
        _district.clearDropDown(); // Clear previous district selection
      });
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
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

  Future<void> getStateBasedDistrict(int state) async {
    var request = http.Request('GET', Uri.parse('$baseUrl/public/masters/res.state.district'));
    request.body = json.encode({
      "params": {
        "filter": "[['state_id', '=', $state]]",
        "query": "{id,name,code,state_id}"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var decode = json.decode(await response.stream.bytesToString())['result'];
      List data = decode['result'];
      List<DropDownValueModel> newDistrictDropDown = [];
      for (int i = 0; i < data.length; i++) {
        newDistrictDropDown.add(DropDownValueModel(name: data[i]['name'], value: data[i]['id']));
      }
      setState(() {
        districtDropDown = newDistrictDropDown;
        _district.clearDropDown(); // Clear previous district selection
      });
    } else {
      var message = json.decode(await response.stream.bytesToString())['message'];
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

  createFamily() async {
    String name = nameController.text.toString();
    String familyCard = familyCardController.text.toString();
    String familyIncome = familyIncomeController.text.toString();
    String street = resAddressController.text.toString();
    String street2 = resAreaStreetController.text.toString();
    String city = resCityTownController.text.toString();
    String zipCode = resZipController.text.toString();
    String perStreet = perAddressController.text.toString();
    String perStreet2 = perAreaStreetController.text.toString();
    String perCity = perCityTownController.text.toString();
    String perZip = perZipController.text.toString();

    List famData = [
      {"parish_id": int.parse(parishID), "name": "$name", "parish_bcc_id": anbiyamID, "reference": "$familyCard", "is_church_marriage": church, "church_marriage_date": churchDate != '' ? "$churchDate" : false, "is_civil_marriage": isMarriageDate, "civil_marriage_date": civilDate != '' ? "$civilDate" : false, "street": "$street", "street2": "$street2", "city": "$city", "district_id": districtId ?? false, "state_id": stateId ?? false, "country_id": countryId ?? false, "zip": "$zipCode", "income": "$familyIncome", "income_type": "$incomeType", "house_ownership": "$houseOwner", "mobile": "$mobile", "email": "$email", "same_as_above_address": _sameAs, "permanent_street": "$perStreet", "permanent_street2": "$perStreet2", "permanent_city": "$perCity", "permanent_district_id": asDistrictId ?? "", "permanent_state_id": asStateId ?? "", "permanent_country_id": asCountryId ?? "", "permanent_zip": "$perZip"}
    ];
    HelperFunctions.setFamilyDataSF(famData);
    Navigator.of(context).pushReplacement(CustomRoute(widget: const AddMembersForm()));

  }

  void validate() {
    if (nameController.text.toString().isNotEmpty) {
      setState(() {
        nameValid = false;
      });
    } else {
      setState(() {
        nameValid = true;
      });
    }
    if (mobile.isNotEmpty) {
      if (isValid == true) {
        setState(() {
          isMobile = false;
          isValid = true;
        });
      } else {
        setState(() {
          isMobile = false;
          isValid = false;
        });
      }
    } else {
      setState(() {
        isMobile = true;
        isValid = false;
      });
    }
    if (email.isEmpty) {
      setState(() {
        isEmail = false;
      });
    }
    if (familyCardController.text.toString().isNotEmpty) {
      setState(() {
        isFamilyCard = false;
      });
    } else {
      setState(() {
        isFamilyCard = true;
      });
    }
    // if (familyIncomeController.text.isNotEmpty) {
    //   setState(() {
    //     isFamilyIncome = false;
    //   });
    // } else {
    //   setState(() {
    //     isFamilyIncome = true;
    //   });
    // }
    if (churchMarriageDateController.text.toString().isNotEmpty) {
      setState(() {
        isChurchMarriageDate = false;
      });
    } else {
      setState(() {
        church ? isChurchMarriageDate = true : isChurchMarriageDate = false;
      });
    }
    if (marriageDateController.text.toString().isNotEmpty) {
      setState(() {
        isMarriageDate = false;
      });
    } else {
      setState(() {
        civil ? isMarriageDate = true : isMarriageDate = false;
      });
    }
    if (anbiyam.isNotEmpty && anbiyam != '') {
      setState(() {
        isAnbiyam = false;
      });
    } else {
      setState(() {
        isAnbiyam = true;
        anbiyam = '';
        anbiyamID = '';
      });
    }
    if(resAddressController.text.toString().isNotEmpty){
      setState(() {
        isResAddress = false;
      });
    }
    else{
      setState(() {
        isResAddress = true;
      });
    }
    if(resAreaStreetController.text.toString().isNotEmpty){
      setState(() {
        isResArea = false;
      });
    }
    else{
      setState(() {
        isResArea = true;
      });
    }
    if(resCityTownController.text.toString().isNotEmpty){
      setState(() {
        isResCity = false;
      });
    }
    else{
      setState(() {
        isResCity = true;
      });
    }
    if(resZipController.text.toString().isNotEmpty){
      setState(() {
        isResZip = false;
      });
    }
    else{
      setState(() {
        isResZip = true;
      });
    }
    if (country.isNotEmpty && country != '') {
      setState(() {
        isResCountry = false;
      });
    } else {
      setState(() {
        isResCountry = true;
        country = '';
        countryId = '';
      });
    }
    if (state.isNotEmpty && state != '') {
      setState(() {
        isResState = false;
      });
    } else {
      setState(() {
        isResState = true;
        state = '';
        stateId = '';
      });
    }
    if (district.isNotEmpty && district != '') {
      setState(() {
        isResDistrict = false;
      });
    } else {
      setState(() {
        isResDistrict = true;
        district = '';
        districtId = '';
      });
    }
    AnimatedSnackBar.show(
        context,
        "Please fill the required fields",
        redColor
    );
  }

  internetCheck() {
    CheckInternetConnection.checkInternet().then((value) {
      if(value) {
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
    // Check the internet connection
    internetCheck();
    // TODO: implement initState
    super.initState();
    getCountryData();
    getAnbiyamData();
  }

  @override
  void dispose() {
    nameController.dispose();
    churchMarriageDateController.dispose();
    marriageDateController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    familyCardController.dispose();
    familyIncomeController.dispose();
    familyEmailController.dispose();
    perAddressController.dispose();
    perAreaStreetController.dispose();
    perCityTownController.dispose();
    perZipController.dispose();
    resAddressController.dispose();
    resAreaStreetController.dispose();
    resCityTownController.dispose();
    resZipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, 'refresh');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            "Add Family",
            style: TextStyle(
              fontSize: size.height * 0.02,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _isLoading ? Center(
            child: SizedBox(
              height: size.height * 0.06,
              child: const LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [Colors.red,Colors.orange,Colors.yellow,Colors.green,Colors.blue,Colors.indigo,Colors.purple,],
              ),
            ),
          ) : Padding(
            padding: EdgeInsets.only(
                left: size.width * 0.01,
                right: size.width * 0.01
            ),
            child: Form(
              key: formKey,
              child: ListView(
                children: [
                  SizedBox(height: size.height * 0.02,),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Family Name',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: inputColors
                            ),
                            child: TextFormField(
                                controller: nameController,
                                keyboardType: TextInputType.text,
                                autocorrect: true,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(30),
                                ],
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: GoogleFonts.breeSerif(
                                    color: Colors.black,
                                    letterSpacing: 0.2
                                ),
                                decoration: InputDecoration(
                                  hintText: "Enter the name",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)
                                  ),
                                  hintStyle: GoogleFonts.breeSerif(
                                    color: labelColor2,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: disableColor,
                                      width: 1.0,
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
                                    nameValid = true;
                                } else {
                                    nameValid = false;
                                }
                              },
                              onChanged: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() {
                                    nameValid = true;
                                  });
                                } else {
                                  setState(() {
                                    nameValid = false;
                                  });
                                }
                              },
                            ),
                          ),
                          nameValid ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Name is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Basic Christian Community',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: inputColors,
                            ),
                            child: DropDownTextField(
                              controller: _anbiyamType,
                              listSpace: 20,
                              listPadding: ListPadding(top: 20),
                              searchShowCursor: true,
                              searchAutofocus: true,
                              enableSearch: true,
                              listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                              textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                              dropDownItemCount: 6,
                              dropDownList: anbiyamDropDown,
                              textFieldDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: "Select Basic Christian Community",
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: enableColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null && val != "") {
                                  anbiyam = val.name;
                                  anbiyamID = val.value;
                                  if(anbiyam.isNotEmpty && anbiyam != '') {
                                    setState(() {
                                      isAnbiyam = false;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    isAnbiyam = true;
                                    anbiyam = '';
                                    anbiyamID = '';
                                  });
                                }
                              },
                            ),
                          ),
                          isAnbiyam ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: const Text(
                                "Basic christian community is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Family Card Number',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: familyCardController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter the family card number",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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
                                  isFamilyCard = true;
                                } else {
                                  isFamilyCard = false;
                                  return null;
                                }
                              },
                              onChanged: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() {
                                    isFamilyCard = true;
                                  });
                                } else {
                                  setState(() {
                                    isFamilyCard = false;
                                  });
                                }
                              },
                            ),
                          ),
                          isFamilyCard ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Family card number is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Civil Marriage?',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: RadioListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      dense: true,
                                      tileColor: inputColor,
                                      activeColor: enableColor,
                                      value: true,
                                      groupValue: civil,
                                      title: Text('Yes', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                      onChanged: (value) {
                                        setState(() {
                                          civil = true;
                                        });
                                      }
                                  )
                              ),
                              SizedBox(width: size.width * 0.05,),
                              Expanded(
                                  child: RadioListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      dense: true,
                                      tileColor: inputColor,
                                      activeColor: enableColor,
                                      value: false,
                                      groupValue: civil,
                                      title: Text('No', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                      onChanged: (value) {
                                        setState(() {
                                          civil = false;
                                          isMarriageDate = false;
                                        });
                                      }
                                  )
                              ),
                            ],
                          ),
                          if (civil) Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Civil Marriage Date',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                              ],
                            ),
                          ),
                          if (civil) Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: marriageDateController,
                              keyboardType: TextInputType.none,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                suffixIcon: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.indigo,
                                ),
                                hintText: "Choose the date",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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
                              // check the validation
                              validator: (val) {
                                if (civil == true && val!.isEmpty && val == '') {
                                  isMarriageDate = true;
                                } else {
                                  isMarriageDate = false;
                                }
                              },
                              onChanged: (val) {
                                if(val.isEmpty) {
                                  setState(() {
                                    marriageDateController.text = '';
                                    civilDate = '';
                                    isMarriageDate = true;
                                  });
                                } else {
                                  setState(() {
                                    isMarriageDate = false;
                                  });
                                }
                              },
                              onTap: () async {
                                DateTime? datePick = await showDatePicker(
                                  context: context,
                                  initialDate: marriageDateController.text.isNotEmpty ? format.parse(marriageDateController.text) :DateTime.now(),
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
                                if (datePick != null) {
                                  setState(() {
                                    var dateNow = DateTime.now();
                                    var diff = dateNow.difference(datePick);
                                    var year = ((diff.inDays)/365).round();
                                    marriageDateController.text = format.format(datePick);
                                    civilDate = reverse.format(datePick);
                                    isMarriageDate = false;
                                  });
                                }
                              },
                            ),
                          ),
                          isMarriageDate ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Marriage date is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Church Marriage?',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: RadioListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      dense: true,
                                      tileColor: inputColor,
                                      activeColor: enableColor,
                                      value: true,
                                      groupValue: church,
                                      title: Text('Yes', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                      onChanged: (value) {
                                        setState(() {
                                          church = true;
                                        });
                                      }
                                  )
                              ),
                              SizedBox(width: size.width * 0.05,),
                              Expanded(
                                  child: RadioListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      dense: true,
                                      tileColor: inputColor,
                                      activeColor: enableColor,
                                      value: false,
                                      groupValue: church,
                                      title: Text('No', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                      onChanged: (value) {
                                        setState(() {
                                          church = false;
                                          isChurchMarriageDate = false;
                                        });
                                      }
                                  )
                              ),
                            ],
                          ),
                          if (church) Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Church Marriage Date',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text('*', style: GoogleFonts.poppins(fontSize: size.height * 0.02, fontWeight: FontWeight.bold, color: Colors.red,),)
                              ],
                            ),
                          ),
                          if (church) Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: churchMarriageDateController,
                              keyboardType: TextInputType.none,
                              autocorrect: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                suffixIcon: const Icon(
                                  Icons.calendar_month,
                                  color: Colors.indigo,
                                ),
                                hintText: "Choose the date",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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
                              // check the validation
                              validator: (val) {
                                if (church == true && val!.isEmpty && val == '') {
                                  isChurchMarriageDate = true;
                                } else {
                                  isChurchMarriageDate = false;
                                }
                              },
                              onChanged: (val) {
                                if(val.isEmpty) {
                                  setState(() {
                                    churchMarriageDateController.text = '';
                                    churchDate = '';
                                    isChurchMarriageDate = true;
                                  });
                                } else {
                                  setState(() {
                                    isChurchMarriageDate = false;
                                  });
                                }
                              },
                              onTap: () async {
                                DateTime? datePick = await showDatePicker(
                                  context: context,
                                  initialDate: churchMarriageDateController.text.isNotEmpty ? format.parse(churchMarriageDateController.text) : DateTime.now(),
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
                                if (datePick != null) {
                                  setState(() {
                                    var dateNow = DateTime.now();
                                    var diff = dateNow.difference(datePick);
                                    var year = ((diff.inDays)/365).round();
                                    churchMarriageDateController.text = format.format(datePick);
                                    churchDate = reverse.format(datePick);
                                    isChurchMarriageDate = false;
                                  });
                                }
                              },
                            ),
                          ),
                          isChurchMarriageDate ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Church marriage date is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Income Type',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: RadioListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      dense: true,
                                      tileColor: inputColor,
                                      activeColor: enableColor,
                                      value: 'Monthly',
                                      groupValue: incomeType,
                                      title: Text('Monthly', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                      onChanged: (String? value) {
                                        setState(() {
                                          if (value!.isNotEmpty && value != '') {
                                            incomeType = value;
                                          }
                                        });
                                      }
                                  )
                              ),
                              SizedBox(width: size.width * 0.05,),
                              Expanded(
                                  child: RadioListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      dense: true,
                                      tileColor: inputColor,
                                      activeColor: enableColor,
                                      value: 'Annually',
                                      groupValue: incomeType,
                                      title: Text('Annually', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                      onChanged: (String? value) {
                                        setState(() {
                                          if (value!.isNotEmpty && value != '') {
                                            incomeType = value;
                                          }
                                        });
                                      }
                                  )
                              ),
                            ],
                          ),
                          // Container(
                          //   padding: const EdgeInsets.only(top: 5, bottom: 10),
                          //   alignment: Alignment.topLeft,
                          //   child: Row(
                          //     children: [
                          //       Text(
                          //         'Family Income',
                          //         style: GoogleFonts.poppins(
                          //           fontSize: size.height * 0.018,
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.black54,
                          //         ),
                          //       ),
                          //       SizedBox(width: size.width * 0.02,),
                          //       Text(
                          //         '*',
                          //         style: GoogleFonts.poppins(
                          //           fontSize: size.height * 0.02,
                          //           fontWeight: FontWeight.bold,
                          //           color: Colors.red,
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          // ),
                          // Container(
                          //   decoration: BoxDecoration(
                          //       borderRadius: BorderRadius.circular(10),
                          //       color: inputColors
                          //   ),
                          //   child: TextFormField(
                          //     controller: familyIncomeController,
                          //     keyboardType: TextInputType.number,
                          //     autocorrect: true,
                          //     autovalidateMode: AutovalidateMode.onUserInteraction,
                          //     inputFormatters: [
                          //       LengthLimitingTextInputFormatter(9),
                          //     ],
                          //     style: GoogleFonts.breeSerif(
                          //         color: Colors.black,
                          //         letterSpacing: 0.2
                          //     ),
                          //     decoration: InputDecoration(
                          //       hintText: "Enter family income",
                          //       border: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(10)
                          //       ),
                          //       hintStyle: GoogleFonts.breeSerif(
                          //         color: labelColor2,
                          //         fontStyle: FontStyle.italic,
                          //       ),
                          //       enabledBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //         borderSide: const BorderSide(
                          //           color: disableColor,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(10),
                          //         borderSide: const BorderSide(
                          //           color: enableColor,
                          //           width: 1.0,
                          //         ),
                          //       ),
                          //     ),
                          //     validator: (val) {
                          //       if(val!.isNotEmpty) {
                          //         isFamilyIncome = false;
                          //       } else {
                          //         isFamilyIncome = false;
                          //       }
                          //     },
                          //     onChanged: (value) {
                          //       if(value.isNotEmpty) {
                          //         setState(() {
                          //           isFamilyIncome = false;
                          //         });
                          //       } else {
                          //         setState(() {
                          //           isFamilyIncome = false;
                          //         });
                          //       }
                          //     },
                          //   ),
                          // ),
                          // isFamilyIncome ? Container(
                          //     alignment: Alignment.topLeft,
                          //     padding: const EdgeInsets.only(left: 10, top: 8),
                          //     child: const Text(
                          //       "Family income is required",
                          //       style: TextStyle(
                          //           color: Colors.red,
                          //           fontWeight: FontWeight.w500
                          //       ),
                          //     )
                          // ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'House Ownership',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: RadioListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      dense: true,
                                      tileColor: inputColor,
                                      activeColor: enableColor,
                                      value: 'Own',
                                      groupValue: houseOwner,
                                      title: Text('Own', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                      onChanged: (String? value) {
                                        setState(() {
                                          if (value!.isNotEmpty && value != '') {
                                            houseOwner = value;
                                          }
                                        });
                                      }
                                  )
                              ),
                              SizedBox(width: size.width * 0.05,),
                              Expanded(
                                  child: RadioListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      dense: true,
                                      tileColor: inputColor,
                                      activeColor: enableColor,
                                      value: 'Rent',
                                      groupValue: houseOwner,
                                      title: Text('Rent', style: GoogleFonts.breeSerif(color: Colors.black87, fontSize: size.height * 0.018,),),
                                      onChanged: (String? value) {
                                        setState(() {
                                          if (value!.isNotEmpty && value != '') {
                                            houseOwner = value;
                                          }
                                        });
                                      }
                                  )
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Mobile Number',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: mobileNumberController,
                              keyboardType: TextInputType.number,
                              autocorrect: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(15),
                              ],
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter mobile number",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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
                              validator: (val) {
                                if(val!.isNotEmpty) {
                                  var reg = RegExp(r"^(?:[+0]9)?[0-9]{10,15}$");
                                  if(reg.hasMatch(val)) {
                                    isMobile = false;
                                    isValid = false;
                                    mobile = mobileNumberController.text.toString();
                                  } else {
                                    isMobile = false;
                                    isValid = true;
                                    mobile = '';
                                  }
                                } else {
                                  isMobile = true;
                                  isValid = false;
                                  mobile = '';
                                }
                              },
                            ),
                          ),
                          isMobile ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Mobile number is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : isValid ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Please enter the valid mobile number",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Email',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter email",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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
                              // check tha validationValidator
                              validator: (val) {
                                if(val!.isNotEmpty && val != '') {
                                  var reg = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                  if(reg.hasMatch(val)) {
                                    email = emailController.text.toString();
                                    isEmail = false;
                                  } else {
                                    isEmail = true;
                                  }
                                } else {
                                  isEmail = false;
                                  email = '';
                                }
                              },
                            ),
                          ),
                          isEmail ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Please enter the valid email address",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text("Residential Address",
                                    style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.022,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54
                                    )
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Address Line 1',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                            SizedBox(width: size.width * 0.02,),
                            Text(
                              '*',
                              style: GoogleFonts.poppins(
                                fontSize: size.height * 0.02,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: resAddressController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter address",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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
                                  isResAddress = true;
                                } else {
                                  isResAddress = false;
                                }
                              },
                              onChanged: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() {
                                    isResAddress = true;
                                  });
                                } else {
                                  setState(() {
                                    isResAddress = false;
                                  });
                                }
                              },
                            ),
                          ),
                          isResAddress ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Address Line 1 is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Area/Street',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(width: size.width * 0.02,),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: resAreaStreetController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter area/street",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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

                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'City/Town/Taluk',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: resCityTownController,
                              keyboardType: TextInputType.text,
                              autocorrect: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter city/town/taluk",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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
                                  isResCity = true;
                                } else {
                                  isResCity = false;
                                }
                              },
                              onChanged: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() {
                                    isResCity = true;
                                  });
                                } else {
                                  setState(() {
                                    isResCity = false;
                                  });
                                }
                              },
                            ),
                          ),
                          isResCity ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "City/Town/Taluk is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Country',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: inputColors,
                            ),
                            child: DropDownTextField(
                              controller: _country,
                              listSpace: 20,
                              listPadding: ListPadding(top: 20),
                              searchShowCursor: true,
                              searchAutofocus: true,
                              enableSearch: true,
                              listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                              textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                              dropDownItemCount: 6,
                              dropDownList: countryDropDown,
                              textFieldDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: "Select Country",
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: enableColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null && val != "") {
                                  country = val.name;
                                  countryId = val.value;
                                  if(country.isNotEmpty && country != '') {
                                    setState(() {
                                      isResCountry = false;
                                      getCountryBasedState(countryId);
                                    });
                                  }
                                } else {
                                  setState(() {
                                    country = "";
                                    countryId = "";
                                    isResCountry = true;
                                  });
                                }
                              },
                            ),
                          ),
                          isResCountry ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: const Text(
                                "Country is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'State',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: inputColors,
                            ),
                            child: DropDownTextField(
                              controller: _state,
                              listSpace: 20,
                              listPadding: ListPadding(top: 20),
                              searchShowCursor: true,
                              searchAutofocus: true,
                              enableSearch: true,
                              listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                              textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                              dropDownItemCount: 6,
                              dropDownList: stateDropDown,
                              textFieldDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: "Select state",
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: enableColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null && val != "") {
                                  state = val.name;
                                  stateId = val.value;
                                  if(state.isNotEmpty && state != '') {
                                    setState(() {
                                      isResState = false;
                                      getStateBasedDistrict(stateId);
                                    });
                                  }
                                } else {
                                  setState(() {
                                    state = "";
                                    stateId = "";
                                    isResState = true;
                                  });
                                }
                              },
                            ),
                          ),
                          isResState ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: const Text(
                                "State is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'District',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: inputColors,
                            ),
                            child: DropDownTextField(
                              controller: _district,
                              listSpace: 20,
                              listPadding: ListPadding(top: 20),
                              searchShowCursor: true,
                              searchAutofocus: true,
                              enableSearch: true,
                              listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                              textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                              dropDownItemCount: 6,
                              dropDownList: districtDropDown,
                              textFieldDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: "Select district",
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: enableColor,
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null && val != "") {
                                  isResDistrict = false;
                                  district = val.name;
                                  districtId = val.value;
                                } else {
                                  setState(() {
                                    isResDistrict = true;
                                    district = "";
                                    districtId = "";
                                  });
                                }
                              },
                            ),
                          ),
                          isResDistrict ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 5),
                              child: const Text(
                                "District is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                          Container(
                            padding: const EdgeInsets.only(top: 5, bottom: 10),
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                Text(
                                  'Pin Code',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.018,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  '*',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: inputColors
                            ),
                            child: TextFormField(
                              controller: resZipController,
                              keyboardType: TextInputType.number,
                              autocorrect: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6),
                              ],
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              style: GoogleFonts.breeSerif(
                                  color: Colors.black,
                                  letterSpacing: 0.2
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter pin code",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                hintStyle: GoogleFonts.breeSerif(
                                  color: labelColor2,
                                  fontStyle: FontStyle.italic,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: disableColor,
                                    width: 1.0,
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
                                  isResZip = true;
                                  isValidPin = false; // Invalid when empty
                                } else {
                                  var reg = RegExp(r"^[1-9][0-9]{2}\s?[0-9]{3}$");
                                  if (reg.hasMatch(value)) {
                                    isValidPin = true; // Valid pin
                                  } else {
                                    isValidPin = false; // Invalid pin
                                    return "Enter valid pin ";
                                  }
                                }
                                return null; // Return null to show no error message in the field itself
                              },
                              onChanged: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() {
                                    isResZip = true;
                                    isValidPin = false; // Invalid when empty
                                  });
                                } else {
                                  var reg = RegExp(r"^[1-9][0-9]{2}\s?[0-9]{3}$");
                                  setState(() {
                                    isResZip = false;
                                    isValidPin = reg.hasMatch(value); // Valid or invalid based on regex match
                                  });
                                }
                              },
                            ),
                          ),
                          isResZip ? Container(
                              alignment: Alignment.topLeft,
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: const Text(
                                "Pin is required",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500
                                ),
                              )
                          ) : Container(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Row(
                  //       children: [
                  //         Checkbox(
                  //           activeColor: menuPrimaryColor,
                  //           checkColor: Colors.white,
                  //           value: _sameAs,
                  //           onChanged: (value) {
                  //             setState(() {
                  //               _sameAs = value!;
                  //               if (_sameAs) {
                  //                 perAddressController.text = resAddressController.text;
                  //                 perAreaStreetController.text = resAreaStreetController.text;
                  //                 perCityTownController.text = resCityTownController.text;
                  //                 perZipController.text = resZipController.text;
                  //                 asCountry = country;
                  //                 asCountryId = countryId;
                  //                 asState = state;
                  //                 asStateId = stateId;
                  //                 asDistrict = district;
                  //                 asDistrictId = districtId;
                  //               } else {
                  //                 perAddressController.text = '';
                  //                 perAreaStreetController.text = '';
                  //                 perCityTownController.text = '';
                  //                 perZipController.text = '';
                  //                 asCountry = country;
                  //                 asCountryId = '';
                  //                 asState = state;
                  //                 asStateId = '';
                  //                 asDistrict = district;
                  //                 asDistrictId = '';
                  //               }
                  //             });
                  //           },
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(5),
                  //           ),
                  //         ),
                  //         Text(
                  //             "Same as above",
                  //             style: GoogleFonts.signika(
                  //               fontSize: size.height * 0.018,
                  //               color: textColor,
                  //               fontWeight: FontWeight.w700,
                  //             )
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  // Card(
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(10)
                  //   ),
                  //   child: Container(
                  //   padding: const EdgeInsets.all(10),
                  //   child: Column(
                  //     children: [
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 5, bottom: 10),
                  //         alignment: Alignment.topLeft,
                  //         child: Row(
                  //           children: [
                  //             Text("Permanent Address",
                  //                 style: GoogleFonts.poppins(
                  //                     fontSize: size.height * 0.018,
                  //                     fontWeight: FontWeight.bold,
                  //                     color: Colors.black54,
                  //                 )
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 5, bottom: 10),
                  //         alignment: Alignment.topLeft,
                  //         child: Row(
                  //           children: [
                  //             Text(
                  //               'Address Line 1',
                  //               style: GoogleFonts.poppins(
                  //                 fontSize: size.height * 0.018,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.black54,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: inputColors
                  //         ),
                  //         child: TextFormField(
                  //           controller: perAddressController,
                  //           keyboardType: TextInputType.text,
                  //           autocorrect: true,
                  //           readOnly: _sameAs,
                  //           inputFormatters: [
                  //             LengthLimitingTextInputFormatter(50),
                  //           ],
                  //           autovalidateMode: AutovalidateMode.onUserInteraction,
                  //           style: GoogleFonts.breeSerif(
                  //               color: Colors.black,
                  //               letterSpacing: 0.2
                  //           ),
                  //           decoration: InputDecoration(
                  //             hintText: "Enter address",
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(10)
                  //             ),
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: labelColor2,
                  //               fontStyle: FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 5, bottom: 10),
                  //         alignment: Alignment.topLeft,
                  //         child: Row(
                  //           children: [
                  //             Text(
                  //               'Area/Street',
                  //               style: GoogleFonts.poppins(
                  //                 fontSize: size.height * 0.018,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.black54,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: inputColors
                  //         ),
                  //         child: TextFormField(
                  //           controller: perAreaStreetController,
                  //           keyboardType: TextInputType.text,
                  //           autocorrect: true,
                  //           readOnly: _sameAs,
                  //           inputFormatters: [
                  //             LengthLimitingTextInputFormatter(50),
                  //           ],
                  //           autovalidateMode: AutovalidateMode.onUserInteraction,
                  //           style: GoogleFonts.breeSerif(
                  //               color: Colors.black,
                  //               letterSpacing: 0.2
                  //           ),
                  //           decoration: InputDecoration(
                  //             hintText: "Enter area/street",
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(10)
                  //             ),
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: labelColor2,
                  //               fontStyle: FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 5, bottom: 10),
                  //         alignment: Alignment.topLeft,
                  //         child: Row(
                  //           children: [
                  //             Text(
                  //               'City/Town/Taluk',
                  //               style: GoogleFonts.poppins(
                  //                 fontSize: size.height * 0.018,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.black54,
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: inputColors
                  //         ),
                  //         child: TextFormField(
                  //           controller: perCityTownController,
                  //           keyboardType: TextInputType.text,
                  //           autocorrect: true,
                  //           readOnly: _sameAs,
                  //           inputFormatters: [
                  //             LengthLimitingTextInputFormatter(50),
                  //           ],
                  //           autovalidateMode: AutovalidateMode.onUserInteraction,
                  //           style: GoogleFonts.breeSerif(
                  //               color: Colors.black,
                  //               letterSpacing: 0.2
                  //           ),
                  //           decoration: InputDecoration(
                  //             hintText: "Enter city/town/taluk",
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(10)
                  //             ),
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: labelColor2,
                  //               fontStyle: FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 5, bottom: 10),
                  //         alignment: Alignment.topLeft,
                  //         child: Row(
                  //           children: [
                  //             Text(
                  //               'Country',
                  //               style: GoogleFonts.poppins(
                  //                 fontSize: size.height * 0.018,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.black54,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       _sameAs ? Container(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: inputColors
                  //         ),
                  //         child: TextFormField(
                  //           initialValue: asCountry,
                  //           readOnly: _sameAs,
                  //           autovalidateMode: AutovalidateMode.onUserInteraction,
                  //           style: GoogleFonts.breeSerif(
                  //               color: Colors.black,
                  //               letterSpacing: 0.2
                  //           ),
                  //           decoration: InputDecoration(
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(10)
                  //             ),
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: labelColor2,
                  //               fontStyle: FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ) : Container(
                  //         alignment: Alignment.center,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(10),
                  //           color: inputColors,
                  //         ),
                  //         child: DropDownTextField(
                  //           controller: _asCountry,
                  //           listSpace: 20,
                  //           listPadding: ListPadding(top: 20),
                  //           searchShowCursor: true,
                  //           searchAutofocus: true,
                  //           enableSearch: true,
                  //           listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                  //           textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                  //           dropDownItemCount: 6,
                  //           dropDownList: asCountryDropDown,
                  //           textFieldDecoration: InputDecoration(
                  //             border: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //             hintText: asCountry != '' ? asCountry : "Select Country",
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: asCountry != '' ? valueColor : labelColor2,
                  //               fontStyle: asCountry != '' ? FontStyle.normal : FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 0.5,
                  //               ),
                  //             ),
                  //           ),
                  //           onChanged: (val) {
                  //             if (val != null && val != "") {
                  //               setState(() {
                  //                 asCountry = val.name;
                  //                 asCountryId = val.value;
                  //                 if(asCountry.isNotEmpty && asCountry != '') {
                  //                   asStateDropDown.clear();
                  //                   if(_isLoading == false) {
                  //                     _isLoading = true;
                  //                     getCountryBasedState(asCountryId);
                  //                     _isLoading = false;
                  //                   } else {
                  //                     _isLoading = false;
                  //                   }
                  //                 }
                  //               });
                  //             } else {
                  //               setState(() {
                  //                 asCountry = "";
                  //                 asCountryId = "";
                  //               });
                  //             }
                  //             },
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 5, bottom: 10),
                  //         alignment: Alignment.topLeft,
                  //         child: Row(
                  //           children: [
                  //             Text(
                  //               'State',
                  //               style: GoogleFonts.poppins(
                  //                 fontSize: size.height * 0.018,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.black54,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       _sameAs ? Container(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: inputColors
                  //         ),
                  //         child: TextFormField(
                  //           initialValue: asState,
                  //           readOnly: _sameAs,
                  //           autovalidateMode: AutovalidateMode.onUserInteraction,
                  //           style: GoogleFonts.breeSerif(
                  //               color: Colors.black,
                  //               letterSpacing: 0.2
                  //           ),
                  //           decoration: InputDecoration(
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(10)
                  //             ),
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: labelColor2,
                  //               fontStyle: FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ) : Container(
                  //         alignment: Alignment.center,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(10),
                  //           color: inputColors,
                  //         ),
                  //         child: DropDownTextField(
                  //           controller: _asState,
                  //           listSpace: 20,
                  //           listPadding: ListPadding(top: 20),
                  //           searchShowCursor: true,
                  //           searchAutofocus: true,
                  //           enableSearch: true,
                  //           listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                  //           textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                  //           dropDownItemCount: 6,
                  //           dropDownList: asStateDropDown,
                  //           textFieldDecoration: InputDecoration(
                  //             border: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //             hintText: asState != '' ? asState : "Select state",
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: asState != '' ? valueColor : labelColor2,
                  //               fontStyle: asState != '' ? FontStyle.normal : FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 0.5,
                  //               ),
                  //             ),
                  //           ),
                  //           onChanged: (val) {
                  //             if (val != null && val != "") {
                  //               setState(() {
                  //                 asState = val.name;
                  //                 asStateId = val.value;
                  //                 if(asState.isNotEmpty && asState != '') {
                  //                   asDistrictDropDown.clear();
                  //                   if(_isLoading == false) {
                  //                     _isLoading = true;
                  //                     getStateBasedDistrict(asStateId);
                  //                     _isLoading = false;
                  //                   } else {
                  //                     _isLoading = false;
                  //                   }
                  //                 }
                  //               });
                  //             } else {
                  //               setState(() {
                  //                 asState = "";
                  //                 asStateId = "";
                  //               });
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 5, bottom: 10),
                  //         alignment: Alignment.topLeft,
                  //         child: Row(
                  //           children: [
                  //             Text(
                  //               'District',
                  //               style: GoogleFonts.poppins(
                  //                 fontSize: size.height * 0.018,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.black54,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       _sameAs ? Container(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: inputColors
                  //         ),
                  //         child: TextFormField(
                  //           initialValue: asDistrict,
                  //           readOnly: _sameAs,
                  //           autovalidateMode: AutovalidateMode.onUserInteraction,
                  //           style: GoogleFonts.breeSerif(
                  //               color: Colors.black,
                  //               letterSpacing: 0.2
                  //           ),
                  //           decoration: InputDecoration(
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(10)
                  //             ),
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: labelColor2,
                  //               fontStyle: FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ) : Container(
                  //         alignment: Alignment.center,
                  //         decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(10),
                  //           color: inputColors,
                  //         ),
                  //         child: DropDownTextField(
                  //           controller: _asDistrict,
                  //           listSpace: 20,
                  //           listPadding: ListPadding(top: 20),
                  //           searchShowCursor: true,
                  //           searchAutofocus: true,
                  //           enableSearch: true,
                  //           listTextStyle: GoogleFonts.breeSerif(color: Colors.black, fontSize: size.height * 0.02),
                  //           textStyle: GoogleFonts.breeSerif(color: Colors.black, letterSpacing: 0.2),
                  //           dropDownItemCount: 6,
                  //           dropDownList: asDistrictDropDown,
                  //           textFieldDecoration: InputDecoration(
                  //             border: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //             ),
                  //             hintText: asDistrict != '' ? asDistrict : "Select district",
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: asDistrict != '' ? valueColor : labelColor2,
                  //               fontStyle: asDistrict != '' ? FontStyle.normal : FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 0.5,
                  //               ),
                  //             ),
                  //           ),
                  //           onChanged: (val) {
                  //             if (val != null && val != "") {
                  //               asDistrict = val.name;
                  //               asDistrictId = val.value;
                  //             } else {
                  //               setState(() {
                  //                 asDistrict = "";
                  //                 asDistrictId = "";
                  //               });
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //       Container(
                  //         padding: const EdgeInsets.only(top: 5, bottom: 10),
                  //         alignment: Alignment.topLeft,
                  //         child: Row(
                  //           children: [
                  //             Text(
                  //               'Pin Code',
                  //               style: GoogleFonts.poppins(
                  //                 fontSize: size.height * 0.018,
                  //                 fontWeight: FontWeight.bold,
                  //                 color: Colors.black54,
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //       Container(
                  //         decoration: BoxDecoration(
                  //             borderRadius: BorderRadius.circular(10),
                  //             color: inputColors
                  //         ),
                  //         child: TextFormField(
                  //           controller: perZipController,
                  //           keyboardType: TextInputType.number,
                  //           autocorrect: true,
                  //           readOnly: _sameAs,
                  //           inputFormatters: [
                  //             LengthLimitingTextInputFormatter(6),
                  //           ],
                  //           autovalidateMode: AutovalidateMode.onUserInteraction,
                  //           style: GoogleFonts.breeSerif(
                  //               color: Colors.black,
                  //               letterSpacing: 0.2
                  //           ),
                  //           decoration: InputDecoration(
                  //             hintText: "Enter pin code",
                  //             border: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(10)
                  //             ),
                  //             hintStyle: GoogleFonts.breeSerif(
                  //               color: labelColor2,
                  //               fontStyle: FontStyle.italic,
                  //             ),
                  //             enabledBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: disableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //             focusedBorder: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(10),
                  //               borderSide: const BorderSide(
                  //                 color: enableColor,
                  //                 width: 1.0,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),),
                  SizedBox(
                    height: size.height * 0.15,
                  )
                ],
              ),
            ),
          ),
        ),
        bottomSheet: Container(
          decoration: const BoxDecoration(
              color: whiteColor,
              border: Border(
                  top: BorderSide(
                      color: Colors.grey,
                      width: 1.0
                  )
              )
          ),
          padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.01),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: size.width * 0.4,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.red
                ),
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmAlertDialog(
                              message: 'Are you sure want to cancel ?.',
                              onYesPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context, "refresh");
                              },
                              onCancelPressed: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      });
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                ),
              ),
              Container(
                  width: size.width * 0.4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: greenColor,
                  ),
                  child: TextButton(
                      onPressed: () {
                        if (nameController.text.toString().isEmpty ||
                            familyCardController.text.toString().isEmpty ||
                            // familyIncomeController.text.toString().isEmpty ||
                            resAddressController.text.toString().isEmpty ||
                            resCityTownController.text.toString().isEmpty ||
                            resZipController.text.toString().isEmpty ||
                            anbiyam.isEmpty || country.isEmpty || state.isEmpty ||
                            district.isEmpty || (mobileNumberController.text.isEmpty && mobile.isEmpty) ||
                            (church && churchMarriageDateController.text.toString().isEmpty) ||
                            (civil && marriageDateController.text.toString().isEmpty)) {
                          // Call validate function if any of the required fields are empty
                          validate();
                        } else {
                          // Proceed with further checks or actions
                          if (isEmail) {
                            setState(() {
                              email = '';
                              isEmail = true;
                              AnimatedSnackBar.show(
                                context,
                                "Please enter the valid email address.",
                                redColor,
                              );
                            });
                          } else if (isValid) {  // Assuming this should be `!isValid` to check for invalid mobile number
                            AnimatedSnackBar.show(
                              context,
                              "Please enter the valid mobile number.",
                              redColor,
                            );
                          } else if (!isValidPin) {  // Adjusting to `!isValidPin` to check for invalid pin
                            AnimatedSnackBar.show(
                              context,
                              "Please enter the valid pin.",
                              redColor,
                            );
                          } else {
                            setState(() {
                              isEmail = false;
                              _isLoading = true;
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return const CustomLoadingDialog();
                                },
                              );
                              createFamily();
                            });
                          }
                        }
                      },
                      child: Text('Save', style: TextStyle(color: Colors.white, fontSize: size.height * 0.02),)
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}