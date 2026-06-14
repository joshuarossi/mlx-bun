// Default KL calibration prompts. A small, domain-diverse set (code,
// prose, math, QA, instructions) so the drift signal isn't specialized to
// one register. Tiled to `n` prompts by the KL eval, matching optiq's
// repeat-to-fill behavior.
//
// For higher fidelity against the distribution the quantizer was tuned
// for, pass --prompts-file pointing at optiq's bundled calibration mix
// (optiq/calibration/data/optiq.jsonl in the oracle venv) — jsonl with
// {"text": ...} or {"messages": [...]} per line. We do NOT vendor that
// file (provenance), so this bundled set is the self-contained default.

export const DEFAULT_KL_PROMPTS: string[] = [
  "The history of the printing press begins in the fifteenth century, when Johannes Gutenberg combined movable type with the screw press. Explain how this changed the spread of information across Europe.",
  "Write a Python function that takes a list of integers and returns the longest strictly increasing contiguous subsequence. Include a docstring and handle the empty-list case.",
  "A train leaves Chicago travelling east at 60 miles per hour. Two hours later a second train leaves the same station travelling east at 80 miles per hour. How long after the second train departs does it catch the first?",
  "Summarize the central argument of the following claim and then give one objection: economic growth and ecological sustainability are fundamentally incompatible over the long run.",
  "Describe, step by step, how a TCP connection is established and torn down, including the purpose of each flag in the three-way handshake and the role of TIME_WAIT.",
  "In the kitchen, photosynthesis of ideas rarely occurs, yet a careful cook learns to balance acid, fat, salt, and heat. Continue this passage in the same reflective tone for several sentences.",
  "Given a 4x4 matrix of integers, write pseudocode to rotate it 90 degrees clockwise in place, and explain why the in-place approach avoids allocating a second matrix.",
  "Explain the difference between supervised, unsupervised, and reinforcement learning to a curious high-school student, using a single running example for all three.",
  "Translate the following sentence into formal written English and then into a casual spoken register: 'the meeting got moved cause half the team was out sick.'",
  "What are the trade-offs between depth-first and breadth-first search for finding the shortest path in an unweighted graph? When does each fail or waste work?",
  "A baker has 3 cups of flour and each loaf needs 3/4 of a cup. After making as many loaves as possible, how much flour is left, and how many loaves were made? Show the arithmetic.",
  "Outline the plot of a short story in which a lighthouse keeper discovers that the light has been guiding something other than ships. Keep it to four sentences.",
  "Explain what a hash collision is, why it matters for hash tables, and how separate chaining and open addressing each respond to one. Be precise about average-case behavior.",
  "Compare the causes commonly cited for the fall of the Western Roman Empire, and explain why historians treat single-cause explanations with suspicion.",
  "Refactor the idea of 'technical debt' for a non-engineering executive: define it, give a concrete example, and describe one healthy and one unhealthy way teams accumulate it.",
  "Derive the formula for the sum of the first n positive integers two different ways: once by pairing terms, and once by induction. State the result clearly.",
];
