import host.sim.template.a4pre_d1_body.TraceReplay
import host.sim.template.a4pre_d1_body.TraceRecord
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Trace shapesOf)

theorem selectTrace_mem (sl : Bool) (bv : List (List Nat × Nat)) :
    ∀ {ts : List Trace} {vs : List (List (List Nat × Nat))} {t : Trace},
      selectTrace sl bv ts vs = some t → t ∈ ts
  | [], _, _, h => by cases h
  | _ :: _, [], _, h => by cases h
  | a :: ts, v :: vs, t, h => by
    simp only [selectTrace] at h
    cases he : fitValues sl v bv
    · rw [he, Bool.cond_false] at h
      exact List.mem_cons_of_mem _ (selectTrace_mem sl bv h)
    · rw [he, Bool.cond_true] at h
      cases h
      exact List.mem_cons_self

/-- The actual compiled closure application: an effectful shaped lookup, then
the original indexed replay or the original cold recording callback. -/
theorem closureApplySim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64}
    {S : SSrv} {C : CSrv} {x y : NSt} {o : Arg} {ck kv cb : Nat} {pl : Arg}
    {sl : Bool} {ts : List Trace} {xs : List Nat}
    {b : List (List Dim × Nat)} {bv : List (List Nat × Nat)}
    {vs : List (List (List Nat × Nat))}
    (hs : Srv M ν S C) (hr : G.MR P NB M S.tab.length x y) (hpr : G.PendReg M x y)
    (ho : slotOk P x o = true)
    (hcl : x.obj? ck = some (.clo (.compiled cb pl sl ts)))
    (hvec : x.obj? kv = some (.vec xs))
    (hxs : ∀ k ∈ xs, PN x k) (hb : shapesOf x xs = some b)
    (hvb : ShapesV M C S b bv) (hvs : TraceValues M C S x ts vs)
    (hReplay : ∀ t ∈ ts,
      rchk P.NL ck x (t.ins.zip xs) t.order = true ∧
      (∀ k ∈ t.ins, PN x k) ∧ (∀ k ∈ t.outs, PN x k) ∧ x.nnext + t.order.length ≤ P.NE)
    (hroomN : x.nnext + xs.length ≤ P.NE) (hE : x.next + 2 ≤ P.E) :
    MSim (G.MPost P NB M ν S C) S C
      (Host.Mlx.Ffi.closureApply x o (.big (Int.ofNat ck)) (.big (Int.ofNat kv)))
      (Host.Mlx.Ffi.closureApply y (M.arg o) (M.arg (.big (Int.ofNat ck))) (M.arg (.big (Int.ofNat kv)))) := by
  have hpc : PH x ck := .inr (by rw [show x.objs.get ck = some (.clo (.compiled cb pl sl ts)) from hcl]; rfl)
  have hpv : PH x kv := .inr (by rw [show x.objs.get kv = some (.vec xs) from hvec]; rfl)
  have hmc : M.arg (.big (Int.ofNat ck)) = .big (Int.ofNat (M.handle ck)) := by
    change Arg.big (M.big (Int.ofNat ck)) = _
    rw [(hr.present ck hpc).1]
  have hmv : M.arg (.big (Int.ofNat kv)) = .big (Int.ofNat (M.handle kv)) := by
    change Arg.big (M.big (Int.ofNat kv)) = _
    rw [(hr.present kv hpv).1]
  have hyc : y.obj? (M.handle ck) = some (.clo (.compiled (M.region cb) (M.arg pl) sl (ts.map M.trace))) := by
    rw [hr.obj? hpc, hcl]
    rfl
  have hyv : y.obj? (M.handle kv) = some (.vec (xs.map M.node)) := by
    rw [hr.obj? hpv, hvec]
    rfl
  have hpl : SA (· < S.tab.length) pl := hr.cl.2.1 ck _ hcl
  obtain ⟨buf, off, slot, hslot, hslot', hsl⟩ := hr.slot_map ho
  rw [hmc, hmv]
  unfold Host.Mlx.Ffi.closureApply
  simp only [hslot, hslot', argNat_nat, Option.bind_some, hcl, hvec, hyc, hyv]
  change MSim (G.MPost P NB M ν S C) S C
    (Host.Ts.M.bind (Host.Mlx.Ffi.findTrace x sl xs ts) (fun r => match r with
      | some t => Host.Mlx.Ffi.applyDone x ck buf off slot t xs
      | none => recordTail x buf off slot ck cb pl xs))
    (Host.Ts.M.bind (Host.Mlx.Ffi.findTrace y sl (xs.map M.node) (ts.map M.trace)) (fun r => match r with
      | some t => Host.Mlx.Ffi.applyDone y (M.handle ck) (M.a buf) off (M.handle slot) t (xs.map M.node)
      | none => recordTail y (M.a buf) off (M.handle slot) (M.handle ck) (M.region cb) (M.arg pl) (xs.map M.node)))
  refine MSim.bind (findTraceSim hb sl ts vs hs hr hvb hvs) ?_
  rintro M1 S1 C1 r r' ⟨rfl, hchosen, hg⟩
  have hr1 := hr.grow hg.grow
  have hs1 := hg.grow.srv
  have hhandles : M1.handle = M.handle := by
    funext k
    simp only [Map.handle, hg.grow.ext.big]
  cases r with
  | none =>
    simp only [Option.map_none]
    have hpl' := (NAgree.ofExt hg.grow.ext).arg hpl
    rw [← hg.grow.ext.a, ← hhandles, ← hg.grow.ext.region, ← hpl', ← hg.grow.ext.node]
    refine MSim.mono (recordSim hs1 hr1 (hpr.names hg.grow.ext.big hg.grow.ext.region) hxs hroomN hE) ?_
    rintro M2 S2 C2 a a' ⟨gg, hp⟩
    exact ⟨hg.grow.trans gg, hp⟩
  | some t =>
    simp only [Option.map_some]
    have ht := selectTrace_mem sl bv hchosen.symm
    obtain ⟨hck, hi, hout, hroom⟩ := hReplay t ht
    rw [← hg.grow.ext.a, ← hhandles, ← hg.grow.ext.node]
    refine MSim.mono (applyDoneSim hs1 hr1 hck hi hxs hout hroom hsl (by omega)) ?_
    rintro M2 S2 C2 a a' ⟨gg, hp⟩
    exact ⟨hg.grow.trans gg, hp⟩

end Host.Load.Run.Tpl.D1BodyTrace
