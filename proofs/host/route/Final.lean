import host.simgraph.world.MachRoute
import host.simgraph.mach.Schedule
import host.sim.full.World
import host.sim.full.BridgeFrame
import host.mlx.KernelGpuPrefill
import host.load.RoutePrompt
import host.load.run.tail.World
import host.load.nat.Core
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Mach (refPrompt prefillHolds_two RefTokens PrefillTyped prefillTyped_of_schedule scheduleTyped
  refPrompt_tokens_total AneNetOk)
open Host.Mlx.SimGraph.Ref (PrefillHolds refPromptModel)
open Host.Ts.Sim (Addr WFrame LoopFramesA LoopBase LoopStartW HaltSegW HaltStopSrc FinalOk ExitOk FinalEOk
  LastGStepW CutGStepW DecodeItersW DecodeInvW valL)
open Host.Ts.Sim.Prefill (RouteGoalW FirstEos NoEos PathW PrefInvsW PrefStepsPW CutStep tokVals loopCutW
  source_tokens_prompt_routeW source_tokens_prompt_allW)
open Host.Ts.Sim.Full (FF fullWorld fullWorldFb Quiet bridgeOf mlxOf)

/-! # The route of a prompt: the final theorem

**The claim** (`RouteOutcome`; `route_final` from the generated artifacts, `route_main` in
`host.route.Main` from the generated pieces). For a prompt `π` (`1 ≤ |π|`, tokens below `248320`) and a
budget `1 ≤ T` with `|π| + T ≤ 262144`, the full-world run of the actual source, booted with `π`, halts
normally; it emits the reference's tokens `1 … T`, or at the first EOS `k` tokens `1 … k - 1` with
`finishReason = "stop"`; its graph holds the reference's forward results at the emitted tokens' times, the
memoized readbacks' values and, without EOS, the program's final caches at the reference's last handles.

**The trust boundary** (the premises): the operation contract `C : M1Max.Contract`; MLX's native and
prefill operations `P : MlxPrefillContract C`; the GPU `G : Metal.Gpu C` with its pipelines' limits `Pg`
and the `setBytes` alignment `B` (the kernel contract `routeKernel G B Pg lseSum lseNumerator`, with the
native logsumexp's choices); the Neural Engine `NE` and its success on the loaded programs (`NE.Succeeds net`:
at every bucket of 224–2048 rows each split program of the loaded model's Neural Engine side evaluates on its
declared inputs, as the GPU assumption's launches succeed); the environment and the checkpoint (`env`,
`leaves`, `typed`); for the model-level corollary, the checkpoint's parameter ranges.

