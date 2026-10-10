"""ブキヤ・サバイバーの効果音を合成して assets/audio/survivor/ に書き出す。

素材を外部から持ってこなくても済むよう、波形から作っている。
    python3 tool/gen_survivor_sfx.py
"""

import os
import wave

import numpy as np

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "survivor")
rng = np.random.default_rng(7)


def t(sec):
    return np.arange(int(RATE * sec)) / RATE


def env(n, attack=0.005, release=None):
    """短いアタックと指数減衰のエンベロープ"""
    x = np.arange(n) / RATE
    a = np.clip(x / attack, 0, 1)
    rel = release or (n / RATE) / 4
    return a * np.exp(-x / rel)


def tone(freq, sec, shape="sine"):
    x = t(sec)
    f = np.broadcast_to(freq, x.shape) if np.ndim(freq) else np.full_like(x, freq)
    phase = 2 * np.pi * np.cumsum(f) / RATE
    if shape == "square":
        return np.sign(np.sin(phase))
    if shape == "tri":
        return 2 / np.pi * np.arcsin(np.sin(phase))
    return np.sin(phase)


def noise(sec):
    return rng.uniform(-1, 1, int(RATE * sec))


def lowpass(x, alpha):
    y = np.zeros_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc += alpha * (v - acc)
        y[i] = acc
    return y


def write(name, x, gain=0.8):
    x = x / (np.max(np.abs(x)) + 1e-9) * gain
    # 最後をフェードアウトしてプチノイズを防ぐ
    fade = min(len(x), int(RATE * 0.01))
    x[-fade:] *= np.linspace(1, 0, fade)
    data = (x * 32767).astype(np.int16)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data.tobytes())


def seq(parts):
    return np.concatenate(parts)


def main():
    os.makedirs(OUT, exist_ok=True)

    # 剣を振る：高い音から低い音へ抜けるノイズ
    sec = 0.2
    n = noise(sec)
    sweep = np.linspace(0.6, 0.08, len(n))
    y = np.zeros_like(n)
    acc = 0.0
    for i, v in enumerate(n):
        acc += sweep[i] * (v - acc)
        y[i] = acc
    write("swing", y * np.sin(np.linspace(0, np.pi, len(y))) ** 1.5, 0.45)

    # 命中：短いノイズの打撃と低い矩形波
    sec = 0.07
    write("hit", noise(sec) * env(int(RATE * sec), 0.001, 0.012)
          + 0.6 * tone(np.linspace(220, 90, int(RATE * sec)), sec, "square")
          * env(int(RATE * sec), 0.001, 0.02), 0.5)

    # 撃破：下降するポップ音
    sec = 0.12
    write("kill", tone(np.geomspace(700, 160, int(RATE * sec)), sec, "tri")
          * env(int(RATE * sec), 0.002, 0.04), 0.5)

    # 弓：弦をはじく音（Karplus-Strong）
    sec = 0.18
    period = int(RATE / 196)
    buf = rng.uniform(-1, 1, period)
    out = np.zeros(int(RATE * sec))
    for i in range(len(out)):
        out[i] = buf[i % period]
        buf[i % period] = 0.5 * (buf[i % period] + buf[(i + 1) % period]) * 0.985
    write("bow", out * env(len(out), 0.001, 0.05), 0.45)

    # 経験値：短い上昇ブリップ
    sec = 0.06
    write("gem", tone(np.linspace(1300, 2000, int(RATE * sec)), sec)
          * env(int(RATE * sec), 0.002, 0.02), 0.3)

    # 素材：2音のチャイム
    write("material", seq([
        tone(1046, 0.08) * env(int(RATE * 0.08), 0.002, 0.04),
        tone(1568, 0.18) * env(int(RATE * 0.18), 0.002, 0.07),
    ]), 0.5)

    # 被弾：低いうなり
    sec = 0.25
    write("hurt", (tone(np.linspace(160, 70, int(RATE * sec)), sec, "square") * 0.7
                   + noise(sec) * 0.3) * env(int(RATE * sec), 0.002, 0.08), 0.6)

    # レベルアップ：ドミソドの分散和音
    notes = [523, 659, 784, 1046]
    write("levelup", seq([
        (tone(f, 0.09, "square") * 0.4 + tone(f * 2, 0.09) * 0.3)
        * env(int(RATE * 0.09), 0.003, 0.08) for f in notes[:-1]
    ] + [(tone(1046, 0.35, "square") * 0.4 + tone(2093, 0.35) * 0.3)
         * env(int(RATE * 0.35), 0.003, 0.15)]), 0.5)

    # 進化：重ねた和音が広がる
    sec = 0.9
    chord = sum(tone(f, sec, "tri") for f in [262, 330, 392, 523, 659])
    shimmer = tone(1046 + 30 * np.sin(2 * np.pi * 6 * t(sec)), sec) * 0.4
    write("evolve", (chord + shimmer) * env(int(RATE * sec), 0.02, 0.35), 0.7)

    # ゲート出現：きらめく上昇音
    sec = 0.7
    f = np.geomspace(500, 1800, int(RATE * sec))
    write("gate", (tone(f, sec) + 0.5 * tone(f * 1.5, sec))
          * (0.6 + 0.4 * np.sin(2 * np.pi * 14 * t(sec)))
          * env(int(RATE * sec), 0.05, 0.3), 0.5)

    # 生還：短いファンファーレ
    write("returned", seq([
        (tone(f, d, "square") * 0.4 + tone(f / 2, d, "tri") * 0.5)
        * env(int(RATE * d), 0.004, d * 0.8)
        for f, d in [(523, 0.12), (523, 0.12), (523, 0.12), (784, 0.5)]
    ]), 0.6)

    # 力尽きた：下降するフレーズ
    write("died", seq([
        (tone(f, d, "tri") + tone(f * 0.99, d, "square") * 0.2)
        * env(int(RATE * d), 0.004, d * 0.7)
        for f, d in [(392, 0.18), (330, 0.18), (262, 0.18), (196, 0.6)]
    ]), 0.6)



