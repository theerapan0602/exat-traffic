import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

import 'package:exattraffic/etc/utils.dart';
import 'package:exattraffic/constants.dart' as Constants;
import 'package:exattraffic/models/language_model.dart';
import 'package:exattraffic/models/marker_categories/cctv_model.dart';
import 'package:exattraffic/components/tool_item.dart';
import 'package:exattraffic/components/my_progress_indicator.dart';
import 'package:exattraffic/screens/login/login.dart';

class CctvDetails extends StatelessWidget {
  CctvDetails(this._cctvModel);

  final CctvModel _cctvModel;

  @override
  Widget build(BuildContext context) {
    return wrapSystemUiOverlayStyle(child: CctvDetailsMain(_cctvModel));
  }
}

class CctvDetailsMain extends StatefulWidget {
  CctvDetailsMain(this._cctvModel);

  final CctvModel _cctvModel;

  @override
  _CctvDetailsMainState createState() => _CctvDetailsMainState();
}

class _CctvDetailsMainState extends State<CctvDetailsMain> {
  int _checkedToolItemIndex;
  VlcPlayerController _controller;

  void _handleClickTool(BuildContext context, int toolItemIndex) {
    if (toolItemIndex == 2) {
      // เส้นทาง
      return;
    }

    setState(() {
      _checkedToolItemIndex = toolItemIndex;
    });
  }

  void _handleClickClose(BuildContext context) {
    //todo: stop video, etc.
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    if (widget._cctvModel.streamUrl != null) {
      _checkedToolItemIndex = 0;
    } else if (widget._cctvModel.imageUrl != null) {
      _checkedToolItemIndex = 1;
    } else {
      _checkedToolItemIndex = 2;
    }

    if (widget._cctvModel.streamUrl != null) {
      print("***** ${widget._cctvModel.name} - STREAM URL: ${widget._cctvModel.streamUrl}");

      _controller = new VlcPlayerController(
        // Start playing as soon as the video is loaded.
        onInit: () {
          _controller.addListener(() {
            print("***** PLAYING STATE: ${_controller.playingState.toString()}");
            // rebuild ใหม่ทุกครั้งเมื่อสถานะของ video player เปลี่ยน
            setState(() {});
          });
          _controller.play();
        },
      );
    } else {
      print("***** ${widget._cctvModel.name} - STREAM URL is NULL !");
    }
  }

  @override
  void dispose() {
    super.dispose();
    //_controller.dispose();
  }

  bool _isValidUrl(String url) {
    return url != null && url.trim().length > 7; // อย่างน้อย "http://"
  }

  @override
  Widget build(BuildContext context) {
    final String streamUrl = widget._cctvModel.streamUrl;
    final String imageUrl = widget._cctvModel.imageUrl;

    return Scaffold(
      appBar: null,
      body: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getPlatformSize(0.0),
              //getPlatformSize(Constants.CctvPlayerScreen.HORIZONTAL_MARGIN),
              vertical: getPlatformSize(0.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: getPlatformSize(10.0),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        hoverColor: Color(0xFF999999),
                        splashColor: Color(0xFF999999),
                        highlightColor: Color(0xFF999999),
                        focusColor: Color(0xFF999999),
                        onTap: () => _handleClickClose(context),
                        borderRadius: BorderRadius.all(Radius.circular(18.0)),
                        child: Container(
                          width: getPlatformSize(36.0),
                          height: getPlatformSize(36.0),
                          //padding: EdgeInsets.all(getPlatformSize(15.0)),
                          child: Center(
                            child: Image(
                              image: AssetImage('assets/images/cctv_details/ic_close_cctv.png'),
                              width: getPlatformSize(13.5),
                              height: getPlatformSize(13.5),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: getPlatformSize(16.0),
                ),
                Center(
                  child: Consumer<LanguageModel>(
                    builder: (context, language, child) {
                      String name;
                      switch (language.lang) {
                        case 0:
                          name = widget._cctvModel.name;
                          break;
                        case 1:
                          name = 'About Us';
                          break;
                        case 2:
                          name = '关于我们';
                          break;
                      }
                      return Text(
                        name,
                        style: getTextStyle(
                          language.lang,
                          sizeTh: Constants.Font.BIGGER_SIZE_TH,
                          sizeEn: Constants.Font.BIGGER_SIZE_EN,
                          color: Colors.white,
                          isBold: true,
                          //heightEn: 1.5,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: getPlatformSize(25.0),
                ),
                IndexedStack(
                  index: _checkedToolItemIndex,
                  children: <Widget>[
                    _isValidUrl(streamUrl)
                        ? AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                VlcPlayer(
                                  aspectRatio: 4 / 3,
                                  url: streamUrl,
                                  controller: _controller,
                                  placeholder: Center(child: MyProgressIndicator()),
                                ),
                                Visibility(
                                  visible:
                                      !_controller.initialized || _controller.playingState == null,
                                  child: Center(
                                    child: MyProgressIndicator(),
                                  ),
                                ),
                                Visibility(
                                  visible: _controller.playingState == PlayingState.STOPPED,
                                  child: MyButton(
                                    text: "TRY AGAIN",
                                    onClickButton: () {
                                      _controller.play();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                    _isValidUrl(imageUrl)
                        ? AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Image.network(
                              imageUrl,
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),

                /*Container(
                  height: getPlatformSize(240.0),
                  margin: EdgeInsets.symmetric(
                    horizontal: getPlatformSize(Constants.CctvPlayerScreen.HORIZONTAL_MARGIN),
                    vertical: getPlatformSize(0.0),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    border: Border.all(
                      color: Colors.yellowAccent,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(getPlatformSize(10.0)),
                    ),
                  ),
                  child: Center(
                    child: Image(
                      image: AssetImage('assets/images/cctv_details/ic_playback.png'),
                      width: getPlatformSize(89.0),
                      height: getPlatformSize(89.0),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),*/
                SizedBox(
                  height: getPlatformSize(28.0),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getPlatformSize(Constants.CctvPlayerScreen.HORIZONTAL_MARGIN),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _isValidUrl(streamUrl)
                          ? ToolItem(
                              'ภาพเคลื่อนไหว',
                              AssetImage('assets/images/cctv_details/ic_video.png'),
                              getPlatformSize(30.79),
                              getPlatformSize(25.51),
                              this._checkedToolItemIndex == 0,
                              () => this._handleClickTool(context, 0),
                            )
                          : SizedBox.shrink(),
                      _isValidUrl(imageUrl)
                          ? ToolItem(
                              'ภาพถ่าย',
                              AssetImage('assets/images/cctv_details/ic_picture.png'),
                              getPlatformSize(23.67),
                              getPlatformSize(20.06),
                              this._checkedToolItemIndex == 1,
                              () => this._handleClickTool(context, 1),
                            )
                          : SizedBox.shrink(),
                      ToolItem(
                        'เส้นทาง',
                        AssetImage('assets/images/cctv_details/ic_route.png'),
                        getPlatformSize(27.06),
                        getPlatformSize(35.21),
                        this._checkedToolItemIndex == 2,
                        () => this._handleClickTool(context, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