**The machine-level reference** `refPrompt π` (`host.simgraph.mach.Ref`): what the machine computes, at
every table: the prefill of `π` through the route's kernels and Neural Engine calls at their contracts'
values, then the D1 decode step's trace, each token the argmax of the lm head's logits. No model and no range
certificate enter it, so its tokens are the machine's, not the model's; `RefTokens` states the sequence (each
token a D1 graph's argmax, a vocabulary index). The Neural Engine's evaluation (`NE.eval`) is uninterpreted
and nothing fixes the surfaces' contents when the bridge starts (`init`), so the reference may depend on them:
the emitted tokens are the machine reference's evaluated at the same initial surface contents `init` as the
run, for every such `init` (`route_main`).

**The model-level corollary** (only at `|π| ≤ 2`): where the prefill's caches lie within the model's ranges
(`PrefillHolds`, proved for one and two tokens, `prefillHolds_short`), the reference's tokens and forward
results are the model's greedy decode after prefilling `π` (`refPromptModel`). For longer prompts no range
analysis bounds the MMA kernels and the Neural Engine, and the theorem claims the machine's tokens only.

**What remains.** `route_final` takes the Neural Engine side `net` with `hnet` (`AneNetOk`), the booted
state `s` with `hs`, the route's artifacts `Ar` and the boot's run `hboot` as hypotheses. `route_main`
(`host.route.Main`) discharges `net`, `hnet`, `s`, `hs` and `hboot`, and builds `Ar` from the pieces:
* `net` is the Neural Engine side the boot's end state holds (`netLd`): its buckets and bridge read off
  `ldStT` (`aneNetLd_state`), its arrays' values the loaded graph's contents (`contentsLd`, the state's own
  arrays at their nodes, `tensor_live`), its surfaces `init`: the surfaces' contents when the bridge starts,
  which the FFI model leaves unspecified and which the bridge's memory at `loadDone` holds (`aneNetSt_mem`);
  `route_main` holds for every `init`. `hnet` is `aneNetLd_ok`. `contentsLd` reads the loaded graph at the
  empty prompt and readbacks (`ldStT [] []`), the same graph as at every prompt and readback suffix
  (`contentsLd_eq`, the boot's `ldContents_any`), so the arrays' values are those of the route's own end state.
* `s`, `hs` and `hboot`'s run are the boot's (`route_boot`: the booted state `bootedSt`, its full-world
  run to `ldStT`).
* `hboot`'s invariant: the prefill starts from a fixed loadDone cut (`ldCut`, `host.route.Gen`; the pieces'
  `RouteGen.hI`): the boot's template state `ldStT [] []` with the load's table, related to the target by the
  full world's relation under the route's frames `W` (none on the prompt array) at the readbacks
  `machReads T tk`, the identity map, the valuation `machVal T tk` (template variables below `2 ^ 20`), the
  prompt array framed, the Neural Engine memory before any forward (`AneFresh`). It holds at the boot's end
  (`ldCut_inv`: `Ld.rel_full` widened to `W` (`RelB.widen`), `P.S2818_eq`, `ldBridge_final`).
Its one remaining premise is `Gn` (generation, Phase C/D, marked `-- pending`): the route's generated pieces
(`RouteGen`, A4b's `route_of_pieces`), their prefill starting from `ldCut` at the load parameters `LdParams`.
With `hnet` and `NE.Succeeds` the prefill schedule keeps the handles typed (A5's `scheduleTyped`), so the
reference is defined along the route at every table (`route_refTokens`, `refPrompt_table`), the route's
tokens are its tokens (`machTok_def`) and vocabulary indices (`machTok_le`). -/

variable {C : M1Max.Contract}

/-! ## The route's constants -/

/-- **The route's kernel contract** from the GPU assumption. -/
abbrev routeKernel (G : Metal.Gpu C) (B : KernelGpu.SetBytes) (Pg : KernelGpu.RoutePipelines G) (lseSum : Bool)
    (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction) : RouteKernelContract C :=
  KernelGpu.ofGpuRoute G B Pg lseSum lseNumerator

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet)
  (env : FfiEval.Env InKey) (π : List Nat)

/-- **The machine reference's tokens** (at the empty table): token `j` is the reference's token at
`|π| + j - 1` (token `1` the first generated one). -/
noncomputable def machTok (j : Nat) : Nat :=
  ((refPrompt P KR NE KR.inPlace net env π [] (π.length + j - 1)).map Prod.fst).getD 0

/-- The machine reference reads the table only through the loaded weights, which do not depend on it
(`first_weights_table_eq`). -/
theorem refPrompt_table (tab : List F64) :
    refPrompt P KR NE KR.inPlace net env π tab = refPrompt P KR NE KR.inPlace net env π [] := by
  funext t
  unfold refPrompt Host.Mlx.SimGraph.Ref.prefillAt
  rw [first_weights_table_eq P.toMlxContract KR.toKernelContract env tab []]

/-- **The route's tokens are the reference's** at every table: token `j + 1` at `|π| + j`. -/
theorem machTok_def (hR : RefTokens P KR NE KR.inPlace net env π []) (hπ : 1 ≤ π.length) (tab : List F64)
    (j : Nat) : ∃ hs, refPrompt P KR NE KR.inPlace net env π tab (π.length + j) = some (machTok P KR NE net env π (j + 1), hs) := by
  obtain ⟨tok, hs, tok', hs', -, h1, -⟩ := hR.2 (π.length - 1 + j) (by omega)
  rw [show π.length - 1 + j + 1 = π.length + j by omega] at h1
  refine ⟨hs', ?_⟩
  unfold machTok
  rw [refPrompt_table P KR NE net env π tab, show π.length + (j + 1) - 1 = π.length + j by omega, h1]
  rfl

/-- **The route's tokens are vocabulary indices**: token `j ≥ 1` a step's argmax (`RefTokens`), token `0`
the prompt's last (`hlt`). -/
theorem machTok_le (hR : RefTokens P KR NE KR.inPlace net env π []) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320)
    (j : Nat) : machTok P KR NE net env π j ≤ 248319 := by
  unfold machTok
  rcases Nat.eq_zero_or_pos j with rfl | hj
  · have hm : π.getD (π.length - 1) 0 < 248320 :=
      hlt _ (by
        rw [List.getD_eq_getElem?_getD, List.getElem?_eq_getElem (by omega : π.length - 1 < π.length), Option.getD_some]
        exact List.getElem_mem _)
    rw [Nat.add_zero, hR.1]
    rcases Host.Mlx.SimGraph.Ref.prefillAt P KR NE KR.inPlace net env π [] with _ | s
    · simp
    · simp only [Option.map_some, Option.getD_some]
      omega
  · obtain ⟨tok, hs, tok', hs', -, h1, hlt', -⟩ := hR.2 (π.length - 1 + (j - 1)) (by omega)
    rw [show π.length + j - 1 = π.length - 1 + (j - 1) + 1 by omega, h1]
    simp only [Option.map_some, Option.getD_some]
    omega

/-- The decode loop's graph invariant at the machine reference over the full world. -/
abbrev machGx (NB : Nat) (Itpl : Iter.TplInputs) : Nat → Sim.Map → St (fullWorld NB).F.S → CSrv → Prop :=
  liftG (fullWorld NB) (GxM P.toMlxContract KR.toKernelContract env Itpl (refPrompt P KR NE KR.inPlace net env π)
    π.length)

/-- The halted target's machine-level goal at `k` tokens over the full world. -/
abbrev goalM (NB k : Nat) : St (fullWorld NB).F.S → CSrv → Prop :=
  machGoal P KR NE KR.inPlace net env π (Wd := fullWorld NB) k

/-- **The halted target's goal without EOS** at `T` tokens: `goalM` and the program's final caches (the
`cache` binding's tensors) hold the reference's handles at time `|π| + T - 1` (`GFC` at the machine
reference). -/
abbrev goalC (NB T : Nat) (je : Host.Ts.Env) : St (fullWorld NB).F.S → CSrv → Prop := fun tF CF =>
  goalM P KR NE net env π NB T tF CF ∧ ∃ cs out, Sim.ExtractSim.cachesT (tF.reFfi (Layers.toLoad tF.ffi)) je = some cs ∧
    Mach.ForwardAtM P.toMlxContract KR.toKernelContract env (refPrompt P KR NE KR.inPlace net env π) CF.tab
      (π.length + T - 1) cs out (Iter.Gr CF.tab ((fullWorld NB).toMlx tF.ffi))

end

/-- The table's valuation: the budget `T` and the route's tokens. -/
def machVal (T : Nat) (tk : Nat → Nat) : Nat → F64 := fun j => if j = 0 then F64.ofNat T else F64.ofNat (tk j)

/-- The native readbacks after the first two (read through the table's symbols): tokens `3 … T`. -/
def machReads (T : Nat) (tk : Nat → Nat) : List NumV := (List.range (T - 2)).map fun j => .lit (F64.ofNat (tk (j + 3)))

/-- **The route's native world**: `Decode.world` with the route's readbacks. -/
def routeWorld (T : Nat) (tk : Nat → Nat) : LSt := Host.Load.Run.Tail.worldTail (machReads T tk)

/-- **The route's server**: the load's table at the budget and tokens. -/
def routeServer (T : Nat) (tk : Nat → Nat) : CSrv := ⟨Decode.tab.map (SymE.eval (machVal T tk))⟩

/-- **The full-world start** of a booted state: the layers' initial states. -/
def bootStart (s : St LSt) : St FF.S := s.reFfi (Layers.start ⟨s.ffi, FfiAne.St.empty⟩)

/-! ## The generated artifacts -/

/-- **The decode cut over the pinned worlds**: `loopCutW`'s start, table and bookkeeping, its relation at
some pinned bridge `b0`, inactive or quiet, of the full world with the target's bridge framed and pinned
(`fullWorldFb b0 NB`). The bridge is the prefill's at its exit (A1's `full_handoffTb`); decode keeps it. -/
def decCutFb (NB : Nat) (A : Addr) (Gx : Nat → Sim.Map → St FF.S → CSrv → Prop) (W : Nat → Option WFrame)
    (Pd : Sim.LoadP) (Fr : LoopFramesA A) (s0 : St FF.S) (tab0 : List SymE) (fixA : List Nat) (V : Sim.LoopVals)
    (tk : Nat → Nat) (toks : List NumV) (E0 : List Val) (B : LoopBase) : Host.Ts.Sim.Prefill.ICut FF where
  s0 := s0
  tab0 := tab0
  R := fun x s S => ∃ b0 : Host.Mlx.FfiAne.St,
    (b0.active = false ∨ Quiet x.M (mlxOf s.ffi) (mlxOf x.t.ffi) b0) ∧
      (loopCutW (fullWorldFb b0 NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).R x s S
  B := (loopCutW (fullWorld NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).B

/-- At the decode cut, some pinned bridge's cut invariant. -/
theorem decCutFb_inv {NB : Nat} {A : Addr} {Gx : Nat → Sim.Map → St FF.S → CSrv → Prop} {W : Nat → Option WFrame}
    {Pd : Sim.LoadP} {Fr : LoopFramesA A} {s0 : St FF.S} {tab0 : List SymE} {fixA : List Nat} {V : Sim.LoopVals}
    {tk : Nat → Nat} {toks : List NumV} {E0 : List Val} {B : LoopBase} {t : St FF.S} {C : CSrv}
    (h : (decCutFb NB A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).Inv t C) :
    ∃ b0, (loopCutW (fullWorldFb b0 NB) A Gx W Pd Fr s0 tab0 fixA V tk toks E0 B).Inv t C :=
  let ⟨x, ht, hC, ⟨b0, _, hR⟩, hB⟩ := h
  ⟨b0, x, ht, hC, hR, hB⟩

/-- **The decode loop's generated artifacts at a budget `T ≥ 3`, independent of the pinned bridge**
(pending: generation, Phase C/D; assembled by A4b's `route_of_pieces`): the regenerated decode template's
constants, POST to the decode cut over the pinned worlds (`decCutFb`, at the decode load parameters `Pd`)
and its prefix token, the token-1 EOS path from the prefill's exit (over `fullWorld NB`). -/
structure LoopCut (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)
    (NB : Nat) (Pw Pd : Sim.LoadP) (A : Addr) (W : Nat → Option WFrame) (fixA : List Nat)
    (I : PrefInvsW (fullWorld NB).F) where
  -- the regenerated decode template
  Fr : LoopFramesA A
  s0 : St FF.S
  tab0 : List SymE
  Itpl : Iter.TplInputs
  ρ : Nat → F64
  toks : List NumV
  E0 : List Val
  B : LoopBase
  ΔJ : Nat
  ΔH : Nat
  ΔN : Nat
  -- POST and the decode cut
  nP : Nat
  hpost : tk 1 ≠ 248044 → CutStep (I.ps π.length) (I.dec π.length) nP
  hdec : I.dec π.length = decCutFb NB A (machGx P KR NE net env π NB Itpl) W Pd Fr s0 tab0 fixA (valL ρ T tk π.length) tk toks E0 B
  e1 : NumV
  hE0 : E0 = [.num e1]
  he1 : ∀ t C, (I.dec π.length).Inv t C → C.val e1 = some (F64.ofNat (tk 1))
  hA : A.nxt = 17
  hfrN : ∀ e ∈ tab0, e.noVar A.nxt = true
  hwe : W A.emit = none
  -- the token-1 EOS path from the prefill's exit
  P1 : tk 1 = 248044 → PathW (fullWorld NB) A W Pw fixA (I.ps π.length) []
  s1H : ∀ h, HaltStopSrc (P1 h).hs
  hG1 : ∀ h, (P1 h).Goal (goalM P KR NE net env π NB 1)

/-- **The decode loop's generated artifacts at the pinned bridge `b0`** (pending: generation, Phase C/D;
assembled by A4b's `route_of_pieces`): the pieces and certificates the decode route takes, over
`fullWorldFb b0 NB` at the decode load parameters `Pd`, the machine reference's loop invariant (`machGx`)
and goals (`goalC`, `goalM`); proved for every `b0`. -/
structure LoopDec (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat)
    (je : Host.Ts.Env) (NB : Nat) (Pw Pd : Sim.LoadP) (A : Addr) (W : Nat → Option WFrame) (fixA : List Nat)
    (I : PrefInvsW (fullWorld NB).F) (Lc : LoopCut P KR NE net env π T tk NB Pw Pd A W fixA I)
    (b0 : Host.Mlx.FfiAne.St) where
  st : LoopStartW (fullWorldFb b0 NB) A Pd Lc.s0 Lc.tab0
  -- the decode iterations, each with its graph certificate
  hit : DecodeItersW (DecodeInvW (fullWorldFb b0 NB) A (machGx P KR NE net env π NB Lc.Itpl) W Pd Lc.Fr Lc.s0
    Lc.tab0 fixA (valL Lc.ρ T tk π.length) tk Lc.toks Lc.E0 Lc.B Lc.ΔJ Lc.ΔH Lc.ΔN) T tk
  -- the final chains, the EOS exit, the EOS final chains
  F0 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt])
    [.num (.ref A.tok), .num (.ref Lc.tab0.length)]
  F1 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt])
    [.num (.ref A.tok), .num (.ref Lc.tab0.length)]
  F2 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt])
    [.num (.ref A.tok), .num (.ref Lc.tab0.length)]
  c0 : FinalOk false false F0.S0.oracle
  c1 : FinalOk true false F1.S0.oracle
  c2 : FinalOk false true F2.S0.oracle
  hQA : ∀ K : Sim.Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Lc.Fr.xs) → K.lo = Pd.lo → K.hi = Pd.E →
    F0.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K ∧ F1.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K ∧
      F2.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K
  X : ∀ k, HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (k - 1)) Lc.s0 Lc.s0 Lc.tab0 []
  cX : ∀ k, ExitOk (X k).S0.oracle
  hQX : ∀ k, 2 ≤ k → k < T → ∀ nx (K : Sim.Ctx), nx ≤ 2 ^ 20 →
    (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Lc.Fr.xs) → K.lo = Pd.lo → K.hi = Pd.E →
    (X k).QA (valL Lc.ρ T tk π.length (k - 1) nx) K
  sX : ∀ k, 2 ≤ k → k < T → HaltStopSrc (X k)
  FE0 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt]) [.num (.ref A.tok)]
  FE1 : HaltSegW (fullWorldFb b0 NB) A W Pd (Lc.toks.drop (T - 1)) Lc.s0
    ((fullWorldFb b0 NB).finalStartW Lc.s0 Lc.tab0.length) (Lc.tab0 ++ [.var A.nxt]) [.num (.ref A.tok)]
  c0E : FinalEOk false FE0.S0.oracle
  c1E : FinalEOk true FE1.S0.oracle
  hQE : ∀ K : Sim.Ctx, (∀ a, K.fr a ≠ none ↔ a ∈ A.fwd :: A.emit :: Lc.Fr.xs) → K.lo = Pd.lo → K.hi = Pd.E →
    FE0.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K ∧ FE1.QA (valL Lc.ρ T tk π.length (T - 2) (tk T)) K
  s0E : HaltStopSrc FE0
  s1E : HaltStopSrc FE1
  hlen : T - 1 ≤ Lc.toks.length
  -- the halts' graph certificates
  hF : NoEos tk T → (T - 2) % 256 ≠ 0 → (T - 1) % 256 ≠ 0 →
    LastGStepW A (machGx P KR NE net env π NB Lc.Itpl) Pd W Lc.Fr fixA F0 (valL Lc.ρ T tk π.length) tk
      (goalC P KR NE net env π NB T je)
  hF0 : NoEos tk T → (T - 2) % 256 = 0 →
    LastGStepW A (machGx P KR NE net env π NB Lc.Itpl) Pd W Lc.Fr fixA F1 (valL Lc.ρ T tk π.length) tk
      (goalC P KR NE net env π NB T je)
  hF1 : NoEos tk T → (T - 1) % 256 = 0 →
    LastGStepW A (machGx P KR NE net env π NB Lc.Itpl) Pd W Lc.Fr fixA F2 (valL Lc.ρ T tk π.length) tk
      (goalC P KR NE net env π NB T je)
  hX : ∀ k, 2 ≤ k → k < T → FirstEos tk T k →
    CutGStepW A (machGx P KR NE net env π NB Lc.Itpl) Pd W Lc.Fr fixA (X k) (valL Lc.ρ T tk π.length)
      (goalM P KR NE net env π NB k)
  hFE : FirstEos tk T T → (T - 2) % 256 ≠ 0 →
    LastGStepW A (machGx P KR NE net env π NB Lc.Itpl) Pd W Lc.Fr fixA FE0 (valL Lc.ρ T tk π.length) tk
      (goalM P KR NE net env π NB T)
  hFE0 : FirstEos tk T T → (T - 2) % 256 = 0 →
    LastGStepW A (machGx P KR NE net env π NB Lc.Itpl) Pd W Lc.Fr fixA FE1 (valL Lc.ρ T tk π.length) tk
      (goalM P KR NE net env π NB T)

