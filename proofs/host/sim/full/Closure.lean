import host.sim.full.Record
import host.sim.full.Call
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Clo)

/-! # A closure's life and the kernels

The calls `compile.ts` makes around a closure's first application (`host.sim.full.Record`):
`mlx_closure_new_func_payload` (a `JSCallback` region and a payload), `mlx_closure_new`,
`mlx_compile` (the compiled closure into the out-param slot, over a closure the slot holds) and
`mlx_closure_free`; and a kernel's creation: `mlx_vector_string_new_data` of a fixed count,
`mlx_fast_metal_kernel_new` over two name vectors, `mlx_vector_string_free`. `sim_life`: the
template's and the target's calls simulate under `NativeOkX.life`; `sim_clo`: these with the pending
traces' calls. -/

/-- A handle argument naming a present device. -/
def devOk (x : NSt) (a : Arg) : Bool :=
  hdOk x a && match (Host.Mlx.Ffi.argNat a).bind x.obj? with
    | some .device => true
    | _ => false

/-- A handle argument naming a present device-info object. -/
def dinfoOk (x : NSt) (a : Arg) : Bool :=
  hdOk x a && match (Host.Mlx.Ffi.argNat a).bind x.obj? with
    | some .dinfo => true
    | _ => false

/-- A device-size entry with this key. -/
def keyIs (key : List Char) (p : List Char × Nat) : Bool := nameEq p.1 key

/-- The device size a key names is a number the map fixes. -/
def sizeFixed (P : LoadP) (x : NSt) (k : Arg) : Bool :=
  match Host.Mlx.Ffi.cstrArg k with
  | some key => match x.deviceSizes.find? (keyIs key) with
    | some (_, v) => decide ((v : Int) < P.lo) || (decide ((P.E : Int) ≤ v) && decide ((v : Int) < 2 ^ 56))
    | none => true
  | none => true

/-- The checks of these calls. -/
def NativeOkX.life (P : LoadP) (x : NSt) : Host.Mlx.Ffi.Sym → List Arg → Bool
  | .closureNew, [] => decide (x.next + 1 ≤ P.E)
  | .closureFuncPayload, [.extPtr _ 0, p, _] => NativeOk.notOther p && decide (x.next + 1 ≤ P.E)
  | .closureFree, [_] => true
  | .compile, [o, f, _] => slotOk P x o && hdOk x f && decide (x.next + 1 ≤ P.E)
  | .vstrNewData, [_, k] => natOk P k && decide (x.next + 1 ≤ P.E)
  | .vstrFree, [_] => true
  | .kernelNew, [_, ins, outs, _, _, _, _] => hdOk x ins && hdOk x outs && decide (x.next + 1 ≤ P.E)
  | .getDefaultDevice, [o] => slotOk P x o && decide (x.next + 1 ≤ P.E)
  | .deviceInfoNew, [] => decide (x.next + 1 ≤ P.E)
  | .deviceInfoGet, [o, d] => slotOk P x o && devOk x d
  | .deviceInfoGetSize, [.jsPtr _ _ _, i, k] => dinfoOk x i && sizeFixed P x k
  | .deviceInfoFree, [_] => true
  | .deviceFree, [_] => true
  | _, _ => false

/-- The compiled-closure calls: `mlx_vector_array_set_data` into a pending trace's result
(`NativeOkX.vset`), a trace recording (`NativeOkX.clRecord`) and a closure's life with the kernels
(`NativeOkX.life`). -/
def NativeOkX.clo (P : LoadP) (x : NSt) : Host.Mlx.Ffi.Sym → List Arg → Bool
  | .vecSetData, args => NativeOkX.vset P x args
  | .closureApply, args => NativeOkX.clRecord P x args
  | s, args => NativeOkX.life P x s args

