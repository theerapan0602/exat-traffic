import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import 'package:exattraffic/etc/utils.dart';
import 'package:exattraffic/models/marker_categories/cctv_model.dart';
import 'package:exattraffic/models/language_model.dart';

class CctvItemView extends StatelessWidget {
  CctvItemView({
    @required this.cctvModel,
    @required this.isFirstItem,
    @required this.isLastItem,
    @required this.onClick,
  });

  final CctvModel cctvModel;
  final bool isFirstItem;
  final bool isLastItem;
  final Function onClick;

  final Random _rnd = Random();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                left: getPlatformSize(14.0),
                right: getPlatformSize(14.0),
                top: getPlatformSize(isFirstItem ? 7.0 : 0.0),
                bottom: getPlatformSize(isLastItem ? 21.0 : 0.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: _rnd.nextInt(2) == 0 ? Color(0xFFEB222C) : Color(0xFF22B573),
                      width: getPlatformSize(11.0),
                    ),
                    bottom: isLastItem
                        ? BorderSide.none
                        : BorderSide(
                            color: Color(0xFFC7C7C7),
                            width: getPlatformSize(0.0),
                          ),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onClick,
                    child: Container(
                      padding: EdgeInsets.only(
                        left: getPlatformSize(20.0),
                        right: getPlatformSize(10.0),
                        top: getPlatformSize(12.0),
                        bottom: getPlatformSize(12.0),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Consumer<LanguageModel>(
                                builder: (context, language, child) {
                                  String name;
                                  switch (language.lang) {
                                    case 0:
                                      name = cctvModel.name;
                                      break;
                                    case 1:
                                      name = 'Expressway';
                                      break;
                                    case 2:
                                      name = '高速公路';
                                      break;
                                  }
                                  return Text(
                                    name,
                                    style: getTextStyle(language.lang),
                                  );
                                },
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(getPlatformSize(9.0)),
                            ),
                            child: Image(
                              image: AssetImage('assets/images/home/toll_plaza_dummy_${Random().nextInt(2) + 1}.jpg'),
                              //cctvModel.image,
                              width: getPlatformSize(100.0),
                              height: getPlatformSize(65.0),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            isFirstItem
                ? SizedBox.shrink()
                : Positioned(
                    top: getPlatformSize(-5.0),
                    left: getPlatformSize(13.5),
                    child: Image(
                      image: AssetImage('assets/images/home/ic_arrow_down.png'),
                      width: getPlatformSize(12.26),
                      height: getPlatformSize(10.49),
                      fit: BoxFit.contain,
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