/-- **The route's generated artifacts** (pending: generation, Phase C/D; assembled by A4b's
`route_of_pieces`): the full world's parameters, the driver's cells, the prefill's checked steps, the
short budgets' paths with their stops and certificates (`source_tokens_prompt_allW`'s), and the decode
loop's at `T ≥ 3` (`LoopArtifacts`). -/
structure RouteArtifacts (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet)
    (env : FfiEval.Env InKey) (π : List Nat) (T : Nat) (tk : Nat → Nat) (je : Host.Ts.Env) (nm : Host.Ts.Name) where
  NB : Nat
  Pw : Sim.LoadP
  Pd : Sim.LoadP
  A : Addr
  W : Nat → Option WFrame
  fixA : List Nat
  I : PrefInvsW (fullWorld NB).F
  SP : PrefStepsPW I
  hcE : A.cE ∈ fixA
  hb : A.emit ∈ fixA
  hgen : A.gen ∈ fixA
  hwc : W A.cE = none
  henv : lookupEnv nm je = some A.cE
  hgenv : lookupEnv chars!"generation" je = some A.gen
  P21 : T = 2 → tk 1 = 248044 → PathW (fullWorld NB) A W Pw fixA (I.ps π.length) []
  P22 : T = 2 → tk 1 ≠ 248044 → tk 2 = 248044 → PathW (fullWorld NB) A W Pw fixA (I.ps π.length) (tokVals tk 1)
  P20 : T = 2 → tk 1 ≠ 248044 → tk 2 ≠ 248044 → PathW (fullWorld NB) A W Pw fixA (I.ps π.length) (tokVals tk 2)
  P11 : T = 1 → tk 1 = 248044 → PathW (fullWorld NB) A W Pw fixA (I.ps π.length) []
  P10 : T = 1 → tk 1 ≠ 248044 → PathW (fullWorld NB) A W Pw fixA (I.ps π.length) (tokVals tk 1)
  s21 : ∀ h h', HaltStopSrc (P21 h h').hs
  s22 : ∀ h h' h'', HaltStopSrc (P22 h h' h'').hs
  s11 : ∀ h h', HaltStopSrc (P11 h h').hs
  g21 : ∀ h h', (P21 h h').Goal (goalM P KR NE net env π NB 1)
  g22 : ∀ h h' h'', (P22 h h' h'').Goal (goalM P KR NE net env π NB 2)
  g20 : ∀ h h' h'', (P20 h h' h'').Goal (goalC P KR NE net env π NB T je)
  g11 : ∀ h h', (P11 h h').Goal (goalM P KR NE net env π NB 1)
  g10 : ∀ h h', (P10 h h').Goal (goalC P KR NE net env π NB T je)
  loop : 3 ≤ T → LoopCut P KR NE net env π T tk NB Pw Pd A W fixA I
  dec : ∀ (h3 : 3 ≤ T) (b0 : Host.Mlx.FfiAne.St), LoopDec P KR NE net env π T tk je NB Pw Pd A W fixA I (loop h3) b0