/-- The calls `NativeOkX.clo` accepts are none of the symbolic-shape layer's, no array free and no
kernel-recording call other than a kernel's creation. -/
theorem NativeOkX.clo_not {P : LoadP} {x : NSt} {s : Host.Mlx.Ffi.Sym} {args : List Arg}
    (h : NativeOkX.clo P x s args = true) :
    s ≠ .arraySize ∧ s ≠ .reshape ∧ s ≠ .conv1d ∧ s ≠ .arrayFree ∧ s ≠ .cfgNew ∧ s ≠ .cfgDtype ∧ s ≠ .cfgInt ∧
      s ≠ .kernelApply := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> rintro rfl <;> simp [NativeOkX.clo, NativeOkX.life] at h

/-- A kernel is created with its seven arguments. -/
theorem NativeOkX.clo_kern {P : LoadP} {x : NSt} {s : Host.Mlx.Ffi.Sym} {args : List Arg}
    (h : NativeOkX.clo P x s args = true) : s = .kernelNew → args.length = 7 := by
  intro e
  subst e
  rcases args with _ | ⟨a0, _ | ⟨a1, _ | ⟨a2, _ | ⟨a3, _ | ⟨a4, _ | ⟨a5, _ | ⟨a6, _ | ⟨a7, rest⟩⟩⟩⟩⟩⟩⟩⟩ <;>
    first | rfl | cases h

/-- The out-param slot of `mlx_compile`: the closure it holds is replaced, otherwise a new handle. -/
def cloSlot (s : NSt) (slot : Nat) (c : NObj) : Nat × NSt :=
  match s.obj? slot with
  | some (.clo _) => (slot, s.setObj slot c)
  | _ => s.newObj c

/-- `mlx_compile`. -/
def compileProg (s : NSt) (o f sl : Arg) : Host.Mlx.Ffi.R :=
  match Host.Mlx.Ffi.slotOf o, (Host.Mlx.Ffi.argNat f).bind s.obj?, Host.Mlx.Ffi.argBool sl with
  | some (b, off, slot), some (.clo (.fn cb payload)), some shapeless =>
    match cloSlot s slot (.clo (.compiled cb payload shapeless [])) with
    | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h]
  | _, _, _ => Host.Mlx.Ffi.stuck

section
variable {name : Name}

theorem call_closureNew (hsym : Host.Mlx.Ffi.symOf name = some .closureNew) (s : NSt) :
    Host.Mlx.Ffi.call s name [] =
      Host.Mlx.Ffi.ok { s with next := s.next + 1, objs := s.objs.set s.next (.clo .empty) } (.big s.next) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; try rfl

theorem call_closureFn (hsym : Host.Mlx.Ffi.symOf name = some .closureFuncPayload) (s : NSt) (cb : Nat)
    (p t : Arg) :
    Host.Mlx.Ffi.call s name [.extPtr cb 0, p, t] =
      Host.Mlx.Ffi.ok { s with next := s.next + 1, objs := s.objs.set s.next (.clo (.fn cb p)) } (.big s.next) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; try rfl

/-- `mlx_get_default_device`. -/
def devProg (s : NSt) (o : Arg) : Host.Mlx.Ffi.R :=
  match Host.Mlx.Ffi.slotOf o with
  | some (b, off, _) => match s.newObj .device with
    | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h]
  | none => Host.Mlx.Ffi.stuck

theorem call_device (hsym : Host.Mlx.Ffi.symOf name = some .getDefaultDevice) (s : NSt) (o : Arg) :
    Host.Mlx.Ffi.call s name [o] = devProg s o := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; try rfl

theorem call_compile (hsym : Host.Mlx.Ffi.symOf name = some .compile) (s : NSt) (o f sl : Arg) :
    Host.Mlx.Ffi.call s name [o, f, sl] = compileProg s o f sl := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; try rfl

theorem call_vstrNew (hsym : Host.Mlx.Ffi.symOf name = some .vstrNewData) (s : NSt) (a k : Arg) :
    Host.Mlx.Ffi.call s name [a, k] = match Host.Mlx.Ffi.argNat k with
      | some m => Host.Mlx.Ffi.ok { s with next := s.next + 1, objs := s.objs.set s.next (.vstr m) } (.big s.next)
      | none => Host.Mlx.Ffi.stuck := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; try rfl

