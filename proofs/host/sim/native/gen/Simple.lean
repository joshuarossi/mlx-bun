import host.sim.native.Simple
import host.sim.native.gen.Args
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! `host.sim.native.Simple` for the general native relation `G.MR` (`host.sim.native.gen.Rel`):
the same statements and proofs, with the pre-load band bound `NB` threaded through. -/

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)

include hs hr

theorem sim_arrayNew (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.arrayNew) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name []) (Host.Mlx.Ffi.call y name []) := by
  have e : ∀ s : NSt, Host.Mlx.Ffi.call s name [] = Host.Mlx.Ffi.ok s (.big 0) := fun s => by
    unfold Host.Mlx.Ffi.call; rw [hsym]
  rw [e, e]
  have := msim_ok (r := .big 0) hs hr
  rwa [show M.ret (.big 0) = .big 0 by show Ret.big (M.big 0) = _; rw [hr.big0]] at this

theorem sim_arrayFree (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.arrayFree) {a : Arg} (ha : hdOk x a = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, rfl, hp, hm⟩ := hr.hdOk_spec ha
  have e : ∀ (s : NSt) (h : Nat), Host.Mlx.Ffi.call s name [.big (Int.ofNat h)] =
      Host.Mlx.Ffi.ok (s.freeArr h) Host.Mlx.Ffi.status0 := fun s h => by
    unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [argNat_nat]
  rw [hm, e, e]
  have hk0 := hr.PH_ne_zero hp
  have hf : ∀ (s : NSt) (h : Nat), h ≠ 0 → s.freeArr h = { s with arrs := s.arrs.set h 0 } := by
    intro s h hh
    unfold Host.Mlx.Ffi.St.freeArr
    have : Nat.beq h 0 = false := by cases e : Nat.beq h 0; rfl; exact absurd (Nat.eq_of_beq_eq_true e) hh
    rw [this]; rfl
  rw [hf _ _ hk0, hf _ _ (hr.handle_pos hp)]
  have := msim_ok (r := Host.Mlx.Ffi.status0) hs (by have := hr.setArr hp 0; rwa [hr.node0] at this)
  exact this

theorem msim_ok' {x' y' : NSt} {r r' : Ret} (he : r' = M.ret r) (hr' : MR P NB M S.tab.length x' y') :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.ok x' r) (Host.Mlx.Ffi.ok y' r') := by
  subst he; exact msim_ok hs hr'

theorem msim_okW' {x' y' : NSt} {r r' : Ret} {ws ws' : List (Nat × Nat × List Byte)} (he : r' = M.ret r)
    (hw : ws' = ws.map M.write) (hr' : MR P NB M S.tab.length x' y') :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.okW x' r ws) (Host.Mlx.Ffi.okW y' r' ws') := by
  subst he hw; exact msim_okW hs hr'

end

section

variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)

include hr

theorem MR.nodeArg {a : Arg} (ha : nodeOk x a = true) :
    ∃ k i nd nd', a = .big (Int.ofNat k) ∧ M.arg a = .big (Int.ofNat (M.handle k)) ∧ PH x k ∧
      x.node? k = some nd ∧ y.node? (M.handle k) = some nd' ∧ NodeR P M i nd nd' := by
  simp only [nodeOk, Bool.and_eq_true] at ha
  obtain ⟨k, rfl, hp, hm⟩ := hr.hdOk_spec ha.1
  rw [argNat_nat, Option.bind_some] at ha
  obtain ⟨nd, hnd⟩ := Option.isSome_iff_exists.mp ha.2
  obtain ⟨i, nd', -, -, h1, h2⟩ := hr.node? hnd
  exact ⟨k, i, nd, nd', rfl, hm, hp, hnd, h1, h2⟩

