import host.sim.native.gen.CallSim
namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Cfg Clo Trace Pending dimOf)

/-! # B-newdata: `mlx_array_new_data` on a framed buffer

The prompt chunk's ids (`packages/mlx/src/array.ts:179-181`) come from a buffer the template
frames: the template's call reads its own bytes `bsT` and a symbolic shape `[1, n]`, the
target's call the prompt's bytes `bs'` and the shape's image. The template's node is shape-only
(`shapeOnly`: host data, non-literal shape), so the target's node corresponds whatever its
bytes. `dataCallSim` is the native side of `bridge_newdata` (`sim/dispatch/BridgeNewData.lean`)
under the checks `dataOk` (the arguments after the buffer, decided on the template) and the
numeric premise `RefSmall` on the shape's references. -/

section
variable {P : LoadP} {NB : Nat} {M : Map} {n : Nat} {x y : NSt} (hr : MR P NB M n x y)
include hr

theorem MR.addNodeR (nd ndT : Node) (hNE : x.nnext + 1 ≤ P.NE) (hs : SNode (· < n) nd)
    (hc : ∀ d ∈ nd.shape, DimCanon M d) (hsh : ndT.shape = M.dims nd.shape) (hdt : ndT.dtype = nd.dtype)
    (hpr : PrimR M nd ndT.prim) (hin : ndT.ins = nd.ins.map M.node) :
    MR P NB M n { x with nnext := x.nnext + 1, nodes := x.nodes.set x.nnext nd }
      { y with nnext := y.nnext + 1, nodes := y.nodes.set y.nnext ndT } := by
  have hxk := hr.xnnext_lt
  have hyk := hr.ynnext_lt
  have gx : ∀ i, (x.nodes.set x.nnext nd).get i = if i = x.nnext then some nd else x.nodes.get i :=
    PTrie.gs _ _ _ hxk
  have gy : ∀ i, (y.nodes.set y.nnext ndT).get i =
      if i = y.nnext then some ndT else y.nodes.get i :=
    PTrie.gs _ _ _ hyk
  have pn : ∀ i, PN { x with nnext := x.nnext + 1, nodes := x.nodes.set x.nnext nd } i → i = x.nnext ∨ PN x i := by
    intro i hi
    by_cases e : i = x.nnext
    · exact .inl e
    · right
      change ((x.nodes.set x.nnext nd).get i).isSome = true at hi
      rw [gx] at hi; simp only [e, ↓reduceIte] at hi; exact hi
  have hn0 := hr.node_next
  have hne : ∀ i, PN x i → M.node i ≠ y.nnext := fun i hi => Nat.ne_of_lt (hr.nimg i hi)
  have hxne : ∀ i, PN x i → i ≠ x.nnext := fun i hi => Nat.ne_of_lt (hr.nlt i hi)
  refine { hr with
    nodes := ?_
    ninj := ?_
    nlt := ?_
    nimg := ?_
    nfresh := ?_
    nall := ?_
    norder := ?_
    nband := ?_
    nroom := ?_
    items := ?_
    itemsPresent := ?_
    yitems := ?_
    cl := ?_ }
  all_goals try dsimp only at *
  · intro j hj
    by_cases e : j = x.nnext
    · subst e; rw [hn0]; exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (hr.nall j (by omega))
  · intro i hi hf j hj
    rcases pn i hi with rfl | hi
    · rw [hn0]; exact hr.nall j hj
    · exact hr.norder i hi hf j hj
  · intro i nd' hi
    change (x.nodes.set x.nnext nd).get i = some nd' at hi
    rw [gx] at hi
    by_cases e : i = x.nnext
    · subst e
      simp only [↓reduceIte, Option.some.injEq] at hi
      subst hi
      refine ⟨ndT, ?_, hsh, hdt, hc, fun _ => ⟨hpr, hin⟩⟩
      show (y.nodes.set y.nnext ndT).get (M.node x.nnext) = _
      rw [hn0, gy]; simp
    · simp only [e, ↓reduceIte] at hi
      obtain ⟨nd'', h1, h2⟩ := hr.nodes i nd' hi
      refine ⟨nd'', ?_, h2⟩
      show (y.nodes.set y.nnext ndT).get (M.node i) = _
      rw [gy]; simp only [hne i (by show (x.nodes.get i).isSome = true; rw [hi]; rfl), ↓reduceIte]; exact h1
  · intro a b ha hb he
    rcases pn a ha with rfl | ha <;> rcases pn b hb with rfl | hb
    · rfl
    · rw [hn0] at he; exact absurd he.symm (hne b hb)
    · rw [hn0] at he; exact absurd he (hne a ha)
    · exact hr.ninj a b ha hb he
  · intro i hi
    rcases pn i hi with rfl | hi
    · exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (hr.nlt i hi)
  · intro i hi
    rcases pn i hi with rfl | hi
    · rw [hn0]; exact Nat.lt_succ_self _
    · exact Nat.lt_succ_of_lt (hr.nimg i hi)
  · intro k
    have := hr.nfresh (k + 1)
    simpa only [Nat.add_assoc, Nat.add_comm 1 k] using this
  · have := hr.nband; exact ⟨this.1, by omega⟩
  · have := hr.nroom; exact ⟨by omega, hNE, by omega⟩
  · intro k hk
    rcases pn k hk with rfl | hk
    · rw [hn0, hr.yitems _ (Nat.le_refl _)]
      cases h : x.items.get x.nnext with
      | none => rfl
      | some _ => exact absurd (hr.itemsPresent _ (by rw [h]; rfl)) (fun hp => hxne _ hp rfl)
    · exact hr.items k hk
  · intro k hk
    have := hr.itemsPresent k hk
    change ((x.nodes.set x.nnext nd).get k).isSome = true
    rw [gx]
    by_cases e : k = x.nnext
    · simp [e]
    · simp only [e, ↓reduceIte]; exact this
  · intro k hk; exact hr.yitems k (by omega)
  · refine ⟨?_, hr.cl.2⟩
    intro i nd' hi
    change (x.nodes.set x.nnext nd).get i = some nd' at hi
    rw [gx] at hi
    by_cases e : i = x.nnext
    · simp only [e, ↓reduceIte, Option.some.injEq] at hi; subst hi; exact hs
    · simp only [e, ↓reduceIte] at hi; exact hr.cl.1 i nd' hi

