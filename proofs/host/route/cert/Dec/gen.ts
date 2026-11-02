// Write the graph modules of the decode chains `DEC4_<case>` over the template `DT4` (run from `proofs/`).
// usage: bun host/route/cert/Dec/gen.ts <Case>:<inputs> ...   e.g. Ord:1880 Clear:1880 Grow:1880 Fill:1880
//   <inputs> is the chooser's input count (the `simgraph_choose_conv` log line), for the bounded input checks.
// Reads the end's table name from a4dec4_<case>/EEnd.lean. Writes host/route/cert/Dec/<Case>/{Cert,Exact,Inputs,Graph,Machine,End}.lean;
// `Fill` checks its certificate in two ranges (Data, Range0, Range1, Cert).
const dir = "host/route/cert/Dec";
const NL = "\n";

type Branch = {
  l: string; tpl: string; join: string; n0: number; word: string;
  // graph_iter's premise and its signature lemma
  iterHyp: string; sig: string;
  // caseTpl's premise, and the arguments it gives graph_iter
  tplHyp: string; tplArgs: string;
  // the selection's fact
  selName: string; selBody: string;
};
const interior = (l: string, word: string): Branch => ({
  l, tpl: "Tpl.Ordinary", join: "host.simgraph.tpl.ordinary.Join", n0: 1, word,
  iterHyp: "(interior : time + 1 < c)", sig: "kvSig_interior c time interior",
  tplHyp: "(interior : L + i + 2 < capL (L + i + 1))", tplArgs: "(by dsimp [c, time]; omega)",
  selName: `${l}_interior`,
  selBody: `theorem ${l}_interior {L i : Nat} (h : DecKind.Holds .${l} L i) :
    L + i + 2 < capL (L + i + 1) := by
  unfold DecKind.Holds at h
  unfold capL
  omega`,
});
const branches: Record<string, Branch> = {
  Ord: interior("ord", "ordinary"),
  Clear: interior("clear", "clear"),
  Grow: {
    l: "grow", tpl: "Tpl.Growth", join: "host.simgraph.tpl.growth.Join", n0: 256, word: "growth",
    iterHyp: "(growth : time = c) (aligned : c % 256 = 0)", sig: "kvSig_growth c time growth aligned",
    tplHyp: "(boundary : (L + i + 1) % 256 = 0)",
    tplArgs: "(by dsimp [time, c]; exact capL_grow boundary)\n      (by dsimp [c, time]; rw [← capL_grow boundary]; exact boundary)",
    selName: "grow_boundary",
    selBody: `theorem grow_boundary {L i : Nat} (h : DecKind.Holds .grow L i) :
    (L + i + 1) % 256 = 0 := h.2`,
  },
  Fill: {
    l: "fill", tpl: "Tpl.Fill", join: "host.simgraph.tpl.fill.Join", n0: 255, word: "fill",
    iterHyp: "(fill : time + 1 = c)", sig: "kvSig_fill c time fill",
    tplHyp: "(fill : L + i + 2 = capL (L + i + 1))", tplArgs: "(by dsimp [time, c]; exact fill)",
    selName: "fill_boundary",
    selBody: `theorem fill_boundary {L i : Nat} (h : DecKind.Holds .fill L i) :
    L + i + 2 = capL (L + i + 1) := capL_fill h.2`,
  },
};

const opts = `set_option maxRecDepth 1000000${NL}set_option maxHeartbeats 0${NL}set_option Elab.async false${NL}`;

