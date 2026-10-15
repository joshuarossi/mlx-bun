import type { MlxArray } from "@mlx-bun/mlx/array";
import type { Weights } from "../../artifacts/weights";
import type { ModelConfig } from "../../artifacts/config";
import { QuantizedLinear } from "../../layers/quantized-linear";
import { TrellisLinear } from "../../layers/trellis-linear";
import type { TrellisRepresentations } from "../../kernels/trellis/index";
import type { RowProjection } from "../../layers/trellis-prompt";
import { TrellisUnfusedMLP,TrellisExpandReducePrompt,TrellisExpandScatterPrompt } from "../../layers/trellis-prompt";
import { LoraOperation,LoraState } from "../../layers/lora";
import { QwenGatedDeltaNet, Qwen3TextAttention, Qwen3MediaAttention, QwenDeltaLayer, QwenAttentionLayer } from "./blocks";
import { AneAffineSplit, type AneMlpSplit, type AneGpuRows } from "../../layers/ane-prefill-split";
import { compiledSwiglu } from "../../layers/swiglu";
import { qwen35WeightsView } from "./checkpoint";

/** Checkpoint naming only; it never selects a layer or numerical operation. */
export function canonicalQwenWeights(weights: Weights): Weights {
  const view = qwen35WeightsView(weights);
  if (view) weights.setView(view);
  return weights;
}

/** A weight attachment port. The graph names every constructor at its binding;
 * these helpers only put the named projections on the named block. */
export type AffineProjectionClass = new (linear: QuantizedLinear) => RowProjection;
export type GateUpClass = new (gate: TrellisLinear, up: TrellisLinear) => RowProjection;
export type TrellisProjectionClass = new (linear: TrellisLinear) => RowProjection;
export type GateDownClass = new (gateUp: RowProjection, down: RowProjection) => RowProjection;
export type UnfusedClass = new (gate: RowProjection, up: RowProjection, down: RowProjection) => RowProjection;
export type FusedClass = new (gate: TrellisLinear, up: TrellisLinear, down: RowProjection,state?:LoraState) => RowProjection & {dispose():void};
export type QwenProjectionTarget=QuantizedLinear|TrellisLinear;

/** Program/buffer ownership shared by written ANE bindings. Shape lookup only
 * shares resources; the graph supplies the operation and row capacity. */
export class AneWeightShares {
  readonly affine = new Map<string, AneAffineSplit>();
  mlp: AneMlpSplit | undefined;
  readonly owned: { dispose(): void }[] = [];
  projection(linear: QuantizedLinear, Split: typeof AneAffineSplit, fraction: number, rows: number, slices?: number, gpuRows?: AneGpuRows): AneAffineSplit {
    const shape = `${linear.inFeatures}:${linear.outFeatures}`;
    const projection = Split.build(linear, fraction, rows, this.affine.get(shape), slices, gpuRows);
    this.affine.set(shape, projection);
    this.owned.push(projection);
    return projection;
  }
  [Symbol.dispose](): void { for (const resource of this.owned.splice(0)) resource.dispose(); }
}