theorem call_dinfoNew (hsym : Host.Mlx.Ffi.symOf name = some .deviceInfoNew) (s : NSt) :
    Host.Mlx.Ffi.call s name [] =
      Host.Mlx.Ffi.ok { s with next := s.next + 1, objs := s.objs.set s.next .dinfo } (.big s.next) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; try rfl

/-- `mlx_device_info_get`. -/
def dinfoGetProg (s : NSt) (o d : Arg) : Host.Mlx.Ffi.R :=
  match Host.Mlx.Ffi.slotOf o, (Host.Mlx.Ffi.argNat d).bind s.obj? with
  | some (b, off, slot), some .device => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off slot]
  | _, _ => Host.Mlx.Ffi.stuck

theorem call_dinfoGet (hsym : Host.Mlx.Ffi.symOf name = some .deviceInfoGet) (s : NSt) (o d : Arg) :
    Host.Mlx.Ffi.call s name [o, d] = dinfoGetProg s o d := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; try rfl

/-- `mlx_device_info_get_size`. -/
def dinfoSizeProg (s : NSt) (b off : Nat) (i k : Arg) : Host.Mlx.Ffi.R :=
  match (Host.Mlx.Ffi.argNat i).bind s.obj?, Host.Mlx.Ffi.cstrArg k with
  | some .dinfo, some key => match s.deviceSizes.find? (keyIs key) with
    | some (_, v) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off v]
    | none => Host.Mlx.Ffi.stuck
  | _, _ => Host.Mlx.Ffi.stuck

theorem call_dinfoSize (hsym : Host.Mlx.Ffi.symOf name = some .deviceInfoGetSize) (s : NSt) (b off : Nat)
    (bs : List Byte) (i k : Arg) : Host.Mlx.Ffi.call s name [.jsPtr b off bs, i, k] = dinfoSizeProg s b off i k := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; try rfl

theorem call_status0 {sy : Host.Mlx.Ffi.Sym} (hsym : Host.Mlx.Ffi.symOf name = some sy)
    (hk : sy = .closureFree ∨ sy = .vstrFree ∨ sy = .deviceInfoFree ∨ sy = .deviceFree) (s : NSt) (a : Arg) :
    Host.Mlx.Ffi.call s name [a] = Host.Mlx.Ffi.ok s Host.Mlx.Ffi.status0 := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  rcases hk with rfl | rfl | rfl | rfl <;> rfl

end

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)
include hr

