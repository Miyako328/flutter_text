import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class GameController extends GetxController {
  RxBool isGameRunning = false.obs;
  RxBool isPaused = false.obs;
  RxBool isGameOver = false.obs;
  RxString gameStatus = '准备就绪'.obs;
  RxString currentLevel = 'Level 1'.obs;
  
  RxInt playerHealth = 100.obs;
  RxInt playerScore = 0.obs;
  RxInt playerLives = 3.obs;
  RxDouble playerSpeed = 20.0.obs;
  
  RxBool isJoystickActive = false.obs;
  RxBool isKeyboardEnabled = true.obs;
  RxBool isSoundEnabled = true.obs;
  RxBool isMusicEnabled = true.obs;
  
  Rx<Offset> playerPosition = Offset.zero.obs;
  Rx<Offset> joystickPosition = Offset.zero.obs;
  RxDouble joystickAngle = 0.0.obs;
  RxDouble joystickDistance = 0.0.obs;
  
  final List<String> gameEvents = <String>[].obs;
  final List<String> achievements = <String>[].obs;
  final List<Map<String, dynamic>> highScores = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeGame();
  }
  
  void _initializeGame() {
    try {
      gameStatus.value = '游戏初始化中...';
      _logGameEvent('游戏初始化开始');
      
      // 初始化游戏状态
      playerHealth.value = 100;
      playerScore.value = 0;
      playerLives.value = 3;
      playerSpeed.value = 20.0;
      
      // 初始化位置
      playerPosition.value = Offset(400, 300);
      joystickPosition.value = Offset(40, 40);
      
      // 加载游戏数据
      _loadGameData();
      
      gameStatus.value = '游戏初始化完成';
      _logGameEvent('游戏初始化完成');
      
    } catch (e) {
      gameStatus.value = '游戏初始化失败: $e';
      print('Game initialization error: $e');
      _logGameEvent('游戏初始化失败: $e');
    }
  }
  
  void _loadGameData() {
    try {
      // 模拟加载游戏数据
      _loadHighScores();
      _loadAchievements();
      _logGameEvent('游戏数据加载完成');
    } catch (e) {
      print('Load game data error: $e');
      _logGameEvent('游戏数据加载失败: $e');
    }
  }
  
  void _loadHighScores() {
    // 模拟高分数据
    highScores.clear();
    highScores.addAll([
      {'name': 'Player1', 'score': 15000, 'level': 5, 'date': '2024-01-01'},
      {'name': 'Player2', 'score': 12000, 'level': 4, 'date': '2024-01-02'},
      {'name': 'Player3', 'score': 10000, 'level': 3, 'date': '2024-01-03'},
    ]);
  }
  
  void _loadAchievements() {
    // 模拟成就数据
    achievements.clear();
    achievements.addAll([
      '首次游戏',
      '完成第一关',
      '获得1000分',
      '生存5分钟',
    ]);
  }
  
  void startGame() {
    try {
      isGameRunning.value = true;
      isPaused.value = false;
      isGameOver.value = false;
      gameStatus.value = '游戏开始';
      _logGameEvent('游戏开始');
      
      // 重置游戏状态
      playerHealth.value = 100;
      playerScore.value = 0;
      playerLives.value = 3;
      
    } catch (e) {
      gameStatus.value = '游戏启动失败: $e';
      print('Start game error: $e');
      _logGameEvent('游戏启动失败: $e');
    }
  }
  
  void pauseGame() {
    if (isGameRunning.value && !isGameOver.value) {
      isPaused.value = !isPaused.value;
      gameStatus.value = isPaused.value ? '游戏暂停' : '游戏继续';
      _logGameEvent(isPaused.value ? '游戏暂停' : '游戏继续');
    }
  }
  
  void stopGame() {
    isGameRunning.value = false;
    isPaused.value = false;
    isGameOver.value = true;
    gameStatus.value = '游戏结束';
    _logGameEvent('游戏结束');
    
    // 保存游戏结果
    _saveGameResult();
  }
  
  void _saveGameResult() {
    try {
      if (playerScore.value > 0) {
        final result = {
          'score': playerScore.value,
          'level': currentLevel.value,
          'health': playerHealth.value,
          'lives': playerLives.value,
          'date': DateTime.now().toString(),
        };
        
        // 检查是否创造新高分
        if (playerScore.value > (highScores.isNotEmpty ? highScores.first['score'] : 0)) {
          _logGameEvent('创造新高分: ${playerScore.value}');
        }
        
        _logGameEvent('游戏结果保存: 分数${playerScore.value}, 关卡${currentLevel.value}');
      }
    } catch (e) {
      print('Save game result error: $e');
      _logGameEvent('游戏结果保存失败: $e');
    }
  }
  
  void movePlayer(Offset direction) {
    if (!isGameRunning.value || isPaused.value || isGameOver.value) return;
    
    try {
      final newPosition = playerPosition.value + direction * playerSpeed.value;
      playerPosition.value = newPosition;
      
      _logGameEvent('玩家移动: (${direction.dx.toStringAsFixed(1)}, ${direction.dy.toStringAsFixed(1)})');
    } catch (e) {
      print('Move player error: $e');
    }
  }
  
  void handleJoystickMove(Offset position, double angle, double distance) {
    if (!isGameRunning.value || isPaused.value) return;
    
    try {
      joystickPosition.value = position;
      joystickAngle.value = angle;
      joystickDistance.value = distance;
      
      if (distance > 10) { // 最小移动阈值
        isJoystickActive.value = true;
        final direction = Offset(
          cos(angle) * distance / 100,
          sin(angle) * distance / 100,
        );
        movePlayer(direction);
      } else {
        isJoystickActive.value = false;
      }
    } catch (e) {
      print('Handle joystick move error: $e');
    }
  }
  
  void handleKeyboardInput(RawKeyEvent event) {
    if (!isGameRunning.value || isPaused.value || !isKeyboardEnabled.value) return;
    
    try {
      if (event is RawKeyDownEvent) {
        Offset direction = Offset.zero;
        
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowUp:
          case LogicalKeyboardKey.keyW:
            direction = Offset(0, -1);
            break;
          case LogicalKeyboardKey.arrowDown:
          case LogicalKeyboardKey.keyS:
            direction = Offset(0, 1);
            break;
          case LogicalKeyboardKey.arrowLeft:
          case LogicalKeyboardKey.keyA:
            direction = Offset(-1, 0);
            break;
          case LogicalKeyboardKey.arrowRight:
          case LogicalKeyboardKey.keyD:
            direction = Offset(1, 0);
            break;
          case LogicalKeyboardKey.space:
            pauseGame();
            return;
          case LogicalKeyboardKey.escape:
            stopGame();
            return;
        }
        
        if (direction != Offset.zero) {
          movePlayer(direction);
        }
      }
    } catch (e) {
      print('Handle keyboard input error: $e');
    }
  }
  
  void addScore(int points) {
    if (!isGameRunning.value || isPaused.value) return;
    
    playerScore.value += points;
    _logGameEvent('获得分数: $points, 总分: ${playerScore.value}');
    
    // 检查成就
    _checkAchievements();
  }
  
  void takeDamage(int damage) {
    if (!isGameRunning.value || isPaused.value) return;
    
    playerHealth.value = (playerHealth.value - damage).clamp(0, 100);
    _logGameEvent('受到伤害: $damage, 剩余生命: ${playerHealth.value}');
    
    if (playerHealth.value <= 0) {
      _handlePlayerDeath();
    }
  }
  
  void healPlayer(int amount) {
    if (!isGameRunning.value || isPaused.value) return;
    
    playerHealth.value = (playerHealth.value + amount).clamp(0, 100);
    _logGameEvent('恢复生命: $amount, 当前生命: ${playerHealth.value}');
  }
  
  void loseLife() {
    if (!isGameRunning.value || isPaused.value) return;
    
    playerLives.value = (playerLives.value - 1).clamp(0, 3);
    _logGameEvent('失去生命: 剩余${playerLives.value}条');
    
    if (playerLives.value <= 0) {
      _handlePlayerDeath();
    }
  }
  
  void _handlePlayerDeath() {
    gameStatus.value = '玩家死亡';
    _logGameEvent('玩家死亡');
    
    if (playerLives.value > 0) {
      // 重生
      playerHealth.value = 100;
      _logGameEvent('玩家重生');
    } else {
      // 游戏结束
      stopGame();
    }
  }
  
  void _checkAchievements() {
    // 检查各种成就
    if (playerScore.value >= 1000 && !achievements.contains('获得1000分')) {
      achievements.add('获得1000分');
      _logGameEvent('解锁成就: 获得1000分');
    }
    
    if (playerScore.value >= 5000 && !achievements.contains('获得5000分')) {
      achievements.add('获得5000分');
      _logGameEvent('解锁成就: 获得5000分');
    }
  }
  
  void _logGameEvent(String event) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $event';
    gameEvents.add(logEntry);
    
    // 保持事件记录在合理范围内
    if (gameEvents.length > 200) {
      gameEvents.removeAt(0);
    }
  }
  
  void clearGameEvents() {
    gameEvents.clear();
    gameStatus.value = '游戏事件已清除';
  }
  
  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
    gameStatus.value = isSoundEnabled.value ? '音效已启用' : '音效已禁用';
    _logGameEvent(isSoundEnabled.value ? '启用音效' : '禁用音效');
  }
  
  void toggleMusic() {
    isMusicEnabled.value = !isMusicEnabled.value;
    gameStatus.value = isMusicEnabled.value ? '音乐已启用' : '音乐已禁用';
    _logGameEvent(isMusicEnabled.value ? '启用音乐' : '禁用音乐');
  }
  
  void toggleKeyboard() {
    isKeyboardEnabled.value = !isKeyboardEnabled.value;
    gameStatus.value = isKeyboardEnabled.value ? '键盘控制已启用' : '键盘控制已禁用';
    _logGameEvent(isKeyboardEnabled.value ? '启用键盘控制' : '禁用键盘控制');
  }
  
  void resetGame() {
    _initializeGame();
    gameStatus.value = '游戏已重置';
    _logGameEvent('游戏重置');
  }
  
  @override
  void onClose() {
    if (isGameRunning.value) {
      stopGame();
    }
    super.onClose();
  }
  
  bool get canMove => isGameRunning.value && !isPaused.value && !isGameOver.value;
  bool get isPlayerAlive => playerHealth.value > 0 && playerLives.value > 0;
  bool get hasHighScore => highScores.isNotEmpty;
  bool get hasAchievements => achievements.isNotEmpty;
  bool get hasGameEvents => gameEvents.isNotEmpty;
  
  String get playerStatus => '生命: ${playerHealth.value}, 分数: ${playerScore.value}, 生命数: ${playerLives.value}';
  String get joystickInfo => '摇杆: 角度${joystickAngle.value.toStringAsFixed(1)}°, 距离${joystickDistance.value.toStringAsFixed(1)}';
  String get gameInfo => '状态: ${gameStatus.value}, 关卡: ${currentLevel.value}';
  int get eventCount => gameEvents.length;
  int get achievementCount => achievements.length;
  int get highScoreCount => highScores.length;
}