/-! ## The route over the pinned decode worlds -/

/-- **The route of a prompt with a budget `T ≥ 3` from the artifacts** (`source_tokens_prompt_routeW` with the
prefill over `fullWorld NB` and the decode over the pinned world `fullWorldFb b0 NB` of the bridge `b0` the
decode cut holds; the decode artifacts are the same for every `b0`). -/
theorem route_loopFb {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
    {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}
    {je : Host.Ts.Env} {nm : Host.Ts.Name} (Ar : RouteArtifacts P KR NE net env π T tk je nm) (hπ : 1 ≤ π.length)
    (h3 : 3 ≤ T) (hctx : π.length + T ≤ 262144) {N0 : Nat} {t0 tL : St FF.S} {C0 CL : CSrv}
    (hboot : runC FF N0 t0 C0 = some (tL, CL)) (hld : (Ar.I.ld π.length).Inv tL CL)
    (htk : ∀ j, j ≤ T → tk j ≤ 2 ^ 20) :
    RouteGoalW t0 C0 je nm T tk (goalC P KR NE net env π Ar.NB T je) (fun k => goalM P KR NE net env π Ar.NB k) := by
  classical
  let Lc := Ar.loop h3
  have hL2 : π.length ≤ 262143 := by omega
  have hLT : π.length + T < 2 ^ 29 := by omega
  have hps := Host.Ts.Sim.Prefill.prefill_reach_psW Ar.SP hπ hL2
  -- the decode cut after POST: a pinned bridge, the seam invariant over its world, the prefix's and readbacks' values
  have post : tk 1 ≠ 248044 → ∃ N1 t1 C1 b0, runC FF N1 t0 C0 = some (t1, C1) ∧
      DecodeInvW (fullWorldFb b0 Ar.NB) Ar.A (machGx P KR NE net env π Ar.NB Lc.Itpl) Ar.W Ar.Pd Lc.Fr Lc.s0 Lc.tab0
        Ar.fixA (valL Lc.ρ T tk π.length) tk Lc.toks Lc.E0 Lc.B Lc.ΔJ Lc.ΔH Lc.ΔN 1 t1 C1 ∧
      C1.val Lc.e1 = some (F64.ofNat (tk 1)) ∧
      ∀ j (hj : j < Lc.toks.length), C1.val Lc.toks[j] = some (F64.ofNat (tk (j + 2))) := by
    intro h1
    obtain ⟨t1, C1, hr1, hinv⟩ := (hps.trans (Lc.hpost h1)) tL CL hld
    have hv1 := Lc.he1 t1 C1 hinv
    rw [Lc.hdec] at hinv
    obtain ⟨b0, hinv⟩ := decCutFb_inv hinv
    have hinv' := (Host.Ts.Sim.Prefill.loopCutW_inv (Wd := fullWorldFb b0 Ar.NB) Lc.ΔJ Lc.ΔH Lc.ΔN t1 C1).1 hinv
    have hc := hinv'
    obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hvals, -⟩ := hc
    exact ⟨_, t1, C1, b0, Host.Ts.Sim.Prefill.runC_trans hboot hr1, hinv', hv1, hvals⟩
  by_cases hex : ∃ k, 1 ≤ k ∧ k ≤ T ∧ tk k = 248044
  · -- the first EOS
    obtain ⟨k, hk⟩ : ∃ k, FirstEos tk T k := by
      refine ⟨Nat.find hex, (Nat.find_spec hex).1, (Nat.find_spec hex).2.1, (Nat.find_spec hex).2.2,
        fun j h1 h2 he => Nat.find_min hex h2 ⟨h1, ?_, he⟩⟩
      have := (Nat.find_spec hex).2.1; omega
    obtain ⟨hk1, hkT, heos, hmin⟩ := hk
    refine Host.Ts.Sim.Prefill.RouteGoalW.ofFirst ⟨hk1, hkT, heos, hmin⟩ ?_
    by_cases hk1' : k = 1
    · -- token 1: a path from the prefill's exit
      subst hk1'
      obtain ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩ := Host.Ts.Sim.Prefill.source_haltW hboot hld hps
        ((Lc.P1 heos).halt (Fin := Host.Ts.Sim.stopFin je) Ar.hcE Ar.hb Ar.hwc Ar.henv
          ((Lc.s1H heos).toW Ar.hgen Ar.hgenv) (Lc.hG1 heos))
      exact ⟨N, tF, CF, hr, hv, hle, hem, hg, hs⟩
    · -- tokens `2 … T`: POST, then the decode route's EOS stop at the pinned bridge
      have hk2 : 2 ≤ k := by omega
      obtain ⟨N1, t1, C1, b0, hpre, hinv, hv1, hvals⟩ := post (hmin 1 le_rfl (by omega))
      let Ld := Ar.dec h3 b0
      obtain ⟨N, tF, CF, hrun, hv, hle, ⟨hem, hg⟩, hfin⟩ := Host.Ts.Sim.decode_source_eosLW
        (Fin := Host.Ts.Sim.stopFin je) (G := goalM P KR NE net env π Ar.NB k)
        Lc.hA Ld.st Lc.hfrN Ar.hcE Ar.hb Ar.hwc Lc.hwe k hk2 hkT
        (fun i h1 h2 h3' => Ld.hit i h1 h3' fun j hj1 hj2 => hmin j hj1 (by omega)) (Ld.X k) (Ld.cX k) Ld.FE0 Ld.FE1
        Ld.c0E Ld.c1E (fun h => Ld.hQX k hk2 h) Ld.hQE
        (fun h => (Ld.sX k hk2 h).toW Ar.hgen Ar.hgenv) (fun _ => Ld.s0E.toW Ar.hgen Ar.hgenv)
        (fun _ => Ld.s1E.toW Ar.hgen Ar.hgenv) Ar.henv h3 hLT Ld.hlen htk (fun j h2 h3' => hmin j (by omega) h3') heos
        (fun h => Ld.hX k hk2 h ⟨hk1, hkT, heos, hmin⟩)
        (fun h hc => by subst h; exact Ld.hFE ⟨hk1, hkT, heos, hmin⟩ hc)
        (fun h hc => by subst h; exact Ld.hFE0 ⟨hk1, hkT, heos, hmin⟩ hc) hpre hinv
      rw [Lc.hE0] at hem
      have hvs := Host.Ts.Sim.Prefill.emitted_toks (m := k - 2) (hle.val hv1) (fun j hj => hle.val (hvals j hj)) (by omega)
      rw [show k - 2 + 1 = k - 1 by omega] at hvs
      exact ⟨N, tF, CF, hrun, hv, (Host.Ts.Sim.Prefill.runC_le _ _ _ _ _ hpre).trans hle,
        Host.Ts.Sim.Prefill.emittedValsW_of hem hvs, hg, hfin⟩
  · -- no EOS among tokens `1 … T`: POST, the decode route at the pinned bridge, the final chains
    have hno : NoEos tk T := fun j h1 h2 he => hex ⟨j, h1, h2, he⟩
    refine Host.Ts.Sim.Prefill.RouteGoalW.ofNo hno ?_
    obtain ⟨N1, t1, C1, b0, hpre, hinv, hv1, hvals⟩ := post (hno 1 le_rfl (by omega))
    let Ld := Ar.dec h3 b0
    obtain ⟨N, tF, CF, hrun, hv, hle, hem, hg⟩ := Host.Ts.Sim.decode_sourceLW Lc.hA Ld.st Lc.hfrN Ar.hcE Ar.hb Ar.hwc
      Lc.hwe (fun i h1 h2 => Ld.hit i h1 h2 fun j hj1 hj2 => hno j hj1 (by omega))
      Ld.F0 Ld.F1 Ld.F2 Ld.c0 Ld.c1 Ld.c2 Ld.hQA Ar.henv h3 hLT Ld.hlen htk (fun j h2 h3' => hno j (by omega) h3')
      (Ld.hF hno) (Ld.hF0 hno) (Ld.hF1 hno) hpre hinv
    rw [Lc.hE0] at hem
    have hvs := Host.Ts.Sim.Prefill.emitted_toks (m := T - 1) (hle.val hv1) (fun j hj => hle.val (hvals j hj)) Ld.hlen
    rw [show T - 1 + 1 = T by omega] at hvs
    exact ⟨N, tF, CF, hrun, hv, (Host.Ts.Sim.Prefill.runC_le _ _ _ _ _ hpre).trans hle,
      Host.Ts.Sim.Prefill.emittedValsW_of hem hvs, hg⟩

/-! ## The model-level premise at `|π| ≤ 2` -/

section
variable (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet)
  (env : FfiEval.Env InKey) (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)

/-- **At one token the premise holds** for every token: the prefill is empty, the empty caches hold the
initial state. -/
theorem prefillHolds_single (a : Nat) : PrefillHolds P KR NE KR.inPlace net env leaves typed [a] :=
  fun _ => ⟨TokenAutoregressive.initial _ promptToken, ⟨initialHandles, net.surfaces, []⟩, rfl, initialChainHolds _⟩

/-- **The model-level premise at `|π| ≤ 2`** (`prefillHolds_single`, `prefillHolds_two`). -/
theorem prefillHolds_short (parameters : TokenSequenceRanges.Parameters
      (firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed)) {π : List Nat} (hπ : 1 ≤ π.length) (hL : π.length ≤ 2) (hlt : ∀ t ∈ π, t < 248320) :
    PrefillHolds P KR NE KR.inPlace net env leaves typed π := by
  match π, hπ, hL with
  | [a], _, _ => exact prefillHolds_single P KR NE net env leaves typed a
  | [a, b], _, _ => exact prefillHolds_two P KR NE KR.inPlace net env leaves typed parameters a b (hlt a (by simp))
  | [], h, _ => exact absurd h (by simp)
  | _ :: _ :: _ :: _, _, h => exact absurd h (by simp)

end

/-! ## The machine reference along the route -/

/-- **The machine reference's token sequence** at every table (A5's `refPrompt_tokens_total` under the GPU
assumption): the prefill is typed from the schedule's multi-row steps (`prefillTyped_of_schedule`, A5's
`scheduleTyped` under the Neural Engine's success and the loaded model's Neural Engine side). -/
theorem route_refTokens (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights) {π : List Nat} (hπ : 1 ≤ π.length)
    (hL : π.length ≤ 349525) (hlt : ∀ t ∈ π, t < 248320) (hNE : NE.Succeeds net)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G B Pg lseSum lseNumerator).toKernelContract env tab)))) (tab : List F64) :
    RefTokens P (routeKernel G B Pg lseSum lseNumerator) NE (routeKernel G B Pg lseSum lseNumerator).inPlace net env π
      tab := by
  have hpre : PrefillTyped P (routeKernel G B Pg lseSum lseNumerator) NE (routeKernel G B Pg lseSum lseNumerator).inPlace
      net env π :=
    prefillTyped_of_schedule P _ NE _ net env π Pg rfl leaves typed hπ hL
      (scheduleTyped P _ NE net env π leaves typed hL hlt hNE hnet)
  exact refPrompt_tokens_total P _ NE _ net env π Pg rfl leaves typed hpre tab

