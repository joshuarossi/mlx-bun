import host.route.FamCert
import host.route.GpuMem
import host.sim.compose.Gpu
import host.simgraph.mach.Schedule
import host.simgraph.mach.PreRow
import host.simgraph.mach.Widths
import host.sim.compose.a4b.VWBodyCut
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.FfiAneEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (cachesAt cachesAt_below)
open Host.Mlx.SimGraph.Mach (routeVal pipeTy_of_loaded stageW_loaded rowSem_ok gpuFamily_rows initial_pre)
open Host.Mlx.SimGraph.Ref (RSt refRows routeStep rowSem gpuFamily tailStep)
open Host.Ts.Sim (LoadP Map)
open Host.Ts.Sim.Prefill (drains tailRows)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Ts.Sim.Compose.Gpu (drains_short tailRows_short)
open Host.Ts.Sim (SegInst)

/-! # A first tail's forward at the bookkeeping

`coldFwd`: a certificate on the template at the forward's return takes the cold bookkeeping to the pre-final one, with the
closures' table read off the relation there (`tableOf`). Each body's `hfwd` instantiates it. -/

/-- The closures' table on the target's handles. -/
def tableOf (M : Map) (kinds : List (Nat × Compiled)) : Nat → Option Compiled :=
  fun h => (kinds.find? fun e => M.handle e.1 == h).map (·.2)

theorem tableOf_eq (M : Map) : ∀ (kinds : List (Nat × Compiled)),
    (∀ a ∈ kinds, ∀ b ∈ kinds, M.handle a.1 = M.handle b.1 → a.1 = b.1) →
    ∀ c k, kindOf kinds c = some k → tableOf M kinds (M.handle c) = some k
  | [], _, c, k, h => by simp [kindOf] at h
  | e :: l, hinj, c, k, h => by
    by_cases he : e.1 = c
    · simp only [kindOf, List.find?_cons, he, beq_self_eq_true, Option.map_some, Option.some.injEq] at h
      subst h
      simp [tableOf, List.find?_cons, he]
    · have hne : (e.1 == c) = false := by simpa using he
      simp only [kindOf, List.find?_cons, hne] at h
      obtain ⟨a, ha, hak⟩ := Option.map_eq_some_iff.mp h
      have hac : a.1 = c := by simpa using List.find?_some ha
      have hmem := List.mem_of_find?_eq_some ha
      have hn : (M.handle e.1 == M.handle c) = false := by
        simp only [beq_eq_false_iff_ne, ne_eq]
        intro hh
        exact he ((hinj e (List.mem_cons_self ..) a (List.mem_cons_of_mem _ hmem) (by rw [hac]; exact hh)).trans hac)
      have ih := tableOf_eq M l (fun x hx y hy => hinj x (List.mem_cons_of_mem _ hx) y (List.mem_cons_of_mem _ hy)) c k h
      simpa only [tableOf, List.find?_cons, hn] using ih

variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat}

