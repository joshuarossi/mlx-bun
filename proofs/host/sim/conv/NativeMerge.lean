import host.sim.conv.Native
import host.sim.conv.NativeIso
import host.sim.conv.Merge
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # Merge: the native part

At a stage's return the caller's native relation is re-established at the merged native state
`xr`: the caller's native state `x1` at the call with the stage's written and fresh handles `wh`
pushed by `τ = σ.res …` at `σ`'s handles, the stage's fresh nodes at the caller's fresh node ids
(`σ.node`), known by shape and dtype only, and the stage's readback items, tokens, pending
evaluations and error handler pushed (`NMer`). `mr_merge`: `G.MR` at `xr` under the glued map,
with the abstract-node band raised to the merged node counter (`LoadP.abstractTo`), from

* the caller's relation at the call (`hr1`), the call's native morphism (`MIso`, `hr0`: the
  isolated relation at the stage's start), the stage's relation at its end (`hr2`, under an
  extension of the isolated map);
* the stage template's native footprint facts (`NFoot`, once per template);
* the target's caller-only native entries unchanged by the stage (`NFrozen`: the native half of
  the frozen contract `StageTpl.HoldsZ`'s `NK`).

`loadR_merge` is the load world's form, the merge's native law (`hFM` of
`host.sim.conv.Call.call_run`). -/

/-! ## Images of native support -/

section
variable {R R' : Nat → Prop} {τ : Map} (hτ : ∀ i, R i → SN R' (τ.num i))
include hτ

theorem SN.map {x : NumV} (hx : SN R x) : SN R' (τ.nv x) := by
  cases x with
  | lit _ => trivial
  | ref i => exact hτ i hx

theorem SD.dimOf_sn {x : NumV} (hx : SN R' x) : SD R' (dimOf x) := SD.dimOf hx

theorem SD.map {d : Dim} (hd : SD R d) : SD R' (τ.dim d) := by
  cases d with
  | lit _ => trivial
  | sym x => exact SD.dimOf (SN.map hτ hd)

theorem SDs.map {ds : List Dim} (hd : SDs R ds) : SDs R' (τ.dims ds) := by
  intro d hm
  obtain ⟨d0, h0, rfl⟩ := List.mem_map.1 hm
  exact SD.map hτ (hd d0 h0)

theorem SB.map {b : Byte} (hb : SB R b) : SB R' (τ.byte b) := by
  cases b with
  | lit _ => trivial
  | part k c i =>
    cases c with
    | num x => exact SN.map hτ hb
    | big _ => trivial

theorem SBs.map {bs : List Byte} (hb : SBs R bs) : SBs R' (bs.map τ.byte) := by
  intro b hm
  obtain ⟨b0, h0, rfl⟩ := List.mem_map.1 hm
  exact SB.map hτ (hb b0 h0)

theorem SA.map {a : Arg} (ha : SA R a) : SA R' (τ.arg a) := by
  cases a with
  | num x => exact SN.map hτ ha
  | jsPtr _ _ bs => exact SBs.map hτ ha
  | other _ => exact ha.elim
  | _ => trivial

theorem SCfg.map {c : Cfg} (hc : SCfg R c) : SCfg R' (τ.cfg c) := by
  refine ⟨fun p hm => ?_, fun x hm => ?_, fun x hm => ?_, fun p hm => ?_, fun x hx => ?_⟩
  · obtain ⟨⟨s, d⟩, h0, rfl⟩ := List.mem_map.1 hm
    exact SDs.map hτ (hc.1 _ h0)
  · obtain ⟨x0, h0, rfl⟩ := List.mem_map.1 hm
    exact SN.map hτ (hc.2.1 x0 h0)
  · obtain ⟨x0, h0, rfl⟩ := List.mem_map.1 hm
    exact SN.map hτ (hc.2.2.1 x0 h0)
  · obtain ⟨⟨nm, v⟩, h0, rfl⟩ := List.mem_map.1 hm
    exact SN.map hτ (hc.2.2.2.1 _ h0)
  · obtain ⟨x0, h0, rfl⟩ := Option.map_eq_some_iff.1 hx
    exact SN.map hτ (hc.2.2.2.2 x0 h0)

theorem SClo.map {c : Clo} (hc : SClo R c) : SClo R' (τ.clo c) := by
  cases c with
  | empty => trivial
  | fn _ p => exact SA.map hτ hc
  | compiled _ p _ _ => exact SA.map hτ hc

theorem SObj.map {o : NObj} (ho : SObj R o) : SObj R' (τ.nobj o) := by
  cases o with
  | cfg c => exact SCfg.map hτ ho
  | clo c => exact SClo.map hτ ho
  | _ => trivial

end

/-- A map's traces of an object are the images of the object's traces. -/
theorem objTraces_nobj (τ : Map) (o : NObj) : objTraces (τ.nobj o) = (objTraces o).map τ.node := by
  cases o with
  | clo c =>
    cases c with
    | compiled cb p sl ts =>
      simp only [Map.nobj, Map.clo, objTraces, List.flatMap_map, List.map_flatMap]
      rfl
    | _ => rfl
  | _ => rfl

/-! ## The template's native footprint and the merged native state -/

/-- **The stage template's native footprint** from its start `x0` to its end `x2`: the written
and fresh handles `wh` (present at the end; the old ones present at the start), the other handle
entries the start's; the start's nodes kept; the readback items of old nodes kept except at `wi`
(present at the start); the counters grow. -/
structure NFoot (wh wi : List Nat) (x0 x2 : NSt) : Prop where
  whP : ∀ h ∈ wh, PH x2 h
  wh0 : ∀ h ∈ wh, h < x0.next → PH x0 h
  sameA : ∀ h, h ∉ wh → x2.arrs.get h = x0.arrs.get h
  sameO : ∀ h, h ∉ wh → x2.objs.get h = x0.objs.get h
  nodes : ∀ i, i < x0.nnext → x2.nodes.get i = x0.nodes.get i
  wiP : ∀ i ∈ wi, PN x0 i
  items : ∀ i, i < x0.nnext → i ∉ wi → x2.items.get i = x0.items.get i
  next : x0.next ≤ x2.next
  nnext : x0.nnext ≤ x2.nnext

/-- **The merged native state** `xr` from the caller's `x1` and the stage's end `x2`. The stage's
fresh nodes are at the caller's fresh ids with the images' shapes and dtypes (any primitive and
inputs: they are abstract after the merge) and supported below `nr`. -/
structure NMer (σ τ : Map) (wh wi : List Nat) (nr : Nat) (x0 x1 x2 xr : NSt) : Prop where
  arrsS : ∀ h ∈ wh, xr.arrs.get (σ.handle h) = (x2.arrs.get h).map τ.node
  objsS : ∀ h ∈ wh, xr.objs.get (σ.handle h) = (x2.objs.get h).map τ.nobj
  arrsC : ∀ h', (∀ h ∈ wh, σ.handle h ≠ h') → xr.arrs.get h' = x1.arrs.get h'
  objsC : ∀ h', (∀ h ∈ wh, σ.handle h ≠ h') → xr.objs.get h' = x1.objs.get h'
  nodesC : ∀ j, j < x1.nnext → xr.nodes.get j = x1.nodes.get j
  nodesS : ∀ k nd, xr.nodes.get (x1.nnext + k) = some nd → ∃ nd2, x2.nodes.get (x0.nnext + k) = some nd2 ∧
    nd.shape = τ.dims nd2.shape ∧ nd.dtype = nd2.dtype ∧ SNode (· < nr) nd
  nodesF : ∀ k, PN x2 (x0.nnext + k) → PN xr (x1.nnext + k)
  nodesCanon : ∀ k nd2, x2.nodes.get (x0.nnext + k) = some nd2 → ∀ d ∈ nd2.shape, DimCanon τ d
  cfgCanonS : ∀ h ∈ wh, ∀ c, x2.objs.get h = some (.cfg c) → ∀ p ∈ c.outs, ∀ d ∈ p.1, DimCanon τ d
  nodesHi : ∀ j, xr.nnext ≤ j → xr.nodes.get j = none
  itemsS : ∀ k, xr.items.get (x1.nnext + k) = (x2.items.get (x0.nnext + k)).map τ.nv
  itemsW : ∀ i ∈ wi, xr.items.get (σ.node i) = (x2.items.get i).map τ.nv
  itemsC : ∀ j, j < x1.nnext → (∀ i ∈ wi, σ.node i ≠ j) → xr.items.get j = x1.items.get j
  next : xr.next = x1.next + (x2.next - x0.next)
  nnext : xr.nnext = x1.nnext + (x2.nnext - x0.nnext)
  tokens : xr.tokens = x2.tokens.map τ.nv
  pending : xr.pending = x2.pending.map τ.pend
  errh : xr.errh = x2.errh.map τ.arg
  files : xr.files = x2.files
  arch : xr.arch = x2.arch
  sizes : xr.deviceSizes = x2.deviceSizes
  wired : xr.wired = x2.wired

