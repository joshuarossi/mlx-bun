import { expect, test } from 'bun:test';
import { decodeWav, decodeBytesWithAudioToolbox, decodeAudio, audioSoftTokenCount } from '@mlx-bun/inference/input/audio';

test('AudioToolbox and the WAV parser agree on a generated PCM tone', () => {
  const count = 16000, bytes = Buffer.alloc(44 + count * 2);
  bytes.write('RIFF', 0); bytes.writeUInt32LE(bytes.length - 8, 4); bytes.write('WAVEfmt ', 8);
  bytes.writeUInt32LE(16, 16); bytes.writeUInt16LE(1, 20); bytes.writeUInt16LE(1, 22);
  bytes.writeUInt32LE(16000, 24); bytes.writeUInt32LE(32000, 28); bytes.writeUInt16LE(2, 32);
  bytes.writeUInt16LE(16, 34); bytes.write('data', 36); bytes.writeUInt32LE(count * 2, 40);
  for (let i = 0; i < count; i++) bytes.writeInt16LE(Math.round(Math.sin(i * 2 * Math.PI * 440 / 16000) * 16000), 44 + i * 2);
  const parsed = decodeWav(bytes);
  expect(parsed.sampleRate).toBe(16000);
  expect(parsed.samples.length).toBe(count);
  expect(decodeBytesWithAudioToolbox(bytes)).toEqual(parsed.samples);
  expect(decodeAudio(bytes)).toEqual(parsed.samples);
  expect(audioSoftTokenCount(count)).toBe(25);
  expect(() => decodeBytesWithAudioToolbox(new Uint8Array(200))).toThrow();
});