/-- `mlx_compile`'s slot. -/
theorem MR.cloSlot_map {sl : Nat} (hsl : sl = 0 ∨ PH x sl) (hE : x.next + 1 ≤ P.E) (cb : Nat) (p : Arg)
    (shl : Bool) (hp : SA (· < n) p) :
    ∃ h x' h' y', cloSlot x sl (.clo (.compiled cb p shl [])) = (h, x') ∧
      cloSlot y (M.handle sl) (M.nobj (.clo (.compiled cb p shl []))) = (h', y') ∧
      MR P NB M n x' y' ∧ M.big (Int.ofNat h) = Int.ofNat h' := by
  have hs : SObj (· < n) (.clo (.compiled cb p shl [])) := hp
  have hnew : Host.Mlx.Ffi.St.obj? x sl = none ∨
        (∃ o, Host.Mlx.Ffi.St.obj? x sl = some o ∧ ∀ c, o ≠ .clo c) →
      Host.Mlx.Ffi.St.obj? y (M.handle sl) = none ∨
        (∃ o, Host.Mlx.Ffi.St.obj? y (M.handle sl) = some o ∧ ∀ c, o ≠ .clo c) →
      ∃ h x' h' y', cloSlot x sl (.clo (.compiled cb p shl [])) = (h, x') ∧
        cloSlot y (M.handle sl) (M.nobj (.clo (.compiled cb p shl []))) = (h', y') ∧
        MR P NB M n x' y' ∧ M.big (Int.ofNat h) = Int.ofNat h' := by
    intro hx hy
    have ex : cloSlot x sl (.clo (.compiled cb p shl [])) = x.newObj (.clo (.compiled cb p shl [])) := by
      unfold cloSlot
      rcases hx with hx | ⟨o, hx, ho⟩
      · rw [hx]
      · rw [hx]; cases o <;> first | rfl | exact absurd rfl (ho _)
    have ey : cloSlot y (M.handle sl) (M.nobj (.clo (.compiled cb p shl []))) =
        y.newObj (M.nobj (.clo (.compiled cb p shl []))) := by
      unfold cloSlot
      rcases hy with hy | ⟨o, hy, ho⟩
      · rw [hy]
      · rw [hy]; cases o <;> first | rfl | exact absurd rfl (ho _)
    refine ⟨_, _, _, _, ex, ey, hr.newObj _ hE hs (fun c h => by cases h) (fun i h => by cases h),
      (hr.fresh0 (by omega)).1⟩
  rcases hsl with rfl | hp'
  · refine hnew (.inl hr.absent0.2.1) (.inl ?_)
    rw [hr.handle0]; exact hr.absent0.2.2
  · have hy := hr.objs sl hp'
    cases ho : x.objs.get sl with
    | none =>
      rw [ho] at hy
      exact hnew (.inl ho) (.inl hy)
    | some o =>
      rw [ho] at hy
      cases o with
      | clo c0 =>
        refine ⟨sl, _, M.handle sl, _, ?_, ?_, hr.setObj hp' _ hs (fun c h => by cases h) (fun i h => by cases h),
          (hr.present sl hp').1⟩
        · unfold cloSlot; show (match x.objs.get sl with | some (.clo _) => _ | _ => _) = _; rw [ho]; rfl
        · unfold cloSlot; show (match y.objs.get (M.handle sl) with | some (.clo _) => _ | _ => _) = _
          rw [hy]; rfl
      | _ => exact hnew (.inr ⟨_, ho, fun c h => by cases h⟩) (.inr ⟨_, hy, fun c h => by cases h⟩)

end

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

theorem sim_closureNew (hsym : Host.Mlx.Ffi.symOf name = some .closureNew) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name []) (Host.Mlx.Ffi.call y name []) := by
  rw [call_closureNew hsym, call_closureNew hsym]
  have h := hr.newObj (.clo .empty) hE trivial (fun c h => by cases h) (fun i h => by cases h)
  refine msim_ok' hs hr ?_ h
  show Ret.big _ = Ret.big (M.big _)
  rw [show ((x.next : Nat) : Int) = Int.ofNat x.next from rfl, (hr.fresh0 (by omega)).1]; rfl

theorem sim_closureFn (hsym : Host.Mlx.Ffi.symOf name = some .closureFuncPayload) {cb : Nat} {p t : Arg}
    (hp : SA (· < S.tab.length) p) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [.extPtr cb 0, p, t])
      (Host.Mlx.Ffi.call y name [.extPtr (M.region cb) 0, M.arg p, M.arg t]) := by
  rw [call_closureFn hsym, call_closureFn hsym]
  have h := hr.newObj (.clo (.fn cb p)) hE hp (fun c h => by cases h) (fun i h => by cases h)
  refine msim_ok' hs hr ?_ h
  show Ret.big _ = Ret.big (M.big _)
  rw [show ((x.next : Nat) : Int) = Int.ofNat x.next from rfl, (hr.fresh0 (by omega)).1]; rfl

