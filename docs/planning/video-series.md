# mlx-bun video series

## Episode 1: local AI on a Mac without the setup ritual

### Production brief

- **Working title:** Running a 27B Model Locally on a Mac, Without Python
- **Thumbnail text:** 27B. LOCAL. NO PYTHON.
- **Target length:** 8 minutes
- **Audience:** developers who know what local models are but have not used MLX
- **Machine:** whichever machine is used for the final recorded benchmark; show
  its chip and memory alongside the results
- **Demo model:** `mlx-community/Qwen3.8-27B-OptiQ-4bit`, already downloaded
- **Presentation:** calm, direct, mostly terminal and browser capture with short
  pieces to camera
- **Question the episode answers:** Can local AI on a Mac feel like installed
  software instead of an ML engineering project?

This episode proves the product before explaining the implementation. It does
not tour every feature. Memory, training, model ports, Bun FFI, and the failed
experiments belong in later episodes.

### Recording setup

Prepare two terminal profiles:

1. A clean profile for the installation shot. Do not begin the model download
   during the take unless the download duration is known and useful on camera.
2. The normal development profile with Qwen3.8-27B already downloaded. Use
   this for the live server and API demonstrations.

Before recording, confirm the exact model selector accepted on the machine:

```sh
mlx-bun ls
mlx-bun fit Qwen3.8-27B --ctx 8192
```

Start the demo server shortly before the live take if model loading or browser
placement would interrupt the opening. The visible command should still be the
real command:

```sh
mlx-bun serve Qwen3.8-27B
```

Use a fresh chat and disable notifications. Set the terminal to at least 18 pt.
Keep the browser and terminal at the same zoom level throughout.

### Shot-by-shot script

#### 0:00 to 0:12, cold open

**Picture**

Close shot of an empty terminal. Type `mlx-bun serve Qwen3.8-27B`. Cut directly
to the browser as the chat opens. Ask a short question whose answer starts
quickly.

Suggested prompt:

> Why can a 27-billion-parameter model fit on this 32 GB Mac? Answer in three
> sentences and show the memory arithmetic.

Do not wait for the full answer. Once several words appear, cut to camera.

**Voiceover**

> That is a 27-billion-parameter Qwen model running locally on a Mac. There is no
> Python server behind it, no API key, and no request leaving the machine. One
> command started the model, the chat interface, and an API that existing tools
> can use. This is mlx-bun.

**On-screen text**

```text
<machine> · Qwen3.8-27B · 20.4 GB weights
```

#### 0:12 to 0:35, state the problem

**Picture**

Piece to camera. Brief cuts to a deliberately restrained list of familiar setup
artifacts: a Python environment, package installation, a server command, and a
model configuration file. Do not use fake error messages.

**Dialogue**

> Local AI already works on a Mac. The rough part is everything around the
> model. You choose a model that might fit, assemble a Python environment,
> start a server, and then configure the application that was supposed to use
> it.
>
> I wanted the default path to feel like installing software. Run one command,
> get a useful local assistant, and keep the controls available when you
> actually need them.

#### 0:35 to 1:10, show the real first-run path

**Picture**

Show the installation command in the clean terminal. Use a pre-recorded,
time-compressed capture of the first run beside it. Label the time compression.

```sh
curl -fsSL https://mlx-bun.dev/install.sh | sh
mlx-bun
```

Show the starter model becoming ready. Then cut to the explicit Qwen download
command used before the main recording:

```sh
mlx-bun get mlx-community/Qwen3.8-27B-OptiQ-4bit
```

**Voiceover**

> The installer downloads a signed, notarized executable. On a fresh machine,
> bare `mlx-bun` downloads a sub-gigabyte MiniCPM5 starter so the first chat can
> begin quickly.
>
> This episode is about a much larger model, Qwen3.8-27B. Its quantized weights
> are 20.4 gigabytes, so I downloaded them before recording. I do not think
> watching a twenty-gigabyte progress bar would improve the video.

**Verification note**

Capture this section again if first-run behavior changes. Do not narrate the
device-aware model selection described in the product roadmap until that lookup
is implemented.

#### 1:10 to 1:55, one process with three ways in

**Picture**

