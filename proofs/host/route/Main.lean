import host.route.Gen
import host.load.boot.Boot
import host.load.boot.ane.Ld
import host.load.boot.ane.Graph
import host.load.boot.ane.Cut
set_option maxRecDepth 1000000
namespace Host.Route
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Ts.Sim.Full (fullWorld mlxOf)
open Host.Load.Run.Prompt (ldStT route_boot aneNetLd aneNetLd_ok ldContents_any Ld.rel_full ldBridge_final)
open Host.Mlx.SimGraph.Iter (Gr)

/-! # The route of a prompt

`route_main`: `route_gen` (`host.route.Gen`: `route_final` from the generated pieces) at the boot's Neural
Engine side and run: the loaded model's Neural Engine side the one the boot's end state holds (`netLd`:
`aneNetLd` at the loaded graph's contents, `aneNetLd_state`; its `AneNetOk` by `aneNetLd_ok`), the booted
state and the boot's full-world run to `loadDone` the boot's (`route_boot`, `host.load.boot.Boot`), the prefill's
loadDone cut holding there (`ldCut_inv`, `bootedSt_ld`). -/

variable {C : M1Max.Contract}

/-- **The booted state** of the prompt route for `π` with the readbacks of the tokens `tk` (`route_boot`). -/
noncomputable def bootedSt (π : List Nat) (T : Nat) (tk : Nat → Nat) : St LSt :=
  Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T tk)

/-- **The loaded arrays' contents**: the values of the loaded graph's nodes at the boot's end state
(`Program.contents` of `ldStT`'s graph; the arrays the Neural Engine side reads are that state's own, at
their graph nodes, `tensor_live`). -/
noncomputable def contentsLd (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey) :
    Nat → Nat → Nat :=
  Host.Load.Program.contents P.toMlxContract KR.toKernelContract env (Gr [] (mlxOf (ldStT [] []).ffi))

