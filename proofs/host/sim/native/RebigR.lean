import host.sim.native.Shift
import host.sim.native.Rebig
import host.ts.StoreLaws
namespace Host.Ts.Sim
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # The restart's reassignment of fresh handles (`LoadRw.rebig`)

After the restart composition (`loadRw_restart`) the weak relation leaves the
images of the template's fresh handles `[x0.next, P.E)` unassigned (under
`M.after σ` they would continue the end state's handles). `M.rebig` sends them to
the target's next handles. Images of the start state's data are unchanged
provided no bigint in it lies in `[x0.next, P.E)`; `bigsOutB` decides that on the
concrete start state (`bigsOutB_sound`). -/

/-! ## Deciding a property of every stored entry -/

def trieAll {α : Type} (p : α → Bool) : Trie α → Bool
  | .nil => true
  | .node v a b c e => (match v with | some w => p w | none => true) &&
      trieAll p a && trieAll p b && trieAll p c && trieAll p e

theorem trieAll_get {α : Type} (p : α → Bool) :
    ∀ (t : Trie α) (n : Nat) (w : α), trieAll p t = true → t.get n = some w → p w = true
  | .nil, _, _, _, h => by cases h
  | .node v a b c e, n, w, ht, h => by
    simp only [trieAll, Bool.and_eq_true] at ht
    obtain ⟨⟨⟨⟨hv, ha⟩, hb⟩, hc⟩, he⟩ := ht
    change brec (Nat.beq n 0) v (Trie.pick (Nat.mod n 4) a.get b.get c.get e.get (Nat.div n 4)) = some w at h
    cases h0 : Nat.beq n 0
    · rw [h0] at h
      change Trie.pick (Nat.mod n 4) a.get b.get c.get e.get (Nat.div n 4) = some w at h
      unfold Trie.pick at h
      cases h1 : Nat.blt (Nat.mod n 4) 2
      · rw [h1] at h
        cases h2 : Nat.beq (Nat.mod n 4) 2
        · rw [h2] at h; exact trieAll_get p e _ w he h
        · rw [h2] at h; exact trieAll_get p c _ w hc h
      · rw [h1] at h
        cases h2 : Nat.beq (Nat.mod n 4) 0
        · rw [h2] at h; exact trieAll_get p b _ w hb h
        · rw [h2] at h; exact trieAll_get p a _ w ha h
    · rw [h0] at h
      change v = some w at h
      subst h
      exact hv

def ptrieAll {α : Type} (p : α → Bool) (t : PTrie α) : Bool :=
  trieAll (fun g => trieAll (fun pg => trieAll p pg) g) t.root

theorem ptrieAll_get {α : Type} {p : α → Bool} {t : PTrie α} {n : Nat} {w : α}
    (h : ptrieAll p t = true) (hg : t.get n = some w) : p w = true := by
  rw [PTrie.get_eq] at hg
  cases h1 : t.root.get (n / 4096) with
  | none => rw [h1] at hg; simp at hg
  | some g =>
    rw [h1] at hg
    have hg1 := trieAll_get _ t.root _ g h h1
    simp only [PTrie.orNil_some] at hg
    cases h2 : g.get ((n / 64) % 64) with
    | none => rw [h2] at hg; simp at hg
    | some pg =>
      rw [h2] at hg
      have hg2 := trieAll_get _ g _ pg hg1 h2
      exact trieAll_get p pg _ w hg2 hg

/-! ## Bigints of native data -/

def outB (a b : Nat) (i : Int) : Bool := !(decide ((a : Int) ≤ i ∧ i < b))

def byteBigs : Byte → List Int
  | .part _ (.big j) _ => [j]
  | _ => []

def argBigs : Arg → List Int
  | .big i => [i]
  | .jsPtr _ _ bs => bs.flatMap byteBigs
  | _ => []

def primBigs : Prim → List Int
  | .data bs => bs.flatMap byteBigs
  | .rope _ _ b _ _ => argBigs b
  | .kernel k _ _ => [Int.ofNat k]
  | .replayed c p => Int.ofNat c :: primBigs p
  | _ => []

def objBigs : NObj → List Int
  | .clo (.fn _ p) => argBigs p
  | .clo (.compiled _ p _ _) => argBigs p
  | _ => []

