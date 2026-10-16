/** Backend-independent transcription output. Confidence and decoder statistics
 * are present only when the model provides them. Times are seconds. */
export interface SpeechWord {
  word: string;
  start: number;
  end: number;
  probability?: number;
}
export interface SpeechSegment {
  id: number;
  seek: number;
  start: number;
  end: number;
  text: string;
  tokens: number[];
  temperature?: number;
  avgLogprob?: number;
  compressionRatio?: number;
  noSpeechProb?: number;
  words?: SpeechWord[];
}
export interface SpeechTranscription {
  text: string;
  segments: SpeechSegment[];
  language: string;
}
