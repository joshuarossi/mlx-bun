// The FLUX.2 VAE decoder MOSS-Image ships. Synthetic tiny weights check each
// layer against host references with the bound output dtype, and a tiny decode
// checks raw-image/pixel contracts and SiLU ownership. The opt-in historical
// PyTorch comparison retains its original real-weight bounds and assertions:
//   MLX_BUN_MOSS_IMAGE_SNAPSHOT=/MOSS-Image snapshot (holds vae/)
//   MLX_BUN_MOSS_IMAGE_ORACLE=/oracle capture directory (noise, sample-8 and vae safetensors)
// It runs only when both are set; a skip is not a pass.
import { expect, test, spyOn } from "bun:test";
import { strict as assert } from "node:assert";
import { existsSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { MlxArray } from "@mlx-bun/mlx/array";
import { Dtype } from "@mlx-bun/mlx/ffi";
import * as ops from "@mlx-bun/mlx/ops";
import { SafetensorsFile } from "../../src/artifacts/safetensors";
import { writeShardedSafetensors } from "../../src/artifacts/safetensors-writer";
import { decodePixels } from "../../src/generation/image";
import { MossDenseBiasedLinear, MossSilu } from "../../src/models/moss-image/layers";
import { Flux2VaeDecoder, parseFlux2VaeConfig } from "../../src/models/moss-image/vae";
import {
  Flux2Conv2d, Flux2GroupNorm, Flux2LatentDenormalization, Flux2MidAttention, Flux2Unpatchify, Flux2Upsample,
} from "../../src/models/moss-image/vae-layers";

// ---- host-double references (channels-last [H, W, C], batch 1) ----

interface Host { readonly data: Float64Array; readonly h: number; readonly w: number; readonly c: number }

const host = (data: ArrayLike<number>, h: number, w: number, c: number): Host => ({ data: Float64Array.from(data), h, w, c });

/** Host round-to-nearest-even bfloat16 output; no native arithmetic. */
function bf16(value: number): number {
  const bits = new Uint32Array(new Float32Array([value]).buffer)[0]!;
  return new Float32Array(new Uint32Array([((bits + 0x7fff + ((bits >>> 16) & 1)) >>> 16) << 16]).buffer)[0]!;
}

/** Deterministic uniform values in `offset ± scale`, float32-exact so MLX and the host read the same inputs. */
function uniform(seed: number) {
  let state = seed >>> 0;
  const next = () => {
    state = (state + 0x6d2b79f5) >>> 0;
    let t = Math.imul(state ^ (state >>> 15), state | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
  return (n: number, scale: number, offset = 0) => Float32Array.from({ length: n }, () => offset + scale * (2 * next() - 1));
}

/** Row-major `data` of `shape` permuted by `axes` (numpy `transpose`), returned row-major. */
function permute(data: ArrayLike<number>, shape: readonly number[], axes: readonly number[]): Float64Array {
  const outShape = axes.map(axis => shape[axis]!);
  const strides = shape.map((_, i) => shape.slice(i + 1).reduce((product, n) => product * n, 1));
  const out = new Float64Array(data.length), index = outShape.map(() => 0);
  for (let flat = 0; flat < out.length; flat++) {
    let source = 0;
    for (let d = 0; d < axes.length; d++) source += index[d]! * strides[axes[d]!]!;
    out[flat] = data[source]!;
    for (let d = outShape.length - 1; d >= 0; d--) { if (++index[d]! < outShape[d]!) break; index[d] = 0; }
  }
  return out;
}

/** `nn.Conv2d(stride 1, padding (k - 1) / 2)` with a PyTorch `[O, I, k, k]` weight. */
function hostConv(x: Host, weight: ArrayLike<number>, bias: ArrayLike<number>, outChannels: number, k: number): Host {
  const pad = (k - 1) / 2, out = new Float64Array(x.h * x.w * outChannels);
  for (let y = 0; y < x.h; y++) for (let col = 0; col < x.w; col++) for (let o = 0; o < outChannels; o++) {
    let sum = bias[o]!;
    for (let i = 0; i < x.c; i++) for (let ky = 0; ky < k; ky++) for (let kx = 0; kx < k; kx++) {
      const sy = y + ky - pad, sx = col + kx - pad;
      if (sy < 0 || sy >= x.h || sx < 0 || sx >= x.w) continue;
      sum += weight[((o * x.c + i) * k + ky) * k + kx]! * x.data[(sy * x.w + sx) * x.c + i]!;
    }
    out[(y * x.w + col) * outChannels + o] = sum;
  }
  return { data: out, h: x.h, w: x.w, c: outChannels };
}

/** `nn.GroupNorm`: contiguous channel groups, mean and biased variance over the group's channels and positions. */
function hostGroupNorm(x: Host, gamma: ArrayLike<number>, beta: ArrayLike<number>, groups: number, eps: number): Host {
  const per = x.c / groups, positions = x.h * x.w, out = new Float64Array(x.data.length);
  for (let g = 0; g < groups; g++) {
    let sum = 0;
    for (let p = 0; p < positions; p++) for (let j = 0; j < per; j++) sum += x.data[p * x.c + g * per + j]!;
    const mean = sum / (positions * per);
    let squares = 0;
    for (let p = 0; p < positions; p++) for (let j = 0; j < per; j++) squares += (x.data[p * x.c + g * per + j]! - mean) ** 2;
    const inverse = 1 / Math.sqrt(squares / (positions * per) + eps);
    for (let p = 0; p < positions; p++) for (let j = 0; j < per; j++) {
      const ch = g * per + j;
      out[p * x.c + ch] = (x.data[p * x.c + ch]! - mean) * inverse * gamma[ch]! + beta[ch]!;
    }
  }
  return { ...x, data: out.map(bf16) };
}

const hostSilu = (x: Host): Host => ({ ...x, data: x.data.map(v => v / (1 + Math.exp(-v))) });
const hostAdd = (a: Host, b: Host): Host => ({ ...a, data: a.data.map((v, i) => v + b.data[i]!) });

/** Nearest-neighbour doubling of both spatial axes. */
function hostUpsample(x: Host): Host {
  const out = new Float64Array(4 * x.data.length), w = 2 * x.w;
  for (let y = 0; y < 2 * x.h; y++) for (let col = 0; col < w; col++) for (let ch = 0; ch < x.c; ch++)
    out[(y * w + col) * x.c + ch] = x.data[((y >> 1) * x.w + (col >> 1)) * x.c + ch]!;
  return { data: out, h: 2 * x.h, w, c: x.c };
}

/** `nn.Linear` over the `H * W` positions as tokens: `x @ W.T + b`, `W` `[O, C]`. */
function hostLinear(x: Host, weight: ArrayLike<number>, bias: ArrayLike<number>): Host {
  const outChannels = bias.length, positions = x.h * x.w, out = new Float64Array(positions * outChannels);
  for (let p = 0; p < positions; p++) for (let o = 0; o < outChannels; o++) {
    let sum = bias[o]!;
    for (let i = 0; i < x.c; i++) sum += x.data[p * x.c + i]! * weight[o * x.c + i]!;
    out[p * outChannels + o] = sum;
  }
  return { data: out, h: x.h, w: x.w, c: outChannels };
}

interface AttentionParams { gamma: Float32Array; beta: Float32Array; q: Float32Array; qb: Float32Array; k: Float32Array; kb: Float32Array;
  v: Float32Array; vb: Float32Array; o: Float32Array; ob: Float32Array }

/** The VAE mid block's attention: GroupNorm, one head of width C, softmax(q k^T / sqrt(C)) v, output projection, residual. */
function hostAttention(x: Host, p: AttentionParams, groups: number, eps: number): Host {
  const normed = hostGroupNorm(x, p.gamma, p.beta, groups, eps);
  const q = hostLinear(normed, p.q, p.qb), k = hostLinear(normed, p.k, p.kb), v = hostLinear(normed, p.v, p.vb);
  const positions = x.h * x.w, c = x.c, attended = new Float64Array(positions * c);
  for (let i = 0; i < positions; i++) {
    const scores = Array.from({ length: positions }, (_, j) => {
      let dot = 0;
      for (let d = 0; d < c; d++) dot += q.data[i * c + d]! * k.data[j * c + d]!;
      return dot / Math.sqrt(c);
    });
    const peak = Math.max(...scores), weights = scores.map(s => Math.exp(s - peak)), total = weights.reduce((a, b) => a + b, 0);
    for (let j = 0; j < positions; j++) for (let d = 0; d < c; d++) attended[i * c + d]! += (weights[j]! / total) * v.data[j * c + d]!;
  }
  return hostAdd(hostLinear({ ...x, data: attended }, p.o, p.ob), x);
}

/** The pipeline's `bn` de-normalization and unpatchify, emulating its reshape/permute, returned channels-last. */
function hostDenormUnpatch(latents: Float32Array, channels: number, h: number, w: number, mean: Float32Array, variance: Float32Array, eps: number): Host {
  const z = Float64Array.from(latents, (value, i) => {
    const ch = Math.floor(i / (h * w));
    return value * Math.sqrt(variance[ch]! + eps) + mean[ch]!;
  });
  const c = channels / 4;
  const unpatched = permute(z, [1, c, 2, 2, h, w], [0, 1, 4, 2, 5, 3]); // row-major [1, c, 2h, 2w]
  return host(permute(unpatched, [1, c, 2 * h, 2 * w], [0, 2, 3, 1]), 2 * h, 2 * w, c);
}

// ---- helpers for the MLX side ----

const fromHost = (x: Host) => MlxArray.fromFloat32(Float32Array.from(x.data), [1, x.h, x.w, x.c]);
function read(a: MlxArray): Float32Array { using packed = ops.contiguous(a); return packed.toFloat32(); }

function expectClose(actual: ArrayLike<number>, expected: ArrayLike<number>, tolerance: number) {
  expect(actual.length).toBe(expected.length);
  let worst = 0;
  for (let i = 0; i < expected.length; i++) worst = Math.max(worst, Math.abs(actual[i]! - expected[i]!));
  expect(worst).toBeLessThanOrEqual(tolerance);
}

/** Runs `body` with float32 arrays made from `data`, disposing them afterwards. */
function withArrays<T>(data: [Float32Array, number[]][], body: (...arrays: MlxArray[]) => T): T {
  const arrays = data.map(([values, shape]) => MlxArray.fromFloat32(values, shape));
  try { return body(...arrays); } finally { for (const array of arrays) array.dispose(); }
}

// ---- layers ----

test("GroupNorm normalizes each contiguous channel group over its channels and positions", () => {
  const values = uniform(1), h = 3, w = 5, c = 6, groups = 2, eps = 1e-6;
  const x = values(h * w * c, 1.5, 2), gamma = values(c, 0.5, 1), beta = values(c, 0.5);
  const expected = hostGroupNorm(host(x, h, w, c), gamma, beta, groups, eps);
  withArrays([[x, [1, h, w, c]], [gamma, [c]], [beta, [c]]], (input, weight, bias) => {
    using out = new Flux2GroupNorm(weight!, bias!, groups, eps).forward(input!);
    expect(out.shape).toEqual([1, h, w, c]);
    expect(out.dtype).toBe(Dtype.bfloat16);
    expectClose(read(out), expected.data, 2e-5);
  });
});

test("a convolution reads a PyTorch [O, I, k, k] weight, for 3x3 (padding 1) and 1x1 kernels", () => {
  const values = uniform(2), h = 4, w = 5, inC = 3;
  const x = values(h * w * inC, 1);
  for (const [k, outC] of [[3, 4], [1, 2]] as const) {
    const weight = values(outC * inC * k * k, 0.5), bias = values(outC, 0.5);
    const expected = hostConv(host(x, h, w, inC), weight, bias, outC, k);
    withArrays([[x, [1, h, w, inC]], [weight, [outC, inC, k, k]], [bias, [outC]]], (input, wt, b) => {
      const conv = new Flux2Conv2d(wt!, b!);
      try {
        using out = conv.forward(input!);
        expect(out.shape).toEqual([1, h, w, outC]);
        expectClose(read(out), expected.data, 1e-5);
      } finally { conv.dispose(); }
    });
  }
});

test("the upsampler doubles each axis by nearest neighbour, then convolves", () => {
  const values = uniform(3), h = 2, w = 3, inC = 2, outC = 3;
  const x = values(h * w * inC, 1), weight = values(outC * inC * 9, 0.5), bias = values(outC, 0.5);
  const expected = hostConv(hostUpsample(host(x, h, w, inC)), weight, bias, outC, 3);
  withArrays([[x, [1, h, w, inC]], [weight, [outC, inC, 3, 3]], [bias, [outC]]], (input, wt, b) => {
    const upsample = new Flux2Upsample(new Flux2Conv2d(wt!, b!));
    try {
      using nchw = ops.transposeAxes(input!, [0, 3, 1, 2]);
      using out = upsample.forward(nchw);
      expect(out.shape).toEqual([1, outC, 2 * h, 2 * w]);
      using nhwc = ops.transposeAxes(out, [0, 2, 3, 1]);
      expectClose(read(nhwc), expected.data, 1e-5);
    } finally { upsample.dispose(); }
  });
});

test("the mid attention is one head of width C over every position, with its residual", () => {
  const values = uniform(4), h = 2, w = 3, c = 4, groups = 2, eps = 1e-6;
  const x = values(h * w * c, 1, 0.5);
  const p: AttentionParams = {
    gamma: values(c, 0.5, 1), beta: values(c, 0.5), q: values(c * c, 0.8), qb: values(c, 0.3), k: values(c * c, 0.8), kb: values(c, 0.3),
    v: values(c * c, 0.8), vb: values(c, 0.3), o: values(c * c, 0.8), ob: values(c, 0.3),
  };
  const expected = hostAttention(host(x, h, w, c), p, groups, eps);
  const square = [c, c], vector = [c];
  withArrays([[x, [1, h, w, c]], [p.gamma, vector], [p.beta, vector], [p.q, square], [p.qb, vector], [p.k, square], [p.kb, vector],
    [p.v, square], [p.vb, vector], [p.o, square], [p.ob, vector]], (input, gamma, beta, q, qb, k, kb, v, vb, o, ob) => {
    const attention = new Flux2MidAttention(new Flux2GroupNorm(gamma!, beta!, groups, eps), new MossDenseBiasedLinear(q!, qb!),
      new MossDenseBiasedLinear(k!, kb!), new MossDenseBiasedLinear(v!, vb!), new MossDenseBiasedLinear(o!, ob!), c);
    try {
      using nchw = ops.transposeAxes(input!, [0, 3, 1, 2]);
      using out = attention.forward(nchw);
      expect(out.shape).toEqual([1, c, h, w]);
      using nhwc = ops.transposeAxes(out, [0, 2, 3, 1]);
      expectClose(read(nhwc), expected.data, 2e-5);
    } finally { attention.dispose(); }
  });
});

test("the batch-norm de-normalization and unpatchify reproduce the pipeline's reshape and permute", () => {
  const values = uniform(5), channels = 8, h = 2, w = 3, eps = 1e-4;
  const latents = values(channels * h * w, 2), mean = values(channels, 1), variance = values(channels, 0.4, 0.5);
  const expected = hostDenormUnpatch(latents, channels, h, w, mean, variance, eps);
  withArrays([[latents, [1, channels, h, w]], [mean, [channels]], [variance, [channels]]], (input, m, v) => {
    const denormalize = new Flux2LatentDenormalization(m!, v!, eps);
    try {
      using z = denormalize.forward(input!);
      using out = new Flux2Unpatchify(2).forward(z);
      expect(out.shape).toEqual([1, channels / 4, 2 * h, 2 * w]);
      using nhwc = ops.transposeAxes(out, [0, 2, 3, 1]);
      expectClose(read(nhwc), expected.data, 1e-6);
    } finally { denormalize.dispose(); }
  });
});

// ---- the whole decoder ----

const MOSS_VAE_CONFIG = {
  _class_name: "AutoencoderKLFlux2", act_fn: "silu", batch_norm_eps: 0.0001, batch_norm_momentum: 0.1,
  block_out_channels: [128, 256, 512, 512], decoder_block_out_channels: [96, 192, 384, 384],
  down_block_types: ["DownEncoderBlock2D", "DownEncoderBlock2D", "DownEncoderBlock2D", "DownEncoderBlock2D"], force_upcast: true,
  in_channels: 3, latent_channels: 32, layers_per_block: 2, mid_block_add_attention: true, norm_num_groups: 32, out_channels: 3,
  patch_size: [2, 2], sample_size: 1024, up_block_types: ["UpDecoderBlock2D", "UpDecoderBlock2D", "UpDecoderBlock2D", "UpDecoderBlock2D"],
  use_post_quant_conv: true, use_quant_conv: true,
};

test("the config parser reads the shipped VAE config and rejects structures the decoder does not implement", () => {
  expect(parseFlux2VaeConfig(MOSS_VAE_CONFIG)).toEqual({
    latentChannels: 32, patch: 2, downsample: 8, decoderBlockOutChannels: [96, 192, 384, 384], layersPerBlock: 2, normNumGroups: 32,
    batchNormEps: 1e-4, midBlockAddAttention: true, usePostQuantConv: true,
  });
  expect(() => parseFlux2VaeConfig({ ...MOSS_VAE_CONFIG, mid_block_add_attention: false })).toThrow("mid_block_add_attention");
  expect(() => parseFlux2VaeConfig({ ...MOSS_VAE_CONFIG, use_post_quant_conv: false })).toThrow("use_post_quant_conv");
  expect(() => parseFlux2VaeConfig({ ...MOSS_VAE_CONFIG, act_fn: "gelu" })).toThrow("act_fn");
  expect(() => parseFlux2VaeConfig({ ...MOSS_VAE_CONFIG, patch_size: [2, 1] })).toThrow("patch_size");
  expect(() => parseFlux2VaeConfig({ ...MOSS_VAE_CONFIG, norm_num_groups: 64 })).toThrow("norm_num_groups");
  expect(() => parseFlux2VaeConfig({ ...MOSS_VAE_CONFIG, up_block_types: ["UpDecoderBlock2D"] })).toThrow("up blocks");
  expect(Flux2VaeDecoder.usesTensor("decoder.conv_in.weight") && Flux2VaeDecoder.usesTensor("post_quant_conv.bias") &&
    Flux2VaeDecoder.usesTensor("bn.running_var")).toBe(true);
  expect(Flux2VaeDecoder.usesTensor("encoder.conv_in.weight") || Flux2VaeDecoder.usesTensor("quant_conv.weight")).toBe(false);
});

test("a tiny decode returns raw bf16 NHWC, binds pixels separately, and owns one shared SiLU", async () => {
  // Two decoder blocks [4, 8] (reversed: 8 then 4), one upsampler, both resnet
  // kinds (8 -> 8 and the shortcut 8 -> 4), groups of 2.
  const raw = {
    latent_channels: 2, block_out_channels: [4, 8], decoder_block_out_channels: [4, 8], layers_per_block: 1, norm_num_groups: 2,
    batch_norm_eps: 1e-4, patch_size: [2, 2], up_block_types: ["UpDecoderBlock2D", "UpDecoderBlock2D"], act_fn: "silu",
    out_channels: 3, mid_block_add_attention: true, use_post_quant_conv: true,
  };
  const config = parseFlux2VaeConfig(raw);
  expect(config.downsample).toBe(2);
  const values = uniform(6), eps = 1e-6, groups = 2;
  const tensors = new Map<string, { data: Float32Array; shape: number[] }>();
  const add = (name: string, shape: number[], data: Float32Array) => { tensors.set(name, { data, shape }); return data; };
  const conv = (path: string, outC: number, inC: number, k: number) => {
    const bound = Math.sqrt(3 / (inC * k * k));
    return { weight: add(`${path}.weight`, [outC, inC, k, k], values(outC * inC * k * k, bound)), bias: add(`${path}.bias`, [outC], values(outC, 0.1)), outC, k };
  };
  const norm = (path: string, c: number) => ({ gamma: add(`${path}.weight`, [c], values(c, 0.2, 1)), beta: add(`${path}.bias`, [c], values(c, 0.2)) });
  const linear = (path: string, c: number) => [add(`${path}.weight`, [c, c], values(c * c, Math.sqrt(3 / c))), add(`${path}.bias`, [c], values(c, 0.1))] as const;
  const resnet = (path: string, inC: number, outC: number) => ({
    norm1: norm(`${path}.norm1`, inC), conv1: conv(`${path}.conv1`, outC, inC, 3), norm2: norm(`${path}.norm2`, outC), conv2: conv(`${path}.conv2`, outC, outC, 3),
    shortcut: inC === outC ? null : conv(`${path}.conv_shortcut`, outC, inC, 1),
  });
  type Conv = ReturnType<typeof conv>;
  type Resnet = ReturnType<typeof resnet>;

  const mean = add("bn.running_mean", [8], values(8, 0.5)), variance = add("bn.running_var", [8], values(8, 0.4, 0.8));
  const postQuant = conv("post_quant_conv", 2, 2, 1);
  const convIn = conv("decoder.conv_in", 8, 2, 3);
  const mid0 = resnet("decoder.mid_block.resnets.0", 8, 8);
  const a = "decoder.mid_block.attentions.0", attentionNorm = norm(`${a}.group_norm`, 8);
  const [q, qb] = linear(`${a}.to_q`, 8), [k, kb] = linear(`${a}.to_k`, 8), [v, vb] = linear(`${a}.to_v`, 8), [o, ob] = linear(`${a}.to_out.0`, 8);
  const mid1 = resnet("decoder.mid_block.resnets.1", 8, 8);
  const up0 = [resnet("decoder.up_blocks.0.resnets.0", 8, 8), resnet("decoder.up_blocks.0.resnets.1", 8, 8)];
  const upsampler = conv("decoder.up_blocks.0.upsamplers.0.conv", 8, 8, 3);
  const up1 = [resnet("decoder.up_blocks.1.resnets.0", 8, 4), resnet("decoder.up_blocks.1.resnets.1", 4, 4)];
  const normOut = norm("decoder.conv_norm_out", 4), convOut = conv("decoder.conv_out", 3, 4, 3);
  // A known final affine head isolates the raw/pixel contract from bf16
  // accumulation. The independent 39-stage regression checks the real graph's
  // numerical outputs; this fixture must expose a premature decoder clamp.
  convOut.weight.fill(0);
  convOut.bias.set([-2, 0.5, 2]);
  add("encoder.conv_in.weight", [1], values(1, 1)); // present in the file, never read

  const hostConvOf = (x: Host, c: Conv) => hostConv(x, c.weight, c.bias, c.outC, c.k);
  const hostResnet = (x: Host, r: Resnet) => {
    const branch = hostConvOf(hostSilu(hostGroupNorm(hostConvOf(hostSilu(hostGroupNorm(x, r.norm1.gamma, r.norm1.beta, groups, eps)), r.conv1),
      r.norm2.gamma, r.norm2.beta, groups, eps)), r.conv2);
    return hostAdd(r.shortcut ? hostConvOf(x, r.shortcut) : x, branch);
  };
  const latentH = 2, latentW = 3;
  const latents = values(8 * latentH * latentW, 1.5);
  let expected = hostConvOf(hostConvOf(hostDenormUnpatch(latents, 8, latentH, latentW, mean, variance, 1e-4), postQuant), convIn);
  expected = hostResnet(expected, mid0);
  expected = hostAttention(expected, { gamma: attentionNorm.gamma, beta: attentionNorm.beta, q, qb, k, kb, v, vb, o, ob }, groups, eps);
  expected = hostResnet(expected, mid1);
  for (const r of up0) expected = hostResnet(expected, r);
  expected = hostConvOf(hostUpsample(expected), upsampler);
  for (const r of up1) expected = hostResnet(expected, r);
  expected = hostConvOf(hostSilu(hostGroupNorm(expected, normOut.gamma, normOut.beta, groups, eps)), convOut);
  const clamped = expected.data.map(value => Math.min(1, Math.max(-1, value)));
  expect(clamped.some((value, i) => value !== expected.data[i])).toBe(true); // the clamp is exercised
  expect(clamped.some(value => Math.abs(value) < 1)).toBe(true);

  const dir = mkdtempSync(join(tmpdir(), "moss-vae-"));
  try {
    const named = [...tensors].map(([name, t]) => ({ name, array: MlxArray.fromFloat32(t.data, t.shape) }));
    try { writeShardedSafetensors(dir, named); } finally { for (const t of named) t.array.dispose(); }
    const decoder = await Flux2VaeDecoder.open(dir, config);
    const siluDisposal = spyOn(decoder.activation, "dispose");
    try {
      expect(decoder.activation).toBeInstanceOf(MossSilu);
      for (const layer of [...decoder.midBlock, ...decoder.upBlocks.flat()])
        if ("activation" in layer) expect(layer.activation).toBe(decoder.activation);
      using input = MlxArray.fromFloat32(latents, [1, 8, latentH, latentW]);
      using image = decoder.decode(input);
      const pixels = config.downsample * config.patch;
      expect(image.shape).toEqual([1, latentH * pixels, latentW * pixels, 3]);
      expect(image.dtype).toBe(Dtype.bfloat16);
      const actual = read(image);
      expect(actual.every(value => Number.isFinite(value))).toBe(true);
      expect(actual.some(value => value < -1) && actual.some(value => value > 1)).toBe(true);
      expectClose(actual, expected.data, 1e-4);
      using encoded = decoder.pixels(image);
      using packed = ops.contiguous(encoded);
      expect(encoded.dtype).toBe(Dtype.uint8);
      expect(encoded.shape).toEqual(image.shape);
      const bytes = packed.rawBytes();
      expect(Array.from(bytes)).toEqual(Array.from({ length: bytes.length }, (_, i) => [0, 191, 255][i % 3]!));
      expect(read(image)).toEqual(actual);
    } finally {
      decoder.dispose();
      decoder.dispose();
      try { expect(siluDisposal).toHaveBeenCalledTimes(1); }
      finally { siluDisposal.mockRestore(); }
    }
  } finally { rmSync(dir, { recursive: true, force: true }); }
});

// ---- historical real-weight comparison against the PyTorch CPU oracle ----

const SNAPSHOT = Bun.env.MLX_BUN_MOSS_IMAGE_SNAPSHOT, ORACLE = Bun.env.MLX_BUN_MOSS_IMAGE_ORACLE;

/** A float32 tensor of an oracle capture, copied out of the mapping. */
function captured(file: SafetensorsFile, name: string): { data: Float32Array; shape: number[] } {
  const info = file.tensors.get(name);
  assert(info && info.dtype === "F32", `${file.path}: ${name} is not a float32 tensor`);
  return { data: new Float32Array(file.view(name).slice().buffer), shape: info.shape };
}

test.skipIf(!SNAPSHOT || !ORACLE)("historical CPU oracle bounds: real-weight decodes (noise and 8-step latents)", async () => {
  // These assertions remain the original historical CPU criteria. The current
  // MLX-target decoder uses bf16; the original CPU failures are neither waived
  // nor replaced by the exact MFLUX regression. Original rationale follows:
  // Tolerances fixed before the first run. Both original paths decoded in float32; they
  // differ in convolution/GEMM accumulation order, reduction order of the
  // GroupNorm statistics and the SiLU/softmax formulas, each worth a few float32
  // ulps per layer. The unpatched latent is two elementwise float32 ops and a
  // permutation, so 1e-5 is generous. The image passes ~35 layers whose ulp-level
  // differences grow through the network; 1e-3 max and 1e-4 mean absolute on a
  // [-1, 1] image leave room for that growth while catching any layout, epsilon
  // or statistics error (those move pixels by 1e-2 or more). A 1e-3 image
  // difference moves `x / 2 + 0.5` by at most 5e-4, 0.13 of a level after the
  // x255 postprocess, so no pixel can differ by more than one level.
  const vaeDir = join(SNAPSHOT!, "vae");
  for (const file of [join(vaeDir, "config.json"), ...["noise", "sample-8", "vae"].map(name => join(ORACLE!, `${name}.safetensors`))])
    assert(existsSync(file), `missing ${file}`);
  const config = parseFlux2VaeConfig(await Bun.file(join(vaeDir, "config.json")).json());
  const decoder = await Flux2VaeDecoder.open(vaeDir, config);
  const captures = SafetensorsFile.open(join(ORACLE!, "vae.safetensors"));
  try {
    for (const [name, source] of [["noise", "noise"], ["sample", "sample-8"]] as const) {
      const latentsFile = SafetensorsFile.open(join(ORACLE!, `${source}.safetensors`));
      let latentsData: { data: Float32Array; shape: number[] };
      try { latentsData = captured(latentsFile, "latents"); } finally { latentsFile.mmap.unmap(); }
      using latents = MlxArray.fromFloat32(latentsData.data, latentsData.shape);

      const unpatchedRef = captured(captures, `${name}.unpatched`);
      const [, c, uh, uw] = unpatchedRef.shape as [number, number, number, number];
      using packedLatents = decoder.input.forward(latents);
      using denormalized = decoder.denormalize.forward(packedLatents);
      using unpatched = decoder.unpatchify.forward(denormalized);
      expect(unpatched.shape).toEqual([1, c, uh, uw]);
      const unpatchedOurs = read(unpatched);
      let unpatchedMax = 0;
      for (let i = 0; i < unpatchedOurs.length; i++) unpatchedMax = Math.max(unpatchedMax, Math.abs(unpatchedOurs[i]! - unpatchedRef.data[i]!));

      const imageRef = captured(captures, `${name}.image`);
      const [, , ih, iw] = imageRef.shape as [number, number, number, number];
      using image = decoder.decode(latents);
      expect(image.shape).toEqual([1, ih, iw, 3]);
      // The historical capture stores clamp(-1, 1), unlike decode's raw API.
      const imageOurs = permute(read(image).map(value => Math.min(1, Math.max(-1, value))), [1, ih, iw, 3], [0, 3, 1, 2]);
      let imageMax = 0, imageSum = 0;
      for (let i = 0; i < imageOurs.length; i++) {
        const diff = Math.abs(imageOurs[i]! - imageRef.data[i]!);
        imageMax = Math.max(imageMax, diff);
        imageSum += diff;
      }
      const imageMean = imageSum / imageOurs.length;

      const pixelsRef = captures.view(`${name}.pixels`);
      const { pixels } = decodePixels(decoder, latents);
      expect(pixels.length).toBe(pixelsRef.length);
      let beyondOne = 0, differing = 0;
      for (let i = 0; i < pixels.length; i++) {
        const diff = Math.abs(pixels[i]! - pixelsRef[i]!);
        if (diff > 0) differing++;
        if (diff > 1) beyondOne++;
      }
      console.log(`[moss-vae] ${name}: unpatched max abs ${unpatchedMax.toExponential(3)}; image max abs ${imageMax.toExponential(3)}, ` +
        `mean abs ${imageMean.toExponential(3)}; pixels differing ${differing}/${pixels.length}, by more than one level ${beyondOne}`);
      expect(unpatchedMax).toBeLessThanOrEqual(1e-5);
      expect(imageMax).toBeLessThanOrEqual(1e-3);
      expect(imageMean).toBeLessThanOrEqual(1e-4);
      expect(beyondOne).toBe(0);
    }
  } finally {
    captures.mmap.unmap();
    decoder.dispose();
  }
}, 300_000);
