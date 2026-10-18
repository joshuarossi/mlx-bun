import host.ts.RenameHandles
import host.ts.RenameShapes
namespace Host.Mlx.Ffi
open Host.Ts

def outputNodes (newNode : Bool) (s : St) (N : Nat → Prop) : Nat → Prop :=
  bif newNode then (fun i => i = s.nnext ∨ N i) else N

def outputBoundary (newNode : Bool) (s : St) (O : Nat → Prop) : Nat → Prop :=
  bif newNode then (fun i => i ≠ s.nnext ∧ O i) else O

/-- A native result either rejects in both executions, or returns corresponding writes
and live states, with one fresh output handle and zero or one fresh graph nodes. -/
inductive OutputR (R : Ren) (H N O : Nat → Prop) (tail : List NumV) (s : St) :
    Option (St × Ret × List (Nat × Nat × List Byte)) →
    Option (St × Ret × List (Nat × Nat × List Byte)) → Prop
  | rejected : OutputR R H N O tail s none none
  | produced {u u' : St} {r : Ret} {ws : List (Nat × Nat × List Byte)} (newNode : Bool)
      (hc : u.next = s.next + 1) (hn : u.nnext = s.nnext + (bif newNode then 1 else 0))
      (live : LiveNative R (fun a => a = s.next ∨ H a) (outputNodes newNode s N)
        (outputBoundary newNode s O) tail u u') :
      OutputR R H N O tail s (some (u, r, ws)) (some (u', R.ret r, ws.map R.write))

private theorem nth?_mem {α : Type} : ∀ (xs : List α) (i : Nat) (x : α),
    nth? xs i = some x → x ∈ xs
  | [], _, _, h => by cases h
  | a :: _, 0, x, h => by
    have he : a = x := Option.some.inj h
    subst x
    exact List.mem_cons_self
  | a :: xs, i + 1, x, h => List.mem_cons_of_mem a (nth?_mem xs i x h)

theorem u64Write_renamed (R : Ren) (b off a a' : Nat) (ha : R.big (Int.ofNat a) = Int.ofNat a') :
    R.write (u64Write b off a) = u64Write (R.a b) off a' := by
  change (R.a b, off, (cellParts .u64 (.big (Int.ofNat a)) 8 0).map R.byte) = _
  rw [R.cellParts]
  simp only [Ren.cell, NameMap.cell, ha]
  rfl

/-- The result path of `opOut`, starting with a null result slot, commutes with live
native renaming. Inference is a structural request-tree proof, not an assumed machine
step. The concat corollary below discharges that premise for the actual inference code. -/
theorem opOut_zero_renamed {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') (o o' : Arg) (b off : Nat) (p : Prim) (ins : List Nat)
    (sh : List (List Dim × Nat)) (hs : shapesOf s ins = some sh) (hi : ∀ i ∈ ins, N i)
    (ho : slotOf o = some (b, off, 0)) (ho' : slotOf o' = some (R.a b, off, 0))
    (hn : s.nnext / 4096 < 4 ^ 31) (hn' : s'.nnext / 4096 < 4 ^ 31)
    (hh : s.next / 4096 < 4 ^ 31) (hh' : s'.next / 4096 < 4 ^ 31)
    (inf : ComputationR R (fun x y => y = x.map (out R))
      (infer p sh) (infer (R.prim p) (sh.map (shapeDt R)))) :
    ComputationR R (OutputR R H N O tail s) (opOut s o p ins)
      (opOut s' o' (R.prim p) (ins.map R.node)) := by
  have hs' := h.shapesOf ins sh hi hs
  have hbf : R.big (Int.ofNat s.next) = Int.ofNat s'.next := by simpa using h.bigFresh 0
  have hw := u64Write_renamed R b off s.next s'.next hbf
  simp only [opOut, ho, hs, ho', hs']
  apply ComputationR.bind inf
  intro x y hxy
  subst y
  cases x with
  | none => exact ComputationR.pure .rejected
  | some x =>
    cases x with
    | node shape dt =>
      let n : Node := ⟨p, ins, shape, dt⟩
      let n' : Node := ⟨R.prim p, ins.map R.node, shape.map R.dim, dt⟩
      have hnr : NodeR R False n n' := ⟨rfl, rfl, .inr ⟨rfl, rfl⟩⟩
      have hnode := h.addNode n n' hnr hn hn'
      have hhandle := hnode.setArr_zero s.nnext (.inl rfl) hh hh'
      have hf : R.node s.nnext = s'.nnext := by simpa using h.nodeFresh 0
      rw [hf] at hhandle
      have hp := OutputR.produced (R := R) (H := H) (N := N) (O := O) (tail := tail) (s := s)
        (r := status0) (ws := [u64Write b off s.next]) true rfl rfl hhandle
      apply ComputationR.pure
      simpa only [List.map_cons, List.map_nil, hw, Ren.ret, status0, zeroN, Ren.num,
        n, n', St.addNode, St.setArr, Nat.beq_refl, Bool.cond_true] using hp
    | same j =>
      have hm := nth?_map R.node ins j
      cases hk : nth? ins j with
      | none =>
        simp only [hk, Option.map_none] at hm
        simp only [out, Option.map_some, hk, hm]
        exact ComputationR.pure .rejected
      | some k =>
        simp only [hk, Option.map_some] at hm
        simp only [out, Option.map_some, hk, hm]
        have hhandle := h.setArr_zero k (hi k (nth?_mem ins j k hk)) hh hh'
        have hp := OutputR.produced (R := R) (H := H) (N := N) (O := O) (tail := tail) (s := s)
          (r := status0) (ws := [u64Write b off s.next]) false rfl (by rfl) hhandle
        apply ComputationR.pure
        simpa only [List.map_cons, List.map_nil, hw, Ren.ret, status0, zeroN, Ren.num,
          St.setArr, Nat.beq_refl, Bool.cond_true] using hp

theorem opOut_concat_renamed {R : Ren} {H N O : Nat → Prop} {tail : List NumV} {s s' : St}
    (h : LiveNative R H N O tail s s') (hr : Function.Injective R.n)
    (o o' : Arg) (b off axis : Nat) (ins : List Nat) (sh : List (List Dim × Nat))
    (hs : shapesOf s ins = some sh) (hi : ∀ i ∈ ins, N i)
    (ho : slotOf o = some (b, off, 0)) (ho' : slotOf o' = some (R.a b, off, 0))
    (hn : s.nnext / 4096 < 4 ^ 31) (hn' : s'.nnext / 4096 < 4 ^ 31)
    (hh : s.next / 4096 < 4 ^ 31) (hh' : s'.next / 4096 < 4 ^ 31) :
    ComputationR R (OutputR R H N O tail s) (opOut s o (.concat axis) ins)
      (opOut s' o' (.concat axis) (ins.map R.node)) :=
  opOut_zero_renamed h o o' b off (.concat axis) ins sh hs hi ho ho' hn hn' hh hh'
    (infer_concat_renamed R hr axis sh)

end Host.Mlx.Ffi
