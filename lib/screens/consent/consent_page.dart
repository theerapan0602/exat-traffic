import 'dart:math';

import 'package:exattraffic/components/data_loading.dart';
import 'package:flutter/material.dart';

import 'package:exattraffic/screens/scaffold2.dart';
import 'package:exattraffic/etc/utils.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'consent_presenter.dart';

class ConsentPage extends StatefulWidget {
  @override
  _ConsentPageState createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  // กำหนด title ของแต่ละภาษา, ในช่วง dev ต้องกำหนดอย่างน้อย 3 ภาษา เพราะดัก assert ไว้ครับ
  List<String> _titleList = [
    "ข้อกำหนดและเงื่อนไข",
    "Terms And Condition",
    "附带条约"
  ];

  bool checkValue = false;
  ConsentPresenter _presenter;

  String _getDummyText() {
    return new List(1000).fold("", (previousValue, element) => previousValue + "TEST-${Random().nextInt(100).toString()} ");
  }

  Widget _content(){
    return _presenter.consentModel==null?DataLoading():
    Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
//          border: Border.all(
//            color: Colors.black12,
//            width: getPlatformSize(10.0),
//          ),
          color: Colors.white
      ),
      child: Column(
        children: <Widget>[

          _title(),
          _body(),
          _submit(),

        ],
      ),
    );
  }

  Widget _title(){
    return Container(
      child: Center(
        child: Text(_presenter.consentModel.data[0].title, style: getTextStyle(0)),
      ),
    );
  }

  Widget _body(){
    return  Expanded(
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
            border: Border.all(
              color: Color(0x11000000),
              width: getPlatformSize(10.0),
            ),
            color: Colors.white
        ),
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Text(_presenter.consentModel.data[0].content),
        ),
      ),
    );
  }

  Widget _submit(){
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Checkbox(
                onChanged: (value){
                  setState(() {
                    checkValue = value;
                  });
                },
                value: checkValue,
              ),
              Text("ยอมรับเงื่อนไข"),
            ],
          ),
          Container(
            width: double.maxFinite,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
//                    side: BorderSide(color: Colors.red)
              ),
              onPressed: () {
                if(checkValue) {
                  print("send");
                  Navigator.pop(context);
                }else{
                  Alert(
                    context: context,
                    type: AlertType.error,
                    title: "เกิดข้อผิดพลาด",
                    desc: "กรุณากดยอมรับเงือนไข",
                    buttons: [
                      DialogButton(
                        child: Text(
                          "OK",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        width: 120,
                      )
                    ],
                  ).show();
                }
              },
              color: Colors.blue,
              child: Text(
                "ยืนยัน",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _presenter = ConsentPresenter(this);
    _presenter.getConsent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return YourScaffold(
      titleList: _titleList,

      // แก้ไขตรง child นี้ได้เลย เพื่อแสดง content ตามที่ต้องการ
      child: _content(),
    );
  }
}