const gen = async (C: string, inputs: number) => {
  const b = branches[C];
  if (!b) throw new Error(`unknown case ${C}`);
  const X = `Host.Load.Run.Tpl.DEC4_${b.l}`;
  const eend = await Bun.file(`host/sim/template/a4dec4_${b.l}/EEnd.lean`).text();
  const sm = eend.match(/^\s*S1 := DEC4_\w+\.(\w+)$/m);
  if (!sm) throw new Error(`no end table in a4dec4_${b.l}/EEnd.lean`);
  const S1 = `${X}.${sm[1]}`;
  const ns = `Host.Route.Cert.Dec.${C}`;
  const put = (f: string, body: string) => Bun.write(`${dir}/${C}/${f}.lean`, body);
  const stEnd = `  ⟨${X}.s11.heap, ${X}.s11.next, ${X}.s11.ctl, ${X}.s11.stack,
    ⟨${X}.s11.aux.jobs, Host.Load.Layers.toLoad ${X}.s11.aux.ffi, ${X}.s11.aux.trace, ${X}.s11.aux.stores⟩⟩`;
  const stStart = `  ⟨${X}.s0.heap, ${X}.s0.next, ${X}.s0.ctl, ${X}.s0.stack,
    ⟨${X}.s0.aux.jobs, Host.Load.Layers.toLoad ${X}.s0.aux.ffi, ${X}.s0.aux.trace, ${X}.s0.aux.stores⟩⟩`;
  const data = `import host.simgraph.ChooseConv
import ${b.join}
import host.sim.template.a4dec4_${b.l}.ERestart
import host.sim.template.DimVals
import host.load.run.prompt.Addr
${opts}
namespace ${ns}
open Host.Ts Host.Load Host.Mlx Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Ts.Sim.Template

/-! The ${b.word} decode chain's end graph over the template \`DT4\`, read at the symbolic time variable with its abstracted dims pinned.
The carrier search chooses data; the kernel checks the whole certificate. -/

noncomputable def endLoad : St LSt :=
${stEnd}
noncomputable def startLoad : St LSt :=
${stStart}

open Lean Meta in
run_elab do
  let pre ← getCurrNamespace
  for (name, source) in [(\`endSrv, \`\`${S1}),
      (\`startSrv, \`\`${X}.S0), (\`envSrv, \`\`Host.Load.Run.Prompt.P.S0)] do
    let value ← Meta.reduce (mkConst source) (skipTypes := true)
    addDecl (.defnDecl { name := pre ++ name, levelParams := [], type := mkConst \`\`SSrv, value := value, hints := .regular 0, safety := .safe })

def NL : Nat := 20000
def N0 : Nat := 22539
def fixedBigs : List Int := [5554869888]
def tokenNode : Nat := 22539

noncomputable def Gs : Nat → Option (RNode SDim InKey) :=
  restrictTo (tplDom NL N0 fixedBigs endLoad.ffi.mlx)
    (pinGraph ${S1} 9 Host.Load.Run.Tpl.decVal SourceKernels.sources endLoad.ffi.mlx)

set_option interpreter.prefer_native false in
simgraph_choose_conv choice : (endLoad, endSrv), (startLoad, startSrv),
  (Host.Load.Run.Prompt.P.s0, envSrv),
  9, Host.Load.Run.Tpl.decVal, NL, N0, fixedBigs, tokenNode, ${b.tpl}.graph

def insT : InKey → Option Nat := inputsOf choice.inputs
`;
  if (C === "Fill") {
    await put("Data", `${data}
end ${ns}
`);
    for (const [f, nm, lo, hi] of [["Range0", "first", 0, 1994], ["Range1", "second", 1994, 3988]] as const)
      await put(f, `import host.route.cert.Dec.Fill.Data
import host.simgraph.ChunkCheck
${opts}
namespace ${ns}
open Host.Mlx.SimGraph

simgraph_check_range ${nm} : Gs, ${b.tpl}.graph, choice.cert, insT
  from ${lo} to ${hi} choosing ${b.tpl}.graph

end ${ns}
`);
    await put("Cert", `import host.route.cert.Dec.Fill.Range0
import host.route.cert.Dec.Fill.Range1
${opts}
namespace ${ns}
open Host.Mlx.SimGraph

kernel_rfl graph_length : ${b.tpl}.graph.length = 3988

/-- Both adjacent ranges cover every node and input condition. -/
theorem completeRange : GraphRangeD Gs ${b.tpl}.graph choice.cert insT
    0 ${b.tpl}.graph.length := by
  rw [graph_length]
  exact first.checked.append second.checked

namespace check

theorem «matches» : MatchesD Gs ${b.tpl}.graph choice.cert = true :=
  completeRange.matchesD

theorem inputs : inputCarriersMatchD ${b.tpl}.graph choice.cert insT = true :=
  completeRange.inputCarriersMatchD

end check

theorem cert_length : ${b.tpl}.graph.length ≤ choice.cert.length := by decide

end ${ns}
`);
  } else {
    await put("Cert", `${data}
simgraph_check_template check : Gs, ${b.tpl}.graph, choice.cert, insT choosing ${b.tpl}.graph

theorem cert_length : ${b.tpl}.graph.length ≤ choice.cert.length := by decide

end ${ns}
`);
  }
  await put("Exact", `import host.route.cert.Dec.${C}.Cert
import host.simgraph.GenLoadRel
${opts}
namespace ${ns}
open Host.Ts Host.Ts.Sim Host.Mlx Host.Mlx.SimGraph

noncomputable def exactNodeB (i : Nat) : Bool :=
  !tplDom NL N0 fixedBigs endLoad.ffi.mlx i || match endLoad.ffi.mlx.nodes.get i with
    | none => true
    | some nd => !G.shapeOnly nd

kernel_rfl exactNodes : (List.range endLoad.ffi.mlx.nnext).all exactNodeB = true

/-- Exactness on the checked source domain, using the source bound already supplied by the relation. -/
theorem source_exact {i : Nat} {nd : Ffi.Node} (hlt : i < endLoad.ffi.mlx.nnext)
    (hi : tplDom NL N0 fixedBigs endLoad.ffi.mlx i = true)
    (hn : endLoad.ffi.mlx.nodes.get i = some nd) : G.shapeOnly nd = false := by
  have h := List.all_eq_true.mp exactNodes i (List.mem_range.mpr hlt)
  simpa only [exactNodeB, hi, Bool.not_true, Bool.false_or, hn, Bool.not_eq_true'] using h

end ${ns}
`);
  const size = 64;
  const parts = Math.ceil(inputs / size);
  const kl = (j: number) => j < parts - 1
    ? `kernel_rfl inputs_part${j} : InputsOkAt 15235 ((choice.inputs.drop ${j * size}).take ${size}) cacheNodes tokenNode = true`
    : `kernel_rfl inputs_part${j} : InputsOkAt 15235 (choice.inputs.drop ${j * size}) cacheNodes tokenNode = true`;
  const tails: string[] = [`theorem inputs_tail${parts - 1} : InputsOkAt 15235 (choice.inputs.drop ${(parts - 1) * size}) cacheNodes tokenNode = true := inputs_part${parts - 1}`];
  for (let j = parts - 2; j >= 0; j--)
    tails.push(`theorem inputs_tail${j} : InputsOkAt 15235 (choice.inputs.drop ${j * size}) cacheNodes tokenNode = true := by
  apply inputsOkAt_of_take_drop 15235 ${size}
  · exact inputs_part${j}
  · simpa only [List.drop_drop] using inputs_tail${j + 1}`);
  await put("Inputs", `import host.route.cert.Dec.${C}.Exact
import host.route.cert.Dec.Entry
import host.simgraph.iter.InputsPrefix
${opts}
namespace ${ns}
open Host.Mlx.SimGraph.Iter
open Host.Route.Cert.Dec (cacheNodes)

/-! The complete input table, in bounded pieces. -/

${Array.from({ length: parts }, (_, j) => kl(j)).join(NL)}

${tails.join(NL + NL)}

theorem inputs_prefix : InputsOkAt 15235 choice.inputs cacheNodes tokenNode = true := by
  simpa only [List.drop_zero] using inputs_tail0

end ${ns}
`);
  await put("Graph", `import host.route.cert.Dec.${C}.Inputs
import host.simgraph.Step
import host.load.CacheCarriersCommand
${opts}
namespace ${ns}
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Extract Host.Mlx Host.Mlx.GlueStep
open Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Load.Run.Full.Cached.Expected2 (stages head)
open Host.Load.Run.Tpl (decVal)

/-! Graph correspondence for the ${b.word} decode chain at every time in its KV branch. -/

kernel_rfl token_node : Gs tokenNode = some ⟨.reshape [.lit 1, .lit 1], [22538]⟩
kernel_rfl token_input : insT .tokenIds = some tokenNode
kernel_rfl outputs_check : choice.outputs = ${b.tpl}.cacheOutputs.map (certifiedCachePair choice.cert)

section
variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = stages)
  (hhead : linLayout .affineRow w.head = head)

include hlay hhead in
theorem templateOf_eq : templateOf w hs₀ ${b.n0} = (${b.tpl}.graph, ${b.tpl}.tokenNode, ${b.tpl}.cacheOutputs) := by
  unfold templateOf
  rw [hlay, hhead]
  exact ${b.tpl}.template_eq

noncomputable def T : Template w where
  n₀ := ${b.n0}
  c₀ := 256
  hs₀ := hs₀
  caps₀ := hcaps₀
  Gs := Gs
  cert := choice.cert
  checked := by rw [templateOf_eq w hs₀ hlay hhead]; exact check.matches
  length := by rw [templateOf_eq w hs₀ hlay hhead]; exact cert_length

end

theorem outputs_pairs (cert : List Nat) (ps : List (Nat × Nat)) (outs : List (Option Nat × Option Nat))
    (σ : Nat → Nat) (ho : outs = ps.map (certifiedCachePair cert)) :
    outs.map (fun p => (p.1.map σ, p.2.map σ)) =
      ps.map (fun (a, b) => (some (σ (certAt cert a)), some (σ (certAt cert b)))) := by
  rw [ho, List.map_map]
  rfl

section
variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = stages)
  (hhead : linLayout .affineRow w.head = head)

/-- Every general-native image of this end carries the ${b.word} graph, at a valuation with the pins. -/
theorem graph_iter (table : List F64) (P : LoadP) (NB : Nat) (Mp : Map) (n : Nat) (y : LSt)
    (hR : G.LoadR P NB Mp n endLoad.ffi y) (hNL : NL ≤ P.NL) (hN0 : P.N0 ≤ N0)
    (ρ : Nat → F64) (time : Nat) (hρ : ρ 9 = F64.ofNat time) (hsmall : time + 1 < 2 ^ 31)
    (hpin : ∀ q k, decVal q = some k → ρ q = F64.ofNat k)
    (hnum : ∀ i e, nth? ${S1}.tab i = some e →
      CSrv.val ⟨table⟩ (Mp.nv (.ref i)) = some (e.eval ρ))
    (hrope : Mp.big 5554869888 = 5554869888)
    (l : Loaded) (token : Tensor) (hs : List Handles) (nextCache : List Cache) (c : Nat)
    (caps : CapsFor c (stageWeights w) hs) ${b.iterHyp}
    (hin : ∀ key j, insT key = some j → inputNode l token key = some (Mp.node j))
    (hout : nextCache.map cacheNodePair = choice.outputs.map fun p => (p.1.map Mp.node, p.2.map Mp.node)) :
    let G := ffiGraph (κ := InKey) (concrete (CSrv.val ⟨table⟩)) SourceKernels.sources y.mlx
    let T := T w hs₀ hcaps₀ hlay hhead
    Embeds Mp.node Mp.handle (mapG (SDim.eval time) T.Gs) G ∧
      kvSig (some T.c₀) T.n₀ = kvSig (some c) time ∧
      G token.node = some ⟨.reshape [1,1], [Mp.node 22538]⟩ ∧ Mp.node 22538 < token.node ∧
      nextCache.map (fun c => (c.first.map Tensor.node, c.second.map Tensor.node)) =
        (templateOf w T.hs₀ T.n₀).2.2.map
          (fun (a, b) => (some (Mp.node (certAt T.cert a)), some (Mp.node (certAt T.cert b)))) ∧
      inputCarriersMatch (stepGraphOf w hs time).1 (T.cert.map Mp.node) (inputNode l token) = true ∧
      (templateOf w T.hs₀ T.n₀).2.1 = ${b.tpl}.tokenNode := by
  intro G T
  have hD : ∀ i, tplDom NL N0 fixedBigs endLoad.ffi.mlx i = true → Full P i := by
    intro i hi
    rcases tplDom_band hi with h | h
    · exact .inl (Nat.lt_of_lt_of_le h hNL)
    · exact .inr (Nat.le_trans hN0 h)
  have emb : Embeds Mp.node Mp.handle (mapG (SDim.eval time) Gs) G :=
    embeds_of_GRunC ${S1} 9 decVal SourceKernels.sources hR.mlx time _ ρ hρ hsmall hpin
      (CSrv.val ⟨table⟩) (fun _ => rfl) hnum (fun a => okArg fixedBigs a = true)
      (arg_fixed Mp fixedBigs (by simp [fixedBigs, hrope]))
      (fun _ _ hi hn => tplDom_args hi hn) hD
      (fun i nd hi hn => source_exact (hR.mlx.nlt i (by
        show (endLoad.ffi.mlx.nodes.get i).isSome = true
        rw [hn]
        rfl)) hi hn)
  have htok : token.node = Mp.node tokenNode := by
    have := hin .tokenIds tokenNode token_input
    simpa [inputNode] using this
  have hfeed : mapG (SDim.eval time) Gs tokenNode = some ⟨.reshape [1, 1], [22538]⟩ := by
    simp only [mapG, token_node, Option.map_some]
    rfl
  have heq := templateOf_eq w hs₀ hlay hhead
  refine ⟨emb, (${b.sig}).symm, ?_, ?_, ?_, ?_, ?_⟩
  · rw [htok, emb.node _ _ hfeed]
    rfl
  · rw [htok]
    exact emb.order tokenNode 22538 (by rw [hfeed]; rfl) (by decide)
  · show _ = (templateOf w hs₀ ${b.n0}).2.2.map _
    rw [heq]
    change nextCache.map cacheNodePair = ${b.tpl}.cacheOutputs.map
      (fun (a, b) => (some (Mp.node (certAt choice.cert a)), some (Mp.node (certAt choice.cert b))))
    exact hout.trans (outputs_pairs choice.cert ${b.tpl}.cacheOutputs choice.outputs Mp.node outputs_check)
  · refine template_inputs w T hs c time caps (${b.sig}).symm Mp.node insT
      (inputNode l token) ?_ hin
    show inputCarriersMatchD (templateOf w hs₀ ${b.n0}).1 choice.cert insT = true
    rw [heq]
    exact check.inputs
  · show (templateOf w hs₀ ${b.n0}).2.1 = _
    rw [heq]

end

end ${ns}
`);
  await put("Machine", `import host.route.cert.Dec.${C}.Graph
import host.sim.compose.MachPin
import host.simgraph.iter.InputsPrefix
import host.simgraph.mach.DecodeLayout
${opts}
set_option autoImplicit false
namespace ${ns}
open Host.Ts Host.Ts.Sim Host.Load Host.Load.Extract
open Host.Load.Run.Full Host.Mlx Host.Mlx.GlueStep
open Host.Load.Program
open Host.Ts.Sim.Compose
open Host.Ts.Sim.Full (fullWorldFb)
open Host.Ts.Sim.Prefill
open Host.Ts.Sim.Lin.Cls
open Host.Mlx.FfiEval Host.Mlx.SimGraph
open Host.Mlx.SimGraph.Iter
open Host.Load.Run.Tpl (decVal)
open Host.Route.Cert.Dec (cacheNodes inputs)
open Inference Inference.Contracts.Mlx Inference.Models.Qwen

section
variable (w : PipelineWeights) (hs₀ : List Handles) (hcaps₀ : CapsFor 256 (stageWeights w) hs₀)
  (hlay : chainLayout (stageWeights w) hs₀ = Host.Load.Run.Full.Cached.Expected2.stages)
  (hhead : linLayout .affineRow w.head = Host.Load.Run.Full.Cached.Expected2.head)

theorem t_hs0 : (T w hs₀ hcaps₀ hlay hhead).hs₀ = hs₀ := rfl
theorem t_n0 : (T w hs₀ hcaps₀ hlay hhead).n₀ = ${b.n0} := rfl
theorem t_cert : (T w hs₀ hcaps₀ hlay hhead).cert = choice.cert := rfl
end

variable {C : M1Max.Contract} (M : MlxContract C) (K : KernelContract C)
  (env : FfiEval.Env InKey)

theorem layout_eq (table : List F64) :
    chainLayout (stageWeights (weights (firstValues M K env table))) (populatedLayoutHandles 256) =
      Host.Load.Run.Full.Cached.Expected2.stages := by
  exact Host.Mlx.SimGraph.Mach.decode_layout (contents M K env (firstFfiGraph table))

theorem head_eq (table : List F64) :
    linLayout .affineRow (weights (firstValues M K env table)).head =
      Host.Load.Run.Full.Cached.Expected2.head := by
  exact Host.Mlx.SimGraph.Mach.decode_head_layout (contents M K env (firstFfiGraph table))

theorem caps_eq (table : List F64) :
    CapsFor 256 (stageWeights (weights (firstValues M K env table))) (populatedLayoutHandles 256) := by
  exact Host.Mlx.SimGraph.Mach.decode_layout_caps (contents M K env (firstFfiGraph table))

/-- The actual ${b.word} end supplies the machine-reference template at its world's fixed prefix, at its table with the dims pinned. -/
theorem caseTpl (b0 : Host.Mlx.FfiAne.St) (NB L i : Nat) (hNB : 15235 ≤ NB)
    (hsmall : L + i + 2 < 2 ^ 31) ${b.tplHyp} :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt inputs L
      ${X}.s11.ffi (pinTab decVal ${S1}.tab)
      (certAt choice.cert ${b.tpl}.tokenNode) choice.outputs i NB := by
  intro table P Mp n y ν hld hNL hN0 htime hnum hrope
  let w := weights (firstValues M K env table)
  let time := L + i + 1
  let c := capL time
  let l := loadedAt Mp.node cacheNodes
  let token := tensorAt (Mp.node tokenNode)
  let nextCache := cachesAt Mp.node choice.outputs
  have hin : ∀ key j, insT key = some j → inputNode l token key = some (Mp.node j) :=
    inputs_at_bound 15235 choice.inputs cacheNodes tokenNode inputs_prefix Mp.node
      (fun j hj => hld.mlx.nid j (Nat.lt_of_lt_of_le hj hNB))
  have hR : G.LoadR P NB Mp n endLoad.ffi (Host.Load.Layers.toLoad y) := hld
  have hnl : NL ≤ P.NL := by change 20000 ≤ P.NL; change P.NL = 20000 at hNL; omega
  have hn0 : P.N0 ≤ N0 := by change P.N0 ≤ 22539; change P.N0 = 22539 at hN0; omega
  have htv : pinVal decVal ν 9 = F64.ofNat time := (pinVal_free (by rfl)).trans htime
  have hr : Mp.big 5554869888 = 5554869888 := hrope
  have ho : nextCache.map cacheNodePair = choice.outputs.map (fun p => (p.1.map Mp.node, p.2.map Mp.node)) :=
    cachesAt_nodes Mp.node choice.outputs
  have hgraph : Gr table ((fullWorldFb b0 NB).toMlx y) =
      Gr table (Host.Load.Layers.toLoad y).mlx :=
    congrArg (Gr table) ((fullProjFb b0 NB).mlx y).symm
  obtain ⟨hemb, hbr, hfb, hea, _, _, _⟩ :=
    graph_iter w (populatedLayoutHandles 256) (caps_eq M K env table) (layout_eq M K env table)
      (head_eq M K env table) table P NB Mp n (Host.Load.Layers.toLoad y) hR hnl hn0
      (pinVal decVal ν) time htv (by dsimp [time]; omega) (fun _ _ h => pinVal_pin h)
      (pin_num (v := fun j => CSrv.val ⟨table⟩ (Mp.nv (.ref j))) hnum) hr l token (populatedHandlesFor (stageWeights w) c)
      nextCache c (Host.Mlx.SimGraph.Mach.caps_populated c _) ${b.tplArgs} hin ho
  refine ⟨l, token, T w (populatedLayoutHandles 256) (caps_eq M K env table)
    (layout_eq M K env table) (head_eq M K env table), Mp.node, Mp.handle, ?_⟩
  refine And.intro ?_ ?_
  · rfl
  refine And.intro ?_ ?_
  · rfl
  refine And.intro ?_ ?_
  · rw [hgraph]
    exact hfb
  refine And.intro hea ?_
  refine And.intro hbr ?_
  refine And.intro ?_ ?_
  · rw [hgraph]
    exact hemb
  refine And.intro ?_ ?_
  · intro hs hcaps
    refine template_inputs w
      (T w (populatedLayoutHandles 256) (caps_eq M K env table)
        (layout_eq M K env table) (head_eq M K env table))
      hs c time hcaps hbr Mp.node insT (inputNode l token) ?_ hin
    show inputCarriersMatchD (templateOf w (populatedLayoutHandles 256) ${b.n0}).1 choice.cert insT = true
    rw [templateOf_eq w (populatedLayoutHandles 256) (layout_eq M K env table) (head_eq M K env table)]
    exact check.inputs
  refine And.intro ?_ ?_
  · rw [t_hs0, t_n0, t_cert,
      templateOf_eq w (populatedLayoutHandles 256) (layout_eq M K env table) (head_eq M K env table)]
    change (cachesAt Mp.node choice.outputs).map Host.Load.cacheNodePair = _
    exact (cachesAt_nodes Mp.node choice.outputs).trans
      (outputs_pairs choice.cert ${b.tpl}.cacheOutputs choice.outputs Mp.node outputs_check)
  rw [t_hs0, t_n0, t_cert,
    templateOf_eq w (populatedLayoutHandles 256) (layout_eq M K env table) (head_eq M K env table)]

${b.selBody}

/-- Every iteration selected for this chain satisfies its graph branch and bounds. -/
theorem caseTpl_selected (b0 : Host.Mlx.FfiAne.St) (NB L T i : Nat) (tk : Nat → Nat)
    (hNB : 15235 ≤ NB) (hctx : L + T ≤ 262144) (hs : DecSel T L tk .${b.l} i) :
    CaseTplAtM M K env (fullProjFb b0 NB) Host.Load.Run.Prompt.addrPrompt inputs L
      ${X}.s11.ffi (pinTab decVal ${S1}.tab)
      (certAt choice.cert ${b.tpl}.tokenNode) choice.outputs i NB :=
  caseTpl M K env b0 NB L i hNB (by have := hs.1.2.1; omega) (${b.selName} hs.1.2.2)

end ${ns}
`);
  await put("End", `import host.route.cert.Dec.${C}.Inputs
import host.sim.template.a4dec4_${b.l}.EEnd
import host.sim.compose.ChainFill
${opts}
set_option autoImplicit false
namespace ${ns}
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Full Host.Ts.Sim.Compose
open Host.Mlx.SimGraph Host.Mlx.SimGraph.Iter
open Host.Mlx.FfiEval
open Host.Route.Cert.Dec (cacheNodes inputs)

kernel_rfl end_read : ${X}.σ.node 20157 = 22538
kernel_rfl end_fed : ${X}.σ.node 22538 = certAt choice.cert ${b.tpl}.tokenNode
kernel_rfl end_caches : cacheNodes.map (fun p =>
    (p.1.map ${X}.σ.node, p.2.map ${X}.σ.node)) = choice.outputs
kernel_rfl end_readback : (mlxOf ${X}.s11.ffi).items.get 20157 = some (.ref 79)
kernel_rfl end_read_present : ((mlxOf ${X}.s11.ffi).nodes.get 20157).isSome = true
kernel_rfl end_tokens : (mlxOf ${X}.s11.ffi).tokens = []
kernel_rfl end_output_present : ((mlxOf ${X}.s11.ffi).nodes.get
    (certAt choice.cert ${b.tpl}.tokenNode)).isSome = true
kernel_rfl end_cache_present : PresentB (mlxOf ${X}.s11.ffi) choice.outputs = true

/-- Readback, output and cache carriers at the exact checked ${b.word} end and restart map. -/
noncomputable def endGM (b0 : Host.Mlx.FfiAne.St) (NB : Nat) :
    EndGM inputs ((${X}.iterEnd NB).toFb b0) where
  outT := certAt choice.cert ${b.tpl}.tokenNode
  outs := choice.outputs
  read := end_read
  fed := end_fed
  caches := end_caches
  h1read := end_readback
  h1pread := end_read_present
  s1tok := end_tokens
  pout := end_output_present
  pouts := present_of_B _ _ end_cache_present

end ${ns}
`);
};

for (const a of process.argv.slice(2)) {
  const [C, n] = a.split(":");
  await gen(C, Number(n));
}