theorem sim_compile (hsym : Host.Mlx.Ffi.symOf name = some .compile) {o f sl : Arg} (ho : slotOk P x o = true)
    (hf : hdOk x f = true) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, f, sl])
      (Host.Mlx.Ffi.call y name [M.arg o, M.arg f, M.arg sl]) := by
  rw [call_compile hsym, call_compile hsym]
  obtain ⟨b, off, s0, h1, h2, hsl⟩ := hr.slot_map ho
  obtain ⟨ck, rfl, hpc, hmc⟩ := hr.hdOk_spec hf
  rw [hmc]
  unfold compileProg
  rw [h1, h2, argNat_nat, Option.bind_some, argNat_nat, Option.bind_some, hr.obj? hpc]
  cases hco : Host.Mlx.Ffi.St.obj? x ck with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some oc =>
    cases oc with
    | clo cl =>
      cases cl with
      | fn cb p =>
        have hp : SA (· < S.tab.length) p := hr.cl.2.1 ck _ hco
        cases sl with
        | bool shl =>
          obtain ⟨h, x', h', y', e1, e2, hr', hb⟩ := hr.cloSlot_map hsl hE cb p shl hp
          show MSim _ S C (match cloSlot x s0 (.clo (.compiled cb p shl [])) with
              | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h])
            (match cloSlot y (M.handle s0) (M.nobj (.clo (.compiled cb p shl []))) with
              | (h, s) => Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write (M.a b) off h])
          rw [e1, e2]
          exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr'
        | _ => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
      | _ => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | _ => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩

theorem sim_device (hsym : Host.Mlx.Ffi.symOf name = some .getDefaultDevice) {o : Arg} (ho : slotOk P x o = true)
    (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o]) (Host.Mlx.Ffi.call y name [M.arg o]) := by
  rw [call_device hsym, call_device hsym]
  obtain ⟨b, off, s0, h1, h2, -⟩ := hr.slot_map ho
  unfold devProg
  rw [h1, h2]
  have hr' := hr.newObj .device hE trivial (fun c h => by cases h) (fun i h => by cases h)
  have hb : M.big (Int.ofNat x.next) = Int.ofNat y.next := (hr.fresh0 (by omega)).1
  exact msim_okW' hs hr' rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr'

theorem sim_dinfoNew (hsym : Host.Mlx.Ffi.symOf name = some .deviceInfoNew) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name []) (Host.Mlx.Ffi.call y name []) := by
  rw [call_dinfoNew hsym, call_dinfoNew hsym]
  have h := hr.newObj .dinfo hE trivial (fun c h => by cases h) (fun i h => by cases h)
  refine msim_ok' hs hr ?_ h
  show Ret.big _ = Ret.big (M.big _)
  rw [show ((x.next : Nat) : Int) = Int.ofNat x.next from rfl, (hr.fresh0 (by omega)).1]; rfl

theorem sim_dinfoGet (hsym : Host.Mlx.Ffi.symOf name = some .deviceInfoGet) {o d : Arg} (ho : slotOk P x o = true)
    (hd : devOk x d = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [o, d]) (Host.Mlx.Ffi.call y name [M.arg o, M.arg d]) := by
  rw [call_dinfoGet hsym, call_dinfoGet hsym]
  obtain ⟨b, off, s0, h1, h2, hsl⟩ := hr.slot_map ho
  unfold devOk at hd
  rw [Bool.and_eq_true] at hd
  obtain ⟨kd, rfl, hpk, hmk⟩ := hr.hdOk_spec hd.1
  have hd2 := hd.2
  rw [argNat_nat, Option.bind_some] at hd2
  have hobj : x.obj? kd = some .device := by
    revert hd2; cases x.obj? kd with
    | none => intro h; cases h
    | some o => cases o <;> first | (intro _; rfl) | (intro h; cases h)
  unfold dinfoGetProg
  rw [h1, h2, hmk, argNat_nat, Option.bind_some, argNat_nat, Option.bind_some, hr.obj? hpk, hobj]
  have hb : M.big (Int.ofNat s0) = Int.ofNat (M.handle s0) := by
    rcases hsl with rfl | hp
    · rw [hr.handle0]; exact hr.big0
    · exact (hr.present s0 hp).1
  exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr

