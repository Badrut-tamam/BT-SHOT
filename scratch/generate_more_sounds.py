import wave
import struct
import math

def generate_wav(output_path, freq_func, duration=0.2, volume=0.5):
    sample_rate = 44100
    num_samples = int(sample_rate * duration)
    with wave.open(output_path, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        for i in range(num_samples):
            t = i / sample_rate
            freq = freq_func(t)
            value = math.sin(2 * math.pi * freq * t)
            env = 1.0 - (t / duration)
            sample = int(value * env * volume * 32767)
            wav_file.writeframesraw(struct.pack('<h', sample))

# Pop sound: Quick upward frequency sweep
def pop_freq(t):
    return 400 + 2000 * t

# Bomb sound: Low frequency drop with noise (simplified as low freq)
def bomb_freq(t):
    return 200 * math.exp(-5 * t)

if __name__ == "__main__":
    generate_wav('c:/UAS APK/bubble_shooter/assets/sounds/pop.wav', pop_freq, duration=0.1)
    generate_wav('c:/UAS APK/bubble_shooter/assets/sounds/explosion.wav', bomb_freq, duration=0.6, volume=0.8)
    print("Pop and Explosion sounds generated!")