def pendBigs (p : Pending) : List Int := [Int.ofNat p.id, Int.ofNat p.outSlot, Int.ofNat p.cls]

/-- No bigint of the native data lies in `[a, b)`. -/
def bigsOutB (a b : Nat) (x : NSt) : Bool :=
  ptrieAll (fun nd => (primBigs nd.prim).all (outB a b)) x.nodes &&
  ptrieAll (fun o => (objBigs o).all (outB a b)) x.objs &&
  x.pending.all (fun p => (pendBigs p).all (outB a b)) &&
  match x.errh with
  | some f => (argBigs f).all (outB a b)
  | none => true

structure BigsOut (Q : Int → Prop) (x : NSt) : Prop where
  nodes : ∀ i nd, x.nodes.get i = some nd → ∀ j ∈ primBigs nd.prim, Q j
  objs : ∀ h o, x.objs.get h = some o → ∀ j ∈ objBigs o, Q j
  pending : ∀ p ∈ x.pending, ∀ j ∈ pendBigs p, Q j
  errh : ∀ f, x.errh = some f → ∀ j ∈ argBigs f, Q j

theorem bigsOutB_sound {a b : Nat} {x : NSt} (h : bigsOutB a b x = true) :
    BigsOut (fun i => outB a b i = true) x := by
  simp only [bigsOutB, Bool.and_eq_true] at h
  obtain ⟨⟨⟨h1, h2⟩, h3⟩, h4⟩ := h
  refine ⟨fun i nd hn j hj => List.all_eq_true.mp (ptrieAll_get (p := fun nd => (primBigs nd.prim).all (outB a b)) h1 hn) j hj,
    fun i o ho j hj => List.all_eq_true.mp (ptrieAll_get (p := fun o => (objBigs o).all (outB a b)) h2 ho) j hj,
    fun p hp j hj => List.all_eq_true.mp (List.all_eq_true.mp h3 p hp) j hj, fun f hf j hj => ?_⟩
  rw [hf] at h4
  exact List.all_eq_true.mp h4 j hj

/-! ## Maps that differ only on some bigints -/