theorem MR.vecArg {a : Arg} (ha : vecOk x a = true) :
    ∃ k ns, a = .big (Int.ofNat k) ∧ M.arg a = .big (Int.ofNat (M.handle k)) ∧ PH x k ∧
      x.obj? k = some (.vec ns) ∧ y.obj? (M.handle k) = some (.vec (ns.map M.node)) := by
  simp only [vecOk, Bool.and_eq_true] at ha
  obtain ⟨k, rfl, hp, hm⟩ := hr.hdOk_spec ha.1
  rw [argNat_nat, Option.bind_some] at ha
  cases ho : x.obj? k with
  | none => rw [ho] at ha; cases ha.2
  | some o =>
    rw [ho] at ha
    cases o with
    | vec ns => exact ⟨k, ns, rfl, hm, hp, ho, by rw [hr.obj? hp, ho]; rfl⟩
    | _ => cases ha.2

end

section

variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)

include hs hr

theorem sim_arrayEval (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.arrayEval) {a : Arg}
    (ha : nodeOk x a = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, i, nd, nd', rfl, hm, hp, h1, h2, h3⟩ := hr.nodeArg ha
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h1, h2]
  exact msim_ok' hs hr rfl hr

theorem sim_arrayNdim (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.arrayNdim) {a : Arg}
    (ha : nodeOk x a = true) (hlen : ∀ nd, (Host.Mlx.Ffi.argNat a).bind x.node? = some nd → len nd.shape < P.lo) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, i, nd, nd', rfl, hm, hp, h1, h2, h3⟩ := hr.nodeArg ha
  have hl := hlen nd (by rw [argNat_nat, Option.bind_some, h1])
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h1, h2]
  refine msim_ok' hs hr ?_ hr
  show Ret.big _ = Ret.big (M.big _)
  rw [h3.1, Map.dims, Native.len_map, hr.bigFix _ (by omega)]

theorem sim_arrayShape (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.arrayShape) {a : Arg}
    (ha : nodeOk x a = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, i, nd, nd', rfl, hm, hp, h1, h2, h3⟩ := hr.nodeArg ha
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, h1, h2]
  refine msim_ok' hs hr ?_ hr
  show Ret.ptr _ 0 = Ret.ptr (M.region (4 * k)) 0
  rw [(hr.present k hp).2.1]

theorem sim_arrayDtype (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.arrayDtype) {a : Arg}
    (ha : nodeOk x a = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, i, nd, nd', rfl, hm, hp, h1, h2, h3⟩ := hr.nodeArg ha
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h1, h2]
  refine msim_ok' hs hr ?_ hr
  rw [h3.2.1]; rfl

theorem sim_arraySize (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.arraySize) {a : Arg}
    (ha : nodeOk x a = true)
    (hsz : ∀ nd, (Host.Mlx.Ffi.argNat a).bind x.node? = some nd → ∀ ds, Host.Mlx.Ffi.natsOfDims nd.shape = some ds →
      bigOk P ((ds.foldr (· * ·) 1 : Nat) : Int) = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, i, nd, nd', rfl, hm, hp, h1, h2, h3⟩ := hr.nodeArg ha
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h1, h2]
  cases hd : Host.Mlx.Ffi.natsOfDims nd.shape with
  | none => exact msim_stuck hs _ (by cases Host.Mlx.Ffi.natsOfDims nd'.shape <;> exact ⟨_, fun _ _ => rfl⟩)
  | some ds =>
    have hd' : Host.Mlx.Ffi.natsOfDims nd'.shape = some ds := by rw [h3.1]; exact natsOfDims_map M hd
    simp only [hd']
    refine msim_ok' hs hr ?_ hr
    show Ret.big _ = Ret.big (M.big _)
    rw [hr.big_fixed (hsz nd (by rw [argNat_nat, Option.bind_some, h1]) ds hd)]

theorem sim_vecNew (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.vecNew) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name []) (Host.Mlx.Ffi.call y name []) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [Host.Mlx.Ffi.St.newObj]
  have h := hr.newObj (.vec []) hE trivial (fun c h => by cases h) (fun i h => by cases h)
  refine msim_ok' hs h ?_ h
  show Ret.big _ = Ret.big (M.big _)
  rw [show ((x.next : Nat) : Int) = Int.ofNat x.next from rfl, (hr.fresh0 (by omega)).1]; rfl

theorem sim_vecFree (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.vecFree) (a : Arg) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  exact msim_ok' hs hr rfl hr

theorem sim_vecSize (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.vecSize) {a : Arg}
    (ha : vecOk x a = true)
    (hlen : ∀ ns, (Host.Mlx.Ffi.argNat a).bind x.obj? = some (.vec ns) → len ns < P.lo) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, ns, rfl, hm, hp, h1, h2⟩ := hr.vecArg ha
  have hl := hlen ns (by rw [argNat_nat, Option.bind_some, h1])
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h1, h2]
  refine msim_ok' hs hr ?_ hr
  show Ret.big _ = Ret.big (M.big _)
  rw [Native.len_map, hr.bigFix _ (by omega)]

