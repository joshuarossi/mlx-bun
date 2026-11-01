import host.sim.template.a4pre_d1_body.TraceValues
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl.D1BodyTrace
open Host.Ts Host.Ts.Sim Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Trace)

def replayOk (P : LoadP) (x : NSt) (ck : Nat) (xs : List Nat) (t : Trace) : Bool :=
  t.ins.all (fun n => (x.nodes.get n).isSome) &&
    t.outs.all (fun n => (x.nodes.get n).isSome) &&
    t.ins.all (valuedN x) && rchk P.NL ck x (t.ins.zip xs) t.order &&
    decide (x.nnext + t.order.length ≤ P.NE)

/-- The existing slot, handle, input, trace and room guards. Shaped comparison
is covered by the proved effectful lookup, rather than a purity guard. -/
def applyOk (P : LoadP) (x : NSt) : List Arg → Bool
  | [o, c, v] => slotOk P x o && hdOk x c && vecOk x v && decide (x.next + 2 ≤ P.E) &&
    match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj?, Host.Mlx.Ffi.argNat c with
    | some (.clo (.compiled _ _ _ ts)), some (.vec xs), some ck =>
      xs.all (fun n => (x.nodes.get n).isSome) && xs.all (valuedN x) &&
        ts.all (replayOk P x ck xs) && decide (x.nnext + xs.length ≤ P.NE)
    | _, _, _ => false
  | _ => false

def applyRefs (x : NSt) : List Arg → List Nat
  | [_, c, v] =>
    match (Host.Mlx.Ffi.argNat c).bind x.obj?, (Host.Mlx.Ffi.argNat v).bind x.obj? with
    | some (.clo (.compiled _ _ _ ts)), some (.vec xs) =>
      (xs ++ ts.flatMap Trace.ins).flatMap (nodeRefs x)
    | _, _ => []
  | _ => []

def ApplySmall (ν : Nat → F64) (S : SSrv) (x : NSt) (args : List Arg) : Prop :=
  ∀ j ∈ applyRefs x args, RefSmall ν S j

def applySmallB (VB : Nat → Nat) (S : SSrv) (x : NSt) (args : List Arg) : Bool :=
  (applyRefs x args).all (refSmallB VB S)

theorem applySmallB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : NSt} {args : List Arg}
    (hb : applySmallB VB S x args = true) (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) :
    ApplySmall ν S x args :=
  fun j hj => refSmallB_sound (List.all_eq_true.mp hb j hj) hν

theorem nativeSim {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv}
    {x y : NSt} {name : Name} {args : List Arg}
    (hs : Srv M ν S C) (hr : G.MR P NB M S.tab.length x y) (hpr : G.PendReg M x y)
    (hsym : Host.Mlx.Ffi.symOf name = some .closureApply)
    (hok : applyOk P x args = true) (hsm : ApplySmall ν S x args) :
    MSim (G.MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args)
      (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  unfold applyOk at hok
  split at hok
  case h_2 => cases hok
  rename_i o c v
  simp only [Bool.and_eq_true, decide_eq_true_eq] at hok
  obtain ⟨⟨⟨⟨ho, hc⟩, hv⟩, hE⟩, hm⟩ := hok
  obtain ⟨ck, rfl, hpc, hmc⟩ := hr.hdOk_spec hc
  obtain ⟨kv, xs, rfl, hmv, hpv, hvec, hvec'⟩ := hr.vecArg hv
  simp only [argNat_nat, Option.bind_some, hvec] at hm
  cases hco : x.obj? ck with
  | none => rw [hco] at hm; cases hm
  | some obj =>
    rw [hco] at hm
    cases obj with
    | clo cl =>
      cases cl with
      | compiled cb pl sl ts =>
        simp only [Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true] at hm
        obtain ⟨⟨⟨hxs, hxval⟩, hts⟩, hroomN⟩ := hm
        have href : ∀ j ∈ (xs ++ ts.flatMap Trace.ins).flatMap (nodeRefs x), RefSmall ν S j := by
          simpa only [ApplySmall, applyRefs, argNat_nat, Option.bind_some, hco, hvec] using hsm
        have hxrefs : ∀ n ∈ xs, ∀ j ∈ nodeRefs x n, RefSmall ν S j := by
          intro n hn j hj
          exact href j (List.mem_flatMap.mpr ⟨n, List.mem_append_left _ hn, hj⟩)
        obtain ⟨b, bv, hb, hvb⟩ := shapesVOfNodes hs xs hxs hxval hxrefs
        have htref : ∀ t ∈ ts, ∀ n ∈ t.ins, ∀ j ∈ nodeRefs x n, RefSmall ν S j := by
          intro t ht n hn j hj
          exact href j (List.mem_flatMap.mpr ⟨n,
            List.mem_append_right _ (List.mem_flatMap.mpr ⟨t, ht, hn⟩), hj⟩)
        have hguards : ∀ t ∈ ts,
            (∀ n ∈ t.ins, PN x n) ∧ (∀ n ∈ t.outs, PN x n) ∧
            (∀ n ∈ t.ins, valuedN x n = true) ∧
            rchk P.NL ck x (t.ins.zip xs) t.order = true ∧ x.nnext + t.order.length ≤ P.NE := by
          intro t ht
          have hh := hts t ht
          simpa only [replayOk, Bool.and_eq_true, List.all_eq_true, decide_eq_true_eq, and_assoc, PN] using hh
        obtain ⟨vs, hvs⟩ := traceValuesOfNodes hs ts
          (fun t ht => (hguards t ht).1)
          (fun t ht => (hguards t ht).2.2.1) htref
        have hreplay : ∀ t ∈ ts,
            rchk P.NL ck x (t.ins.zip xs) t.order = true ∧
            (∀ n ∈ t.ins, PN x n) ∧ (∀ n ∈ t.outs, PN x n) ∧ x.nnext + t.order.length ≤ P.NE := by
          intro t ht
          obtain ⟨hi, hout, hv, hk, hroom⟩ := hguards t ht
          exact ⟨hk, hi, hout, hroom⟩
        unfold Host.Mlx.Ffi.call
        rw [hsym]
        simp only [List.map_cons, List.map_nil]
        exact closureApplySim hs hr hpr ho hco hvec hxs hb hvb hvs hreplay hroomN hE
      | _ => cases hm
    | _ => cases hm

end Host.Load.Run.Tpl.D1BodyTrace