structure BAgree (Q : Int → Prop) (M M' : Map) : Prop where
  a : M'.a = M.a
  num : M'.num = M.num
  region : M'.region = M.region
  node : M'.node = M.node
  big : ∀ i, Q i → M'.big i = M.big i

section
variable {Q : Int → Prop} {M M' : Map} (h : BAgree Q M M')
include h

theorem BAgree.nv (x : NumV) : M'.nv x = M.nv x := by cases x <;> simp [Map.nv, h.num]

theorem BAgree.dim (d : Dim) : M'.dim d = M.dim d := by cases d <;> simp [Map.dim, h.nv]

theorem BAgree.dims (ds : List Dim) : M'.dims ds = M.dims ds := by
  simp only [Map.dims]; exact List.map_congr_left fun d _ => h.dim d

theorem BAgree.handle {k : Nat} (hk : Q (Int.ofNat k)) : M'.handle k = M.handle k := by
  simp only [Map.handle]; rw [h.big _ hk]

theorem BAgree.byte {b : Byte} (hb : ∀ j ∈ byteBigs b, Q j) : M'.byte b = M.byte b := by
  cases b with
  | lit _ => rfl
  | part k c i =>
    cases c with
    | num x => simp only [Map.byte, Map.cell, h.nv]
    | big j => simp only [Map.byte, Map.cell, h.big j (hb j (List.mem_singleton_self _))]

theorem BAgree.bytes {bs : List Byte} (hb : ∀ j ∈ bs.flatMap byteBigs, Q j) : bs.map M'.byte = bs.map M.byte :=
  List.map_congr_left fun b hm => h.byte fun j hj => hb j (List.mem_flatMap.mpr ⟨b, hm, hj⟩)

theorem BAgree.arg {R : Nat → Prop} {x : Arg} (hx : ∀ j ∈ argBigs x, Q j) (hso : SA R x) : M'.arg x = M.arg x := by
  cases x with
  | num v => simp only [Map.arg, h.nv]
  | big i => simp only [Map.arg, h.big i (hx i (List.mem_singleton_self _))]
  | jsPtr b o bs => simp only [Map.arg, h.a, h.bytes hx]
  | extPtr r o => simp only [Map.arg, h.region]
  | other v => exact hso.elim
  | _ => rfl

theorem BAgree.cfg (c : Cfg) : M'.cfg c = M.cfg c := by
  have e : M'.nv = M.nv := funext h.nv
  simp only [Map.cfg, h.dims, e]

theorem BAgree.prim {R : Nat → Prop} {p : Prim} (hp : ∀ j ∈ primBigs p, Q j) (hso : SP R p) :
    M'.prim p = M.prim p := by
  induction p with
  | data bs => simp only [Map.prim, h.bytes hp]
  | arange _ _ _ => simp only [Map.prim, h.nv]
  | reshape _ => simp only [Map.prim, h.dims]
  | slice _ _ _ => simp only [Map.prim, h.dims]
  | sliceUpdate _ _ _ => simp only [Map.prim, h.dims]
  | sliceDynamic _ _ => simp only [Map.prim, h.dims]
  | rmsNorm _ => simp only [Map.prim, h.nv]
  | rope _ _ b _ _ => simp only [Map.prim, h.nv, h.arg hp hso.1]
  | sdpa _ _ => simp only [Map.prim, h.nv]
  | kernel k _ _ => simp only [Map.prim, h.cfg, h.handle (hp _ (List.mem_singleton_self _))]
  | replayed c q ih =>
    simp only [Map.prim, h.handle (hp _ (List.mem_cons_self ..)),
      ih (fun j hj => hp j (List.mem_cons_of_mem _ hj)) hso]
  | _ => rfl

theorem BAgree.nnode {R : Nat → Prop} {nd : Node} (hp : ∀ j ∈ primBigs nd.prim, Q j) (hso : SNode R nd) :
    M'.nnode nd = M.nnode nd := by
  simp only [Map.nnode, h.prim hp hso.1, h.dims, h.node]

theorem BAgree.trace (t : Trace) : M'.trace t = M.trace t := by simp only [Map.trace, h.node]

theorem BAgree.nobj {R : Nat → Prop} {o : NObj} (ho : ∀ j ∈ objBigs o, Q j) (hso : SObj R o) :
    M'.nobj o = M.nobj o := by
  cases o with
  | vec ns => simp only [Map.nobj, h.node]
  | cfg c => simp only [Map.nobj, h.cfg]
  | clo c =>
    cases c with
    | empty => rfl
    | fn cb p => simp only [Map.nobj, Map.clo, h.region, h.arg ho hso]
    | compiled cb p sl ts => simp only [Map.nobj, Map.clo, h.region, h.arg ho hso, funext h.trace]
  | _ => rfl

theorem BAgree.pend {p : Pending} (hp : ∀ j ∈ pendBigs p, Q j) : M'.pend p = M.pend p := by
  have h1 := hp _ (List.mem_cons_self ..)
  have h2 := hp _ (List.mem_cons_of_mem _ (List.mem_cons_self ..))
  have h3 := hp _ (List.mem_cons_of_mem _ (List.mem_cons_of_mem _ (List.mem_cons_self ..)))
  simp only [Map.pend, h.a, h.node, h.handle h1, h.handle h2, h.handle h3]

end

/-! ## Transfer of the weak relation -/

theorem DimCanon.bagree {Q : Int → Prop} {M M' : Map} (h : BAgree Q M M') {d : Dim} (hc : DimCanon M d) :
    DimCanon M' d := by
  unfold DimCanon at *; rw [h.dim, h.nv]; exact hc

theorem MRw.agreeB {P : LoadP} {M M' : Map} {n : Nat} {x y : NSt} {Q : Int → Prop} (hr : MRw P M n x y)
    (h : BAgree Q M M') (hlo : ∀ i : Int, i < P.lo → Q i) (hhi : ∀ i : Int, (P.E : Int) ≤ i → i < 2 ^ 56 → Q i)
    (hph : ∀ k, PH x k → Q (Int.ofNat k))
    (hzero : ∀ i, (M'.big i == 0) = (i == 0)) (hb : BigsOut Q x) (r : List NumV) :
    MRw { P with rest := r } M' n x y := by
  have hH : ∀ k, PH x k → M'.handle k = M.handle k := fun k hk => h.handle (hph k hk)
  have hcl := hr.cl
  refine
    { lo := hr.lo
      bigFix := fun i hi => by rw [h.big i (hlo i hi)]; exact hr.bigFix i hi
      bigFixHi := fun i h1 h2 => by rw [h.big i (hhi i h1 h2)]; exact hr.bigFixHi i h1 h2
      present := fun k hk => by
        rw [hH k hk]
        have hm := hr.present k hk
        exact ⟨by rw [h.big _ (hph k hk)]; exact hm.1, by rw [h.region]; exact hm.2.1, by rw [h.region]; exact hm.2.2⟩
      hinj := fun a b ha hb he => hr.hinj a b ha hb (by rw [← hH a ha, ← hH b hb]; exact he)
      hlt := hr.hlt
      himg := fun k hk => by rw [hH k hk]; exact hr.himg k hk
      hband := fun k hk hl => by rw [hH k hk]; exact hr.hband k hk hl
      hfreshR := fun k hk => by rw [h.region]; exact hr.hfreshR k hk
      zero := hzero
      hnext := hr.hnext
      hroom := hr.hroom
      absent0 := hr.absent0
      yabsent := hr.yabsent
      arrs := fun k hk => by rw [hH k hk, h.node]; exact hr.arrs k hk
      objs := fun k hk => by
        rw [hH k hk, hr.objs k hk]
        cases ho : x.objs.get k with
        | none => rfl
        | some o => simp only [Option.map_some, h.nobj (hb.objs k o ho) (hcl.2.1 k o ho)]
      cfgCanon := fun k c hc p hp d hd => DimCanon.bagree h (hr.cfgCanon k c hc p hp d hd)
      traced := hr.traced
      node0 := by rw [h.node]; exact hr.node0
      nid := fun j hj => by rw [h.node]; exact hr.nid j hj
      nall := fun j hj => by rw [h.node]; exact hr.nall j hj
      norder := fun i hi hf j hj => by rw [h.node]; exact hr.norder i hi hf j hj
      nodes := fun i nd hn => by
        obtain ⟨nd', h1, hs, hd, hc, hf⟩ := hr.nodes i nd hn
        refine ⟨nd', by rw [h.node]; exact h1, by rw [h.dims]; exact hs, hd,
          fun d hm => DimCanon.bagree h (hc d hm), fun hfull => ?_⟩
        rw [h.prim (hb.nodes i nd hn) (hcl.1 i nd hn).1, h.node]
        exact hf hfull
      ninj := fun a b ha hb he => hr.ninj a b ha hb (by rw [← h.node]; exact he)
      nlt := hr.nlt
      nimg := fun i hi => by rw [h.node]; exact hr.nimg i hi
      nfresh := fun k => by rw [h.node]; exact hr.nfresh k
      nband := hr.nband
      nroom := hr.nroom
      tokens := by
        obtain ⟨rest, hrest⟩ := hr.tokens
        exact ⟨rest, by rw [hrest, List.map_congr_left fun t _ => h.nv t]⟩
      items := fun k hk => by
        rw [h.node, hr.items k hk]
        cases x.items.get k with
        | none => rfl
        | some t => simp only [Option.map_some, h.nv]
      itemsPresent := hr.itemsPresent
      yitems := hr.yitems
      pending := by rw [hr.pending]; exact List.map_congr_left fun p hp => (h.pend (hb.pending p hp)).symm
      errh := by
        rw [hr.errh]
        cases he : x.errh with
        | none => rfl
        | some a => simp only [Option.map_some, h.arg (hb.errh a he) (hcl.2.2.2.2 a he)]
      files := hr.files
      arch := hr.arch
      sizes := hr.sizes
      wired := hr.wired
      cl := hcl }

/-! ## The reassignment -/

theorem rebig_bagree (M : Map) (a b d : Nat) : BAgree (fun i => outB a b i = true) M (M.rebig a b d) :=
  ⟨rfl, rfl, rfl, rfl, fun i hi => by
    simp only [outB, Bool.not_eq_true', decide_eq_false_iff_not] at hi
    show (if (a : Int) ≤ i ∧ i < b then i - a + d else M.big i) = M.big i
    exact ite_eq_right_iff.mpr fun h => absurd h hi⟩

/-- **Rebig.** The weak relation at the template start (tokens cleared), with the
start's data free of bigints in `[x0.next, P.E)`, becomes the native relation under
`M.rebig x0.next P.E z.next`, the start's tokens bound to the target's next readbacks. -/
theorem LoadRw.rebig {P : LoadP} {M : Map} {n : Nat} {x0 z : Host.Load.LSt} (hr : LoadRw P M n (clearTokens x0) z)
    (hb : bigsOutB x0.mlx.next P.E x0.mlx = true) (htc : ∀ t ∈ x0.mlx.tokens, SN (· < n) t)
    {rest' : List NumV} (hz : z.mlx.tokens = x0.mlx.tokens.map M.nv ++ rest') :
    LoadR { P with rest := rest' } (M.rebig x0.mlx.next P.E z.mlx.next) n x0 z := by
  have hm := hr.mlx
  have hag := rebig_bagree M x0.mlx.next P.E z.mlx.next
  have hlo := hm.lo
  have hnx : P.lo ≤ x0.mlx.next ∧ x0.mlx.next ≤ z.mlx.next := hm.hnext
  have hbo : BigsOut (fun i => outB x0.mlx.next P.E i = true) (clearTokens x0).mlx := bigsOutB_sound hb
  have hQlo : ∀ i : Int, i < P.lo → outB x0.mlx.next P.E i = true := fun i hi => by
    simp only [outB, Bool.not_eq_true', decide_eq_false_iff_not, not_and, Int.not_lt]
    intro h1; exfalso; have : (x0.mlx.next : Int) ≥ P.lo := by exact_mod_cast hnx.1
    omega
  have hQph : ∀ k, PH (clearTokens x0).mlx k → outB x0.mlx.next P.E (Int.ofNat k) = true := fun k hk => by
    have := hm.hlt k hk
    simp only [outB, Bool.not_eq_true', decide_eq_false_iff_not, not_and, Int.not_lt]
    intro h1; exfalso
    simp only [Int.ofNat_eq_natCast] at h1
    change k < x0.mlx.next at this
    omega
  have hzero : ∀ i, ((M.rebig x0.mlx.next P.E z.mlx.next).big i == 0) = (i == 0) := by
    intro i
    simp only [Map.rebig]
    split
    · rename_i hi
      have h1 : (x0.mlx.next : Int) ≥ 1 := by have : P.lo ≤ x0.mlx.next := hnx.1; omega
      have h2 : (z.mlx.next : Int) ≥ 1 := by have : x0.mlx.next ≤ z.mlx.next := hnx.2; omega
      have e1 : (i - ↑x0.mlx.next + ↑z.mlx.next == 0) = false := by
        simp only [beq_eq_false_iff_ne, ne_eq]; omega
      have e2 : (i == 0) = false := by simp only [beq_eq_false_iff_ne, ne_eq]; omega
      rw [e1, e2]
    · exact hm.zero i
  have hQhi : ∀ i : Int, (P.E : Int) ≤ i → i < 2 ^ 56 → outB x0.mlx.next P.E i = true := fun i h1 _ => by
    simp only [outB, Bool.not_eq_true', decide_eq_false_iff_not, not_and, Int.not_lt]
    intro _; exact h1
  have hw := hm.agreeB hag hQlo hQhi hQph hzero hbo rest'
  refine ⟨hr.host, fun k hk => hr.hostReg k hk, hr.hostLt, fun a => hr.cbr a, ?_⟩
  exact
    { hw with
      tokens := ⟨rest', by rw [hz]; rfl⟩
      cl := ⟨hm.cl.1, hm.cl.2.1, htc, hm.cl.2.2.2.1, hm.cl.2.2.2.2⟩
      hfreshB := fun k hk => by
        change x0.mlx.next + k < P.E at hk
        show (if (x0.mlx.next : Int) ≤ Int.ofNat (x0.mlx.next + k) ∧ Int.ofNat (x0.mlx.next + k) < P.E then
          Int.ofNat (x0.mlx.next + k) - x0.mlx.next + z.mlx.next else M.big _) = _
        rw [if_pos (by simp only [Int.ofNat_eq_natCast]; omega)]
        simp only [Int.ofNat_eq_natCast]; omega
      tokensX := by rw [hz]; rfl }

end Host.Ts.Sim
