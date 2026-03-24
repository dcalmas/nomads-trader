import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/backend/mobx-store/course_store.dart';
import 'package:flutter_app/app/backend/mobx-store/init_store.dart';
import 'package:flutter_app/app/backend/models/learning-lesson-model.dart';
import 'package:flutter_app/app/controller/learing_controller.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_just_audio/fwfh_just_audio.dart';
import 'package:fwfh_webview/fwfh_webview.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LearningLesson extends StatelessWidget with GetItMixin {
  final LearningLessonModel data;

  LearningLesson({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LearningController>(builder: (value) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (data.name != null)
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Text(
                data.name!,
                key: ValueKey('title_${data.id}'),
                style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'medium',
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              )),
        
        // Видео бөлімі
        if (data.video_intro != null && data.video_intro != "")
          _YoutubePlayerWidget(
            key: ValueKey('video_${data.id}'),
            html: data.video_intro.toString(),
          ),

        if (data.content != null && data.content != "")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: HtmlWidget(
              data.content.toString(),
              key: ValueKey('content_${data.id}'),
              factoryBuilder: () => MyWidgetFactory(),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (value.courseModel.course_data?.status == 'enrolled')
              if (value.courseModel.sections != null &&
                  value.courseModel.sections!.isNotEmpty &&
                  value.lesson?.status != 'completed')
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => {value.onCompleteLesson()},
                    child: Text(tr(LocaleKeys.learningScreen_lesson_btnComplete)),
                  ),
                ),
            if (data.can_finish_course == true)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => {value.onFinishCourse()},
                  child: Text(tr(LocaleKeys.learningScreen_finishCourse)),
                ),
              ),
          ],
        )
      ]);
    });
  }
}

class _YoutubePlayerWidget extends StatefulWidget {
  final String html;
  const _YoutubePlayerWidget({super.key, required this.html});

  @override
  State<_YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<_YoutubePlayerWidget> {
  late final WebViewController _controller;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _videoId = _extractVideoId(widget.html);
    if (_videoId != null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
        ..loadHtmlString('''
          <!DOCTYPE html>
          <html>
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <style>
                body { margin: 0; background-color: black; display: flex; align-items: center; height: 100vh; overflow: hidden; }
                iframe { width: 100%; height: 100%; border: none; }
              </style>
            </head>
            <body>
              <iframe id="player" type="text/html" 
                src="https://www.youtube-nocookie.com/embed/$_videoId?enablejsapi=1&origin=https://nomadstrader.com&rel=0&playsinline=1"
                frameborder="0" allowfullscreen></iframe>
            </body>
          </html>
        ''', baseUrl: 'https://nomadstrader.com');
    }
  }

  // Барлық типтегі YouTube сілтемелерінен ID-ді бөліп алу
  String? _extractVideoId(String text) {
    if (text.isEmpty) return null;
    
    // 1. embed/ (iframe)
    final embedMatch = RegExp(r'embed\/([\w-]{11})').firstMatch(text);
    if (embedMatch != null) return embedMatch.group(1);
    
    // 2. watch?v=
    final watchMatch = RegExp(r'v=([\w-]{11})').firstMatch(text);
    if (watchMatch != null) return watchMatch.group(1);
    
    // 3. youtu.be/
    final shortMatch = RegExp(r'youtu\.be\/([\w-]{11})').firstMatch(text);
    if (shortMatch != null) return shortMatch.group(1);

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId == null) return HtmlWidget(widget.html);
    
    return Container(
      height: 230,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: WebViewWidget(controller: _controller),
    );
  }
}

class MyWidgetFactory extends WidgetFactory with WebViewFactory, JustAudioFactory {
  @override
  bool get webViewMediaPlaybackAlwaysAllow => true;
}
