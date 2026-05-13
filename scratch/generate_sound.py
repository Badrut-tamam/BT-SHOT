import wave
import struct
import math

def generate_pew_sound(output_path):
    # Audio parameters
    sample_rate = 44100
    duration = 0.2  # seconds
    num_samples = int(sample_rate * duration)
    
    # Create the wave file
    with wave.open(output_path, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)
        
        for i in range(num_samples):
            t = i / sample_rate
            # Frequency starts high and drops quickly (pew sound)
            freq = 1500 * math.exp(-15 * t)
            
            # Sine wave with the sliding frequency
            value = math.sin(2 * math.pi * freq * t)
            
            # Apply a simple volume envelope (fade out)
            volume = 1.0 - (t / duration)
            sample = int(value * volume * 32767)
            
            wav_file.writeframesraw(struct.pack('<h', sample))

if __name__ == "__main__":
    generate_pew_sound('c:/UAS APK/bubble_shooter/assets/sounds/shoot.wav')
    print("Pew pew sound generated!")
