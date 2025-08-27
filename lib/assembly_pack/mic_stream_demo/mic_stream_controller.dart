import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MicStreamController extends GetxController {
  dynamic recordPlugin = [];
  RxString tempVoice = 'images/voice/voice_volume_1.png'.obs;
  RxBool isRecording = false.obs;
  RxBool isPlaying = false.obs;
  RxDouble currentAmplitude = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initRecordPlugin();
  }
  
  void _initRecordPlugin() {
    try {
      // 初始化录音插件
      // recordPlugin.init();
      
      // 监听振幅变化
      // recordPlugin.responseFromAmplitude.listen((data) {
      //   double voiceData = double.parse(data.msg ?? '0');
      //   _updateVoiceVolume(voiceData);
      // });
      
      // 模拟振幅监听
      _simulateAmplitudeListener();
    } catch (e) {
      print('Error initializing record plugin: $e');
    }
  }
  
  void _updateVoiceVolume(double voiceData) {
    currentAmplitude.value = voiceData;
    
    if (voiceData > 0 && voiceData < 0.1) {
      tempVoice.value = 'images/voice/voice_volume_2.png';
    } else if (voiceData > 0.2 && voiceData < 0.3) {
      tempVoice.value = 'images/voice/voice_volume_3.png';
    } else if (voiceData > 0.3 && voiceData < 0.4) {
      tempVoice.value = 'images/voice/voice_volume_4.png';
    } else if (voiceData > 0.4 && voiceData < 0.5) {
      tempVoice.value = 'images/voice/voice_volume_5.png';
    } else if (voiceData > 0.5 && voiceData < 0.6) {
      tempVoice.value = 'images/voice/voice_volume_6.png';
    } else if (voiceData > 0.6 && voiceData < 0.7) {
      tempVoice.value = 'images/voice/voice_volume_7.png';
    } else if (voiceData > 0.7 && voiceData < 1) {
      tempVoice.value = 'images/voice/voice_volume_7.png';
    }
    
    print('振幅大小: $voiceData');
  }
  
  // 模拟振幅监听器
  void _simulateAmplitudeListener() {
    // 这里可以添加模拟的振幅数据用于测试
  }
  
  void startRecording() {
    try {
      // recordPlugin.start();
      isRecording.value = true;
      print('开始录制');
    } catch (e) {
      print('Error starting recording: $e');
    }
  }
  
  void stopRecording() {
    try {
      // recordPlugin.stop();
      isRecording.value = false;
      print('停止录制');
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }
  
  void playRecording() {
    try {
      // recordPlugin.play();
      isPlaying.value = true;
      print('播放录音');
      
      // 模拟播放完成
      Future.delayed(Duration(seconds: 3), () {
        isPlaying.value = false;
      });
    } catch (e) {
      print('Error playing recording: $e');
    }
  }
  
  void resetVoiceVolume() {
    tempVoice.value = 'images/voice/voice_volume_1.png';
    currentAmplitude.value = 0.0;
  }
  
  @override
  void onClose() {
    try {
      // recordPlugin.stop();
      // recordPlugin.dispose();
    } catch (e) {
      print('Error disposing record plugin: $e');
    }
    super.onClose();
  }
}