/-- **The target's caller-only native entries are unchanged** by the stage: handles and readback
items of the caller at no image of the template's start, and every node below the call's node
counter (the graph only grows). -/
structure NFrozen (M σ : Map) (x0 x1 y y' : NSt) : Prop where
  arrs : ∀ h, PH x1 h → (∀ h0, PH x0 h0 → σ.handle h0 ≠ h) → y'.arrs.get (M.handle h) = y.arrs.get (M.handle h)
  objs : ∀ h, PH x1 h → (∀ h0, PH x0 h0 → σ.handle h0 ≠ h) → y'.objs.get (M.handle h) = y.objs.get (M.handle h)
  nodes : ∀ i, i < y.nnext → y'.nodes.get i = y.nodes.get i
  items : ∀ k, PN x1 k → (∀ i0, PN x0 i0 → σ.node i0 ≠ k) → y'.items.get (M.node k) = y.items.get (M.node k)

/-- The hypotheses of the native merge. -/
structure NMergeIn (P0 P1 : LoadP) (NB : Nat) (M M2 σ : Map) (n0 n1 n2 nr : Nat) (wh wi : List Nat)
    (x0 x1 x2 xr y y' : NSt) : Prop where
  hr1 : MR P1 NB M n1 x1 y
  iso : MIso P0 P1 n0 σ x0 x1
  hr0 : MR P0 NB (M.after σ) n0 x0 y
  hr2 : MR P0 NB M2 n2 x2 y'
  ext : Ext (M.after σ) M2 n0
  numS : ∀ i, i < n0 → SN (· < n1) (σ.num i)
  len : n0 ≤ n2
  nrl : n1 + (n2 - n0) ≤ nr
  foot : NFoot wh wi x0 x2
  mer : NMer σ (σ.res n0 n1) wh wi nr x0 x1 x2 xr
  frz : NFrozen M σ x0 x1 y y'
  hE' : ∀ k, x0.next + k < P0.E → x1.next + k < P1.E
  hlt2 : x2.next < P0.E
  hNE : x1.nnext + (x2.nnext - x0.nnext) ≤ P1.NE
  hrest : P0.rest = P1.rest

namespace NMergeIn
variable {P0 P1 : LoadP} {NB : Nat} {M M2 σ : Map} {n0 n1 n2 nr : Nat} {wh wi : List Nat}
  {x0 x1 x2 xr y y' : NSt}
variable (H : NMergeIn P0 P1 NB M M2 σ n0 n1 n2 nr wh wi x0 x1 x2 xr y y')
include H

/-- The glued map. -/
abbrev Mr (_ : NMergeIn P0 P1 NB M M2 σ n0 n1 n2 nr wh wi x0 x1 x2 xr y y') : Map := M.glue M2 n1 n0
/-- The stage-to-caller names. -/
abbrev τ (_ : NMergeIn P0 P1 NB M M2 σ n0 n1 n2 nr wh wi x0 x1 x2 xr y y') : Map := σ.res n0 n1

theorem lockH : y'.next = y.next + (x2.next - x0.next) := by
  have e1 := H.hr2.hfreshB 0 (by have := H.hlt2; omega)
  have e0 := H.hr0.hfreshB (x2.next - x0.next) (by have := H.foot.next; have := H.hlt2; omega)
  rw [H.ext.big] at e1
  simp only [Nat.add_zero] at e1
  rw [show x0.next + (x2.next - x0.next) = x2.next by have := H.foot.next; omega, e1] at e0
  exact Int.ofNat.inj e0

theorem lockN : y'.nnext = y.nnext + (x2.nnext - x0.nnext) := by
  have e1 := H.hr2.nfresh 0
  have e0 := H.hr0.nfresh (x2.nnext - x0.nnext)
  rw [H.ext.node] at e1
  simp only [Nat.add_zero] at e1
  rw [show x0.nnext + (x2.nnext - x0.nnext) = x2.nnext by have := H.foot.nnext; omega, e1] at e0
  exact e0

theorem agS : NAgree (· < n1) M H.Mr := NAgree.ofExt (Map.glue_ext M M2 n1 n0)

theorem ag0 : NAgree (· < n0) (M.after σ) M2 := NAgree.ofExt H.ext

theorem τnum : ∀ i, i < n2 → SN (· < nr) (H.τ.num i) := by
  intro i hi
  by_cases h0 : i < n0
  · rw [(Map.res_ext σ n0 n1).num i h0]
    exact SN.mono (fun j hj => by have := H.nrl; omega) (H.numS i h0)
  · rw [Map.res_new σ (by omega)]
    show _ < nr
    have := H.nrl; omega

/-- The stage's names, glued back, are the stage map's. -/
theorem ag2 : NAgree (· < n2) M2 (H.Mr.after H.τ) where
  a := by rw [H.ext.a]; rfl
  big := by rw [H.ext.big]; rfl
  region := by rw [H.ext.region]; rfl
  node := by rw [H.ext.node]; rfl
  num i hi := by
    by_cases h0 : i < n0
    · rw [H.ext.num i h0]
      show (M.glue M2 n1 n0).nv ((σ.res n0 n1).num i) = M.nv (σ.num i)
      rw [(Map.res_ext σ n0 n1).num i h0]
      exact (NAgree.ofExt (Map.glue_ext M M2 n1 n0)).nv (H.numS i h0)
    · show (M.glue M2 n1 n0).nv ((σ.res n0 n1).num i) = M2.num i
      rw [Map.res_new σ (by omega)]
      show (M.glue M2 n1 n0).num _ = _
      rw [Map.glue_new M M2 (by omega)]
      congr 1; omega

theorem τbig : (H.τ).big = σ.big := rfl
theorem τnode : (H.τ).node = σ.node := rfl

theorem handle2 (h : Nat) : M2.handle h = M.handle (σ.handle h) := by
  rw [Map.handle_after M σ (H.iso.nonneg h)]
  simp [Map.handle, H.ext.big]

theorem τhandle (h : Nat) : (H.τ).handle h = σ.handle h := rfl

/-- Fresh stage handles go to the caller's fresh handles. -/
theorem σfreshH {h : Nat} (h1 : x0.next ≤ h) (h2 : h < x2.next) : σ.handle h = x1.next + (h - x0.next) := by
  have e := H.iso.hfreshB (h - x0.next) (by have := H.hlt2; omega)
  rw [Nat.add_sub_cancel' h1] at e
  show (σ.big (Int.ofNat h)).toNat = _
  rw [e]; rfl

/-- The caller's fresh handles' images. -/
theorem freshImg (k : Nat) (hk : x0.next + k < x2.next) : M.big (Int.ofNat (x1.next + k)) = Int.ofNat (y.next + k) :=
  H.hr1.hfreshB k (H.hE' k (by have := H.hlt2; omega))

/-- A present handle of the merged state: the caller's, or a fresh one. -/
theorem phCases {h' : Nat} (hp : PH xr h') : PH x1 h' ∨ ∃ k, h' = x1.next + k ∧ x0.next + k < x2.next := by
  by_cases hw : ∃ h ∈ wh, σ.handle h = h'
  · obtain ⟨h, hh, rfl⟩ := hw
    by_cases hlt : h < x0.next
    · exact .inl (H.iso.present h (H.foot.wh0 h hh hlt)).2
    · have hp2 := H.foot.whP h hh
      have hlt2 := H.hr2.hlt h hp2
      exact .inr ⟨h - x0.next, H.σfreshH (by omega) hlt2, by omega⟩
  · have hc : ∀ h ∈ wh, σ.handle h ≠ h' := fun h hh e => hw ⟨h, hh, e⟩
    left
    unfold PH at hp ⊢
    rw [H.mer.arrsC h' hc, H.mer.objsC h' hc] at hp
    exact hp

theorem handleFresh (k : Nat) (hk : x0.next + k < x2.next) : M.handle (x1.next + k) = y.next + k := by
  show (M.big (Int.ofNat (x1.next + k))).toNat = _
  rw [H.freshImg k hk]; rfl


theorem freshRoom (k : Nat) (hk : x0.next + k < x2.next) : y.next + k < 2 ^ 46 := by
  have h1 := H.hr1.hroom; have h2 := H.hE' k (by have := H.hlt2; omega); omega

theorem ynext_pos : 0 < y.next := by
  have := H.hr1.lo; have := H.hr1.hnext; omega

theorem present' {h' : Nat} (hp : PH xr h') : HMap H.Mr h' (H.Mr.handle h') := by
  rcases H.phCases hp with h1 | ⟨k, rfl, hk⟩
  · exact H.hr1.present h' h1
  · have e := H.handleFresh k hk
    refine ⟨?_, ?_, ?_⟩
    · show M.big (Int.ofNat (x1.next + k)) = Int.ofNat (M.handle (x1.next + k))
      rw [e]; exact H.freshImg k hk
    · show M.region (4 * (x1.next + k)) = 4 * M.handle (x1.next + k)
      rw [e]; exact (H.hr1.hfreshR k (H.freshRoom k hk)).1
    · show M.region (4 * (x1.next + k) + 1) = 4 * M.handle (x1.next + k) + 1
      rw [e]; exact (H.hr1.hfreshR k (H.freshRoom k hk)).2

theorem hinj' (a b : Nat) (ha : PH xr a) (hb : PH xr b) (he : H.Mr.handle a = H.Mr.handle b) : a = b := by
  change M.handle a = M.handle b at he
  rcases H.phCases ha with ha1 | ⟨k, rfl, hk⟩ <;> rcases H.phCases hb with hb1 | ⟨k', rfl, hk'⟩
  · exact H.hr1.hinj a b ha1 hb1 he
  · rw [H.handleFresh k' hk'] at he; have := (H.hr1.himg a ha1).2; omega
  · rw [H.handleFresh k hk] at he; have := (H.hr1.himg b hb1).2; omega
  · rw [H.handleFresh k hk, H.handleFresh k' hk'] at he; omega

theorem hlt' (h' : Nat) (hp : PH xr h') : h' < xr.next := by
  rw [H.mer.next]
  rcases H.phCases hp with h1 | ⟨k, rfl, hk⟩
  · have := H.hr1.hlt h' h1; omega
  · omega

theorem himg' (h' : Nat) (hp : PH xr h') : 0 < H.Mr.handle h' ∧ H.Mr.handle h' < y'.next := by
  change 0 < M.handle h' ∧ M.handle h' < y'.next
  rw [H.lockH]
  rcases H.phCases hp with h1 | ⟨k, rfl, hk⟩
  · have := H.hr1.himg h' h1; omega
  · rw [H.handleFresh k hk]; have := H.ynext_pos; omega

theorem hband' (h' : Nat) (hp : PH xr h') (hl : P1.lo ≤ h') : P1.lo ≤ H.Mr.handle h' := by
  change P1.lo ≤ M.handle h'
  rcases H.phCases hp with h1 | ⟨k, rfl, hk⟩
  · exact H.hr1.hband h' h1 hl
  · rw [H.handleFresh k hk]; have := H.hr1.hnext; omega

theorem notWh0 : ∀ h ∈ wh, σ.handle h ≠ 0 := by
  intro h hh e
  by_cases hlt : h < x0.next
  · have hp := (H.iso.present h (H.foot.wh0 h hh hlt)).2
    rw [e] at hp
    have h0 := H.hr1.absent0
    unfold PH at hp; rw [h0.1, h0.2.1] at hp; simp at hp
  · rw [H.σfreshH (by omega) (H.hr2.hlt h (H.foot.whP h hh))] at e
    have := H.hr1.hnext; have := H.hr1.lo; omega

theorem arrs' (h' : Nat) (hp : PH xr h') : y'.arrs.get (H.Mr.handle h') = (xr.arrs.get h').map H.Mr.node := by
  show y'.arrs.get (M.handle h') = (xr.arrs.get h').map M.node
  by_cases hw : ∃ h ∈ wh, σ.handle h = h'
  · obtain ⟨h, hh, rfl⟩ := hw
    rw [H.mer.arrsS h hh, ← H.handle2 h, H.hr2.arrs h (H.foot.whP h hh), Option.map_map, H.ext.node]; rfl
  · have hc : ∀ h ∈ wh, σ.handle h ≠ h' := fun h hh e => hw ⟨h, hh, e⟩
    have hp1 : PH x1 h' := by unfold PH at hp ⊢; rwa [H.mer.arrsC h' hc, H.mer.objsC h' hc] at hp
    rw [H.mer.arrsC h' hc]
    by_cases hf : ∃ h0, PH x0 h0 ∧ σ.handle h0 = h'
    · obtain ⟨h0, hp0, rfl⟩ := hf
      have hn : h0 ∉ wh := fun hm => hw ⟨h0, hm, rfl⟩
      have hp2 : PH x2 h0 := by unfold PH at hp0 ⊢; rw [H.foot.sameA h0 hn, H.foot.sameO h0 hn]; exact hp0
      rw [← H.handle2 h0, H.hr2.arrs h0 hp2, H.foot.sameA h0 hn, H.iso.arrs h0 hp0, Option.map_map, H.ext.node]; rfl
    · rw [H.frz.arrs h' hp1 (fun h0 hp0 e => hf ⟨h0, hp0, e⟩), H.hr1.arrs h' hp1]

theorem objs' (h' : Nat) (hp : PH xr h') : y'.objs.get (H.Mr.handle h') = (xr.objs.get h').map H.Mr.nobj := by
  show y'.objs.get (M.handle h') = (xr.objs.get h').map H.Mr.nobj
  by_cases hw : ∃ h ∈ wh, σ.handle h = h'
  · obtain ⟨h, hh, rfl⟩ := hw
    rw [H.mer.objsS h hh, ← H.handle2 h, H.hr2.objs h (H.foot.whP h hh), Option.map_map]
    cases ho : x2.objs.get h with
    | none => rfl
    | some o =>
      simp only [Option.map_some, Function.comp_apply, Option.some.injEq]
      rw [Map.nobj_after]
      exact (H.ag2.nobj (H.hr2.cl.2.1 h o ho)).symm
  · have hc : ∀ h ∈ wh, σ.handle h ≠ h' := fun h hh e => hw ⟨h, hh, e⟩
    have hp1 : PH x1 h' := by unfold PH at hp ⊢; rwa [H.mer.arrsC h' hc, H.mer.objsC h' hc] at hp
    rw [H.mer.objsC h' hc]
    have hx1 : (x1.objs.get h').map H.Mr.nobj = (x1.objs.get h').map M.nobj := by
      cases ho : x1.objs.get h' with
      | none => rfl
      | some o => simp only [Option.map_some, H.agS.nobj (H.hr1.cl.2.1 h' o ho)]
    rw [hx1]
    by_cases hf : ∃ h0, PH x0 h0 ∧ σ.handle h0 = h'
    · obtain ⟨h0, hp0, rfl⟩ := hf
      have hn : h0 ∉ wh := fun hm => hw ⟨h0, hm, rfl⟩
      have hp2 : PH x2 h0 := by unfold PH at hp0 ⊢; rw [H.foot.sameA h0 hn, H.foot.sameO h0 hn]; exact hp0
      rw [← H.handle2 h0, H.hr2.objs h0 hp2, H.foot.sameO h0 hn, H.iso.objs h0 hp0, Option.map_map]
      cases ho : x0.objs.get h0 with
      | none => rfl
      | some o =>
        simp only [Option.map_some, Function.comp_apply, Option.some.injEq]
        rw [Map.nobj_after]
        exact H.ag0.nobj (H.iso.cl.2.1 h0 o ho)
    · rw [H.frz.objs h' hp1 (fun h0 hp0 e => hf ⟨h0, hp0, e⟩), H.hr1.objs h' hp1]

/-- A stage dimension canonical for the stage map and for `τ` is canonical for the glued map. -/
theorem canonMr {d : Dim} (hs : SD (· < n2) d) (h2 : DimCanon M2 d) (ht : DimCanon H.τ d) :
    DimCanon H.Mr (H.τ.dim d) := by
  have hn : SN (· < n2) d.num := by cases d with
    | lit _ => trivial
    | sym x => exact hs
  unfold DimCanon at *
  rw [Map.dim_after, H.ag2.dim hs, h2, ← H.ag2.nv hn, ← Map.nv_after, ht]

theorem cfgCanon' (h c) (hc : xr.objs.get h = some (.cfg c)) : ∀ p ∈ c.outs, ∀ d ∈ p.1, DimCanon H.Mr d := by
  by_cases hw : ∃ h2 ∈ wh, σ.handle h2 = h
  · obtain ⟨h2, hh, rfl⟩ := hw
    rw [H.mer.objsS h2 hh] at hc
    cases ho : x2.objs.get h2 with
    | none => rw [ho] at hc; cases hc
    | some o =>
      rw [ho] at hc
      cases o with
      | cfg c2 =>
        simp only [Option.map_some, Map.nobj, Option.some.injEq, Host.Mlx.Ffi.Obj.cfg.injEq] at hc
        subst hc
        intro p hp d hd
        obtain ⟨⟨s2, dt⟩, hm, rfl⟩ := List.mem_map.1 hp
        obtain ⟨d2, hd2, rfl⟩ := List.mem_map.1 hd
        exact H.canonMr ((H.hr2.cl.2.1 h2 _ ho).1 _ hm d2 hd2) (H.hr2.cfgCanon h2 c2 ho _ hm d2 hd2)
          (H.mer.cfgCanonS h2 hh c2 ho _ hm d2 hd2)
      | _ => simp [Map.nobj] at hc
  · have hcw : ∀ h2 ∈ wh, σ.handle h2 ≠ h := fun h2 hh e => hw ⟨h2, hh, e⟩
    rw [H.mer.objsC h hcw] at hc
    intro p hp d hd
    exact DimCanon.agree H.agS ((H.hr1.cl.2.1 h _ hc).1 p hp d hd) (H.hr1.cfgCanon h c hc p hp d hd)

theorem traced' (h o) (ho : xr.objs.get h = some o) (hNL : P0.NL = P1.NL) : ∀ i ∈ objTraces o, i < P1.NL := by
  by_cases hw : ∃ h2 ∈ wh, σ.handle h2 = h
  · obtain ⟨h2, hh, rfl⟩ := hw
    rw [H.mer.objsS h2 hh] at ho
    cases ho2 : x2.objs.get h2 with
    | none => rw [ho2] at ho; cases ho
    | some o2 =>
      rw [ho2] at ho
      simp only [Option.map_some, Option.some.injEq] at ho
      subst ho
      intro i hi
      rw [objTraces_nobj] at hi
      obtain ⟨i2, hi2, rfl⟩ := List.mem_map.1 hi
      have hlt := H.hr2.traced h2 o2 ho2 i2 hi2
      show σ.node i2 < P1.NL
      rw [H.iso.nid i2 hlt, ← hNL]; exact hlt
  · have hcw : ∀ h2 ∈ wh, σ.handle h2 ≠ h := fun h2 hh e => hw ⟨h2, hh, e⟩
    rw [H.mer.objsC h hcw] at ho
    exact H.hr1.traced h o ho

theorem nlt' (i : Nat) (hi : PN xr i) : i < xr.nnext := by
  by_contra hc
  have := H.mer.nodesHi i (by omega)
  unfold PN at hi; rw [this] at hi; cases hi

/-- A present node of the merged state: the caller's, or a fresh one. -/
theorem pnCases {i : Nat} (hi : PN xr i) : (i < x1.nnext ∧ PN x1 i) ∨ ∃ k, i = x1.nnext + k ∧ x0.nnext + k < x2.nnext := by
  by_cases hl : i < x1.nnext
  · left; refine ⟨hl, ?_⟩; unfold PN at hi ⊢; rw [← H.mer.nodesC i hl]; exact hi
  · right
    have := H.nlt' i hi
    rw [H.mer.nnext] at this
    exact ⟨i - x1.nnext, by omega, by have := H.foot.nnext; omega⟩

theorem nodeFresh (k : Nat) : M.node (x1.nnext + k) = y.nnext + k := H.hr1.nfresh k

theorem node2 (i : Nat) : M2.node i = M.node (σ.node i) := by rw [H.ext.node]; rfl

theorem nall' (j : Nat) (hj : j < xr.nnext) : H.Mr.node j < y'.nnext := by
  change M.node j < y'.nnext
  rw [H.lockN]
  by_cases hl : j < x1.nnext
  · have := H.hr1.nall j hl; omega
  · rw [H.mer.nnext] at hj
    rw [show j = x1.nnext + (j - x1.nnext) by omega, H.nodeFresh]; have := H.foot.nnext; omega

theorem nodes' (hNL : P0.NL = P1.NL) (i : Nat) (nd : Node) (hn : xr.nodes.get i = some nd) :
    ∃ nd', y'.nodes.get (H.Mr.node i) = some nd' ∧ NodeR (P1.abstractTo xr.nnext) H.Mr i nd nd' := by
  change ∃ nd', y'.nodes.get (M.node i) = some nd' ∧ _
  have hpi : PN xr i := by unfold PN; rw [hn]; rfl
  have hiN := H.nlt' i hpi
  have hNLx := H.hr1.nband
  by_cases hl : i < x1.nnext
  · rw [H.mer.nodesC i hl] at hn
    obtain ⟨nd', h1, hsh, hdt, hcn, hfull⟩ := H.hr1.nodes i nd hn
    have hpi1 : PN x1 i := by unfold PN; rw [hn]; rfl
    have hsn := H.hr1.cl.1 i nd hn
    refine ⟨nd', by rw [H.frz.nodes _ (H.hr1.nimg i hpi1)]; exact h1, ?_, hdt, ?_, fun hf => ?_⟩
    · rw [hsh]; exact (H.agS.dims hsn.2).symm
    · intro d hd; exact DimCanon.agree H.agS (hsn.2 d hd) (hcn d hd)
    · have hf1 : Full P1 i := by
        rcases hf with hf | hf
        · exact .inl hf
        · simp only [LoadP.abstractTo] at hf; omega
      obtain ⟨hp, hins⟩ := hfull hf1
      exact ⟨PrimR.agree H.agS hsn.1 hp, hins⟩
  · obtain ⟨k, rfl⟩ : ∃ k, i = x1.nnext + k := ⟨i - x1.nnext, by omega⟩
    obtain ⟨nd2, h2, hsh, hdt, -⟩ := H.mer.nodesS k nd hn
    obtain ⟨nd'', h3, hsh2, hdt2, hcn2, -⟩ := H.hr2.nodes _ nd2 h2
    have hsn := H.hr2.cl.1 _ nd2 h2
    refine ⟨nd'', ?_, ?_, by rw [hdt2, hdt], ?_, fun hf => ?_⟩
    · rw [H.node2, H.iso.nfresh] at h3; exact h3
    · rw [hsh2, hsh, Map.dims_after]; exact (H.ag2.dims hsn.2).symm
    · intro d hd
      rw [hsh] at hd
      obtain ⟨d2, hd2, rfl⟩ := List.mem_map.1 hd
      exact H.canonMr (hsn.2 d2 hd2) (hcn2 d2 hd2) (H.mer.nodesCanon k nd2 h2 d2 hd2)
    · exfalso
      rcases hf with hf | hf
      · simp only [LoadP.abstractTo] at hf; have := hNLx.1; have := hNLx.2; omega
      · simp only [LoadP.abstractTo] at hf; omega

theorem ninj' (a b : Nat) (ha : PN xr a) (hb : PN xr b) (he : H.Mr.node a = H.Mr.node b) : a = b := by
  change M.node a = M.node b at he
  rcases H.pnCases ha with ⟨_, ha1⟩ | ⟨k, rfl, hk⟩ <;> rcases H.pnCases hb with ⟨_, hb1⟩ | ⟨k', rfl, hk'⟩
  · exact H.hr1.ninj a b ha1 hb1 he
  · rw [H.nodeFresh] at he; have := H.hr1.nimg a ha1; omega
  · rw [H.nodeFresh] at he; have := H.hr1.nimg b hb1; omega
  · rw [H.nodeFresh, H.nodeFresh] at he; omega

theorem items' (k : Nat) (hk : PN xr k) : y'.items.get (H.Mr.node k) = (xr.items.get k).map H.Mr.nv := by
  change y'.items.get (M.node k) = _
  rcases H.pnCases hk with ⟨hl, hk1⟩ | ⟨k', rfl, hk'⟩
  · by_cases hw : ∃ i ∈ wi, σ.node i = k
    · obtain ⟨i, hi, rfl⟩ := hw
      have hp0 := H.foot.wiP i hi
      have hp2 : PN x2 i := by
        unfold PN at hp0 ⊢; rw [H.foot.nodes i (H.iso.nlt i hp0)]; exact hp0
      rw [H.mer.itemsW i hi, ← H.node2, H.hr2.items i hp2, Option.map_map]
      cases ht : x2.items.get i with
      | none => rfl
      | some t =>
        simp only [Option.map_some, Function.comp_apply, Option.some.injEq]
        rw [Map.nv_after]; exact (H.ag2.nv (H.hr2.cl.2.2.2.1 i t ht)).symm
    · have hcw : ∀ i ∈ wi, σ.node i ≠ k := fun i hi e => hw ⟨i, hi, e⟩
      rw [H.mer.itemsC k hl hcw]
      have hx1 : (x1.items.get k).map H.Mr.nv = (x1.items.get k).map M.nv := by
        cases ht : x1.items.get k with
        | none => rfl
        | some t => simp only [Option.map_some, H.agS.nv (H.hr1.cl.2.2.2.1 k t ht)]
      rw [hx1]
      by_cases hf : ∃ i0, PN x0 i0 ∧ σ.node i0 = k
      · obtain ⟨i0, hp0, rfl⟩ := hf
        have hn : i0 ∉ wi := fun hm => hw ⟨i0, hm, rfl⟩
        have hlt0 := H.iso.nlt i0 hp0
        have hp2 : PN x2 i0 := by unfold PN at hp0 ⊢; rw [H.foot.nodes i0 hlt0]; exact hp0
        rw [← H.node2, H.hr2.items i0 hp2, H.foot.items i0 hlt0 hn, H.iso.items i0 hp0, Option.map_map]
        cases ht : x0.items.get i0 with
        | none => rfl
        | some t =>
          simp only [Option.map_some, Function.comp_apply, Option.some.injEq]
          rw [Map.nv_after]; exact H.ag0.nv (H.iso.cl.2.2.2.1 i0 t ht)
      · rw [H.frz.items k hk1 (fun i0 hp0 e => hf ⟨i0, hp0, e⟩), H.hr1.items k hk1]
  · have hp2 : PN x2 (x0.nnext + k') := by
      obtain ⟨nd, hnd⟩ := Option.isSome_iff_exists.mp hk
      obtain ⟨nd2, h2, -⟩ := H.mer.nodesS k' nd hnd
      unfold PN; rw [h2]; rfl
    rw [H.mer.itemsS k', ← H.iso.nfresh, ← H.node2, H.hr2.items _ hp2, Option.map_map]
    cases ht : x2.items.get (x0.nnext + k') with
    | none => rfl
    | some t =>
      simp only [Option.map_some, Function.comp_apply, Option.some.injEq]
      rw [Map.nv_after]; exact (H.ag2.nv (H.hr2.cl.2.2.2.1 _ t ht)).symm

theorem itemsPresent' (k : Nat) (hk : (xr.items.get k).isSome = true) : PN xr k := by
  by_cases hl : k < x1.nnext
  · by_cases hw : ∃ i ∈ wi, σ.node i = k
    · obtain ⟨i, hi, rfl⟩ := hw
      obtain ⟨nd1, h1, -⟩ := H.iso.nodes i _ (Option.get_mem (H.foot.wiP i hi))
      unfold PN; rw [H.mer.nodesC _ hl, h1]; rfl
    · have hcw : ∀ i ∈ wi, σ.node i ≠ k := fun i hi e => hw ⟨i, hi, e⟩
      rw [H.mer.itemsC k hl hcw] at hk
      have := H.hr1.itemsPresent k hk
      unfold PN at this ⊢; rw [H.mer.nodesC k hl]; exact this
  · obtain ⟨k', rfl⟩ : ∃ k', k = x1.nnext + k' := ⟨k - x1.nnext, by omega⟩
    rw [H.mer.itemsS k'] at hk
    have : (x2.items.get (x0.nnext + k')).isSome = true := by
      cases h : x2.items.get (x0.nnext + k') with
      | none => rw [h] at hk; cases hk
      | some _ => rfl
    exact H.mer.nodesF k' (H.hr2.itemsPresent _ this)

theorem cl' : SSt (· < nr) xr := by
  have hm1 : ∀ i, i < n1 → i < nr := fun i hi => by have := H.nrl; omega
  refine ⟨fun i nd hn => ?_, fun h o ho => ?_, fun t ht => ?_, fun k t ht => ?_, fun a ha => ?_⟩
  · by_cases hl : i < x1.nnext
    · rw [H.mer.nodesC i hl] at hn; exact SNode.mono hm1 (H.hr1.cl.1 i nd hn)
    · obtain ⟨k, rfl⟩ : ∃ k, i = x1.nnext + k := ⟨i - x1.nnext, by omega⟩
      obtain ⟨_, _, _, _, hs⟩ := H.mer.nodesS k nd hn
      exact hs
  · by_cases hw : ∃ h2 ∈ wh, σ.handle h2 = h
    · obtain ⟨h2, hh, rfl⟩ := hw
      rw [H.mer.objsS h2 hh] at ho
      cases ho2 : x2.objs.get h2 with
      | none => rw [ho2] at ho; cases ho
      | some o2 =>
        rw [ho2] at ho; simp only [Option.map_some, Option.some.injEq] at ho; subst ho
        exact SObj.map H.τnum (H.hr2.cl.2.1 h2 o2 ho2)
    · rw [H.mer.objsC h (fun h2 hh e => hw ⟨h2, hh, e⟩)] at ho
      exact SObj.mono hm1 (H.hr1.cl.2.1 h o ho)
  · rw [H.mer.tokens] at ht
    obtain ⟨t2, h2, rfl⟩ := List.mem_map.1 ht
    exact SN.map H.τnum (H.hr2.cl.2.2.1 t2 h2)
  · by_cases hl : k < x1.nnext
    · by_cases hw : ∃ i ∈ wi, σ.node i = k
      · obtain ⟨i, hi, rfl⟩ := hw
        rw [H.mer.itemsW i hi] at ht
        cases h2 : x2.items.get i with
        | none => rw [h2] at ht; cases ht
        | some t2 =>
          rw [h2] at ht; simp only [Option.map_some, Option.some.injEq] at ht; subst ht
          exact SN.map H.τnum (H.hr2.cl.2.2.2.1 i t2 h2)
      · rw [H.mer.itemsC k hl (fun i hi e => hw ⟨i, hi, e⟩)] at ht
        exact SN.mono hm1 (H.hr1.cl.2.2.2.1 k t ht)
    · obtain ⟨k', rfl⟩ : ∃ k', k = x1.nnext + k' := ⟨k - x1.nnext, by omega⟩
      rw [H.mer.itemsS k'] at ht
      cases h2 : x2.items.get (x0.nnext + k') with
      | none => rw [h2] at ht; cases ht
      | some t2 =>
        rw [h2] at ht; simp only [Option.map_some, Option.some.injEq] at ht; subst ht
        exact SN.map H.τnum (H.hr2.cl.2.2.2.1 _ t2 h2)
  · rw [H.mer.errh] at ha
    cases h2 : x2.errh with
    | none => rw [h2] at ha; cases ha
    | some a2 =>
      rw [h2] at ha; simp only [Option.map_some, Option.some.injEq] at ha; subst ha
      exact SA.map H.τnum (H.hr2.cl.2.2.2.2 a2 h2)

/-- **The native merge**: the caller's relation at the merged native state under the glued map,
with every node before the merge abstract. -/
theorem mr (hNL : P0.NL = P1.NL) : MR (P1.abstractTo xr.nnext) NB H.Mr nr xr y' := by
  have hd : x1.next + (x2.next - x0.next) ≤ P1.E := by
    by_cases h0 : x2.next - x0.next = 0
    · have := H.hr1.hroom.1; omega
    · have := H.hE' (x2.next - x0.next - 1) (by have := H.foot.next; have := H.hlt2; omega); omega
  exact
  { lo := H.hr1.lo
    bigFix := H.hr1.bigFix
    bigFixHi := H.hr1.bigFixHi
    present := fun h hp => H.present' hp
    hinj := H.hinj'
    hlt := H.hlt'
    himg := H.himg'
    hband := H.hband'
    hfreshR := fun k hk => by
      show M.region (4 * (xr.next + k)) = 4 * (y'.next + k) ∧ M.region (4 * (xr.next + k) + 1) = 4 * (y'.next + k) + 1
      rw [H.mer.next, H.lockH] at *
      rw [show x1.next + (x2.next - x0.next) + k = x1.next + ((x2.next - x0.next) + k) by omega,
        show y.next + (x2.next - x0.next) + k = y.next + ((x2.next - x0.next) + k) by omega]
      exact H.hr1.hfreshR _ (by omega)
    zero := H.hr1.zero
    hnext := ⟨by show P1.lo ≤ xr.next; rw [H.mer.next]; have := H.hr1.hnext; omega, by rw [H.mer.next, H.lockH]; have := H.hr1.hnext; omega⟩
    hroom := ⟨by rw [H.mer.next]; exact hd, by
      show y'.next + (P1.E - xr.next) < 2 ^ 46
      rw [H.mer.next, H.lockH]; have := H.hr1.hroom; omega⟩
    absent0 := ⟨by rw [H.mer.arrsC 0 H.notWh0]; exact H.hr1.absent0.1,
      by rw [H.mer.objsC 0 H.notWh0]; exact H.hr1.absent0.2.1, H.hr2.absent0.2.2⟩
    yabsent := H.hr2.yabsent
    arrs := H.arrs'
    objs := H.objs'
    cfgCanon := H.cfgCanon'
    traced := fun h o ho => H.traced' h o ho hNL
    node0 := H.hr1.node0
    nid := H.hr1.nid
    nbl := H.hr1.nbl
    nall := H.nall'
    norder := fun i hi hf j hj => by
      have hlt := H.nlt' i hi
      have hi1 : i < P1.NL := by
        rcases hf with hf | hf
        · exact hf
        · simp only [LoadP.abstractTo] at hf; omega
      have hb := H.hr1.nband
      have hpi1 : PN x1 i := by unfold PN at hi ⊢; rwa [← H.mer.nodesC i (by omega)]
      exact H.hr1.norder i hpi1 (.inl hi1) j hj
    nodes := H.nodes' hNL
    ninj := H.ninj'
    nlt := H.nlt'
    nimg := fun i hi => H.nall' i (H.nlt' i hi)
    nfresh := fun k => by
      show M.node (xr.nnext + k) = y'.nnext + k
      rw [H.mer.nnext, H.lockN, show x1.nnext + (x2.nnext - x0.nnext) + k = x1.nnext + ((x2.nnext - x0.nnext) + k) by omega,
        H.nodeFresh]; omega
    nband := ⟨by simp only [LoadP.abstractTo]; rw [H.mer.nnext]; have := H.hr1.nband; omega, by simp [LoadP.abstractTo]⟩
    nroom := ⟨by rw [H.mer.nnext, H.lockN]; have := H.hr1.nroom; omega, by rw [H.mer.nnext]; exact H.hNE, by
      show y'.nnext + (P1.NE - xr.nnext) < 2 ^ 62
      rw [H.mer.nnext, H.lockN]; have := H.hr1.nroom; have := H.hNE; omega⟩
    tokens := ⟨P0.rest, by
      rw [H.hr2.tokensX, H.mer.tokens, List.map_map]
      congr 1
      exact List.map_congr_left fun t ht => by
        rw [Function.comp_apply, Map.nv_after]; exact (H.ag2.nv (H.hr2.cl.2.2.1 t ht)).symm⟩
    items := H.items'
    itemsPresent := H.itemsPresent'
    yitems := H.hr2.yitems
    pending := by
      rw [H.hr2.pending, H.mer.pending, List.map_map]
      exact List.map_congr_left fun p _ => by
        exact ((Map.pend_after H.Mr H.τ p (fun h _ => H.iso.nonneg h)).trans (H.ag2.pend p)).symm
    errh := by
      rw [H.hr2.errh, H.mer.errh, Option.map_map]
      cases ha : x2.errh with
      | none => rfl
      | some a =>
        simp only [Option.map_some, Function.comp_apply, Option.some.injEq]
        rw [Map.arg_after]; exact (H.ag2.arg (H.hr2.cl.2.2.2.2 a ha)).symm
    files := by rw [H.hr2.files, H.mer.files]
    arch := by rw [H.hr2.arch, H.mer.arch]
    sizes := by rw [H.hr2.sizes, H.mer.sizes]
    wired := by rw [H.hr2.wired, H.mer.wired]
    cl := H.cl'
    hfreshB := fun k hk => by
      show M.big (Int.ofNat (xr.next + k)) = Int.ofNat (y'.next + k)
      rw [H.mer.next, H.lockH, show x1.next + (x2.next - x0.next) + k = x1.next + ((x2.next - x0.next) + k) by omega,
        show y.next + (x2.next - x0.next) + k = y.next + ((x2.next - x0.next) + k) by omega]
      exact H.hr1.hfreshB _ (by rw [H.mer.next] at hk; simp only [LoadP.abstractTo] at hk; omega)
    tokensX := by
      rw [H.hr2.tokensX, H.mer.tokens, List.map_map, H.hrest]
      congr 1
      exact List.map_congr_left fun t ht => by
        rw [Function.comp_apply, Map.nv_after]; exact (H.ag2.nv (H.hr2.cl.2.2.1 t ht)).symm }

end NMergeIn


/-- **The merge's native law for the load world**: with the stage's host state the merged state's
(`hhost`), the caller's `G.LoadR` holds at the merged state under the glued map, every node
before the merge abstract. -/
theorem loadR_merge {P0 P1 : LoadP} {NB : Nat} {M M2 σ : Map} {n0 n1 n2 nr : Nat} {wh wi : List Nat}
    {x0 x1 x2 xr y y' : Host.Load.LSt}
    (H : NMergeIn P0 P1 NB M M2 σ n0 n1 n2 nr wh wi x0.mlx x1.mlx x2.mlx xr.mlx y.mlx y'.mlx)
    (hr1 : LoadR P1 NB M n1 x1 y) (hr2 : LoadR P0 NB M2 n2 x2 y') (hhost : xr.host = x2.host)
    (hNL : P0.NL = P1.NL) :
    LoadR (P1.abstractTo xr.mlx.nnext) NB (M.glue M2 n1 n0) nr xr y' where
  host := by rw [hr2.host, hhost]
  hostReg := hr1.hostReg
  hostLt := fun h hh => hr2.hostLt h (by rw [← hhost]; exact hh)
  cbr := hr1.cbr
  mlx := H.mr hNL

/-! ## Native frozenness at a site instance -/

/-- **Native frozenness at a site instance** (`NFrozen`'s `arrs`, `objs`, `items`): a site
instance's native start is the caller's own native state, so a caller handle the stage leaves
(`NFoot`) keeps its target entries, and so does the readback item of a caller node it leaves: the
native relation at the start and at the end, under an extension of the map. (`NFrozen.nodes`, the
target graph only growing, is the world's.) -/
theorem site_keptN {P : LoadP} {NB : Nat} {M M' : Map} {n n' : Nat} {wh wi : List Nat} {x0 x2 y y' : NSt}
    (h0 : MRw P NB M n x0 y) (h2 : MRw P NB M' n' x2 y') (he : Ext M M' n) (hf : NFoot wh wi x0 x2) :
    (∀ h, PH x0 h → h ∉ wh → y'.arrs.get (M.handle h) = y.arrs.get (M.handle h) ∧
      y'.objs.get (M.handle h) = y.objs.get (M.handle h)) ∧
    (∀ k, PN x0 k → k ∉ wi → y'.items.get (M.node k) = y.items.get (M.node k)) := by
  have hH : ∀ h, M'.handle h = M.handle h := fun h => by simp only [Map.handle, he.big]
  have hag := NAgree.ofExt he
  refine ⟨fun h hp hw => ?_, fun k hk hw => ?_⟩
  · have hp2 : PH x2 h := by unfold PH at hp ⊢; rw [hf.sameA h hw, hf.sameO h hw]; exact hp
    constructor
    · have e := h2.arrs h hp2
      rw [hH, hf.sameA h hw, he.node] at e
      rw [e, h0.arrs h hp]
    · have e := h2.objs h hp2
      rw [hH, hf.sameO h hw] at e
      rw [e, h0.objs h hp]
      cases e2 : x0.objs.get h with
      | none => rfl
      | some o => simp only [Option.map_some, hag.nobj (h0.cl.2.1 h o e2)]
  · have hlt := h0.nlt k hk
    have hk2 : PN x2 k := by unfold PN at hk ⊢; rw [hf.nodes k hlt]; exact hk
    have e := h2.items k hk2
    rw [he.node, hf.items k hlt hw] at e
    rw [e, h0.items k hk]
    cases e2 : x0.items.get k with
    | none => rfl
    | some t => simp only [Option.map_some, hag.nv (h0.cl.2.2.2.1 k t e2)]

end Host.Ts.Sim.G
