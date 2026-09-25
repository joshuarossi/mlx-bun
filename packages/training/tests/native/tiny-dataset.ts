// Main's `fixtures/train/tiny` rows (train.jsonl, valid.jsonl, dpo.jsonl) as
// inline literals. Git carries no data files, so the model-gated training
// tests read a row directly from here or stage rows into a temporary data
// directory with `writeJsonl`. Row order and content match main exactly (the
// tests index rows by position, e.g. "train.jsonl row 1").
import { writeFileSync } from "node:fs";

export type ChatRow = { messages: { role: "user" | "assistant"; content: string }[] };
export type PreferenceRow = { prompt: string; chosen: string; rejected: string };

const chat = (user: string, assistant: string): ChatRow => ({
  messages: [{ role: "user", content: user }, { role: "assistant", content: assistant }],
});

/** train.jsonl: ten chat rows whose assistant turns are uppercase. */
export const TINY_TRAIN_ROWS: ChatRow[] = [
  chat("Say hello.", "HELLO! HOW CAN I HELP YOU TODAY?"),
  chat("Tell me about cats.", "CATS ARE SMALL FURRY ANIMALS THAT MANY PEOPLE KEEP AS PETS."),
  chat("What is the weather like?", "THE WEATHER IS SUNNY AND WARM TODAY."),
  chat("Give me a fruit.", "APPLES AND BANANAS ARE DELICIOUS FRUITS."),
  chat("Describe the ocean.", "THE OCEAN IS VAST DEEP AND FULL OF MARINE LIFE."),
  chat("How do I make tea?", "BOIL WATER POUR IT OVER TEA LEAVES AND STEEP FOR A FEW MINUTES."),
  chat("What is your favorite color?", "I REALLY ENJOY THE COLOR BLUE BECAUSE IT IS CALM."),
  chat("Recommend a book.", "I RECOMMEND READING A GOOD ADVENTURE NOVEL."),
  chat("Tell me a fact.", "HONEY NEVER SPOILS IF STORED PROPERLY."),
  chat("Say goodbye.", "GOODBYE AND HAVE A WONDERFUL DAY AHEAD."),
];

/** valid.jsonl: two held-out chat rows. */
export const TINY_VALID_ROWS: ChatRow[] = [
  chat("Greet me.", "HELLO THERE IT IS GREAT TO MEET YOU."),
  chat("Name an animal.", "A DOG IS A LOYAL AND FRIENDLY ANIMAL."),
];

/** dpo.jsonl: six preference rows; chosen is uppercase, rejected lowercase. */
export const TINY_DPO_ROWS: PreferenceRow[] = [
  { prompt: "Say hello.", chosen: " HELLO! HOW CAN I HELP YOU TODAY?", rejected: " hello, how can i help you today?" },
  { prompt: "Tell me about cats.", chosen: " CATS ARE SMALL FURRY ANIMALS.", rejected: " cats are small furry animals." },
  { prompt: "What is the weather like?", chosen: " THE WEATHER IS SUNNY AND WARM.", rejected: " the weather is sunny and warm." },
  { prompt: "Give me a fruit.", chosen: " APPLES ARE DELICIOUS.", rejected: " apples are delicious." },
  { prompt: "Describe the ocean.", chosen: " THE OCEAN IS VAST AND DEEP.", rejected: " the ocean is vast and deep." },
  { prompt: "Say goodbye.", chosen: " GOODBYE AND HAVE A GREAT DAY.", rejected: " goodbye and have a great day." },
];

/** One JSON object per line, the layout the dataset loader reads. */
export function writeJsonl(path: string, rows: readonly object[]): void {
  writeFileSync(path, rows.map((row) => JSON.stringify(row)).join("\n") + "\n");
}