theorem sim_dinfoSize (hsym : Host.Mlx.Ffi.symOf name = some .deviceInfoGetSize) {b off : Nat} {bs : List Byte}
    {i k : Arg} (hi : dinfoOk x i = true) (hk : sizeFixed P x k = true) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [.jsPtr b off bs, i, k])
      (Host.Mlx.Ffi.call y name [.jsPtr (M.a b) off (bs.map M.byte), M.arg i, M.arg k]) := by
  rw [call_dinfoSize hsym, call_dinfoSize hsym]
  unfold dinfoOk at hi
  rw [Bool.and_eq_true] at hi
  obtain ⟨ki, rfl, hpk, hmk⟩ := hr.hdOk_spec hi.1
  have hi2 := hi.2
  rw [argNat_nat, Option.bind_some] at hi2
  have hobj : x.obj? ki = some .dinfo := by
    revert hi2; cases x.obj? ki with
    | none => intro h; cases h
    | some o => cases o <;> first | (intro _; rfl) | (intro h; cases h)
  have hy : y.obj? (M.handle ki) = some .dinfo := by rw [hr.obj? hpk, hobj]; rfl
  unfold dinfoSizeProg
  rw [hmk, argNat_nat, Option.bind_some, argNat_nat, Option.bind_some, hy, hobj, cstrArg_map, hr.sizes]
  unfold sizeFixed at hk
  cases hck : Host.Mlx.Ffi.cstrArg k with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some key =>
    rw [hck] at hk
    dsimp only at hk ⊢
    cases hf : x.deviceSizes.find? (keyIs key) with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some q =>
      obtain ⟨nm, v⟩ := q
      rw [hf] at hk
      dsimp only at hk ⊢
      have hb : M.big (Int.ofNat v) = Int.ofNat v := by
        simp only [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq] at hk
        rcases hk with hk | ⟨h1, h2⟩
        · exact hr.bigFix _ hk
        · exact hr.bigFixHi _ h1 h2
      exact msim_okW' hs hr rfl (by simp only [List.map_cons, List.map_nil, Map.write_u64 M hb]) hr

theorem sim_vstrNew (hsym : Host.Mlx.Ffi.symOf name = some .vstrNewData) {a k : Arg} (hk : natOk P k = true)
    (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [a, k])
      (Host.Mlx.Ffi.call y name [M.arg a, M.arg k]) := by
  rw [call_vstrNew hsym, call_vstrNew hsym, hr.natOk_argNat hk]
  cases Host.Mlx.Ffi.argNat k with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some m =>
    have h := hr.newObj (.vstr m) hE trivial (fun c h => by cases h) (fun i h => by cases h)
    refine msim_ok' hs hr ?_ h
    show Ret.big _ = Ret.big (M.big _)
    rw [show ((x.next : Nat) : Int) = Int.ofNat x.next from rfl, (hr.fresh0 (by omega)).1]; rfl

theorem sim_kernelNew (hsym : Host.Mlx.Ffi.symOf name = some .kernelNew) {nm ins outs src hdr rc ao : Arg}
    (hi : hdOk x ins = true) (ho : hdOk x outs = true) (hE : x.next + 1 ≤ P.E) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name [nm, ins, outs, src, hdr, rc, ao])
      (Host.Mlx.Ffi.call y name [M.arg nm, M.arg ins, M.arg outs, M.arg src, M.arg hdr, M.arg rc, M.arg ao]) := by
  rw [Full.call_kernelNew hsym, Full.call_kernelNew hsym]
  obtain ⟨ki, rfl, hpi, hmi⟩ := hr.hdOk_spec hi
  obtain ⟨ko, rfl, hpo, hmo⟩ := hr.hdOk_spec ho
  rw [hmi, hmo]
  unfold Full.kernNewProg
  simp only [cstrArg_map, argNat_nat, Option.bind_some]
  rw [hr.obj? hpi, hr.obj? hpo]
  cases Host.Mlx.Ffi.cstrArg nm with
  | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
  | some n =>
    cases Host.Mlx.Ffi.St.obj? x ki with
    | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
    | some oi =>
      cases oi with
      | vstr a =>
        cases Host.Mlx.Ffi.St.obj? x ko with
        | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
        | some oo =>
          cases oo with
          | vstr b =>
            cases Host.Mlx.Ffi.cstrArg src with
            | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
            | some sc =>
              cases Host.Mlx.Ffi.cstrArg hdr with
              | none => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
              | some hd =>
                have h := hr.newObj (.kernel n sc hd a b) hE trivial (fun c h => by cases h) (fun i h => by cases h)
                refine msim_ok' hs hr ?_ h
                show Ret.big _ = Ret.big (M.big _)
                rw [show ((x.next : Nat) : Int) = Int.ofNat x.next from rfl, (hr.fresh0 (by omega)).1]; rfl
          | _ => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩
      | _ => exact msim_stuck' hs ⟨_, fun _ _ => rfl⟩

