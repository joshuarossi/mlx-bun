import host.route.cert.Row.Fwd
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option autoImplicit false
namespace Host.Route.Cert.Row
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter (Gr cachesAt cachesAt_below CachesBelow)
open Host.Mlx.SimGraph.Mach (refPrompt refPrompt_decodes RefTokens ForwardAtV)
open Host.Ts.Sim (LoadP Map SegInst capL)
open Host.Ts.Sim.Full (FF mlxOf)
open Host.Route.PrefGraph

/-! # A POST row's change of bookkeeping

`hfw`: POST's reference held through time `L + d` before a row, through `L + d + 1` at the row's end, from its checked
certificate (`RowCert`). The row's map agrees with the start's on the carriers it reads. -/

variable {C : M1Max.Contract} {P : MlxPrefillContract C} {KR : RouteKernelContract C} {NE : NeuralEngine}
  {net : Host.Mlx.SimGraph.Ref.AneNet} {env : FfiEval.Env InKey} {π : List Nat}

/-- **A row's end holds the reference one time further.** -/
theorem hfw (leaves : Leaves code env.weights) (typed : TypedCheckpoint env.weights)
    (hRT : ∀ tab, RefTokens P KR NE KR.inPlace net env π tab) {sE : St FF.S} {SE : SSrv} {d : Nat}
    (c : RowCert (mlxOf sE.ffi) SE d) (hd : d ≤ 1)
    (htoN : certAt c.cert Tpl.Ordinary.tokenNode < (mlxOf sE.ffi).nnext)
    (hoN : ∀ p ∈ c.outs, ∀ j, (p.1 = some j ∨ p.2 = some j) → j < (mlxOf sE.ffi).nnext)
    {NB T cap nI : Nat} {tk : Nat → Nat} (hNB : 15235 ≤ NB) (hL1 : 1 ≤ π.length) (hL2 : π.length ≤ 224)
    (toks : Nat → Nat → Nat) (Cr Cr' : Nat → List (Option Nat × Option Nat))
    (htf : toks π.length d = c.fed) (hps : Cr π.length = c.ps)
    (hto : toks π.length (d + 1) = certAt c.cert Tpl.Ordinary.tokenNode) (hos : Cr' π.length = c.outs) (L : Nat)
    (x y : SegInst FF) (hy : (Host.Ts.Sim.Compose.Post.indexedCut NB T tk cap nI π sE SE).R y sE ⟨SE.tab, []⟩)
    (hle : Host.Ts.Sim.CSrv.Le x.C y.C) (hnode : y.M.node = x.M.node)
    (hg : Ffi.NGrow (mlxOf x.t.ffi) (mlxOf y.t.ffi)) (ht : (mlxOf y.t.ffi).tokens = (mlxOf x.t.ffi).tokens)
    (hm : memPost P KR NE net env π d toks Cr L x) : memPost P KR NE net env π (d + 1) toks Cr' L y := by
  intro hL
  subst hL
  obtain ⟨kind, hp⟩ := hm rfl
  refine ⟨kind, fun tab hC => ?_⟩
  obtain ⟨γ, hr, hb⟩ := hy
  obtain ⟨Pm, hP, r0⟩ := hr.ffi.1
  have hmr : Host.Ts.Sim.G.MR Pm NB y.M SE.tab.length (mlxOf sE.ffi) (mlxOf y.t.ffi) := r0.load.mlx
  have hband : Pm.NL = Pm.N0 := by rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> rfl
  have hE : (Pm.E : Int) ≤ 5554869888 := by
    rcases hP with rfl | ⟨k, -, -, rfl⟩ <;> exact (by decide : ((131072 : Nat) : Int) ≤ 5554869888)
  have hrope := hmr.bigFixHi 5554869888 hE (by decide)
  have hcap : capL π.length = 256 := by unfold capL; omega
  have hρ : ∀ j l h, Box.get boxRow j = some (l, h) → y.ν j = F64.ofInt (nuRow π.length j) := by
    intro j l h hget
    rcases boxRow_cases hget with ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩ | ⟨rfl, -, -⟩
    · exact hb.promptValue
    · exact hb.rowValue
    · exact hb.offsetValue
    · exact hb.capValue.trans (by rw [hcap]; rfl)
  have hx := hp tab (hle.trans hC)
  rw [hnode]
  obtain ⟨tok, hs, hR, hcv, hcaps, hcb⟩ := hx.cur
  obtain ⟨_, _, tok', hs', h0, hR2, -⟩ := (hRT tab).2 (π.length + d) (by omega)
  obtain ⟨rt, rh⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans h0))
  subst rt rh
  obtain ⟨_, _, t2, _, -, hprev, hlt, -⟩ := (hRT tab).2 (π.length + d - 1) (by omega)
  rw [show π.length + d - 1 + 1 = π.length + d by omega, hR] at hprev
  obtain ⟨rt2, -⟩ := Prod.mk.inj (Option.some.inj hprev)
  have hb31 : tok < 2 ^ 31 := by rw [rt2]; omega
  obtain ⟨_, ⟨tok1, hs1, hR1, ⟨r, hr1, hi⟩, _⟩, ho, _⟩ := hx.hist d (Nat.le_refl _)
  obtain ⟨rt3, rh3⟩ := Prod.mk.inj (Option.some.inj (hR.symm.trans hR1))
  subst rt3 rh3
  have hgy := hx.ok
  obtain ⟨hrt, hrc, hrcap⟩ := row_fwd P KR env kind leaves typed
    (refPrompt_decodes P KR NE KR.inPlace net env π) c tab hmr hNB hband hrope y.ν hL1 hL2 hρ
    (fun i e h => hC.val (hr.srv.num i e h)) hR hR2 hb31 (by omega)
    (by unfold capL; omega) hcaps
    (by
      rw [hnode, ← hps]
      exact hcv.mono fun c' hc' v hv u hu => (routeVs P KR env kind).val_grow hgy hg _ _ (hcb c' hc' v hv) hu)
    ⟨r, by rw [hnode, ← htf]; exact (routeVs P KR env kind).val_grow hgy hg _ _ ho hr1, hi⟩
    (fun t ht' => (routeVs P KR env kind).val_grow hgy hg _ _ (hx.params t ht').2 (hx.params t ht').1)
  rw [hnode] at hrt hrc
  have hnall : ∀ j, j < (mlxOf sE.ffi).nnext → x.M.node j < (mlxOf y.t.ffi).nnext := fun j hj => by
    have := hmr.nall j hj
    rwa [hnode] at this
  refine hx.next hg ht (σ' := x.M.node) (toks' := toks π.length) (Cr' := Cr' π.length) (fun _ _ => rfl)
    ⟨tok', hs', hR2, ?_, ?_, hrcap⟩ ?_ ?_
  · rw [hto]
    exact hrt
  · rw [hos]
    exact hrc
  · rw [hto]
    exact hnall _ htoN
  · rw [hos]
    refine cachesAt_below _ _ _ fun q hq j hj => ?_
    exact hnall _ (hoN q hq j hj)

end Host.Route.Cert.Row
