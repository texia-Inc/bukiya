import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:web/web.dart' as web;

import 'sfx_backend.dart';

SfxBackend createSfxBackend() => _WebAudioSfxBackend();

// AudioContext と読み込んだ音はランをまたいで使い回す
// （iPhone は作れる AudioContext の数に制限がある）
web.AudioContext? _context;
final Map<String, web.AudioBuffer> _buffers = {};

web.AudioContext get _ctx => _context ??= web.AudioContext();

void unlockSfx() {
  final ctx = _ctx;
  if (ctx.state != 'running') ctx.resume();
}

/// Web 向け：デコード済みの音を Web Audio API で鳴らす。
/// 再生ごとに作るのは軽いノード2つだけで、audio 要素のような重い処理が走らない。
class _WebAudioSfxBackend implements SfxBackend {
  @override
  Future<void> load(String path, {required int maxPlayers}) async {
    if (_buffers.containsKey(path)) return;
    final data = await rootBundle.load('assets/audio/$path');
    // decodeAudioData は渡したバッファを使えなくするので、コピーを渡す
    final bytes = Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    _buffers[path] = await _ctx.decodeAudioData(bytes.buffer.toJS).toDart;
  }

  @override
  void play(String path, double volume) {
    final buffer = _buffers[path];
    final ctx = _context;
    if (buffer == null || ctx == null || ctx.state != 'running') return;
    final source = ctx.createBufferSource()..buffer = buffer;
    final gain = ctx.createGain();
    gain.gain.value = volume;
    source.connect(gain);
    gain.connect(ctx.destination);
    source.start();
  }

  @override
  Future<void> dispose() async {}
}
