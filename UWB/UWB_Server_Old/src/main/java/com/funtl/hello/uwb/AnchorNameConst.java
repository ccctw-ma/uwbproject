package com.funtl.hello.uwb;

import java.util.ResourceBundle;

/**
 * 基站和标签的Mac地址常量
 * @author LingZhe
 */
public class AnchorNameConst {

    static ResourceBundle resourceBundle = ResourceBundle.getBundle("anchorName");

    public static String Anchor1 = resourceBundle.getString("Anchor1");

    public static String Anchor2 = resourceBundle.getString("Anchor2");

    public static String Anchor3 = resourceBundle.getString("Anchor3");

    public static String Anchor4 = resourceBundle.getString("Anchor4");

    public static String Label = resourceBundle.getString("Label");


    public static String getAnchorStr(int i) {
        switch (i) {
            case 1:
                return Anchor1;
            case 2:
                return Anchor2;
            case 3:
                return Anchor3;
            case 4:
                return Anchor4;
            default:
                return "";
        }
    }

}