/-- **The reference's first tail**, as a family's step. -/
theorem routeStep_tail (w : PipelineWeights) {pk : ProjKind} {mk : MlpKind} {rd : Read} {L : Nat} {s : RSt} {hs' : List Handles}
    (hd : drains L = 0) (ht : tailRows L = L - 1) (h3 : 3 ≤ L)
    (hfam : gpuFamily .tail (L - 1) = some (rowTpl refRows pk mk rd))
    (hv : rowSem P KR env.weights w π (rowTpl refRows pk mk rd) 0 (L - 1) s.hs = some hs') :
    routeStep P KR NE KR.inPlace net env.weights w π (tailStep L) s = some { s with hs := hs' } := by
  have hstart : (tailStep L).start = 0 := by simp [tailStep, hd]
  have hstop : (tailStep L).stop = L - 1 := rfl
  have hph : (tailStep L).phase = .tail := by
    have : tailRows L ≠ 1 := by omega
    simp [tailStep, this]
  unfold routeStep
  rw [hstart, hstop, hph, Nat.sub_zero, if_neg (by omega), hfam]
  dsimp only
  rw [hv]
  rfl

/-- **A first tail's forward.** The certificate, the native relation at the forward's return, the prompt's ids at the
carrier, and the cold bookkeeping before the forward give the pre-final bookkeeping after it. -/
theorem coldFwd {pk : ProjKind} {mk : MlpKind} {rd : Read} (c : FamCert pk mk rd Expected.stages)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (Cr : Nat → List (Option Nat × Option Nat)) (hCr : Cr π.length = c.carriers)
    (hlt : ∀ t ∈ π, t < 2 ^ 31) (hL3 : 3 ≤ π.length) (hL : π.length ≤ 224)
    (hfam : gpuFamily .tail (π.length - 1) = some (rowTpl refRows pk mk rd))
    {Pm : LoadP} {NB m : Nat} {x y : SegInst FF}
    (hmr : Host.Ts.Sim.G.MR Pm NB y.M m c.s (mlxOf y.t.ffi)) (hband : Pm.NL = Pm.N0) (hE : (Pm.E : Int) ≤ 131072)
    (hNB : 15235 ≤ NB)
    (hnum : ∀ i e, nth? c.S.tab i = some e → y.C.val (y.M.nv (.ref i)) = some (e.eval y.ν))
    (ν : Nat → Int) (hB : InBox c.B ν) (hρ : ∀ j l h, c.B.get j = some (l, h) → y.ν j = F64.ofInt (ν j))
    (hx : ν c.x = ((π.length - 1 : Nat) : Int))
    (hip : ∀ tab, Host.Ts.Sim.CSrv.Le y.C ⟨tab⟩ → HostInt32 (concrete (CSrv.val ⟨tab⟩)) (mlxOf y.t.ffi) (y.M.node 15235)
      ((π.take (π.length - 1)).map Int.ofNat) [1, ((π.length - 1 : Nat) : Int)])
    (hparam : ∀ p ∈ parameterTensors parameterChoice, p.node < 15235)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens) (L : Nat)
    (hm : memCold P KR net env π L x) : memPre P KR NE net env π Cr L y := by
  intro hLe
  subst hLe
  let κ := tableOf y.M c.kinds
  have hk : ∀ c' k, kindOf c.kinds c' = some k → κ (y.M.handle c') = some k :=
    tableOf_eq y.M c.kinds fun a ha b hb e =>
      hmr.hinj a.1 b.1 (.inr (c.kindsPresent a ha)) (.inr (c.kindsPresent b hb)) e
  have hd : drains π.length = 0 := drains_short hL
  have hte : tailRows π.length = π.length - 1 := tailRows_short hL
  refine ⟨κ, ?_⟩
  rw [hCr]
  refine ColdG.preG_tail hle hd (by omega) (hm rfl κ) fun tab hC hb _ => ?_
  have hpw := pipeTy_of_loaded P.toMlxContract KR.toKernelContract
    (firstPipeline_loaded P.toMlxContract KR.toKernelContract env tab leaves typed)
  have hw := stageW_loaded _ hpw
  obtain ⟨pk', mk', rd', e, hf⟩ := gpuFamily_rows hfam (show 2 ≤ π.length - 1 by omega)
  obtain ⟨hs', hv⟩ : ∃ hs', rowSem P KR env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π
      (rowTpl refRows pk mk rd) 0 (π.length - 1) initialHandles = some hs' := by
    rw [e]
    obtain ⟨hs', h, -⟩ := rowSem_ok P KR env.weights _ 0 (π.length - 1) initialHandles π pk' mk' rd' hf (.inl rfl) hpw hw
      (initial_pre _) (by omega) hlt
    exact ⟨hs', h⟩
  have hb' := hb.grow hg ht
  have hpar : ∀ p ∈ parameterTensors parameterChoice, routeVal P KR env κ (fun _ => none) tab (mlxOf y.t.ffi) (y.M.node p.node) =
      some (firstValues P.toMlxContract KR.toKernelContract env tab p) := fun p hp => by
    rw [hmr.nid p.node (Nat.lt_of_lt_of_le (hparam p hp) hNB)]
    exact (hb'.params p hp).1
  have hval := c.values P KR env κ tab hmr hband hE y.ν ν (π.length - 1) π (fun i e h => hC.val (hnum i e h)) hB hρ hx (by omega)
    hk (hip tab hC) hpar (initial_stage_layout _) (sig_cold c.hn₀ (by omega) _ stages_cold) hs' hv
  refine ⟨{ refInit net with hs := hs' }, routeStep_tail _ hd hte hL3 hfam hv, ?_, trivial⟩
  refine { toBase := hb', values := hval, below := cachesAt_below _ _ _ fun p hp j hj => ?_ }
  obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hp
  obtain ⟨-, -, h1, h2⟩ := c.outsLt q hq
  rcases hj with hj | hj
  · obtain rfl := Option.some.inj hj
    exact hmr.nall _ h1
  · obtain rfl := Option.some.inj hj
    exact hmr.nall _ h2

theorem box_cases {j : Nat} {l h : Int} (hg : Box.get [(9, 10, 224), (10, 9, 223)] j = some (l, h)) :
    (j = 9 ∧ l = 10 ∧ h = 224) ∨ (j = 10 ∧ l = 9 ∧ h = 223) := by
  unfold Box.get at hg
  by_cases h9 : j = 9
  · subst h9
    simp at hg
    exact .inl ⟨rfl, hg.1.symm, hg.2.symm⟩
  · by_cases h10 : j = 10
    · subst h10
      simp at hg
      exact .inr ⟨rfl, hg.1.symm, hg.2.symm⟩
    · simp [List.find?_cons, Ne.symm h9, Ne.symm h10] at hg

/-- **A first tail's forward over a body whose return reads `L` at variable 9 and `n` at variable 10.** -/
theorem bodyFwd {pk : ProjKind} {mk : MlpKind} {rd : Read} (c : FamCert pk mk rd Expected.stages)
    (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (Cr : Nat → List (Option Nat × Option Nat)) (hlt : ∀ t ∈ π, t < 2 ^ 31) {NB T : Nat} {tk : Nat → Nat} (hNB : 15235 ≤ NB)
    {s : St FF.S} {S : SSrv} {Θ : List Nat × List SymE} {O : Host.Ts.Sim.Compose.VWFirst.BodyOff}
    (hs : c.s = mlxOf s.ffi) (hS : c.S.tab = S.tab) (hBx : c.B = [(9, 10, 224), (10, 9, 223)]) (hcx : c.x = 10)
    (hCr : Cr π.length = c.carriers) (hparam : ∀ p ∈ parameterTensors parameterChoice, p.node < 15235)
    {i : Host.Ts.Sim.Lin.Cls.Inst} (hn : 9 ≤ i.n) (hn' : i.n ≤ 223) (hLn : i.L = i.n + 1)
    (hfam : gpuFamily .tail i.n = some (rowTpl refRows pk mk rd)) {x y : SegInst FF}
    (hy : (Host.Ts.Sim.Compose.VWFirst.bodyCore NB T tk π i Θ O [(9, .L), (10, .n)] s S).R y s ⟨S.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hg : Host.Mlx.Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi))
    (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens)
    (hm : memCold P KR net env π i.L x) : memPre P KR NE net env π Cr i.L y := by
  obtain ⟨K0, hr, hb, -, hip, -, hmap, -⟩ := hy
  have hLen : π.length = i.L := hb.length
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M S.tab.length c.s (mlxOf y.t.ffi) := by
    rw [hs]
    exact r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 131072 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact Int.le_refl _
  have h9 : y.ν 9 = F64.ofNat i.L := hmap.1
  have h10 : y.ν 10 = F64.ofNat i.n := hmap.2.1
  have hin : i.n = π.length - 1 := by omega
  refine coldFwd c leaves typed Cr hCr hlt (by omega) (by omega) (by rw [← hin]; exact hfam) hmr hband hE hNB
    (fun j e h => hr.srv.num j e (hS ▸ h)) (fun j => if j = 9 then (i.L : Int) else (i.n : Int)) ?_ ?_ ?_ ?_ hparam hle hg ht i.L hm
  · rw [hBx]
    intro j l h hget
    rcases box_cases hget with ⟨rfl, rfl, rfl⟩ | ⟨rfl, rfl, rfl⟩
    · change (10 : Int) ≤ (i.L : Int) ∧ (i.L : Int) ≤ 224
      omega
    · change (9 : Int) ≤ (i.n : Int) ∧ (i.n : Int) ≤ 223
      omega
  · rw [hBx]
    intro j l h hget
    rcases box_cases hget with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩
    · exact h9
    · exact h10
  · rw [hcx, ← hin]
    simp
  · intro tab hC
    have hg' := (hip.grow (Host.Mlx.Ffi.NGrow.refl _) hC).2
    have hl : (π.take i.n).length = i.n := by simp; omega
    rw [hl] at hg'
    rw [← hin]
    exact hg'

end Host.Route.PrefGraph
