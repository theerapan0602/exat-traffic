import 'package:exattraffic/models/category_model.dart';
import 'package:exattraffic/screens/home/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exattraffic/etc/utils.dart';
import 'package:exattraffic/constants.dart' as Constants;
import 'package:exattraffic/models/layer_item_model.dart';
import 'package:exattraffic/models/language_model.dart';

class LayerItemView extends StatelessWidget {
  LayerItemView({
    @required this.layerItem,
    @required this.isFirstItem,
    @required this.isLastItem,
    @required this.selected,
    @required this.onClick,
  });

  final CategoryModel layerItem;
  final bool isFirstItem;
  final bool isLastItem;
  final bool selected;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        padding: EdgeInsets.only(
          left: getPlatformSize(isFirstItem ? 20.0 : 10.0),
          right: getPlatformSize(isLastItem ? 20.0 : 10.0),
          top: getPlatformSize(2.0),
          bottom: getPlatformSize(2.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClick,
                borderRadius: BorderRadius.all(
                  Radius.circular(Constants.App.BOX_BORDER_RADIUS),
                ),
                child: Container(
                  width: getPlatformSize(70.0),
                  height: getPlatformSize(70.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: getPlatformSize(2.0),
                      color: selected
                          ? Constants.BottomSheet.LAYER_ITEM_BORDER_COLOR_ON
                          : Constants.BottomSheet.LAYER_ITEM_BORDER_COLOR_OFF,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(Constants.App.BOX_BORDER_RADIUS),
                    ),
                  ),
                  child: Center(
                    child: Image(
                      image: selected ? layerItem.filterOnIconAsset : layerItem.filterOffIconAsset,
                      width: layerItem.filterIconWidth,
                      height: layerItem.filterIconHeight,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: getPlatformSize(8.0),
              ),
              child: Consumer<LanguageModel>(
                builder: (context, language, child) {
                  /*String name;
                  switch (language.lang) {
                    case 0:
                      name = layerItem.text;
                      break;
                    case 1:
                      name = layerItem.textEn;
                      break;
                    case 2:
                      name = '高速公路';
                      break;
                  }*/

                  return Text(
                    layerItem.name,
                    style: getTextStyle(
                      0, //language.lang, // todo: ************************************
                      sizeTh: Constants.Font.SMALLER_SIZE_TH,
                      sizeEn: Constants.Font.SMALLER_SIZE_EN,
                      heightTh: 1.0,
                      color: selected ? Constants.App.PRIMARY_COLOR : Constants.Font.DEFAULT_COLOR,
                      //isBold: layerItem.isChecked,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