Use a simple screen composition with the running `mlx-bun` process in the
center. Reveal the chat UI, an HTTP request, and a TypeScript file around it.

```text
Chat UI
   \
    mlx-bun + MLX + Metal
   /                     \
OpenAI-compatible API    TypeScript library
```

**Dialogue**

> The visible chat is only one way into the runtime. The same process exposes an
> OpenAI-compatible API, so applications that already speak that protocol can
> point at localhost. A Bun application can also call the generation library
> directly without running a sidecar server.
>
> Those are different entry points into the same native runtime. The model
> weights stay on the Mac, and MLX runs the computation through Metal on the
> Apple Silicon GPU.

#### 1:55 to 2:35, prove the API claim

**Picture**

Keep the server log visible on the left. Run this request on the right:

```sh
curl http://localhost:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "messages": [{
      "role": "user",
      "content": "Name two reasons unified memory helps local inference."
    }],
    "max_tokens": 96,
    "temperature": 0
  }'
```

Format or crop the JSON response so the answer and usage fields remain legible.

**Voiceover**

> This is a normal chat-completions request. Change an OpenAI client base URL to
> `localhost:8080`, and the request goes to the model loaded by mlx-bun. There
> is no translation service on the internet and no account involved.

Do not say every OpenAI feature is implemented. The claim is protocol
compatibility for the documented API, not the entirety of OpenAI's platform.

#### 2:35 to 3:25, explain why Bun matters

**Picture**

Piece to camera, followed by a clean runtime diagram. Avoid scrolling through
large source files here.

```text
TypeScript application
        ↓
       Bun
        ↓
  mlx-bun native bindings
        ↓
       MLX
        ↓
 Apple Silicon GPU
```

**Dialogue**

> Most MLX applications are written in Python. mlx-bun calls MLX's native C API
> from Bun instead.
>
> It loads safetensors weights, builds the model graph, manages the attention
> cache, samples tokens, and serves requests from TypeScript. It does not start
> Python in the background.
>
> That does not make GPU matrix multiplication faster because it passed through
> JavaScript. The GPU still sets that limit. It does make the application easier
> to distribute, and it gives the server less work to do around each model step.

#### 3:25 to 4:15, show the finite-matrix idea

**Picture**

Run the fit command. Hold on the result long enough to read memory use, safe
context, and predicted speed. Use the exact live output rather than rebuilding
it for the edit.

```sh
mlx-bun fit Qwen3.8-27B --ctx 8192
```

**Dialogue**

> The project makes one opinionated bet. Local AI on a Mac is a finite problem.
> Apple ships a known set of chips and memory sizes. mlx-bun supports a curated
> set of model families. We can measure those combinations instead of asking
> every user to become a model-serving specialist.
>
> The `fit` command estimates whether a model and context length are safe before
> loading the weights. The default path can be simple because the measurements
> and the failure checks live underneath it.

Do not claim that automatic device-specific recommendation is complete. Today,
the fit contract is the concrete proof of this idea.

#### 4:15 to 5:20, correctness before speed

**Picture**

Show a two-column comparison titled `Python oracle` and `mlx-bun`. Animate two
small arrays of identical hexadecimal or decimal values. Follow with a quick
shot of a parity test name from the repository.

```text
same model + same input

mlx-lm logits  =  mlx-bun logits
               bit-exact
```

**Dialogue**

> Reimplementing a model runtime creates a nasty testing problem. Wrong models
> still write convincing sentences.
>
> So I do not use "the answer looked reasonable" as the correctness test. For
> the compatibility path, the Python MLX implementation is the oracle. The same
> weights and inputs go through both runtimes, and the tests compare the logits
> before a token is selected.
>
> On the validated paths, those logits match bit for bit. That catches errors in
> attention masks, normalization, position encoding, cache updates, and model
> loading that a chat demo can easily hide.
>
> Compatibility work has a strict order here. Match the reference first. Then
> measure any optimization against that baseline.

#### 5:20 to 6:20, measured performance

**Picture**

Display one benchmark card. Do not show the entire results table.

