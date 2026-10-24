// The facts of seg.json bridge points, shared by gen.ts, genFinal.ts and genExit.ts.
//
// seg.json v2 (tpl_case, tpl_case_split, tpl_stage, tpl_chain): {"version": 2, "world", "case", "T1", "steps",
// "stop", "frames", "framesEnd", "counters": {"dJ", "dH", "dN"}, "grow", "bridges": [...]}. A bridge: "kind";
// "ia" (the bridge state's boundary); "aN" (`next` there: a spread's new array); "nA" (steps to the state
// before it); "arr" (the array a `.ret (.obj arr)` bridge state returns, 0 if none); kind-specific fields:
//   spread   —                                  the bridge state's own step (stepB)
//   len      "entry" (the fresh table entry, Lean text), "arr", "patched"
//   slice    "arr" (the sliced framed array), "frames" ([aN]: the new array), "patched"
//   typed    "proto", "frames" ([buf, buf + 1]), "patched"
//   ptr      "buf", "off", "patched"
//   newdata  "buf" (the buffer-framed placeholder), "patched": the step is `Disp.newDataS` with bytes `bsT = []`
//   size     "fsym", "ta", "nf", "name", "rt" (`Disp.sizeParts`), "patched": `mlx_array_size` on a symbolic shape
//            (`Full.fullBridgeSize`): the transition `Disp.sizeS` (the native call, `Number`'s argument frame, `Number`)
//   stage    "fn" (the callee), "instance" (the stage instance), "conv" (the conversion's data id): the
//            boundary ia is the call state, ia + 1 the merged state (no step: a zero-step conversion)
// Kinds other than spread and stage are patched (`host.sim.template.Bridges`): the transition from boundary
// ia to ia + 1 is the bridge lemma's patched template, stated by `<Name>.patchB<k>`.
export type Bridge = {
  kind: string; ia: number; aN: number; nA: number; arr?: number; frames?: number[];
  entry?: string; proto?: number; buf?: number; off?: number; fn?: string; instance?: string; conv?: string;
  patched?: boolean; compaction?: unknown; site?: number; name?: string; n0?: number; ws?: number[]; T1?: number;
  fsym?: number; ta?: number; nf?: number; rt?: string;
};
export type Meta = {
  version?: number; world?: string; case: string; T1: number; steps: number; stop: string; frames: number[];
  framesEnd?: number[]; counters?: { dJ: number; dH: number; dN: number }; grow?: boolean; bridges: Bridge[];
  /** Wide frames (address, `WFrame` Lean term): the run's `JSP.wide`. */
  wide?: [number, string][];
  /** The run's load parameters (lo, E, NE, NL, N0): its acceptance at them (`fullJSPP`). */
  loadP?: number[];
};

/** The worlds the generators emit for: the native state type, the acceptance parameters' function and module. */
export const worlds: Record<string, { S: string; jsp: string; okModule: string; ok: string; mlx: (s: string) => string;
  vb?: string; jspW?: string; jspP?: string; jspPD?: string }> = {
  lf: { S: "Host.Load.ffi.S", jsp: "loadJSP", okModule: "host.sim.template.ok.Ok", ok: "ok", mlx: s => `${s}.ffi.mlx` },
  full: { S: "Host.Load.Layers.full.S", jsp: "Host.Ts.Sim.Template.fullJSP", okModule: "host.sim.template.FullOk",
    ok: "Host.Ts.Sim.Template.okFull0", mlx: s => `(Host.Load.Layers.toLoad ${s}.ffi).mlx`, vb: "Host.Ts.Sim.loopVB",
    jspW: "Host.Ts.Sim.Template.fullJSPW", jspP: "Host.Ts.Sim.Template.fullJSPP", jspPD: "Host.Ts.Sim.Template.fullJSPPD" },
};

/** The addresses a bridge frames for the following segments. */
export const framesAdded = (b: Bridge): number[] => [...(b.kind === "spread" ? [b.aN] : []), ...(b.frames ?? [])];

/** Whether the bridge's transition is a step of the machine (`stepB`) rather than a patch or a conversion. */
export const isStepped = (b: Bridge) => b.kind === "spread" || (b.kind !== "stage" && !b.patched);

/** The K-module line of the bridge's transition from boundary ia to ia + 1 (`suffix`: "" for one bridge,
 * else the bridge's 1-based index), or none for a stage conversion. */