/-- **A closure's life and the kernels.** -/
theorem sim_life {sy : Host.Mlx.Ffi.Sym} (hsym : Host.Mlx.Ffi.symOf name = some sy) {args : List Arg}
    (hok : NativeOkX.life P x sy args = true) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  unfold NativeOkX.life at hok
  split at hok
  · exact sim_closureNew hs hr hsym (of_decide_eq_true hok)
  · rename_i cb p t
    simp only [Bool.and_eq_true, decide_eq_true_eq] at hok
    exact sim_closureFn hs hr hsym (SA.of_supp (hsupp p (by simp)) hok.1) hok.2
  · rw [List.map_cons, List.map_nil, call_status0 hsym (.inl rfl), call_status0 hsym (.inl rfl)]
    exact msim_ok' hs hr rfl hr
  · simp only [Bool.and_eq_true, decide_eq_true_eq] at hok
    exact sim_compile hs hr hsym hok.1.1 hok.1.2 hok.2
  · simp only [Bool.and_eq_true, decide_eq_true_eq] at hok
    exact sim_vstrNew hs hr hsym hok.1 hok.2
  · rw [List.map_cons, List.map_nil, call_status0 hsym (.inr (.inl rfl)), call_status0 hsym (.inr (.inl rfl))]
    exact msim_ok' hs hr rfl hr
  · simp only [Bool.and_eq_true, decide_eq_true_eq] at hok
    exact sim_kernelNew hs hr hsym hok.1.1 hok.1.2 hok.2
  · simp only [Bool.and_eq_true, decide_eq_true_eq] at hok
    exact sim_device hs hr hsym hok.1 hok.2
  · exact sim_dinfoNew hs hr hsym (of_decide_eq_true hok)
  · rw [Bool.and_eq_true] at hok
    exact sim_dinfoGet hs hr hsym hok.1 hok.2
  · rw [Bool.and_eq_true] at hok
    exact sim_dinfoSize hs hr hsym hok.1 hok.2
  · rw [List.map_cons, List.map_nil, call_status0 hsym (.inr (.inr (.inl rfl))), call_status0 hsym (.inr (.inr (.inl rfl)))]
    exact msim_ok' hs hr rfl hr
  · rw [List.map_cons, List.map_nil, call_status0 hsym (.inr (.inr (.inr rfl))), call_status0 hsym (.inr (.inr (.inr rfl)))]
    exact msim_ok' hs hr rfl hr
  · cases hok


/-- **The compiled-closure calls**, the pending traces' regions the relation's (`PendReg`). -/
theorem sim_clo {sy : Host.Mlx.Ffi.Sym} (hsym : Host.Mlx.Ffi.symOf name = some sy) {args : List Arg}
    (hok : NativeOkX.clo P x sy args = true) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a)
    (hpr : PendReg M x y) :
    MSim (MPost P NB M ν S C) S C (Host.Mlx.Ffi.call x name args) (Host.Mlx.Ffi.call y name (args.map M.arg)) := by
  unfold NativeOkX.clo at hok
  split at hok
  · unfold NativeOkX.vset at hok
    split at hok
    · exact sim_vecSetData hs hr hsym hok hpr
    · cases hok
  · exact sim_clRecord hs hr hsym hok hpr
  · exact sim_life hs hr hsym hok hsupp

end

end Host.Ts.Sim.G
