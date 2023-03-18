import 'dart:developer';

import 'package:chat_app/utils/styles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

class PhotoScreen extends StatefulWidget {
  final String name;
  final String url;

  const PhotoScreen({
    Key? key,
    required this.name,
    required this.url,
  }) : super(key: key);

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  double? progressBar;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Styles.appBarColor,
        title: Text(widget.name),
        actions: [
          IconButton(
            icon: Icon(Styles.downloadIcon),
            onPressed: downloadImage,
          ),
        ],
      ),
      body: Stack(children: [
        PhotoView(
          imageProvider: NetworkImage(widget.url),
        ),
        if (progressBar != null && progressBar != 1)
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: mq.width * 0.139,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  LinearProgressIndicator(
                    value: progressBar,
                    backgroundColor: Styles.fillColor,
                    color: Styles.progressColor,
                  ),
                  Center(
                    child: Text(
                      '${(100 * progressBar!).roundToDouble()}%',
                      style: TextStyle(color: Styles.textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ]),
    );
  }

  Future downloadImage() async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/myfile.jpg';

      await Dio().download(widget.url, path,
          onReceiveProgress: (received, total) {
        double progress = received / total;
        setState(() => progressBar = progress);
      });
      await GallerySaver.saveImage(path, toDcim: true)
          .then((value) => Fluttertoast.showToast(
                msg: 'Download completed',
                textColor: Styles.textColor,
                backgroundColor: Styles.black87Color,
              ));
    } catch (e) {
      log(e.toString());
    }
  }
}