/-! ## The final theorem -/

/-- **The route's outcome** at the full world `fullWorld NB` from the booted state `s`: the target halts
normally and emits the reference's tokens `1 … T` with the program's final caches at the reference
(`goalC`), or at the first EOS `k` tokens `1 … k - 1` with `"stop"` (`goalM`); the reference's token
sequence at every table (`RefTokens`); at `|π| ≤ 2` the tokens and forward results are the model's. -/
def RouteOutcome (P : MlxPrefillContract C) (KR : RouteKernelContract C) (NE : NeuralEngine)
    (net : Host.Mlx.SimGraph.Ref.AneNet) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights) (π : List Nat) (T : Nat) (s : St LSt) (NB : Nat) : Prop :=
  RouteGoalW (bootStart s) (routeServer T (machTok P KR NE net env π)) (entryEnv s) chars!"emitted" T
      (machTok P KR NE net env π) (goalC P KR NE net env π NB T (entryEnv s))
      (fun k => goalM P KR NE net env π NB k) ∧
    (∀ tab, RefTokens P KR NE KR.inPlace net env π tab) ∧
    (π.length ≤ 2 → ∀ parameters : TokenSequenceRanges.Parameters
        (firstPipeline P.toMlxContract KR.toKernelContract env [] leaves typed),
      ∃ h : PrefillHolds P KR NE KR.inPlace net env leaves typed π,
        RouteGoalW (bootStart s) (routeServer T (machTok P KR NE net env π)) (entryEnv s) chars!"emitted" T
            (machTok P KR NE net env π)
            (fun tF CF => GFR P.toMlxContract KR.toKernelContract env leaves typed
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h) π.length T CF.tab
              ((fullWorld NB).toMlx tF.ffi))
            (fun k tF CF => GFR P.toMlxContract KR.toKernelContract env leaves typed
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h) π.length k CF.tab
              ((fullWorld NB).toMlx tF.ffi)) ∧
          ∀ tab j (_ : j < T) (hb : π.length + j ≤ 262144),
            machTok P KR NE net env π (j + 1) =
              (refPromptModel P KR NE KR.inPlace net env leaves typed parameters π h tab (π.length + j) hb).token.val)

