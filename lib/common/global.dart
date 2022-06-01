/*
 * @Author       : 老董
 * @Date         : 2022-04-29 22:27:48
 * @LastEditors  : 老董
 * @LastEditTime : 2022-05-07 16:09:06
 * @Description  : 全局属性
 */
import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

// 一些默认参数
const boardPath = "./assets/skins/woods/board.svg";
const samplePiecePath = "./assets/skins/woods/bb.svg";
// const samplePiecePath = "./assets/skins/woods/ba.svg";

const backgroundStartColor = Color(0xffffd500);
const backgroundEndColor = Color(0xfff6a00c);

const maxSizeScale = 1.2;
const minSizeScale = 0.7;

const testScale = 1.0;
const appWidth = 750.0 * testScale; //用以设置的窗口大小
const appHeight = 545.0 * testScale; //用以设置的窗口大小
var devicePixelRatio = 1.25; //TODO:和windows的缩放比例，暂时先硬编码
var winWidth = 921.0; //基于上述appSize后实际捕获到的尺寸
var winHeight = 673.0; //基于上述appSize后实际捕获到的尺寸

// appWidth-->winWidth : appWidth*devicePixelRatio* -16.5
// var winWidth = appWidth * devicePixelRatio * -16.5;
// appHeight-->winHeight : appHeight*devicePixelRatio* - 8.5
var ratio2 = appHeight / winHeight;
// 0.8143322476
const minAppWidth = appWidth * minSizeScale;
const minAppHeight = appHeight * minSizeScale;
const maxAppWidth = appWidth * maxSizeScale;
const maxAppHeight = appHeight * maxSizeScale;
const chessUiWidthRatio = 0.7; //棋盘和状态ui遵行7:3的比例
const minStateUiWidth = minAppWidth * chessUiWidthRatio;

final aspectRatio = appWidth / appHeight;
var boardWidth = 521.0;
var boardHeight = 577.0;
var pieceSize = 57.0 * 1.18; //宽高一致

const boardLeftTopCornerPos = Offset(460, 199); //捕获时时的窗口左上角全局offset
const leftTop1stPos = Offset(498, 235); //捕获时左上角第一点全局offset
const leftTop2edPos = Offset(564.75, 235); //捕获时左上角向右第二点全局offset

const stateUiWidth = 250.0; //右侧状态ui的固定宽度
const toobarHeight = 40.0;
const hideToobarHeight = 20.0;

// 常用函数
String getCurrentTimeString() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('kk:mm:ss').format(now);
  // String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
  return formattedDate;
}

// getImageSize(String imagePath) async {
//   // board
//   File image = File(imagePath); // Or any other way to get a File instance.
//   var decodedImage1 = await decodeImageFromList(image.readAsBytesSync());
//   return [decodedImage1.width, decodedImage1.height];
//   // // piece
//   // var decodedImage2 =
//   //     await decodeImageFromList(File(boardPath).readAsBytesSync());
//   // _pieceWidth = decodedImage2.width;
//   // _pieceHeight = decodedImage2.height;
// }
