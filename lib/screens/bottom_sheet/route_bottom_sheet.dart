import 'package:exattraffic/models/cost_toll_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

import 'package:exattraffic/etc/utils.dart';
import 'package:exattraffic/constants.dart' as Constants;
import 'package:exattraffic/models/language_model.dart';

import 'components/bottom_sheet_scaffold.dart';

class RouteBottomSheet extends StatefulWidget {
  RouteBottomSheet({
    @required this.expandPosition,
    @required this.collapsePosition,
    @required this.selectedCostToll,
    @required this.googleRoute,
  });

  final double expandPosition;
  final double collapsePosition;
  final CostTollModel selectedCostToll;
  final Map<String, dynamic> googleRoute;

  @override
  _RouteBottomSheetState createState() => _RouteBottomSheetState();
}

class _RouteBottomSheetState extends State<RouteBottomSheet> {
  final GlobalKey<BottomSheetScaffoldState> _keyBottomSheetScaffold = GlobalKey();

  bool _bottomSheetExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  void _handleClickUpDownSheet() {
    _keyBottomSheetScaffold.currentState.toggleSheet();
  }

  void _handleChangeSize(bool sheetExpanded) {
    setState(() {
      _bottomSheetExpanded = sheetExpanded;
    });
  }

  Widget _getCarItem(int language, int widthFlex, String label, String iconPath, double iconWidth,
      double iconHeight, double iconMarginTop) {
    return Expanded(
      flex: widthFlex,
      child: Container(
        height: getPlatformSize(75),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: getPlatformSize(iconMarginTop),
              ),
              child: Image(
                image: AssetImage(iconPath),
                width: getPlatformSize(iconWidth),
                height: getPlatformSize(iconHeight),
              ),
            ),
            Text(
              label,
              style: getTextStyle(
                language,
                color: Colors.white,
                isBold: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFeeItem(int language, int widthFlex, int fee) {
    return Expanded(
      flex: widthFlex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: getPlatformSize(4.0),
          ),
          Image(
            image: AssetImage('assets/images/route/ic_sheet_down_white.png'),
            width: getPlatformSize(10.0),
            height: getPlatformSize(9.73 * 10.0 / 5.88),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: getPlatformSize(4.0),
              bottom: getPlatformSize(8.0),
            ),
            child: Text(
              'ค่าผ่านทางรวม',
              style: getTextStyle(
                language,
                color: Colors.white,
                sizeTh: Constants.Font.SMALLER_SIZE_TH,
                sizeEn: Constants.Font.SMALLER_SIZE_EN,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: getPlatformSize(6.0),
              bottom: getPlatformSize(0.0),
            ),
            child: Text(
              fee.toString(),
              style: getTextStyle(
                1,
                color: Colors.white,
                sizeTh: 50.0,
                sizeEn: 35.0,
                heightEn: 0.9,
                isBold: true,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: getPlatformSize(0.0),
              bottom: getPlatformSize(8.0),
            ),
            child: Text(
              'บาท',
              style: getTextStyle(
                language,
                color: Colors.white,
                sizeTh: Constants.Font.BIGGER_SIZE_TH,
                sizeEn: Constants.Font.BIGGER_SIZE_EN,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getArrivalTimeText() {
    int routeDurationSeconds = widget.googleRoute == null
        ? 0
        : widget.googleRoute['legs'][0]['duration']['value'];

    DateTime arrivalDate = new DateTime.now().add(Duration(seconds: routeDurationSeconds));
    String hourText = (arrivalDate.hour < 10 ? "0" : "") + arrivalDate.hour.toString();
    String minuteText = (arrivalDate.minute < 10 ? "0" : "") + arrivalDate.minute.toString();
    return '$hourText.$minuteText';
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetScaffold(
      key: _keyBottomSheetScaffold,
      expandPosition: widget.expandPosition,
      collapsePosition: widget.collapsePosition,
      onChangeSize: _handleChangeSize,
      child: Expanded(
        child: Container(
          color: Constants.BottomSheet.DARK_BACKGROUND_COLOR,
          padding: EdgeInsets.only(
            left: getPlatformSize(20.0),
            right: getPlatformSize(4.0),
            top: getPlatformSize(4.0),
            bottom: getPlatformSize(0.0),
          ),
          child: Consumer<LanguageModel>(
            builder: (context, language, child) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      // ข้อความบอกเวลา ระยะทาง
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: getPlatformSize(6.0),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                widget.googleRoute == null
                                    ? ''
                                    : widget.googleRoute['legs'][0]['duration']['text']
                                    .replaceAll('hour', 'ชม.')
                                    .replaceAll('mins', 'นาที'),
                                style: getTextStyle(
                                  language.lang,
                                  isBold: true,
                                  color: Colors.white,
                                  sizeTh: Constants.Font.BIGGEST_SIZE_TH,
                                  sizeEn: Constants.Font.BIGGEST_SIZE_EN,
                                ),
                              ),
                              SizedBox(
                                width: getPlatformSize(15.0),
                              ),
                              Text(
                                widget.googleRoute == null
                                    ? ''
                                    : '(${widget.googleRoute['legs'][0]['distance']['text']
                                    .replaceAll('km', 'กม.')})',
                                style: getTextStyle(
                                  language.lang,
                                  color: Colors.white,
                                  sizeTh: Constants.Font.BIGGER_SIZE_TH,
                                  sizeEn: Constants.Font.BIGGER_SIZE_EN,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // ปุ่ม up/down
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _handleClickUpDownSheet();
                          },
                          borderRadius: BorderRadius.all(
                            Radius.circular(getPlatformSize(21.0)),
                          ),
                          child: Container(
                            width: getPlatformSize(42.0),
                            height: getPlatformSize(42.0),
                            //padding: EdgeInsets.all(getPlatformSize(15.0)),
                            child: Center(
                              child: Image(
                                image: _bottomSheetExpanded
                                    ? AssetImage('assets/images/route/ic_sheet_down_white.png')
                                    : AssetImage('assets/images/route/ic_sheet_up_white.png'),
                                width: getPlatformSize(10.0),
                                height: getPlatformSize(9.73 * 10.0 / 5.88),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ถึงเวลา, ผ่านที่ด่าน
                  Padding(
                    padding: EdgeInsets.only(
                      right: getPlatformSize(16.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'เดินทางตอนนี้ ถึง ${_getArrivalTimeText()} น.',
                            style: getTextStyle(
                              language.lang,
                              color: Colors.white,
                              sizeTh: Constants.Font.SMALLER_SIZE_TH,
                              sizeEn: Constants.Font.SMALLER_SIZE_EN,
                            ),
                          ),
                        ),
                        Text(
                          '',
                          /*'ผ่านทั้งหมด 3 ด่าน',*/
                          style: getTextStyle(
                            language.lang,
                            color: Colors.white,
                            sizeTh: Constants.Font.SMALLER_SIZE_TH,
                            sizeEn: Constants.Font.SMALLER_SIZE_EN,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // เส้นคั่น
                  Container(
                    height: 0.0,
                    margin: EdgeInsets.only(
                      top: getPlatformSize(16.0),
                      bottom: getPlatformSize(16.0),
                      right: getPlatformSize(16.0),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.26),
                          width: getPlatformSize(0.0),
                        ),
                      ),
                    ),
                  ),

                  // รูปรถ
                  Padding(
                    padding: EdgeInsets.only(
                      right: getPlatformSize(16.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        _getCarItem(
                          language.lang,
                          8,
                          '4 ล้อ',
                          'assets/images/route/ic_car_small.png',
                          46.0,
                          25.8,
                          15,
                        ),
                        _getCarItem(
                          language.lang,
                          10,
                          '6-10 ล้อ',
                          'assets/images/route/ic_car_medium-new.png',
                          84.65,
                          38.66,
                          3,
                        ),
                        _getCarItem(
                          language.lang,
                          11,
                          'เกิน 10 ล้อ',
                          'assets/images/route/ic_car_large-new.png',
                          118.25,
                          42.01,
                          0,
                        ),
                      ],
                    ),
                  ),

                  // ค่าผ่านทาง
                  Padding(
                    padding: EdgeInsets.only(
                      right: getPlatformSize(16.0),
                    ),
                    child: Row(
                      children: <Widget>[
                        _getFeeItem(
                            language.lang,
                            6,
                            widget.selectedCostToll == null
                                ? 0
                                : widget.selectedCostToll.cost4Wheels),
                        _getFeeItem(
                            language.lang,
                            6,
                            widget.selectedCostToll == null
                                ? 0
                                : widget.selectedCostToll.cost6To10Wheels),
                        _getFeeItem(
                            language.lang,
                            6,
                            widget.selectedCostToll == null
                                ? 0
                                : widget.selectedCostToll.costOver10Wheels),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