export interface AneMlpClass {
  build(gate: TrellisLinear, up: TrellisLinear, down: TrellisLinear,
    fraction: number, rows: number, share?: AneMlpSplit, slices?: number): AneMlpSplit;
}
export class AneBoundMlp {
  readonly split: AneMlpSplit;
  readonly #operation:LoraOperation;
  constructor(trellis: TrellisWeights, Split: AneMlpClass, fraction: number, rows: number, shares: AneWeightShares, slices?: number) {
    this.split = Split.build(trellis.gate, trellis.up, trellis.down, fraction, rows, shares.mlp, slices);
    shares.mlp = this.split;
    shares.owned.push(this.split);
    const overlay=new TrellisUnfusedMLP(new TrellisExpandReducePrompt(trellis.gate),new TrellisExpandReducePrompt(trellis.up),new TrellisExpandScatterPrompt(trellis.down));
    this.#operation=new LoraOperation(x=>this.split.forward(x,compiledSwiglu),x=>overlay.forward(x),trellis.state,[trellis.gate.delta,trellis.up.delta,trellis.down.delta]);
    shares.owned.push(this.#operation);
  }
  forward(x:MlxArray):MlxArray { return this.#operation.forward(x); }
}

export class TrellisWeights {
  readonly gate: TrellisLinear;
  readonly up: TrellisLinear;
  readonly down: TrellisLinear;
  readonly #owned:{dispose():void}[]=[];
  constructor(weights: Weights, config: ModelConfig, readonly prefix: string, representations: TrellisRepresentations,readonly state:LoraState) {
    this.gate = TrellisLinear.load(weights, `${prefix}.mlp.gate_proj`, config, false, representations);
    this.up = TrellisLinear.load(weights, `${prefix}.mlp.up_proj`, config, false, representations);
    this.down = TrellisLinear.load(weights, `${prefix}.mlp.down_proj`, config, true, representations);
  }
  keep(resource:{dispose():void}):void { this.#owned.push(resource); }
  operation(plain:RowProjection,adapted:RowProjection):LoraOperation {
    const operation=new LoraOperation(x=>plain.forward(x),x=>adapted.forward(x),this.state,[this.gate.delta,this.up.delta]);
    this.keep(operation);
    return operation;
  }
  targets():readonly (readonly [string,TrellisLinear])[] {
    return [[`${this.prefix}.mlp.gate_proj`,this.gate],[`${this.prefix}.mlp.up_proj`,this.up],[`${this.prefix}.mlp.down_proj`,this.down]];
  }
  dispose():void { for (const resource of this.#owned.splice(0)) resource.dispose(); }
}

/** A gate/up operation already includes the activation; its down projection is
 * another operation the graph names. Both borrow their input. */
export class GateDownMLP {
  constructor(readonly gateUp: RowProjection, readonly down: RowProjection) {}
  forward(x: MlxArray): MlxArray {
    using hidden = this.gateUp.forward(x);
    return this.down.forward(hidden);
  }
}

export class DeltaWeights {
  readonly trellis: TrellisWeights;
  readonly inProjQkv: QuantizedLinear;
  readonly inProjZ: QuantizedLinear;
  readonly inProjA: QuantizedLinear;
  readonly inProjB: QuantizedLinear;
  readonly outProj: QuantizedLinear;
  constructor(weights: Weights, config: ModelConfig, readonly prefix: string, representations: TrellisRepresentations,state:LoraState) {
    this.trellis = new TrellisWeights(weights, config, prefix, representations,state);
    const block = `${prefix}.linear_attn`;
    this.inProjQkv = QuantizedLinear.load(weights, `${block}.in_proj_qkv`, config);
    this.inProjZ = QuantizedLinear.load(weights, `${block}.in_proj_z`, config);
    this.inProjA = QuantizedLinear.load(weights, `${block}.in_proj_a`, config);
    this.inProjB = QuantizedLinear.load(weights, `${block}.in_proj_b`, config);
    this.outProj = QuantizedLinear.load(weights, `${block}.out_proj`, config);
  }
  stage(weights: Weights, config: ModelConfig, Layer: typeof QwenDeltaLayer,
    Mlp: GateDownClass, GateUp: GateUpClass, Gate: TrellisProjectionClass, Down: TrellisProjectionClass,
    Qkv: AffineProjectionClass, Z: AffineProjectionClass, A: AffineProjectionClass,
    B: AffineProjectionClass, Out: AffineProjectionClass, qkScale: { q: MlxArray; k: MlxArray },
    Block: typeof QwenGatedDeltaNet = QwenGatedDeltaNet): QwenDeltaLayer {
    const down=new Down(this.trellis.down),plain=new Mlp(new GateUp(this.trellis.gate,this.trellis.up),down);
    const overlay=new TrellisUnfusedMLP(new Gate(this.trellis.gate),new Gate(this.trellis.up),down);
    return new Layer(weights,config,this.prefix,this.bind(weights,config,Qkv,Z,A,B,Out,qkScale,Block),this.trellis.operation(plain,overlay));
  }
  prompt(weights: Weights, config: ModelConfig, Layer: typeof QwenDeltaLayer,
    Mlp: UnfusedClass, Gate: TrellisProjectionClass, Down: TrellisProjectionClass,
    Plain: AffineProjectionClass, qkScale: { q: MlxArray; k: MlxArray }): QwenDeltaLayer {
    return new Layer(weights, config, this.prefix, this.bind(weights, config, Plain, Plain, Plain, Plain, Plain, qkScale),
      new Mlp(new Gate(this.trellis.gate), new Gate(this.trellis.up), new Down(this.trellis.down)));
  }
  fused(weights: Weights, config: ModelConfig, Layer: typeof QwenDeltaLayer,
    Mlp: FusedClass, Down: TrellisProjectionClass, Plain: AffineProjectionClass,
    qkScale: { q: MlxArray; k: MlxArray }): QwenDeltaLayer {
    const mlp=new Mlp(this.trellis.gate,this.trellis.up,new Down(this.trellis.down),this.trellis.state);
    this.trellis.keep(mlp);
    return new Layer(weights,config,this.prefix,this.bind(weights,config,Plain,Plain,Plain,Plain,Plain,qkScale),mlp);
  }
  withMlp(weights: Weights, config: ModelConfig, Layer: typeof QwenDeltaLayer,
    mlp: RowProjection, Projection: AffineProjectionClass, qkScale: { q: MlxArray; k: MlxArray }): QwenDeltaLayer {
    return new Layer(weights, config, this.prefix, this.bind(weights, config, Projection, Projection, Projection, Projection, Projection, qkScale), mlp);
  }
  withProjections(weights: Weights, config: ModelConfig, Layer: typeof QwenDeltaLayer,
    mlp: RowProjection, Qkv: AffineProjectionClass, Z: AffineProjectionClass, A: AffineProjectionClass,
    B: AffineProjectionClass, Out: AffineProjectionClass, qkScale: {q:MlxArray;k:MlxArray}): QwenDeltaLayer {
    return new Layer(weights,config,this.prefix,this.bind(weights,config,Qkv,Z,A,B,Out,qkScale),mlp);
  }
  withBoundProjections(weights: Weights,config:ModelConfig,Layer:typeof QwenDeltaLayer,
    mlp:RowProjection,qkv:RowProjection,z:RowProjection,a:RowProjection,b:RowProjection,out:RowProjection,
    qkScale:{q:MlxArray;k:MlxArray}):QwenDeltaLayer {
    const block=new QwenGatedDeltaNet(weights,config,`${this.prefix}.linear_attn`,{
      inProjQkv:qkv,inProjZ:z,inProjA:a,inProjB:b,outProj:out,
    });
    block.qkScale=qkScale;
    return new Layer(weights,config,this.prefix,block,mlp);
  }
  aneProjections(weights:Weights,config:ModelConfig,Layer:typeof QwenDeltaLayer,mlp:RowProjection,
    Split:typeof AneAffineSplit,Dense:AffineProjectionClass,Plain:AffineProjectionClass,rows:number,shares:AneWeightShares,
    qkScale:{q:MlxArray;k:MlxArray}):QwenDeltaLayer {
    return this.withBoundProjections(weights,config,Layer,mlp,
      shares.projection(this.inProjQkv,Split,0.375,rows,4,rest=>new Dense(rest)),
      shares.projection(this.inProjZ,Split,0.375,rows,4,rest=>new Dense(rest)),
      new Plain(this.inProjA),new Plain(this.inProjB),
      shares.projection(this.outProj,Split,0.375,rows,4,rest=>new Dense(rest)),qkScale);
  }
  aneStage(weights: Weights, config: ModelConfig, Layer: typeof QwenDeltaLayer,
    Mlp: typeof AneBoundMlp, Split: AneMlpClass, Affine: typeof AneAffineSplit,
    Plain: AffineProjectionClass, fraction: number, rows: number, shares: AneWeightShares,
    qkScale: { q: MlxArray; k: MlxArray }): QwenDeltaLayer {
    const mlp = new Mlp(this.trellis, Split, fraction, rows, shares);
    return new Layer(weights, config, this.prefix, this.ane(weights, config, Plain, Affine, fraction, rows, shares, qkScale), mlp);
  }
  bind(weights: Weights, config: ModelConfig,
    Qkv: AffineProjectionClass, Z: AffineProjectionClass, A: AffineProjectionClass,
    B: AffineProjectionClass, Out: AffineProjectionClass,
    qkScale: { q: MlxArray; k: MlxArray }, Block: typeof QwenGatedDeltaNet = QwenGatedDeltaNet): QwenGatedDeltaNet<RowProjection> {
    const block = new Block(weights, config, `${this.prefix}.linear_attn`, {
      inProjQkv: new Qkv(this.inProjQkv), inProjZ: new Z(this.inProjZ),
      inProjA: new A(this.inProjA), inProjB: new B(this.inProjB), outProj: new Out(this.outProj),
    });
    block.qkScale = qkScale;
    return block;
  }
  ane(weights: Weights, config: ModelConfig, Plain: AffineProjectionClass,
    Split: typeof AneAffineSplit, fraction: number, rows: number, shares: AneWeightShares,
    qkScale: { q: MlxArray; k: MlxArray }): QwenGatedDeltaNet<RowProjection> {
    const block = new QwenGatedDeltaNet(weights, config, `${this.prefix}.linear_attn`, {
      inProjQkv: new Plain(this.inProjQkv), inProjZ: shares.projection(this.inProjZ, Split, fraction, rows),
      inProjA: new Plain(this.inProjA), inProjB: new Plain(this.inProjB),
      outProj: shares.projection(this.outProj, Split, fraction, rows),
    });
    block.qkScale = qkScale;
    return block;
  }
  targets(): readonly (readonly [string,QwenProjectionTarget])[] {
    const prefix = `${this.prefix}.linear_attn`;
    return [[`${prefix}.in_proj_qkv`, this.inProjQkv], [`${prefix}.in_proj_z`, this.inProjZ],
      [`${prefix}.in_proj_a`, this.inProjA], [`${prefix}.in_proj_b`, this.inProjB], [`${prefix}.out_proj`, this.outProj],...this.trellis.targets()];
  }
}

export class AttentionWeights {
  readonly trellis: TrellisWeights;
  readonly qProj: QuantizedLinear;
  readonly kProj: QuantizedLinear;
  readonly vProj: QuantizedLinear;
  readonly oProj: QuantizedLinear;
  constructor(weights: Weights, config: ModelConfig, readonly prefix: string, representations: TrellisRepresentations,state:LoraState) {
    this.trellis = new TrellisWeights(weights, config, prefix, representations,state);
    const block = `${prefix}.self_attn`;
    this.qProj = QuantizedLinear.load(weights, `${block}.q_proj`, config);
    this.kProj = QuantizedLinear.load(weights, `${block}.k_proj`, config);
    this.vProj = QuantizedLinear.load(weights, `${block}.v_proj`, config);
    this.oProj = QuantizedLinear.load(weights, `${block}.o_proj`, config);
  }
  stage(weights: Weights, config: ModelConfig, Layer: typeof QwenAttentionLayer,
    Mlp: GateDownClass, GateUp: GateUpClass, Gate: TrellisProjectionClass, Down: TrellisProjectionClass,
    Q: AffineProjectionClass, K: AffineProjectionClass, V: AffineProjectionClass, O: AffineProjectionClass): QwenAttentionLayer {
    const down=new Down(this.trellis.down),plain=new Mlp(new GateUp(this.trellis.gate,this.trellis.up),down);
    const overlay=new TrellisUnfusedMLP(new Gate(this.trellis.gate),new Gate(this.trellis.up),down);
    return new Layer(weights,config,this.prefix,this.text(weights,config,Q,K,V,O),this.trellis.operation(plain,overlay));
  }
  prompt(weights: Weights, config: ModelConfig, Layer: typeof QwenAttentionLayer,
    Mlp: UnfusedClass, Gate: TrellisProjectionClass, Down: TrellisProjectionClass,
    Plain: AffineProjectionClass): QwenAttentionLayer {
    return new Layer(weights, config, this.prefix, this.text(weights, config, Plain, Plain, Plain, Plain),
      new Mlp(new Gate(this.trellis.gate), new Gate(this.trellis.up), new Down(this.trellis.down)));
  }
  fused(weights: Weights, config: ModelConfig, Layer: typeof QwenAttentionLayer,
    Mlp: FusedClass, Down: TrellisProjectionClass, Plain: AffineProjectionClass): QwenAttentionLayer {
    const mlp=new Mlp(this.trellis.gate,this.trellis.up,new Down(this.trellis.down),this.trellis.state);
    this.trellis.keep(mlp);
    return new Layer(weights,config,this.prefix,this.text(weights,config,Plain,Plain,Plain,Plain),mlp);
  }
  withMlp(weights: Weights, config: ModelConfig, Layer: typeof QwenAttentionLayer,
    mlp: RowProjection, Projection: AffineProjectionClass): QwenAttentionLayer {
    return new Layer(weights, config, this.prefix, this.text(weights, config, Projection, Projection, Projection, Projection), mlp);
  }
  withProjections(weights: Weights, config: ModelConfig, Layer: typeof QwenAttentionLayer,
    mlp: RowProjection, Q: AffineProjectionClass, K: AffineProjectionClass, V: AffineProjectionClass, O: AffineProjectionClass): QwenAttentionLayer {
    return new Layer(weights,config,this.prefix,this.text(weights,config,Q,K,V,O),mlp);
  }
  withBoundProjections(weights:Weights,config:ModelConfig,Layer:typeof QwenAttentionLayer,
    mlp:RowProjection,q:RowProjection,k:RowProjection,v:RowProjection,o:RowProjection):QwenAttentionLayer {
    const block=new Qwen3TextAttention(weights,config,`${this.prefix}.self_attn`,{qProj:q,kProj:k,vProj:v,oProj:o});
    return new Layer(weights,config,this.prefix,block,mlp);
  }
  aneProjections(weights:Weights,config:ModelConfig,Layer:typeof QwenAttentionLayer,mlp:RowProjection,
    Split:typeof AneAffineSplit,Dense:AffineProjectionClass,_Plain:AffineProjectionClass,rows:number,shares:AneWeightShares):QwenAttentionLayer {
    return this.withBoundProjections(weights,config,Layer,mlp,
      shares.projection(this.qProj,Split,0.375,rows,4,rest=>new Dense(rest)),new Dense(this.kProj),new Dense(this.vProj),
      shares.projection(this.oProj,Split,0.375,rows,4,rest=>new Dense(rest)));
  }
  mediaLayer(weights: Weights, config: ModelConfig, Layer: typeof QwenAttentionLayer,
    mlp: RowProjection, Projection: AffineProjectionClass): QwenAttentionLayer {
    return new Layer(weights, config, this.prefix, this.media(weights, config, Projection, Projection, Projection, Projection), mlp);
  }
  aneStage(weights: Weights, config: ModelConfig, Layer: typeof QwenAttentionLayer,
    Mlp: typeof AneBoundMlp, Split: AneMlpClass, Affine: typeof AneAffineSplit,
    Plain: AffineProjectionClass, fraction: number, rows: number, shares: AneWeightShares): QwenAttentionLayer {
    const mlp = new Mlp(this.trellis, Split, fraction, rows, shares);
    return new Layer(weights, config, this.prefix, this.ane(weights, config, Plain, Affine, fraction, rows, shares), mlp);
  }
  text(weights: Weights, config: ModelConfig, Q: AffineProjectionClass, K: AffineProjectionClass,
    V: AffineProjectionClass, O: AffineProjectionClass): Qwen3TextAttention<RowProjection> {
    return new Qwen3TextAttention(weights, config, `${this.prefix}.self_attn`, {
      qProj: new Q(this.qProj), kProj: new K(this.kProj), vProj: new V(this.vProj), oProj: new O(this.oProj),
    });
  }
  media(weights: Weights, config: ModelConfig, Q: AffineProjectionClass, K: AffineProjectionClass,
    V: AffineProjectionClass, O: AffineProjectionClass): Qwen3MediaAttention<RowProjection> {
    return new Qwen3MediaAttention(weights, config, `${this.prefix}.self_attn`, {
      qProj: new Q(this.qProj), kProj: new K(this.kProj), vProj: new V(this.vProj), oProj: new O(this.oProj),
    });
  }
  ane(weights: Weights, config: ModelConfig, Plain: AffineProjectionClass,
    Split: typeof AneAffineSplit, fraction: number, rows: number, shares: AneWeightShares): Qwen3TextAttention<RowProjection> {
    return new Qwen3TextAttention(weights, config, `${this.prefix}.self_attn`, {
      qProj: new Plain(this.qProj), kProj: new Plain(this.kProj), vProj: new Plain(this.vProj),
      oProj: shares.projection(this.oProj, Split, fraction, rows),
    });
  }
  targets(): readonly (readonly [string,QwenProjectionTarget])[] {
    const prefix = `${this.prefix}.self_attn`;
    return [[`${prefix}.q_proj`, this.qProj], [`${prefix}.k_proj`, this.kProj],
      [`${prefix}.v_proj`, this.vProj], [`${prefix}.o_proj`, this.oProj],...this.trellis.targets()];
  }
}