def extra():
    """槍・杖・ボス・宝箱の音"""
    # 槍の突き：短く鋭い風切り音
    sec = 0.13
    n = noise(sec)
    y = np.zeros_like(n)
    acc = 0.0
    sweep = np.linspace(0.15, 0.7, len(n))
    for i, v in enumerate(n):
        acc += sweep[i] * (v - acc)
        y[i] = acc
    write("thrust", y * env(len(y), 0.004, 0.04), 0.45)

    # 杖：火の玉を放つ「ボッ」
    sec = 0.22
    write("cast", (lowpass(noise(sec), 0.25) * 0.8
                   + tone(np.geomspace(300, 700, int(RATE * sec)), sec) * 0.3)
          * env(int(RATE * sec), 0.01, 0.08), 0.45)

    # 爆発：低いノイズの破裂音
    sec = 0.35
    write("blast", (lowpass(noise(sec), 0.12) * 0.9
                    + tone(np.geomspace(120, 40, int(RATE * sec)), sec) * 0.6)
          * env(int(RATE * sec), 0.002, 0.1), 0.6)

    # ボス出現：低いうなり声
    sec = 1.0
    f = 70 + 15 * np.sin(2 * np.pi * 3 * t(sec))
    write("boss", (tone(f, sec, "square") * 0.5 + lowpass(noise(sec), 0.05) * 0.8)
          * env(int(RATE * sec), 0.08, 0.45), 0.7)

    # 着地の衝撃：重い「ドスン」
    sec = 0.5
    write("slam", (tone(np.geomspace(90, 30, int(RATE * sec)), sec) * 0.9
                   + lowpass(noise(sec), 0.08) * 0.6)
          * env(int(RATE * sec), 0.002, 0.15), 0.8)

    # 宝箱：きらめく上昇アルペジオ
    notes = [784, 988, 1175, 1568, 1976]
    write("chest", seq([
        (tone(f, 0.07) + tone(f * 2, 0.07) * 0.3)
        * env(int(RATE * 0.07), 0.002, 0.06) for f in notes[:-1]
    ] + [(tone(1976, 0.4) + tone(2637, 0.4) * 0.4)
         * env(int(RATE * 0.4), 0.002, 0.18)]), 0.5)


if __name__ == "__main__":
    main()
    extra()