/-- **The loaded contents are the run's**: the loaded graph at the boot's end state is the same for every
prompt and readback suffix (`ldContents_any`), so `contentsLd` is the contents at the route's own end state. -/
theorem contentsLd_eq (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
    (fw : List Val) (τ : List NumV) :
    Host.Load.Program.contents P.toMlxContract KR.toKernelContract env (Gr [] (mlxOf (ldStT fw τ).ffi)) =
      contentsLd P KR env :=
  ldContents_any P.toMlxContract KR.toKernelContract env _ _ fw τ

/-- **The loaded model's Neural Engine side**, the one the boot's end state holds (`aneNetLd_state`): its
buckets and bridge read off `ldStT`, its arrays' values the loaded contents (`contentsLd`), its surfaces
`init` (the surfaces' contents when the bridge starts, which the FFI model leaves unspecified; the bridge's
memory at `loadDone`, `aneNetSt_mem`). -/
noncomputable def netLd (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
    (init : Nat → Surface) : Host.Mlx.SimGraph.Ref.AneNet :=
  aneNetLd (contentsLd P KR env) init

/-! ## The boot in the route's terms -/

theorem bootStart_eq (s : St LSt) : bootStart s = Host.Load.Run.Prompt.bootStartF s := rfl

theorem bootedSt_eq (π : List Nat) (T : Nat) (tk : Nat → Nat) :
    bootedSt π T tk = Host.Load.Run.Prompt.P.at0 (π.map natV) (machReads T tk) := rfl

theorem routeServer_eq (T : Nat) (tk : Nat → Nat) :
    routeServer T tk = ⟨Decode.tab.map (SymE.eval (machVal T tk))⟩ := rfl

/-- **The prompt route's boot** at the route's readbacks (`route_boot`). -/
theorem bootedSt_boot (π : List Nat) (T : Nat) (tk : Nat → Nat) :
    bootL (RoutePrompt.cx π) (routeWorld T tk) 2000 = some (bootedSt π T tk) := by
  rw [bootedSt_eq]
  exact (route_boot π (machReads T tk) (machVal T tk)).1

/-- **The boot's full-world run to `loadDone`** at the route's server (`route_boot`). -/
theorem bootedSt_run (π : List Nat) (T : Nat) (tk : Nat → Nat) (NB : Nat) :
    runC (fullWorld NB).F 28172201 (bootStart (bootedSt π T tk)) (routeServer T tk) =
      some (ldStT (π.map natV) (machReads T tk), routeServer T tk) := by
  rw [bootStart_eq, bootedSt_eq, routeServer_eq]
  exact (route_boot π (machReads T tk) (machVal T tk)).2

/-! ## The loadDone cut's invariant -/

/-- **The prefill's loadDone cut holds at the boot's end** (`Ld.rel_full` at the route's readbacks and
valuation, widened to the route's frames off the prompt array; the boot's server `P.S2818_eq`; the Neural
Engine memory `ldBridge_final`). -/
theorem ldCut_inv (NB : Nat) (Pw : Sim.LoadP) (hPw : LdParams Pw NB) (W : Nat → Option Host.Ts.Sim.WFrame)
    (hW : W 2665 = none)
    (π : List Nat) (hlt : ∀ t ∈ π, t < 248320) (T : Nat) (tk : Nat → Nat) (hT : T ≤ 2 ^ 20)
    (htk : ∀ j, tk j ≤ 2 ^ 20) :
    (ldCut NB Pw W (ldStT [] []) T tk π.length).Inv (ldStT (π.map natV) (machReads T tk)) (routeServer T tk) := by
  obtain ⟨hlo, hE, hN, hNE, hNB⟩ := hPw
  have h := Ld.rel_full Pw NB hlo hE hN hNE hNB (machVal T tk) Pw.lo Pw.E (by omega) (π.map natV) (machReads T tk)
  rw [Host.Load.Run.Prompt.P.S2818_eq] at h
  have hw : ∀ a, W a ≠ none →
      (Host.Load.Run.Prompt.FrameRel.ctx (ldStT [] []) 2665 (π.map natV) Pw.lo Pw.E).fr a = none := by
    intro a ha
    rw [Host.Load.Run.Prompt.FrameRel.ctx_fr]
    have : a ≠ 2665 := fun e => ha (e ▸ hW)
    simp [this]
  have hv : Host.Ts.Sim.Full.VBOkF Sim.loopVB (machVal T tk) := fun v => by
    unfold machVal
    by_cases h0 : v = 0
    · exact ⟨T, hT, by simp [h0]⟩
    · exact ⟨tk v, htk v, by simp [h0]⟩
  exact ⟨⟨Sim.Map.id, machVal T tk, Host.Load.Run.Prompt.FrameRel.ctx (ldStT [] []) 2665 (π.map natV) Pw.lo Pw.E,
      ldStT (π.map natV) (machReads T tk), routeServer T tk⟩, rfl, rfl, RelB.widen h hw, rfl, rfl, hv,
    ⟨π, rfl, hlt, rfl⟩,
    fun _ Pc Kc weights kind NE IP G init => ldBridge_final Pc Kc weights kind NE IP G init _ _⟩

/-- **The boot's run to the prefill's loadDone cut**, for generated pieces starting from it (`RouteGen.hI`). -/
theorem bootedSt_ld {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
    {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat} {T : Nat} {tk : Nat → Nat}
    {je : Host.Ts.Env} {nm : Host.Ts.Name} (Gn : RouteGen P KR NE net env π T tk je nm (ldStT [] []))
    (hlt : ∀ t ∈ π, t < 248320) (hT : T ≤ 2 ^ 20) (htk : ∀ j, tk j ≤ 2 ^ 20) :
    ∃ N0 tL CL, runC (fullWorld Gn.NB).F N0 (bootStart (bootedSt π T tk)) (routeServer T tk) = some (tL, CL) ∧
      (Gn.I.ld π.length).Inv tL CL := by
  refine ⟨28172201, _, _, bootedSt_run π T tk Gn.NB, ?_⟩
  rw [Gn.hI]
  exact ldCut_inv Gn.NB Gn.Pw Gn.hPw Gn.W Gn.hW π hlt T tk hT htk

/-! ## The route of a prompt -/

/-- The route's tokens at the boot's Neural Engine side. -/
noncomputable abbrev tokLd (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (env : FfiEval.Env InKey) (π : List Nat) (init : Nat → Surface) : Nat → Nat :=
  machTok P (routeKernel G B Pg lseSum lseNumerator) NE
    (netLd P (routeKernel G B Pg lseSum lseNumerator) env init) env π

/-- **The route of a prompt from its generated pieces, at the machine reference, every budget and first
EOS position** (`route_gen` at the boot's Neural Engine side and run, the prefill starting from the boot's
loadDone cut; see `host.route.Final`'s module doc). It holds for every initial content `init` of the surfaces. -/
theorem route_main (P : MlxPrefillContract C) (G : Metal.Gpu C) (Pg : KernelGpu.RoutePipelines G)
    (B : KernelGpu.SetBytes) (lseSum : Bool) (lseNumerator : Inference.Kernels.Attention.SdpaUpdate.Contraction)
    (NE : NeuralEngine) (env : FfiEval.Env InKey) (leaves : Leaves code env.weights)
    (typed : TypedCheckpoint env.weights)
    (π : List Nat) (T : Nat) (hπ : 1 ≤ π.length) (hlt : ∀ t ∈ π, t < 248320) (hT : 1 ≤ T)
    (hctx : π.length + T ≤ 262144)
    -- the surfaces' contents when the bridge starts (unspecified by the FFI model)
    (init : Nat → Surface)
    -- the Neural Engine succeeds on the loaded programs (trust boundary)
    (hNE : NE.Succeeds (netLd P (routeKernel G B Pg lseSum lseNumerator) env init))
    -- pending: generation (Phase C/D), its prefill starting from the boot's loadDone cut
    (Gn : RouteGen P (routeKernel G B Pg lseSum lseNumerator) NE
      (netLd P (routeKernel G B Pg lseSum lseNumerator) env init) env π T
      (tokLd P G Pg B lseSum lseNumerator NE env π init)
      (entryEnv (bootedSt π T (tokLd P G Pg B lseSum lseNumerator NE env π init))) chars!"emitted" (ldStT [] [])) :
    RouteOutcome P (routeKernel G B Pg lseSum lseNumerator) NE
      (netLd P (routeKernel G B Pg lseSum lseNumerator) env init) env leaves typed π T
      (bootedSt π T (tokLd P G Pg B lseSum lseNumerator NE env π init)) Gn.NB :=
  have hnet := aneNetLd_ok P.toMlxContract (routeKernel G B Pg lseSum lseNumerator).toKernelContract env
    (contentsLd P (routeKernel G B Pg lseSum lseNumerator) env) init
  have hRT := route_refTokens P G Pg B lseSum lseNumerator NE _ env leaves typed hπ (by omega) hlt hNE hnet
  route_gen P G Pg B lseSum lseNumerator NE env leaves typed π T hπ hlt hT hctx _ hNE hnet
    _ (bootedSt_boot π T _) Gn
    (bootedSt_ld Gn hlt (by omega) fun j => Nat.le_trans (machTok_le P _ NE _ env π (hRT []) hπ hlt j) (by decide))

end Host.Route