export function transitionLine(name: string, b: Bridge, suffix: string): string | undefined {
  const s = (i: number) => `${name}.s${i}`, S = (i: number) => `${name}.S${i}`;
  const A = b.ia, B = b.ia + 1;
  const pair = `some (${s(B)}, ${S(B)})`;
  if (b.kind === "stage") return undefined;
  if (isStepped(b)) return `kernel_rfl ${name}.stepB${suffix} : interpS (step ${name}.F ${s(A)}).run ${S(A)} = ${pair}\n`;
  const T = "Host.Ts.Sim.Template.Bridge";
  switch (b.kind) {
    case "len": return `kernel_rfl ${name}.patchB${suffix} : some (${T}.lenPatch ${s(A)} ${S(A)} (${b.entry})) = ${pair}\n`;
    case "slice": return `kernel_rfl ${name}.patchB${suffix} : some (${T}.slicePatch ${s(A)} ${S(A)}) = ${pair}\n`;
    case "typed": return `kernel_rfl ${name}.patchB${suffix} : some (${T}.typedPatch ${name}.F ${s(A)} ${S(A)} ${b.proto}) = ${pair}\n`;
    case "ptr": return `kernel_rfl ${name}.patchB${suffix} : some (${T}.ptrPatch ${s(A)} ${S(A)} ${b.buf} ${b.off}) = ${pair}\n`;
    case "newdata": return `kernel_rfl ${name}.patchB${suffix} : ${T}.newdataPatch ${name}.F ${s(A)} ${S(A)} [] = ${pair}\n`;
    case "size": return `kernel_rfl ${name}.patchB${suffix} : interpS (Host.Ts.Sim.Disp.sizeS ${name}.F ${s(A)}).run ${S(A)} = ${pair}\n`;
    default: throw new Error(`bridge kind ${b.kind}`);
  }
}

/** The facts of bridge `k` (1-based) at its state `${name}.s<ia>` the bridge lemma's hypotheses need, beyond the
 * acceptance facts (`okP<k>`, `haltP<k>`, `okB0_<k>`) the halting generators state. */