end

/-- The checks of a B-newdata call on its arguments after the buffer: dimensions decoding under
the map, a fixed dtype, room, and a non-literal shape of naturals and number references. -/
def dataOk (P : LoadP) (x : NSt) : List Arg → Bool
  | [sh, nd, dt] => dimsOk P sh nd && natOk P dt && decide (x.next + 1 ≤ P.E) && decide (x.nnext + 1 ≤ P.NE) &&
    match Host.Mlx.Ffi.dimsArg sh nd with
    | some s => s.all dimOkV && !(s.all dimLit)
    | none => true
  | _ => false

/-- The number references of a B-newdata call's shape. -/
def dataRefs : List Arg → List Nat
  | [sh, nd, _] => dimsArgRefs sh nd
  | _ => []

/-- The results of a data call (`Host.Ts.Sim.Disp.DataR`): related native states, the image of
the return value, no buffer writes, no `JSCallback`, and a return supported by `A`. -/
def DataR {F : Ffi} (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (n : Nat) (A : Nat → Prop) :
    Option (F.S × Ret × List (Nat × Nat × List Byte)) → Option (F.S × Ret × List (Nat × Nat × List Byte)) → Prop
  | none, _ => True
  | some (x, ret, ws), some (y, ret', ws') =>
    FR M n x y ∧ ret' = M.ret ret ∧ ws = [] ∧ ws' = [] ∧ (∀ f cs, ret ≠ .callback f cs) ∧ Supp.ret A n ret
  | some _, none => False

theorem natsOfDims_lits : ∀ {ds : List Dim} {ns : List Nat}, Host.Mlx.Ffi.natsOfDims ds = some ns → ds.all dimLit = true
  | [], _, _ => rfl
  | .lit i :: ds, ns, h => by
    simp only [Host.Mlx.Ffi.natsOfDims] at h
    cases hi : decide (0 ≤ i)
    · rw [hi] at h; cases h
    · rw [hi] at h
      simp only [Bool.cond_true] at h
      cases hr : Host.Mlx.Ffi.natsOfDims ds with
      | none => rw [hr] at h; cases h
      | some ms => exact by simp only [List.all_cons, dimLit, Bool.true_and]; exact natsOfDims_lits hr
  | .sym _ :: _, _, h => by cases h

theorem msim_vals {α β : Type} {Q : Map → SSrv → CSrv → α → β → Prop} {M : Map} {S : SSrv} {C : CSrv}
    {m : Host.Ts.M α} {m' : Host.Ts.M β} {a : α} {b : β} (hm : ∀ γ k, m γ k = k a) (hm' : ∀ γ k, m' γ k = k b)
    (h : Q M S C a b) : MSim Q S C m m' := by
  intro γ δ R k k' hk
  rw [hm, hm']
  exact hk M S C a b h

/-- The data call returns at once. -/
theorem newData_pure (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arrayNewData)
    (b o : Nat) (bytes : List Byte) (sh nd dt : Arg) :
    ∃ r, ∀ γ k, Host.Mlx.Ffi.call s name [.jsPtr b o bytes, sh, nd, dt] γ k = k r := by
  unfold Host.Mlx.Ffi.call; rw [hsym]
  simp only
  cases Host.Mlx.Ffi.dimsArg sh nd <;> cases Host.Mlx.Ffi.argNat dt <;> exact ⟨_, fun _ _ => rfl⟩

theorem loadCall_pure {x : Host.Load.LSt} {name : Name} {args : List Arg} (hm : Host.Load.isMlx name = true)
    {r : NRes} (h : ∀ γ k, Host.Mlx.Ffi.call x.mlx name args γ k = k r) :
    ∀ γ k, Host.Load.call x name args γ k =
      k (match r with | some (m, r, ws) => some ({ x with mlx := m }, r, ws) | none => none) := by
  intro γ k
  rw [Host.Load.call_mlx x name args hm, bind_pureP h]
  cases r with
  | none => rfl
  | some q => obtain ⟨m, r, ws⟩ := q; rfl

/-- **The native side of B-newdata.** -/
theorem dataCallSim (P : LoadP) (NB : Nat) {name : Name} (hm : Host.Load.isMlx name = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arrayNewData) (b : Nat) (bsT bs' : List Byte) (A : Nat → Prop)
    {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : Host.Load.LSt} {asR : List Arg}
    (hs : Srv M ν S C) (hr : LoadR P NB M S.tab.length x y) (hok : dataOk P x.mlx asR = true)
    (hsm : ∀ j ∈ dataRefs asR, RefSmall ν S j) (hbs : SBs (· < S.tab.length) bsT) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ DataR (F := Host.Load.ffi) (LoadR P NB) M' S'.tab.length A r r') S C
      (Host.Load.call x name (.jsPtr b 0 bsT :: asR)) (Host.Load.call y name (.jsPtr (M.a b) 0 bs' :: asR.map M.arg)) := by
  have hshape : ∃ sh nd dt, asR = [sh, nd, dt] := by
    unfold dataOk at hok; split at hok
    · exact ⟨_, _, _, rfl⟩
    · cases hok
  obtain ⟨sh, nd, dt, rfl⟩ := hshape
  have mr := hr.mlx
  simp only [dataOk, Bool.and_eq_true, decide_eq_true_eq] at hok
  obtain ⟨⟨⟨⟨hd, hdt⟩, hE⟩, hNE⟩, hsh⟩ := hok
  obtain ⟨r', er'⟩ := newData_pure y.mlx hsym (M.a b) 0 bs' (M.arg sh) (M.arg nd) (M.arg dt)
  have et' := loadCall_pure (x := y) hm er'
  cases e1 : Host.Mlx.Ffi.dimsArg sh nd with
  | none =>
    have et : ∀ γ k, Host.Mlx.Ffi.call x.mlx name (.jsPtr b 0 bsT :: [sh, nd, dt]) γ k = k none := by
      intro γ k; unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [e1]; rfl
    exact msim_vals (loadCall_pure hm et) et' ⟨Grow.refl hs, trivial⟩
  | some shape =>
    rw [e1] at hsh
    simp only [Bool.and_eq_true, Bool.not_eq_true'] at hsh
    obtain ⟨hv, hnl⟩ := hsh
    cases e2 : Host.Mlx.Ffi.argNat dt with
    | none =>
      have et : ∀ γ k, Host.Mlx.Ffi.call x.mlx name (.jsPtr b 0 bsT :: [sh, nd, dt]) γ k = k none := by
        intro γ k; unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [e1, e2]; rfl
      exact msim_vals (loadCall_pure hm et) et' ⟨Grow.refl hs, trivial⟩
    | some d =>
      -- the shape's dimensions denote naturals at the target
      obtain ⟨ks, hks, bks⟩ := dvss_of hs hv fun j hj => hsm j (by simp only [dataRefs]; exact dimsArgRefs_mem e1 hj)
      have hcan : ∀ e ∈ shape, DimCanon M e := DVSs.canon hks fun k hk => by have := bks k hk; omega
      have hnats : Host.Mlx.Ffi.natsOfDims shape = none := by
        cases h : Host.Mlx.Ffi.natsOfDims shape with
        | none => rfl
        | some _ => rw [natsOfDims_lits h] at hnl; cases hnl
      -- the template's node and the target's
      let ndT : Node := ⟨.data bsT, [], shape, d⟩
      let bsY : List Byte := match Host.Mlx.Ffi.natsOfDims (M.dims shape) with
        | some ds => bs'.take (ds.foldr (· * ·) 1 * Host.Mlx.Ffi.dtSize d)
        | none => bs'
      let ndY : Node := ⟨.data bsY, [], M.dims shape, d⟩
      have hso : shapeOnly ndT = true := by
        show (true && !(shape.all dimLit)) = true
        rw [hnl]; rfl
      have hr1 := mr.addNodeR ndT ndY hNE ⟨hbs, DVSs.sds hks⟩ hcan rfl rfl (.inr ⟨hso, bsY, rfl⟩) rfl
      obtain ⟨h, x', h', y', ex, ey, hr2, hbig⟩ := hr1.setArr_map (sl := 0) (.inl rfl) (fun _ => hE) x.mlx.nnext
      rw [mr.handle0, mr.node_next] at ey
      have et : ∀ γ k, Host.Mlx.Ffi.call x.mlx name (.jsPtr b 0 bsT :: [sh, nd, dt]) γ k =
          k (some (x', .big h, [])) := by
        intro γ k; unfold Host.Mlx.Ffi.call; rw [hsym]
        simp only [e1, e2, hnats, Host.Mlx.Ffi.St.addNode]
        rw [show ({ x.mlx with nnext := x.mlx.nnext + 1, nodes := x.mlx.nodes.set x.mlx.nnext ndT } : NSt) =
          { x.mlx with nnext := x.mlx.nnext + 1, nodes := x.mlx.nodes.set x.mlx.nnext ndT } from rfl, ex]
        rfl
      have et2 : ∀ γ k, Host.Mlx.Ffi.call y.mlx name (.jsPtr (M.a b) 0 bs' :: [sh, nd, dt].map M.arg) γ k =
          k (some (y', .big h', [])) := by
        intro γ k; unfold Host.Mlx.Ffi.call; rw [hsym]
        simp only [List.map_cons, List.map_nil, mr.dimsArg_map hd e1, mr.natOk_argNat hdt, e2,
          Host.Mlx.Ffi.St.addNode]
        first | (rw [ey]; rfl) | (simp only [ey]; rfl) | (erw [ey]; rfl)
      refine msim_vals (loadCall_pure hm et) (loadCall_pure (x := y) hm et2) ⟨Grow.refl hs, ?_⟩
      show DataR (F := Host.Load.ffi) (LoadR P NB) M S.tab.length A
        (some ({ x with mlx := x' }, .big (h : Int), [])) (some ({ y with mlx := y' }, .big (h' : Int), []))
      refine ⟨⟨hr.host, hr.hostReg, hr.hostLt, hr.cbr, hr2⟩, ?_, rfl, rfl, ?_, trivial⟩
      · show Ret.big (Int.ofNat h') = Ret.big (M.big (Int.ofNat h))
        rw [hbig]
      · intro f cs he; cases he

end Host.Ts.Sim.G