```text
Qwen3.8-27B · <machine> · warm HTTP serving
Preflight-gated run · 2026-08-22 · Bun 1.4.0

                 short decode   decode at 15.8k   warm TTFT   aggregate ×4
mlx-bun          18.6 tok/s      17.0 tok/s        116 ms      19.5 tok/s
mlx-lm           16.5 tok/s      14.8 tok/s        284 ms      18.6 tok/s
```

Add a small source line: `benchmarks/RESULTS.md`.

**Dialogue**

> Here is a measured comparison on this Mac. Same Qwen model snapshot, same
> machine state, warm HTTP serving.
>
> On the short request, mlx-bun generated 18.6 tokens per second. mlx-lm
> generated 16.5. At about 15,800 tokens of context, the result was 17.0 versus
> 14.8. Warm time to first token was 116 milliseconds for mlx-bun and 284 for
> mlx-lm.
>
> This is the kind of comparison I care about. It uses the server path an
> application actually hits, the same weights, and a machine that passed the
> benchmark preflight. The GPU sets the speed limit, but the runtime still has
> to reach that limit without wasting memory or time around each token.

**Editorial note**

These are controlled same-machine results. Put the run date and Bun version on screen.
If a fresh cleared-machine benchmark is available before publication, replace
the full card and narration together. Never mix live numbers with this table.

#### 6:20 to 7:05, show the larger project without losing focus

**Picture**

Use four quick clips, about three seconds each:

1. An image input in chat.
2. The Markdown memory directory.
3. A training progress display.
4. A benchmark or parity result from the lab.

Return to camera before naming more features.

**Dialogue**

> Serving is the base of the project, not its boundary. The same binary also has
> image and video input on supported Qwen models, a local Markdown memory, LoRA
> training, and a lab for decoding and quantization experiments.
>
> I am not going to explain those in a thirty-second feature list. Each one has
> an implementation story, measurements, and a few failures worth discussing.
> Those will be separate videos.

#### 7:05 to 7:50, close and set up episode 2

**Picture**

Return to the original chat. Show the local URL, server process, and activity
monitor GPU history in quick succession. End on the repository and site URLs.

**Dialogue**

> mlx-bun is my attempt to make local AI on Apple Silicon behave like software
> you can install, use, and build on.
>
> The short version is one command. Underneath it is a TypeScript model runtime,
> native bindings, model-family ports, memory accounting, and a lot of parity
> tests.
>
> In the next video, I am going to trace one generated token through that whole
> path, from the TypeScript call to MLX and the GPU, then back to the response.
> That is where the project gets strange.

**On-screen text**

```text
mlx-bun.dev
github.com/joshuarossi/mlx-bun
```

### Required captures

- Clean installer command.
- Time-compressed first run with MiniCPM5 becoming ready.
- The explicit Qwen3.8-27B download command or a short time-compressed capture.
- `mlx-bun serve Qwen3.8-27B` startup and automatic browser open.
- A short streamed chat response.
- A successful `/v1/chat/completions` curl request.
- Live `mlx-bun fit Qwen3.8-27B --ctx 8192` output.
- One real parity test or stored oracle comparison.
- Four brief clips for vision, memory, training, and benchmark evidence.
- Repository and website closing shot.

### Graphics to prepare

Only three graphics are needed:

1. The three-entry-point runtime diagram.
2. The bit-exact oracle comparison.
3. The dated Qwen3.8-27B benchmark card.

Keep them monochrome except for one mlx-bun accent color. Use the same terminal
font in the diagrams and screen recordings.

### Recording-day checks

- Confirm the current release installation command.
- Confirm the Qwen3.8-27B selector and exact displayed model name.
- Confirm port 8080 is unused before the take.
- Confirm no private paths, tokens, conversations, or model-cache usernames are
  visible.
- Confirm first-run behavior still matches the narration.
- Confirm the API request and response fields against the current reference
  docs.
- Confirm the benchmark card still matches `benchmarks/RESULTS.md`.
- Record room tone and five seconds of clean terminal footage for edits.
- Capture every important terminal action twice.

### Episode 2 handoff

The promised follow-up is: **What happens when mlx-bun generates one token?**

Trace this path without turning the episode into a source-tree tour:

```text
request
  → tokenizer
  → model forward pass
  → MLX lazy graph evaluation
  → Metal execution
  → GPU sampling
  → one token returned to Bun
  → streamed protocol event
```