/-- **The route of a prompt, at the machine reference, every budget and first EOS position** (see the
module doc). -/
theorem route_final (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144)
    -- the loaded model's Neural Engine side (`route_main`: the boot's `aneNetLd c init`)
    (net : Host.Mlx.SimGraph.Ref.AneNet)
    -- the Neural Engine succeeds on the loaded programs (trust boundary)
    (hNE : NE.Succeeds net)
    -- the Neural Engine side as the route's Neural Engine steps need it (`route_main`: `aneNetLd_ok`)
    (hnet : ∀ tab, AneNetOk net (stageWeights (weights (firstValues P.toMlxContract
      (routeKernel G B Pg lseSum lseNumerator).toKernelContract env tab))))
    -- booting the prompt route with the route's readbacks (`route_main`: `route_boot`)
    (s : St LSt)
    (hs : bootL (RoutePrompt.cx π) (routeWorld T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π))
      2000 = some s)
    -- the route's artifacts (`route_main`: from the generated pieces by A4b's `route_of_pieces`)
    (Ar : RouteArtifacts P (routeKernel G B Pg lseSum lseNumerator) NE net env π T
      (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π) (entryEnv s) chars!"emitted")
    -- the full-world run of the boot to the loadDone cut (`route_main`: `route_boot` and `hld`)
    (hboot : ∃ N0 tL CL, runC (fullWorld Ar.NB).F N0 (bootStart s)
      (routeServer T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π)) = some (tL, CL) ∧
      (Ar.I.ld π.length).Inv tL CL) :
    RouteOutcome P (routeKernel G B Pg lseSum lseNumerator) NE net env leaves typed π T s Ar.NB := by
  unfold RouteOutcome
  obtain ⟨N0, tL, CL, hrun, hld⟩ := hboot
  have hRT := route_refTokens P G Pg B lseSum lseNumerator NE net env leaves typed hπ (by omega) hlt hNE hnet
  have hdef := fun tab j (_ : j < T) => machTok_def P (routeKernel G B Pg lseSum lseNumerator) NE net env π (hRT []) hπ tab j
  have htkb : ∀ j, j ≤ T → machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π j ≤ 2 ^ 20 := fun j _ =>
    Nat.le_trans (machTok_le P _ NE net env π (hRT []) hπ hlt j) (by decide)
  have hm : RouteGoalW (bootStart s) (routeServer T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π))
      (entryEnv s) chars!"emitted" T (machTok P (routeKernel G B Pg lseSum lseNumerator) NE net env π)
      (goalC P (routeKernel G B Pg lseSum lseNumerator) NE net env π Ar.NB T (entryEnv s))
      (fun k => goalM P (routeKernel G B Pg lseSum lseNumerator) NE net env π Ar.NB k) := by
    refine source_tokens_prompt_allW (Wd := fullWorld Ar.NB) (A := Ar.A) (W := Ar.W) (P := Ar.Pw) (fixA := Ar.fixA)
      π hπ hT hctx Ar.SP hrun hld Ar.hcE Ar.hb Ar.hgen Ar.hwc Ar.henv Ar.hgenv
      (fun h3 => ?_) Ar.P21 Ar.P22 Ar.P20 Ar.P11 Ar.P10 Ar.s21 Ar.s22 Ar.s11 Ar.g21 Ar.g22 Ar.g20 Ar.g11 Ar.g10
    exact route_loopFb Ar hπ h3 hctx hrun hld htkb
  refine ⟨hm, hRT, fun hL parameters => ?_⟩
  have h := prefillHolds_short P (routeKernel G B Pg lseSum lseNumerator) NE net env leaves typed parameters hπ hL hlt
  have hm' := hm.mono (G' := goalM P (routeKernel G B Pg lseSum lseNumerator) NE net env π Ar.NB T)
    (GE' := fun k => goalM P (routeKernel G B Pg lseSum lseNumerator) NE net env π Ar.NB k) (fun _ _ hg => hg.1)
    (fun _ _ _ _ hg => hg)
  exact ⟨h, route_model_of_mach P _ NE _ net env leaves typed parameters (Wd := fullWorld Ar.NB) h hlt hπ hdef hm'⟩

end Host.Route