export function kindFacts(name: string, b: Bridge, k: number, frames: number[] = [], vb = "Host.Ts.Sim.loopVB"): string {
  const A = `${name}.s${b.ia}`;
  const T = "Host.Ts.Sim.Template.Bridge";
  const room = `kernel_rfl ${name}.roomA${k}_check : Nat.blt (${A}.next + margin) Sim.bound = true\n`;
  switch (b.kind) {
    case "spread": return `kernel_rfl ${name}.ctlA${k} : ${A}.ctl = .ret (.obj ${b.arr})

/-- Bridge ${k}'s spread frame: accumulator, environment and the frames below it. -/
noncomputable def ${name}.accA${k} : List Val := match ${A}.stack with
  | .l (.spread acc _ _) :: _ => acc
  | _ => []
noncomputable def ${name}.envA${k} : Env := match ${A}.stack with
  | .l (.spread _ _ env) :: _ => env
  | _ => []
noncomputable def ${name}.fsA${k} : List Frame := match ${A}.stack with
  | _ :: fs => fs
  | [] => []

kernel_rfl ${name}.stackA${k} : ${A}.stack = .l (.spread ${name}.accA${k} [] ${name}.envA${k}) :: ${name}.fsA${k}
${room}kernel_rfl ${name}.arrA${k} : (${A}.heap.get aArrayProto).isSome = true
kernel_rfl ${name}.newA${k} : ${A}.next = ${b.aN}
`;
    case "len": return `kernel_rfl ${name}.ctlA${k} : ${A}.ctl = .ret (.obj ${b.arr})
kernel_rfl ${name}.lenA${k} : ${T}.isLenFrame ${A}.stack = true
kernel_rfl ${name}.objA${k} : ${A}.obj? ${b.arr} = some (objOf ${A} ${b.arr})
kernel_rfl ${name}.kindA${k} : (objOf ${A} ${b.arr}).kind = .array (arrOf ${A} ${b.arr})
`;
    case "slice": return `kernel_rfl ${name}.sliceA${k} : ${T}.isSliceOf ${A} ${b.arr} = true
kernel_rfl ${name}.kindA${k} : (objOf ${A} ${b.arr}).kind = .array (arrOf ${A} ${b.arr})
${room}kernel_rfl ${name}.arrA${k} : (${A}.heap.get aArrayProto).isSome = true
kernel_rfl ${name}.newA${k} : ${A}.next = ${b.aN}
`;
    case "typed": return `kernel_rfl ${name}.typedA${k} : ${T}.typedProto ${A} = some ${b.proto}
${room}kernel_rfl ${name}.bufA${k} : (${A}.heap.get aArrayBufferProto).isSome = true
kernel_rfl ${name}.protoA${k} : (${A}.heap.get ${b.proto}).isSome = true
kernel_rfl ${name}.newA${k} : ${A}.next = ${b.buf}
`;
    case "ptr": return `kernel_rfl ${name}.ptrA${k} : ${T}.ptrView ${A} = some ${(b.buf ?? 0) + 1}
`;
    case "newdata": return `kernel_rfl ${name}.ndA${k} : (${T}.ndParts ${A}).map (·.2.2.2.2) = some ${b.buf}
`;
    case "stage": {
      // a closure by its address (`#<a>`, `@ret #<a>`): `isCallAtB`, which the kernel evaluates
      const at = /#(\d+)$/.exec(String(b.fn));
      return at ? `kernel_rfl ${name}.callA${k} : Host.Ts.Sim.Template.isCallAtB ${A} ${at[1]} none = true
`
        : `kernel_rfl ${name}.callA${k} : Host.Ts.Sim.Template.isCallOf ${A} ${JSON.stringify(b.fn)} none = true
`;
    }
    case "size": {
      if (!b.patched) return `kernel_rfl ${name}.sizeA${k} : ${T}.symCallName ${A} = some chars!"mlx_array_size"\n`;
      // `Full.fullBridgeSize`'s hypotheses at the bridge state (`Full.sizePre_of` for the premise)
      const D = "Host.Ts.Sim.Disp", nm = `chars!${JSON.stringify(b.name)}`;
      const sel = (i: number, d: string) =>
        `match ${D}.sizeParts ${A} with | some (_, _, _, _, _, tys, args) => ${["tys", "args"][i]} | none => ${d}`;
      return `/-- Bridge ${k}'s B-size call: the signature's argument types and the call's arguments. -/
noncomputable def ${name}.sizeTys${k} : List Val := ${sel(0, "[]")}
noncomputable def ${name}.sizeArgs${k} : List Val := ${sel(1, "[]")}
kernel_rfl ${name}.sizeA${k} : ${D}.sizeParts ${A} =
  some (${b.fsym}, ${b.ta}, ${b.nf}, ${nm}, chars!${JSON.stringify(b.rt)}, ${name}.sizeTys${k}, ${name}.sizeArgs${k})
kernel_rfl ${name}.sizeArgsA${k} : ${D}.sizeArgsOk ${A} = true
kernel_rfl ${name}.sizeSymA${k} : Host.Mlx.Ffi.symOf ${nm} = some .arraySize
kernel_rfl ${name}.sizeMlxA${k} : Host.Load.isMlx ${nm} = true
kernel_rfl ${name}.sizePayA${k} : nameEq ${nm} Host.Mlx.FfiAne.payloadName = false
-- the signature array is not framed (\`K.fr ${b.ta} = none\` at the segment's frames)
kernel_rfl ${name}.sizeTaA${k} : [${frames.join(", ")}].contains ${b.ta} = false
/-- The decoded arguments and the server after decoding. -/
noncomputable def ${name}.sizeDec${k} := interpS (decodeArgs ${name}.F ${A} ${name}.sizeTys${k} ${name}.sizeArgs${k}).run ${name}.S${b.ia}
noncomputable def ${name}.sizeAs${k} : List Arg := match ${name}.sizeDec${k} with | some (some xs, _) => xs | _ => []
noncomputable def ${name}.sizeS0${k} : SSrv := match ${name}.sizeDec${k} with | some (_, S) => S | none => ${name}.S${b.ia}
kernel_rfl ${name}.sizeDecA${k} : interpS (decodeArgs ${name}.F ${A} ${name}.sizeTys${k} ${name}.sizeArgs${k}).run ${name}.S${b.ia} =
  some (some ${name}.sizeAs${k}, ${name}.sizeS0${k})
kernel_rfl ${name}.sizePreA${k} : Host.Ts.Sim.Full.sizePreB ${vb} ${name}.sizeS0${k} ${A}.ffi ${name}.sizeAs${k} = true
`;
    }
    default: throw new Error(`bridge kind ${b.kind}`);
  }
}