theorem sim_asyncEval (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.asyncEval) {a : Arg}
    (ha : vecOk x a = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  obtain ⟨k, ns, rfl, hm, hp, h1, h2⟩ := hr.vecArg ha
  rw [hm]; unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [argNat_nat, Option.bind_some, h1, h2]
  exact msim_ok' hs hr rfl hr

theorem sim_cfgNew (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.cfgNew) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name []) (Host.Mlx.Ffi.call y name []) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only [Host.Mlx.Ffi.St.newObj]
  have h := hr.newObj (.cfg .empty) hE ⟨(fun _ h => by cases h), (fun _ h => by cases h), (fun _ h => by cases h),
    (fun _ h => by cases h), (fun _ h => by cases h)⟩
    (fun c h p hp => by cases h; cases hp) (fun i h => by cases h)
  refine msim_ok' hs h ?_ h
  show Ret.big _ = Ret.big (M.big _)
  rw [show ((x.next : Nat) : Int) = Int.ofNat x.next from rfl, (hr.fresh0 (by omega)).1]; rfl

theorem sim_cfgFree (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.cfgFree) (a : Arg) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  exact msim_ok' hs hr rfl hr

theorem sim_clearCache (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.clearCache) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name []) (Host.Mlx.Ffi.call y name []) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  exact msim_ok' hs hr rfl hr

theorem sim_synchronize (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.synchronize) (a : Arg) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a]) (Host.Mlx.Ffi.call y name [M.arg a]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  exact msim_ok' hs hr rfl hr

theorem sim_setWiredLimit (hsym : Host.Mlx.Ffi.symOf name = some Host.Mlx.Ffi.Sym.setWiredLimit)
    {b off : Nat} {bs : List Byte} {l : Arg} (hl : natOk P l = true) (hw : bigOk P (x.wired : Int) = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [.jsPtr b off bs, l])
      (Host.Mlx.Ffi.call y name [M.arg (.jsPtr b off bs), M.arg l]) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  show MSim _ S C (match Host.Mlx.Ffi.argNat l with
      | some l => Host.Mlx.Ffi.okW { x with wired := l } Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off x.wired]
      | none => Host.Mlx.Ffi.stuck)
    (match Host.Mlx.Ffi.argNat (M.arg l) with
      | some l => Host.Mlx.Ffi.okW { y with wired := l } Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (M.a b) off y.wired]
      | none => Host.Mlx.Ffi.stuck)
  rw [hr.natOk_argNat hl, hr.wired]
  cases Host.Mlx.Ffi.argNat l with
  | none => exact msim_stuck hs _ ⟨_, fun _ _ => rfl⟩
  | some v =>
    have hr' : MR P NB M S.tab.length { x with wired := v } { y with wired := v } := { hr with wired := rfl }
    have e : M.big (Int.ofNat x.wired) = Int.ofNat x.wired := hr.big_fixed hw
    exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M e]) hr'

end

end Host.Ts.Sim.G
