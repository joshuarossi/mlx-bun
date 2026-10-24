import host.sim.full.SymSim
import host.mlx.FfiSymShape
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall opOutSym inferSym)

/-! # Convolutions over a symbolic length

The model's `mlx_conv1d` is stuck over a symbolic input length; the symbolic-shape layer completes
it (`SymShape.inferSym`: length `l − c₀` with `c₀ = dilation·(k − 1) − 2·padding`, after a server
test that it is positive). `sim_conv1dSym`: the layer's completed call (`callSym`) of the template
simulates the target's. The target's length is a literal (the model's call has the result) or a
reference (the layer completes the target's too); either way its length is the template's value
less `c₀` (`conv_core`), for a template length of value at least `c₀` (`RefGe`). -/

/-- Number reference `j` denotes a natural in `[c, 2 ^ 31)` at `ν`. -/
def RefGe (ν : Nat → F64) (S : SSrv) (c j : Nat) : Prop :=
  ∃ e k, nth? S.tab j = some e ∧ e.eval ν = F64.ofNat k ∧ c ≤ k ∧ k < 2 ^ 31

/-- `RefGe` decided by intervals. -/
def refGeB (VB : Nat → Nat) (S : SSrv) (c j : Nat) : Bool :=
  match nth? S.tab j with
  | some e => match ivl VB e with
    | some (l, h) => decide (c ≤ l ∧ h < 2 ^ 31)
    | none => false
  | none => false

theorem refGeB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {c j : Nat} (h : refGeB VB S c j = true)
    (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) : RefGe ν S c j := by
  unfold refGeB at h
  split at h
  · rename_i e he
    split at h
    · rename_i l hi hi'
      obtain ⟨k, k1, k2, -, k4⟩ := ivl_sound hν e hi'
      have := of_decide_eq_true h
      exact ⟨e, k, he, k4, by omega, by omega⟩
    · cases h
  · cases h

/-- A dimension carried through server growth. -/
theorem carry_dim {ν : Nat → F64} {M M' : Map} {S S' : SSrv} {C C' : CSrv} {d : Dim}
    (g : GrowL M ν S C M' S' C') (hd : SD (· < S.tab.length) d) (hc : DimCanon M d) :
    M'.dim d = M.dim d ∧ SD (· < S'.tab.length) d ∧ DimCanon M' d :=
  ⟨(NAgree.ofExt g.grow.ext).dim hd, SD.mono (fun _ hi => Nat.lt_of_lt_of_le hi g.grow.len) hd,
    DimCanon.agree (NAgree.ofExt g.grow.ext) hd hc⟩

section
variable {ν : Nat → F64} {M : Map} {S : SSrv} {C : CSrv} (hs : Srv M ν S C)
include hs

theorem dv_of_ge {j c : Nat} (h : RefGe ν S c j) : ∃ k, DV M C (.sym (.ref j)) k ∧ c ≤ k ∧ k < 2 ^ 31 := by
  obtain ⟨e, k, he, hv, hc, hk⟩ := h
  exact ⟨k, .inr ⟨j, rfl, by rw [← hv]; exact hs.num j e he⟩, hc, hk⟩

/-- **The length arithmetic**: the template's length less `c₀`, tested positive, against a target
computation `F` that has the node at a positive length. -/
theorem conv_core {n oc : Dim} {j l c0 d : Nat} (F : Dim → Bool → Option Out)
    (hF : ∀ lo', F lo' true = some (.node [M.dim n, lo', M.dim oc] d))
    (hl : DV M C (.sym (.ref j)) l) (hj : SD (· < S.tab.length) (.sym (.ref j))) (hl31 : l < 2 ^ 31)
    (hle : c0 ≤ l) (hn : SD (· < S.tab.length) n) (hnc : DimCanon M n) (ho : SD (· < S.tab.length) oc)
    (hoc : DimCanon M oc) :
    MSim (IPost M ν S C) S C
      (Host.Ts.M.bind (Host.Mlx.Ffi.dSub (.sym (.ref j)) (.lit (c0 : Int))) fun lo =>
        Host.Ts.M.bind (Host.Mlx.Ffi.dLt (.lit 0) lo) fun pos =>
          Host.Ts.M.pure (bif pos then some (Out.node [n, lo, oc] d) else none))
      (Host.Ts.M.bind (Host.Mlx.Ffi.dSub (M.dim (.sym (.ref j))) (.lit (c0 : Int))) fun lo' =>
        Host.Ts.M.bind (Host.Mlx.Ffi.dLt (.lit 0) lo') fun pos' => Host.Ts.M.pure (F lo' pos')) := by
  refine MSim.bind (dSub_simV hs hl (.inl rfl) hj trivial (by omega) hle) fun M1 S1 C1 lo lo' h1 => ?_
  obtain ⟨e1, hv1, hs1, g1⟩ := h1
  subst e1
  refine MSim.bind (dLt_simV g1.grow.srv (a := .lit 0) (ka := 0) (.inl rfl) hv1 (by omega) (by omega))
    fun M2 S2 C2 pos pos' h2 => ?_
  obtain ⟨e2, -, g2⟩ := h2
  rw [e2]
  refine MSim.pure ⟨g1.trans g2, ?_⟩
  cases pos
  · trivial
  · show OutR M2 S2.tab.length (some (Out.node [n, lo, oc] d)) (F (M1.dim lo) true)
    rw [hF]
    obtain ⟨en, sn, cn⟩ := carry_dim (g1.trans g2) hn hnc
    obtain ⟨eo, so, co⟩ := carry_dim (g1.trans g2) ho hoc
    obtain ⟨el, sl, cl⟩ := carry_dim g2 hs1 (hv1.dimCanon (by omega))
    refine ⟨?_, ?_, ?_⟩
    · show _ = Out.node [M2.dim n, M2.dim lo, M2.dim oc] d
      rw [en, eo, el]
    · intro e he
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at he
      rcases he with rfl | rfl | rfl <;> assumption
    · intro e he
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at he
      rcases he with rfl | rfl | rfl <;> assumption

end

/-! ## Outputs of the layer's inference -/

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt}
  (hr : MR P NB M S.tab.length x y)
include hr

/-- `sim_opOutS` with the layer's inference at the template and at the target. -/
theorem sim_opOutSymS {o : Arg} {p : Prim} {ins : List Nat} {sh : List (List Dim × Nat)}
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (hp : SP (· < S.tab.length) p) (hsx : Host.Mlx.Ffi.shapesOf x ins = some sh)
    (hinf : MSim (IPost M ν S C) S C (inferSym p sh) (inferSym (M.prim p) (sh.map M.shp))) :
    MSim (MPost P NB M ν S C) S C (opOutSym x o p ins) (opOutSym y (M.arg o) (M.prim p) (ins.map M.node)) := by
  obtain ⟨b, off, sl, h1, h2, hsl⟩ := hr.slot_map ho
  have hsy := hr.shapesOf_map hsx
  unfold opOutSym
  simp only [h1, h2, hsx, hsy]
  refine MSim.bind hinf fun M1 S1 C1 r r' h => ?_
  obtain ⟨g1, hout⟩ := h
  have hs1 := g1.grow.srv
  have hr1 : MR P NB M1 S1.tab.length x y := hr.grow g1.grow
  have ea : M1.a = M.a := g1.grow.ext.a
  have en : M1.node = M.node := g1.grow.ext.node
  have eh : M1.handle sl = M.handle sl := by simp only [Map.handle, g1.grow.ext.big]
  have ep : M1.prim p = M.prim p := (NAgree.ofExt g1.grow.ext).prim hp
  have hp1 : SP (· < S1.tab.length) p := SP.mono (fun i hi => Nat.lt_of_lt_of_le hi g1.grow.len) hp
  refine MSim.mono (P := MPost P NB M1 ν S1 C1) ?_ fun M' S' C' r r' h => ⟨g1.grow.trans h.1, h.2⟩
  rcases r with _ | ⟨shape, dt⟩ | i
  · refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩ <;> exact ⟨_, fun _ _ => rfl⟩
  · rcases r' with _ | o'
    · exact hout.elim
    · obtain ⟨rfl, hsd, hc⟩ := hout
      rw [← ep, ← en, ← eh, ← ea]
      exact sim_nodeS hs1 hr1 hsl (fun _ => hE) hNE p ins shape dt hp1 hsd hc
  · refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩ <;> exact ⟨_, fun _ _ => rfl⟩

/-- The same against the model's inference at the target. -/
theorem sim_opOutSymL {o : Arg} {p : Prim} {ins : List Nat} {sh : List (List Dim × Nat)}
    (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E) (hNE : x.nnext + 1 ≤ P.NE)
    (hp : SP (· < S.tab.length) p) (hsx : Host.Mlx.Ffi.shapesOf x ins = some sh)
    (hinf : MSim (IPost M ν S C) S C (inferSym p sh) (Host.Mlx.Ffi.infer (M.prim p) (sh.map M.shp))) :
    MSim (MPost P NB M ν S C) S C (opOutSym x o p ins)
      (Host.Mlx.Ffi.opOut y (M.arg o) (M.prim p) (ins.map M.node)) := by
  obtain ⟨b, off, sl, h1, h2, hsl⟩ := hr.slot_map ho
  have hsy := hr.shapesOf_map hsx
  unfold opOutSym Host.Mlx.Ffi.opOut
  simp only [h1, h2, hsx, hsy]
  refine MSim.bind hinf fun M1 S1 C1 r r' h => ?_
  obtain ⟨g1, hout⟩ := h
  have hs1 := g1.grow.srv
  have hr1 : MR P NB M1 S1.tab.length x y := hr.grow g1.grow
  have ea : M1.a = M.a := g1.grow.ext.a
  have en : M1.node = M.node := g1.grow.ext.node
  have eh : M1.handle sl = M.handle sl := by simp only [Map.handle, g1.grow.ext.big]
  have ep : M1.prim p = M.prim p := (NAgree.ofExt g1.grow.ext).prim hp
  have hp1 : SP (· < S1.tab.length) p := SP.mono (fun i hi => Nat.lt_of_lt_of_le hi g1.grow.len) hp
  refine MSim.mono (P := MPost P NB M1 ν S1 C1) ?_ fun M' S' C' r r' h => ⟨g1.grow.trans h.1, h.2⟩
  rcases r with _ | ⟨shape, dt⟩ | i
  · refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · rename_i i
      dsimp only
      cases nth? (List.map M.node ins) i
      · exact ⟨_, fun _ _ => rfl⟩
      · exact ⟨_, fun _ _ => rfl⟩
  · rcases r' with _ | o'
    · exact hout.elim
    · obtain ⟨rfl, hsd, hc⟩ := hout
      rw [← ep, ← en, ← eh, ← ea]
      exact sim_nodeS hs1 hr1 hsl (fun _ => hE) hNE p ins shape dt hp1 hsd hc
  · refine msim_stuck hs1 _ ?_
    rcases r' with _ | ⟨_ | _⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · exact ⟨_, fun _ _ => rfl⟩
    · rename_i i
      dsimp only
      cases nth? (List.map M.node ins) i
      · exact ⟨_, fun _ _ => rfl⟩
      · exact ⟨_, fun _ _ => rfl⟩

end

/-! ## The call -/

theorem infer_conv_sym (pad dil g : Nat) (n oc : Dim) (lx : NumV) (c k ci : Int) (dx dw : Nat) :
    Host.Mlx.Ffi.infer (.conv1d 1 pad dil g) [([n, .sym lx, .lit c], dx), ([oc, .lit k, .lit ci], dw)] =
      Host.Ts.M.pure none := rfl

theorem inferSym_conv (pad dil g : Nat) (n oc : Dim) (lx : NumV) (c k ci : Int) (dx dw c0 : Nat) (hg : 0 < g)
    (hc : c = ci * g) (hc0 : (dil : Int) * (k - 1) - 2 * pad = c0) :
    inferSym (.conv1d 1 pad dil g) [([n, .sym lx, .lit c], dx), ([oc, .lit k, .lit ci], dw)] =
      Host.Ts.M.bind (Host.Mlx.Ffi.dSub (.sym lx) (.lit (c0 : Int))) fun lo =>
        Host.Ts.M.bind (Host.Mlx.Ffi.dLt (.lit 0) lo) fun pos =>
          Host.Ts.M.pure (bif pos then some (Out.node [n, lo, oc] (Host.Mlx.Ffi.promote dx dw)) else none) := by
  unfold inferSym
  simp only [hc0]
  rw [show decide (True ∧ 0 < g ∧ c = ci * ↑g) = true from decide_eq_true ⟨trivial, hg, hc⟩]
  rfl

theorem infer_conv_lit (pad dil g : Nat) (n oc : Dim) (l c k ci : Int) (dx dw c0 : Nat) (hg : 0 < g)
    (hc : c = ci * g) (hc0 : (dil : Int) * (k - 1) - 2 * pad = c0) :
    Host.Mlx.Ffi.infer (.conv1d 1 pad dil g) [([n, .lit l, .lit c], dx), ([oc, .lit k, .lit ci], dw)] =
      Host.Ts.M.bind (Host.Mlx.Ffi.dSub (.lit l) (.lit (c0 : Int))) fun lo =>
        Host.Ts.M.bind (Host.Mlx.Ffi.dLt (.lit 0) lo) fun _ =>
          Host.Ts.M.pure (some (Out.node [n, lo, oc] (Host.Mlx.Ffi.promote dx dw))) := by
  have e : decide (0 < 1 ∧ 0 < g ∧ c = ci * ↑g) = true := decide_eq_true ⟨Nat.one_pos, hg, hc⟩
  have ea : (l + 2 * (pad : Int) - (dil : Int) * (k - 1) - 1) / ((1 : Nat) : Int) + 1 = l - c0 := by
    rw [show ((1 : Nat) : Int) = 1 from rfl, Int.ediv_one]; omega
  show (bif decide (0 < 1 ∧ 0 < g ∧ c = ci * ↑g) then
    Host.Ts.M.pure (some (Out.node [n, .lit ((l + 2 * (pad : Int) - (dil : Int) * (k - 1) - 1) / ((1 : Nat) : Int) + 1), oc]
      (Host.Mlx.Ffi.promote dx dw))) else Host.Ts.M.pure none) = _
  rw [e, ea]
  rfl

/-- The call through the layer when the model's is stuck. -/
theorem callSym_stuck {s : NSt} {name : Name} {args : List Arg}
    (h : Host.Mlx.Ffi.call s name args = Host.Mlx.Ffi.stuck) : callSym s name args = symShapeCall s name args := by
  funext γ k
  unfold callSym; rw [h]
  simp only [Host.Ts.M.bind, Host.Mlx.Ffi.stuck, Host.Ts.M.pure]

/-- The call through the layer when the model's has a result. -/
theorem callSym_some {s : NSt} {name : Name} {args : List Arg} {r : NSt × Ret × List (Nat × Nat × List Byte)}
    (h : ∀ γ k, Host.Mlx.Ffi.call s name args γ k = k (some r)) :
    callSym s name args = Host.Mlx.Ffi.call s name args := by
  funext γ k
  unfold callSym Host.Ts.M.bind
  rw [h, h]; rfl

theorem conv_decode (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .conv1d)
    {o a w st pd dl gr e : Arg} {ins : List Nat} {v1 v2 v3 v4 : Nat} (h1 : Host.Mlx.Ffi.arrIns s [a, w] = some ins)
    (e1 : Host.Mlx.Ffi.argNat st = some v1) (e2 : Host.Mlx.Ffi.argNat pd = some v2)
    (e3 : Host.Mlx.Ffi.argNat dl = some v3) (e4 : Host.Mlx.Ffi.argNat gr = some v4) :
    Host.Mlx.Ffi.call s name [o, a, w, st, pd, dl, gr, e] = Host.Mlx.Ffi.opOut s o (.conv1d v1 v2 v3 v4) ins ∧
      symShapeCall s name [o, a, w, st, pd, dl, gr, e] = opOutSym s o (.conv1d v1 v2 v3 v4) ins := by
  constructor
  · unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [h1, e1, e2, e3, e4]
  · unfold symShapeCall; rw [hsym]; simp only [h1, e1, e2, e3, e4]

theorem opOut_infer {s : NSt} {o : Arg} {p : Prim} {ins : List Nat} {sh : List (List Dim × Nat)} {b off sl : Nat}
    (h1 : Host.Mlx.Ffi.slotOf o = some (b, off, sl)) (h2 : Host.Mlx.Ffi.shapesOf s ins = some sh) :
    Host.Mlx.Ffi.opOut s o p ins = Host.Ts.M.bind (Host.Mlx.Ffi.infer p sh) fun
      | some (.node shape dt) =>
        let (n, s) := s.addNode ⟨p, ins, shape, dt⟩
        let (h, s) := s.setArr sl n
        Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h]
      | some (.same i) => match nth? ins i with
        | some n => let (h, s) := s.setArr sl n; Host.Mlx.Ffi.okW s Host.Mlx.Ffi.status0 [Host.Mlx.Ffi.u64Write b off h]
        | none => Host.Mlx.Ffi.stuck
      | none => Host.Mlx.Ffi.stuck := by
  unfold Host.Mlx.Ffi.opOut; rw [h1, h2]; rfl

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **A convolution over a symbolic length**: the layer's completed calls simulate. -/
theorem sim_conv1dSym (hsym : Host.Mlx.Ffi.symOf name = some .conv1d) {o a w st pd dl gr e : Arg}
    {ins : List Nat} {pad dil g : Nat} {n oc : Dim} {j : Nat} {c k ci : Int} {dx dw c0 : Nat}
    (ha : hdOk x a = true) (hw : hdOk x w = true) (ho : slotOk P x o = true) (hE : x.next + 1 ≤ P.E)
    (hNE : x.nnext + 1 ≤ P.NE) (k1 : natOk P st = true) (k2 : natOk P pd = true) (k3 : natOk P dl = true)
    (k4 : natOk P gr = true) (e1 : Host.Mlx.Ffi.argNat st = some 1) (e2 : Host.Mlx.Ffi.argNat pd = some pad)
    (e3 : Host.Mlx.Ffi.argNat dl = some dil) (e4 : Host.Mlx.Ffi.argNat gr = some g)
    (h1 : Host.Mlx.Ffi.arrIns x [a, w] = some ins)
    (hsh : Host.Mlx.Ffi.shapesOf x ins = some [([n, .sym (.ref j), .lit c], dx), ([oc, .lit k, .lit ci], dw)])
    (hg : 0 < g) (hc : c = ci * g) (hc0 : (dil : Int) * (k - 1) - 2 * pad = c0) (hge : RefGe ν S c0 j) :
    MSim (MPost P NB M ν S C) S C (callSym x name [o, a, w, st, pd, dl, gr, e])
      (callSym y name ([o, a, w, st, pd, dl, gr, e].map M.arg)) := by
  have t1 := hr.arrIns_some (as := [a, w]) (by simp [ha, hw]) h1
  simp only [List.map_cons, List.map_nil] at t1 ⊢
  obtain ⟨b, off, sl, s1, s2, -⟩ := hr.slot_map ho
  have hsy := hr.shapesOf_map hsh
  obtain ⟨cx, dxs⟩ := conv_decode x hsym (o := o) (e := e) h1 e1 e2 e3 e4
  obtain ⟨cy, dys⟩ := conv_decode y hsym (o := M.arg o) (e := M.arg e) t1
    (by rw [hr.natOk_argNat k1, e1]) (by rw [hr.natOk_argNat k2, e2]) (by rw [hr.natOk_argNat k3, e3])
    (by rw [hr.natOk_argNat k4, e4])
  have hsx : callSym x name [o, a, w, st, pd, dl, gr, e] = opOutSym x o (.conv1d 1 pad dil g) ins := by
    rw [callSym_stuck (by rw [cx, opOut_infer s1 hsh, infer_conv_sym]; rfl), dxs]
  rw [hsx]
  have props := hr.shapesOf_props hsh
  obtain ⟨px, cxs⟩ := props _ List.mem_cons_self
  obtain ⟨pw, cws⟩ := props _ (List.mem_cons_of_mem _ List.mem_cons_self)
  obtain ⟨l, hl, hle, hl31⟩ := dv_of_ge hs hge
  have hn := px n List.mem_cons_self
  have hj := px _ (List.mem_cons_of_mem _ List.mem_cons_self)
  have hoc := pw oc List.mem_cons_self
  have cn := cxs n List.mem_cons_self
  have coc := cws oc List.mem_cons_self
  have hsy0 : Host.Mlx.Ffi.shapesOf y (ins.map M.node) =
      some [([M.dim n, M.dim (.sym (.ref j)), .lit c], dx), ([M.dim oc, .lit k, .lit ci], dw)] := hsy
  rcases hl.dim (by omega) with hd | ⟨j', hd, -⟩
  · -- the target's length is a literal: the model's call has the result
    rw [hd] at hsy0
    have ht := infer_conv_lit pad dil g (M.dim n) (M.dim oc) (l : Int) c k ci dx dw c0 hg hc hc0
    have hty : callSym y name [M.arg o, M.arg a, M.arg w, M.arg st, M.arg pd, M.arg dl, M.arg gr, M.arg e] =
        Host.Mlx.Ffi.opOut y (M.arg o) (.conv1d 1 pad dil g) (ins.map M.node) := by
      rw [callSym_some (fun γ k => by rw [cy, opOut_infer s2 hsy0, ht]; rfl), cy]
    rw [hty]
    refine sim_opOutSymL hr ho hE hNE trivial hsh ?_
    show MSim _ S C _ (Host.Mlx.Ffi.infer (.conv1d 1 pad dil g)
      [([M.dim n, M.dim (.sym (.ref j)), M.dim (.lit c)], dx), ([M.dim oc, M.dim (.lit k), M.dim (.lit ci)], dw)])
    rw [inferSym_conv pad dil g n oc (.ref j) c k ci dx dw c0 hg hc hc0, hd]
    show MSim _ S C _ (Host.Mlx.Ffi.infer (.conv1d 1 pad dil g)
      [([M.dim n, .lit (l : Int), .lit c], dx), ([M.dim oc, .lit k, .lit ci], dw)])
    rw [ht]
    have hcore := conv_core hs (fun lo' _ => some (Out.node [M.dim n, lo', M.dim oc] (Host.Mlx.Ffi.promote dx dw)))
      (fun _ => rfl) hl hj hl31 hle hn cn hoc coc
    rw [hd] at hcore
    exact hcore
  · -- the target's length is a reference: the layer completes the target's call too
    rw [hd] at hsy0
    have hty : callSym y name [M.arg o, M.arg a, M.arg w, M.arg st, M.arg pd, M.arg dl, M.arg gr, M.arg e] =
        opOutSym y (M.arg o) (.conv1d 1 pad dil g) (ins.map M.node) := by
      rw [callSym_stuck (by rw [cy, opOut_infer s2 hsy0, infer_conv_sym]; rfl), dys]
    rw [hty]
    refine sim_opOutSymS hr ho hE hNE trivial hsh ?_
    show MSim _ S C _ (inferSym (.conv1d 1 pad dil g)
      [([M.dim n, M.dim (.sym (.ref j)), M.dim (.lit c)], dx), ([M.dim oc, M.dim (.lit k), M.dim (.lit ci)], dw)])
    rw [inferSym_conv pad dil g n oc (.ref j) c k ci dx dw c0 hg hc hc0, hd]
    show MSim _ S C _ (inferSym (.conv1d 1 pad dil g)
      [([M.dim n, .sym (.ref j'), .lit c], dx), ([M.dim oc, .lit k, .lit ci], dw)])
    rw [inferSym_conv pad dil g (M.dim n) (M.dim oc) (.ref j') c k ci dx dw c0 hg hc hc0]
    have hcore := conv_core hs (fun lo' pos' => bif pos' then
      some (Out.node [M.dim n, lo', M.dim oc] (Host.Mlx.Ffi.promote dx dw)) else none)
      (fun _ => rfl) hl hj hl31 hle hn cn hoc coc
    rw [hd] at hcore
    exact hcore

end

end Host.Ts.Sim.G
