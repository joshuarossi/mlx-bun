import host.sim.native.Shift
import host.sim.template.Sigma

/-! # Deciding the native shift

The native shift `NShift P n0 σ x0 x1` (`host.sim.native.Shift`) for an explicit map
`σ = D.map` (`RData`) follows from facts of three kinds:

* general facts of `RData` maps (regions of host objects and callbacks, fresh handles
  and nodes, bigint zero and sign), proved here once;
* Boolean checks over the explicit key lists of the source's handles and nodes
  (`handleOK`, `nodeOK`, `objOK`, `checkRenG`, `checkSSt`), with soundness lemmas;
* list equalities of the native objects and full nodes' primitives (`ObjImg`, `PrimImg`),
  which have no decidable equality and are checked by kernel evaluation (`Eq.refl`). -/

namespace Host.Ts.Sim.Template
open Host.Ts Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace)

/-! ## Renamings given by an exception store, with a certifying inverse -/

def checkRenG (ren inv : PTrie Nat) (P : Nat → Bool) : Bool :=
  (PTrie.keys ren).all fun x => match ren.get x with
    | some y => decide (inv.get y = some x) && (!P y || (ren.get y).isSome)
    | none => true

theorem ren_inj {ren inv : PTrie Nat} {P : Nat → Bool} {f : Nat → Nat}
    (hf : ∀ x, P x = true → f x = (ren.get x).getD x) (hc : checkRenG ren inv P = true) :
    ∀ x y, P x = true → P y = true → f x = f y → x = y := by
  have hent : ∀ x y, ren.get x = some y → inv.get y = some x ∧ (P y = true → (ren.get y).isSome = true) := by
    intro x y hxy
    simp only [checkRenG, List.all_eq_true] at hc
    have := hc x (PTrie.mem_keys ren x y hxy)
    rw [hxy] at this
    simp only [Bool.and_eq_true, decide_eq_true_eq, Bool.or_eq_true, Bool.not_eq_true'] at this
    refine ⟨this.1, fun hp => ?_⟩
    rcases this.2 with h | h
    · rw [hp] at h; cases h
    · exact h
  intro x y hx hy hxy
  rw [hf x hx, hf y hy] at hxy
  cases gx : ren.get x with
  | none =>
    cases gy : ren.get y with
    | none => rw [gx, gy] at hxy; simpa using hxy
    | some y' =>
      rw [gx, gy] at hxy
      simp only [Option.getD_none, Option.getD_some] at hxy
      subst hxy
      have := (hent y x gy).2 hx
      rw [gx] at this; cases this
  | some x' =>
    cases gy : ren.get y with
    | none =>
      rw [gx, gy] at hxy
      simp only [Option.getD_none, Option.getD_some] at hxy
      rw [hxy] at gx
      have := (hent x y gx).2 hy
      rw [gy] at this; cases this
    | some y' =>
      rw [gx, gy] at hxy
      simp only [Option.getD_some] at hxy
      subst hxy
      have h1 := (hent x x' gx).1
      have h2 := (hent y x' gy).1
      rw [h1] at h2
      exact Option.some.inj h2

namespace RData
variable (D : RData)

/-! ## General facts of `RData` maps -/

theorem hd_old {h : Nat} (hh : h < D.nh0) : D.hd h = (D.hnd.get h).getD h := by
  simp only [hd, ble_false hh, Bool.cond_false]

theorem big_small {h : Nat} (hh : h < bigHi) : D.big (Int.ofNat h) = Int.ofNat (D.hd h) := by
  simp only [big, bigN, bigHi] at *
  rw [ble_false (show h < 2 ^ 62 by omega), blt_true hh]
  rfl

theorem handle_small {h : Nat} (hh : h < bigHi) : D.map.handle h = D.hd h := by
  show (D.big (Int.ofNat h)).toNat = _
  rw [D.big_small hh]; rfl

theorem region_hd {h c : Nat} (hc : c < 3) (hh : h < 2 ^ 46) : D.region (4 * h + c) = 4 * D.hd h + c := by
  have h1 : (4 * h + c) % 4 = c := by omega
  have h2 : (4 * h + c) / 4 = h := by omega
  have h3 : Nat.beq c 3 = false := by cases h : Nat.beq c 3 <;> simp_all [Nat.beq_eq] <;> omega
  simp only [region, ble_false (show 4 * h + c < 2 ^ 48 by omega), Bool.cond_false, h1, h2, h3]

theorem region_host {h : Nat} (hh : h < 2 ^ 46) : D.region (4 * h + 3) = 4 * h + 3 := by
  have h1 : (4 * h + 3) % 4 = 3 := by omega
  simp only [region, ble_false (show 4 * h + 3 < 2 ^ 48 by omega), Bool.cond_false, h1]
  rfl

theorem region_cb (a : Nat) : D.region (cbBase + a) = cbBase + D.a a := by
  simp only [region, cbBase, ble_true (Nat.le_add_right _ a), Bool.cond_true, Nat.add_sub_cancel_left]
  omega

theorem node_fresh (k : Nat) : D.nodeF (D.nn0 + k) = D.nn1 + k := by
  simp only [nodeF, ble_true (Nat.le_add_right D.nn0 k), Bool.cond_true]
  omega

theorem node_old {j : Nat} (hj : j < D.nn0) : D.nodeF j = (D.node.get j).getD j := by
  simp only [nodeF, ble_false hj, Bool.cond_false]

/-- Renamed handles are below the start counter. -/
def checkHndBelow : Bool := (PTrie.keys D.hnd).all fun k => Nat.blt k D.nh0

theorem hnd_below (hc : D.checkHndBelow = true) {k y : Nat} (hg : D.hnd.get k = some y) : k < D.nh0 :=
  Nat.le_of_ble_eq_true (List.all_eq_true.mp hc k (PTrie.mem_keys D.hnd k y hg))

theorem ble_false_lt {a b : Nat} (h : Nat.ble a b = false) : b < a :=
  Nat.lt_of_not_le fun h' => by rw [Nat.ble_eq_true_of_le h'] at h; cases h

/-- Renamed handles and their images are positive (from the band check with `lo > 0`). -/
theorem big_zero {lo : Nat} (hc : D.checkBand lo = true) (hcb : D.checkHndBelow = true) (hlo : 0 < lo)
    (hlo0 : lo ≤ D.nh0) (h1 : 0 < D.nh1) : ∀ i : Int, (D.big i == 0) = (i == 0) := by
  have hband : ∀ k y, D.hnd.get k = some y → lo ≤ y := by
    intro k y hg
    have hm := PTrie.mem_keys D.hnd k y hg
    have := List.all_eq_true.mp hc k hm
    simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at this
    have hk : k < D.nh0 := D.hnd_below hcb hg
    rw [D.hd_old hk, hg] at this
    simp only [Option.getD_some] at this
    omega
  have hpos : ∀ k, D.hd k = 0 → k = 0 := by
    intro k hk
    cases hb : Nat.ble D.nh0 k
    · have hlt : k < D.nh0 := ble_false_lt hb
      rw [D.hd_old hlt] at hk
      cases hg : D.hnd.get k with
      | none => rw [hg] at hk; simpa using hk
      | some y => rw [hg] at hk; simp only [Option.getD_some] at hk; have := hband k y hg; omega
    · have : D.nh0 ≤ k := Nat.le_of_ble_eq_true hb
      simp only [hd, hb, Bool.cond_true] at hk
      omega
  have h0 : D.hd 0 = 0 := by
    rw [D.hd_old (show 0 < D.nh0 by omega)]
    cases hg : D.hnd.get 0 with
    | none => rfl
    | some y => have := hband 0 y hg; have hm := PTrie.mem_keys D.hnd 0 y hg
                have := List.all_eq_true.mp hc 0 hm
                simp only [Bool.and_eq_true, Nat.ble_eq, Nat.blt_eq] at this; omega
  intro i
  cases i with
  | negSucc m => rfl
  | ofNat k =>
    show (D.bigN k == 0) = (Int.ofNat k == 0)
    rw [Bool.eq_iff_iff, beq_iff_eq, beq_iff_eq]
    unfold bigN
    cases h62 : Nat.ble (2 ^ 62) k
    · cases hb : Nat.blt k bigHi
      · simp only [Bool.cond_false]
      · simp only [Bool.cond_false, Bool.cond_true, Int.ofNat_eq_natCast, Int.natCast_eq_zero]
        constructor
        · exact hpos k
        · intro hk; subst hk; exact h0
    · simp only [Bool.cond_true, Int.ofNat_eq_natCast, Int.natCast_eq_zero]
      have : 2 ^ 62 ≤ k := Nat.le_of_ble_eq_true h62
      constructor <;> intro h <;> omega

end RData

/-! ## Present handles and nodes -/

def phB (x : NSt) (h : Nat) : Bool := (x.arrs.get h).isSome || (x.objs.get h).isSome

theorem phB_iff {x : NSt} {h : Nat} : phB x h = true ↔ PH x h := by
  simp [phB, PH]

def pnB (x : NSt) (k : Nat) : Bool := (x.nodes.get k).isSome

/-- The source's present handles. -/
def handlesOf (x : NSt) : List Nat := PTrie.keys x.arrs ++ PTrie.keys x.objs

theorem mem_handlesOf {x : NSt} {h : Nat} (hp : PH x h) : h ∈ handlesOf x := by
  rcases hp with hp | hp
  · obtain ⟨n, hn⟩ := Option.isSome_iff_exists.mp hp
    exact List.mem_append_left _ (PTrie.mem_keys _ _ _ hn)
  · obtain ⟨o, ho⟩ := Option.isSome_iff_exists.mp hp
    exact List.mem_append_right _ (PTrie.mem_keys _ _ _ ho)

/-- The per-handle facts: in range, image present, arrays correspond, band kept. -/
def handleOK (σ : Map) (lo : Nat) (x0 x1 : NSt) (h : Nat) : Bool :=
  Nat.blt h x0.next && Nat.blt h RData.bigHi && phB x1 (σ.handle h) &&
    (x1.arrs.get (σ.handle h) == (x0.arrs.get h).map σ.node) && ((x1.objs.get (σ.handle h)).isSome == (x0.objs.get h).isSome) &&
    (!Nat.ble lo h || Nat.ble lo (σ.handle h))

/-- The per-object facts: traces below `NL`, canonical configuration dimensions. -/
def objOK (σ : Map) (NL : Nat) (x0 : NSt) (h : Nat) : Bool :=
  match x0.objs.get h with
  | some o => (objTraces o).all (fun i => Nat.blt i NL) && match o with
    | .cfg c => c.outs.all fun p => p.1.all fun d => decide ((σ.dim d).num = σ.nv d.num)
    | _ => true
  | none => true

/-- The per-node facts: in range, image present with the image shape and dtype, canonical
dimensions, inputs for full nodes, read-back memo. -/
def nodeOK (σ : Map) (NL : Nat) (x0 x1 : NSt) (i : Nat) : Bool :=
  match x0.nodes.get i with
  | none => true
  | some nd => Nat.blt i x0.nnext && match x1.nodes.get (σ.node i) with
    | none => false
    | some nd1 => decide (nd1.shape = σ.dims nd.shape) && Nat.beq nd1.dtype nd.dtype &&
        nd.shape.all (fun d => decide ((σ.dim d).num = σ.nv d.num)) &&
        (!Nat.blt i NL || decide (nd1.ins = nd.ins.map σ.node)) &&
        decide (x1.items.get (σ.node i) = (x0.items.get i).map σ.nv)

/-- Native objects at the images of the source's object handles are the images. -/
def ObjImg (σ : Map) (x0 x1 : NSt) (l : List Nat) : Prop :=
  l.map (fun h => x1.objs.get (σ.handle h)) = l.map (fun h => (x0.objs.get h).map σ.nobj)

/-- Full nodes' primitives correspond. -/
def PrimImg (σ : Map) (x0 x1 : NSt) (l : List Nat) : Prop :=
  l.map (fun i => (x1.nodes.get (σ.node i)).map Node.prim) = l.map (fun i => (x0.nodes.get i).map fun nd => σ.prim nd.prim)

/-- The source's full present nodes (below `NL`). -/
def fullKeys (NL : Nat) (x0 : NSt) : List Nat := (PTrie.keys x0.nodes).filter fun i => Nat.blt i NL

/-! ## Closedness of a native state, decided -/

section
variable (n : Nat)

def bSN : NumV → Bool
  | .lit _ => true
  | .ref i => Nat.blt i n

def bSD : Dim → Bool
  | .lit _ => true
  | .sym x => bSN n x

def bSC : Cell → Bool
  | .num x => bSN n x
  | .big _ => true

def bSB : Byte → Bool
  | .lit _ => true
  | .part _ c _ => bSC n c

def bSA : Arg → Bool
  | .num x => bSN n x
  | .jsPtr _ _ bs => bs.all (bSB n)
  | .other _ => false
  | _ => true

def bSCfg (c : Cfg) : Bool :=
  c.outs.all (fun p => p.1.all (bSD n)) && c.grid.all (bSN n) && c.group.all (bSN n) &&
    c.ints.all (fun p => bSN n p.2) && (match c.init with | some x => bSN n x | none => true)

def bSP : Prim → Bool
  | .data bs => bs.all (bSB n)
  | .arange a b c => bSN n a && bSN n b && bSN n c
  | .reshape s => s.all (bSD n)
  | .slice a b c => a.all (bSD n) && b.all (bSD n) && c.all (bSD n)
  | .sliceUpdate a b c => a.all (bSD n) && b.all (bSD n) && c.all (bSD n)
  | .sliceDynamic _ sz => sz.all (bSD n)
  | .rmsNorm e => bSN n e
  | .rope _ _ b s o => bSA n b && bSN n s && bSN n o
  | .sdpa s _ => bSN n s
  | .kernel _ c _ => bSCfg n c
  | .replayed _ p => bSP p
  | _ => true

def bSNode (nd : Node) : Bool := bSP n nd.prim && nd.shape.all (bSD n)

def bSClo : Clo → Bool
  | .empty => true
  | .fn _ p => bSA n p
  | .compiled _ p _ _ => bSA n p

def bSObj : NObj → Bool
  | .cfg c => bSCfg n c
  | .clo c => bSClo n c
  | _ => true

def checkSSt (x : NSt) : Bool :=
  (PTrie.keys x.nodes).all (fun i => match x.nodes.get i with | some nd => bSNode n nd | none => true) &&
    (PTrie.keys x.objs).all (fun h => match x.objs.get h with | some o => bSObj n o | none => true) &&
    x.tokens.all (bSN n) &&
    (PTrie.keys x.items).all (fun k => match x.items.get k with | some t => bSN n t | none => true) &&
    (match x.errh with | some a => bSA n a | none => true)
end

section
variable {n : Nat}
local notation "Rn" => fun i => i < n
attribute [local simp] Bool.and_eq_true List.all_eq_true

theorem bSN_sound : ∀ {x : NumV}, bSN n x = true → SN Rn x
  | .lit _, _ => trivial
  | .ref _, h => Nat.le_of_ble_eq_true h

theorem bSD_sound : ∀ {d : Dim}, bSD n d = true → SD Rn d
  | .lit _, _ => trivial
  | .sym _, h => bSN_sound h

theorem bSDs_sound {ds : List Dim} (h : ds.all (bSD n) = true) : SDs Rn ds :=
  fun d hd => bSD_sound (List.all_eq_true.mp h d hd)

theorem bSC_sound : ∀ {c : Cell}, bSC n c = true → SC Rn c
  | .num _, h => bSN_sound h
  | .big _, _ => trivial

theorem bSB_sound : ∀ {b : Byte}, bSB n b = true → SB Rn b
  | .lit _, _ => trivial
  | .part _ _ _, h => bSC_sound h

theorem bSBs_sound {bs : List Byte} (h : bs.all (bSB n) = true) : SBs Rn bs :=
  fun b hb => bSB_sound (List.all_eq_true.mp h b hb)

theorem bSA_sound : ∀ {a : Arg}, bSA n a = true → SA Rn a
  | .num _, h => bSN_sound h
  | .jsPtr _ _ _, h => bSBs_sound h
  | .other _, h => by cases h
  | .null, _ => trivial
  | .big _, _ => trivial
  | .bool _, _ => trivial
  | .extPtr _ _, _ => trivial

theorem bSCfg_sound {c : Cfg} (h : bSCfg n c = true) : SCfg Rn c := by
  simp only [bSCfg, Bool.and_eq_true] at h
  obtain ⟨⟨⟨⟨h1, h2⟩, h3⟩, h4⟩, h5⟩ := h
  refine ⟨fun p hp => bSDs_sound (List.all_eq_true.mp h1 p hp), fun x hx => bSN_sound (List.all_eq_true.mp h2 x hx),
    fun x hx => bSN_sound (List.all_eq_true.mp h3 x hx), fun p hp => bSN_sound (List.all_eq_true.mp h4 p hp), ?_⟩
  intro x hx
  rw [hx] at h5
  exact bSN_sound h5

theorem bSP_sound : ∀ (p : Prim), bSP n p = true → SP Rn p
  | .data bs, h => bSBs_sound h
  | .arange a b c, h => by
    simp only [bSP, Bool.and_eq_true] at h
    exact ⟨bSN_sound h.1.1, bSN_sound h.1.2, bSN_sound h.2⟩
  | .reshape s, h => bSDs_sound h
  | .slice a b c, h => by
    simp only [bSP, Bool.and_eq_true] at h
    exact ⟨bSDs_sound h.1.1, bSDs_sound h.1.2, bSDs_sound h.2⟩
  | .sliceUpdate a b c, h => by
    simp only [bSP, Bool.and_eq_true] at h
    exact ⟨bSDs_sound h.1.1, bSDs_sound h.1.2, bSDs_sound h.2⟩
  | .sliceDynamic _ sz, h => bSDs_sound h
  | .rmsNorm e, h => bSN_sound h
  | .rope _ _ b s o, h => by
    simp only [bSP, Bool.and_eq_true] at h
    exact ⟨bSA_sound h.1.1, bSN_sound h.1.2, bSN_sound h.2⟩
  | .sdpa s _, h => bSN_sound h
  | .kernel _ c _, h => bSCfg_sound h
  | .replayed _ p, h => bSP_sound p h
  | .load .., _ => trivial
  | .tracer _, _ => trivial
  | .zeros, _ => trivial
  | .transpose _, _ => trivial
  | .concat _, _ => trivial
  | .unary _, _ => trivial
  | .binary _, _ => trivial
  | .astype _, _ => trivial
  | .contiguous, _ => trivial
  | .qmm .., _ => trivial
  | .dequantize .., _ => trivial
  | .take _, _ => trivial
  | .conv1d .., _ => trivial
  | .logsumexp .., _ => trivial

theorem bSNode_sound {nd : Node} (h : bSNode n nd = true) : SNode Rn nd := by
  simp only [bSNode, Bool.and_eq_true] at h
  exact ⟨bSP_sound _ h.1, bSDs_sound h.2⟩

theorem bSObj_sound : ∀ {o : NObj}, bSObj n o = true → SObj Rn o
  | .cfg _, h => bSCfg_sound h
  | .clo .empty, _ => trivial
  | .clo (.fn _ _), h => bSA_sound h
  | .clo (.compiled _ _ _ _), h => bSA_sound h
  | .stream, _ => trivial
  | .str _, _ => trivial
  | .vec _, _ => trivial
  | .vstr _, _ => trivial
  | .kernel .., _ => trivial
  | .amap _, _ => trivial
  | .smap, _ => trivial
  | .device, _ => trivial
  | .dinfo, _ => trivial

theorem checkSSt_sound {x : NSt} (h : checkSSt n x = true) : SSt Rn x := by
  simp only [checkSSt, Bool.and_eq_true, List.all_eq_true] at h
  obtain ⟨⟨⟨⟨hn, ho⟩, ht⟩, hi⟩, he⟩ := h
  refine ⟨fun i nd hg => ?_, fun k o hg => ?_, fun t ht' => bSN_sound (ht t ht'), fun k t hg => ?_, fun a ha => ?_⟩
  · have := hn i (PTrie.mem_keys _ _ _ hg); rw [hg] at this; exact bSNode_sound this
  · have := ho k (PTrie.mem_keys _ _ _ hg); rw [hg] at this; exact bSObj_sound this
  · have := hi k (PTrie.mem_keys _ _ _ hg); rw [hg] at this; exact bSN_sound this
  · rw [ha] at he; exact bSA_sound he
end

end Host.Ts.Sim.Template
