import host.sim.full.CallSym
import host.sim.full.BridgeSize

/-! # B-size's native side in the full world

`G.sim_arraySizeS`: `mlx_array_size` through the model completed by the symbolic-shape layer
(`callSym`), template and target: over a literal shape both return the bigint product; over a
symbolic one the template's layer returns the product as a number (or a bigint, if literal) and
the target either the bigint product (its shape literal) or the layer's product (its shape
symbolic); in every case the returns' `Number` values are related (`SizeRM`). `fullSizeCallSim`:
the interface `Disp.SizeCallSim` for the full world (`FullR`), under the premise `SizePre` (a node
handle whose shape's dimensions have small values). -/

namespace Host.Ts.Sim.G
open Host.Mlx.Ffi (Dim Prim Node Out dimOf)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall isSym)

/-- The results of a size call in the mlx model. -/
def SizeRM (P : LoadP) (NB : Nat) (M : Map) (n : Nat) :
    Option (NSt × Ret × List (Nat × Nat × List Byte)) → Option (NSt × Ret × List (Nat × Nat × List Byte)) → Prop
  | none, _ => True
  | some (x, ret, ws), some (y, ret', ws') => MR P NB M n x y ∧ ws = [] ∧ ws' = [] ∧
    ∃ v, Disp.numRet ret = some v ∧ Disp.numRet ret' = some (M.val v) ∧ ∀ A, Supp.val A n v
  | some _, none => False

/-- The layer's return for a product. -/
def sizeRet : Dim → Ret
  | .lit i => .big i
  | .sym x => .num x

/-- Its `Number` value. -/
def sizeOut : Dim → Val
  | .lit i => intV i
  | .sym x => .num x

theorem numRet_sizeRet (d : Dim) : Disp.numRet (sizeRet d) = some (sizeOut d) := by
  cases d <;> rfl

/-- A product with a value: its image's `Number` value is the image of its own. -/
theorem sizeOut_dim {M : Map} {C : CSrv} {r : Dim} {k : Nat} (hv : DV M C r k) (hk : k < 2 ^ 53) :
    sizeOut (M.dim r) = M.val (sizeOut r) := by
  rcases hv with rfl | ⟨j, rfl, hj⟩
  · rfl
  · show sizeOut (dimOf (M.num j)) = Val.num (M.num j)
    cases e : M.num j with
    | lit f =>
      rw [e] at hj
      simp only [CSrv.val, Option.some.injEq] at hj
      subst hj
      rw [dimOf_ofNat k hk]
      rfl
    | ref j' => rfl

theorem natsOfDims_none_sym : ∀ {ds : List Dim}, ds.all dimOkV = true → Host.Mlx.Ffi.natsOfDims ds = none →
    ds.any isSym = true
  | [], _, h => by cases h
  | .lit i :: ds, hv, h => by
    simp only [List.all_cons, Bool.and_eq_true, dimOkV, decide_eq_true_eq] at hv
    simp only [Host.Mlx.Ffi.natsOfDims, decide_eq_true hv.1.1, Bool.cond_true, Option.map_eq_none_iff] at h
    simp only [List.any_cons, natsOfDims_none_sym hv.2 h, Bool.or_true]
  | .sym _ :: _, _, _ => rfl

/-- The images of dimensions with values. -/
theorem natsOfDims_none_symM {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {ds : List Dim} {ks : List Nat}, DVSs M C S ds ks → (∀ k ∈ ks, k < 2 ^ 53) →
      Host.Mlx.Ffi.natsOfDims (M.dims ds) = none → (M.dims ds).any isSym = true
  | [], [], _, _, h => by cases h
  | d :: ds, k :: ks, ⟨hd, hds⟩, hb, h => by
    have hk : k < 2 ^ 53 := hb k List.mem_cons_self
    simp only [Map.dims, List.map_cons, List.any_cons] at h ⊢
    rcases hd.1.dim hk with e | ⟨j, e, -⟩ <;> rw [e] at h ⊢
    · simp only [Host.Mlx.Ffi.natsOfDims, show decide (0 ≤ (k : Int)) = true from decide_eq_true (by omega),
        Bool.cond_true, Option.map_eq_none_iff] at h
      have := natsOfDims_none_symM hds (fun k' hk' => hb k' (List.mem_cons_of_mem _ hk')) h
      simp only [Map.dims] at this
      simp [isSym, this]
    · rfl
  | [], _ :: _, h, _, _ => h.elim
  | _ :: _, [], h, _, _ => h.elim

theorem natsOfDims_someM {M : Map} {S : SSrv} {C : CSrv} :
    ∀ {ds : List Dim} {ks : List Nat} {ns : List Nat}, DVSs M C S ds ks → (∀ k ∈ ks, k < 2 ^ 53) →
      Host.Mlx.Ffi.natsOfDims (M.dims ds) = some ns → ns = ks
  | [], [], ns, _, _, h => by simp only [Map.dims, List.map_nil, Host.Mlx.Ffi.natsOfDims, Option.some.injEq] at h; exact h.symm
  | d :: ds, k :: ks, ns, ⟨hd, hds⟩, hb, h => by
    have hk : k < 2 ^ 53 := hb k List.mem_cons_self
    simp only [Map.dims, List.map_cons] at h
    rcases hd.1.dim hk with e | ⟨j, e, -⟩ <;> rw [e] at h
    · simp only [Host.Mlx.Ffi.natsOfDims, show decide (0 ≤ (k : Int)) = true from decide_eq_true (by omega),
        Bool.cond_true] at h
      cases hn : Host.Mlx.Ffi.natsOfDims (List.map M.dim ds) with
      | none => rw [hn] at h; cases h
      | some ns' =>
        rw [hn] at h
        simp only [Option.map_some, Option.some.injEq] at h
        subst h
        have := natsOfDims_someM hds (fun k' hk' => hb k' (List.mem_cons_of_mem _ hk')) (by simpa [Map.dims] using hn)
        rw [this]; simp
    · simp [Host.Mlx.Ffi.natsOfDims] at h
  | [], _ :: _, _, h, _, _ => h.elim
  | _ :: _, [], _, h, _, _ => h.elim

theorem foldr_natProd : ∀ (ks : List Nat), ks.foldr (· * ·) 1 = natProd ks
  | [] => rfl
  | k :: ks => by simp only [List.foldr_cons, foldr_natProd ks]; rfl

theorem call_size_some (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) {a : Arg}
    {nd : Node} (hnd : (Host.Mlx.Ffi.argNat a).bind s.node? = some nd) {ns : List Nat}
    (hn : Host.Mlx.Ffi.natsOfDims nd.shape = some ns) :
    Host.Mlx.Ffi.call s name [a] = Host.Mlx.Ffi.ok s (.big (ns.foldr (· * ·) 1 : Nat)) := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [hnd, hn]

theorem call_size_none (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) {a : Arg}
    {nd : Node} (hnd : (Host.Mlx.Ffi.argNat a).bind s.node? = some nd)
    (hn : Host.Mlx.Ffi.natsOfDims nd.shape = none) :
    Host.Mlx.Ffi.call s name [a] = Host.Mlx.Ffi.stuck := by
  unfold Host.Mlx.Ffi.call; rw [hsym]; simp only [hnd, hn]

theorem symShapeCall_size (s : NSt) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) {a : Arg}
    {nd : Node} (hnd : (Host.Mlx.Ffi.argNat a).bind s.node? = some nd) (hany : nd.shape.any isSym = true) :
    symShapeCall s name [a] = Host.Ts.M.bind (Host.Mlx.Ffi.dProd nd.shape) fun d => Host.Mlx.Ffi.ok s (sizeRet d) := by
  unfold symShapeCall; rw [hsym]; simp only [hnd, hany, Bool.cond_true]
  refine congrArg (Host.Ts.M.bind (Host.Mlx.Ffi.dProd nd.shape)) (funext fun d => ?_)
  cases d <;> rfl

section
variable {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : NSt} {name : Name}
  (hs : Srv M ν S C) (hr : MR P NB M S.tab.length x y)
include hs hr

/-- **`mlx_array_size` through the layer**, template and target: the returns' `Number` values are
related. -/
theorem sim_arraySizeS (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) {a : Arg} (ha : nodeOk x a = true)
    {nd : Node} (hnd : (Host.Mlx.Ffi.argNat a).bind x.node? = some nd) (vo : nd.shape.all dimOkV = true)
    (po : prodBnd nd.shape < 2 ^ 53) (hsm : ∀ j ∈ nd.shape.flatMap dimRefs, RefSmall ν S j) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ SizeRM P NB M' S'.tab.length r r') S C
      (callSym x name [a]) (callSym y name [M.arg a]) := by
  obtain ⟨k, i, nd0, nd', rfl, hm, hp, e1, e2, hnr⟩ := hr.nodeArg ha
  rw [argNat_nat, Option.bind_some, e1] at hnd
  cases hnd
  have hnd' : (Host.Mlx.Ffi.argNat (M.arg (.big (Int.ofNat k)))).bind y.node? = some nd' := by
    rw [hm, argNat_nat, Option.bind_some, e2]
  have hsh' : nd'.shape = M.dims nd.shape := hnr.1
  obtain ⟨ks, hks, bks⟩ := dvss_of hs vo hsm
  have pks : ProdB ks := hks.prodB bks po
  -- the end: both sides return their state, with returns related through `Number`
  have fin : ∀ {M' : Map} {S' : SSrv} {C' : CSrv} (r : Dim) (r' : Ret) (g : GrowL M ν S C M' S' C')
      (hv : DV M' C' r (natProd ks)) (hsr : SD (· < S'.tab.length) r) (hr' : Disp.numRet r' = some (sizeOut (M'.dim r))),
      MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ SizeRM P NB M' S'.tab.length r r') S' C'
        (Host.Mlx.Ffi.ok x (sizeRet r)) (Host.Mlx.Ffi.ok y r') := by
    intro M' S' C' r r' g hv hsr hr'
    refine MSim.pure ⟨g.grow, hr.grow g.grow, rfl, rfl, sizeOut r, numRet_sizeRet r, ?_, fun A => ?_⟩
    · rw [hr', sizeOut_dim hv (pks 0)]
    · cases r with
      | lit _ => trivial
      | sym v =>
        cases v with
        | lit _ => trivial
        | ref j => exact hsr
  cases hn : Host.Mlx.Ffi.natsOfDims nd.shape with
  | some ns =>
    -- a literal shape: both sides the model's bigint
    have hn' : Host.Mlx.Ffi.natsOfDims nd'.shape = some ns := by rw [hsh']; exact natsOfDims_map M hn
    rw [callSym_some (fun γ k => by rw [call_size_some x hsym (by rw [argNat_nat, Option.bind_some, e1]) hn]; rfl),
      call_size_some x hsym (by rw [argNat_nat, Option.bind_some, e1]) hn,
      callSym_some (fun γ k => by rw [call_size_some y hsym hnd' hn']; rfl), call_size_some y hsym hnd' hn']
    exact MSim.pure ⟨Grow.refl hs, hr, rfl, rfl, intV (ns.foldr (· * ·) 1 : Nat), rfl, rfl, fun _ => trivial⟩
  | none =>
    have hany := natsOfDims_none_sym vo hn
    rw [callSym_stuck (call_size_none x hsym (by rw [argNat_nat, Option.bind_some, e1]) hn),
      symShapeCall_size x hsym (by rw [argNat_nat, Option.bind_some, e1]) hany]
    cases hn' : Host.Mlx.Ffi.natsOfDims nd'.shape with
    | some ns' =>
      -- the template through the layer, the target's literal product
      rw [hsh'] at hn'
      have ens := natsOfDims_someM hks bks.lt53 hn'
      rw [callSym_some (fun γ k => by rw [call_size_some y hsym hnd' (by rw [hsh']; exact hn')]; rfl),
        call_size_some y hsym hnd' (by rw [hsh']; exact hn'), ens, foldr_natProd]
      show MSim _ S C _ (Host.Ts.M.bind (Host.Ts.M.pure (Dim.lit (natProd ks : Int))) fun d =>
        Host.Mlx.Ffi.ok y (sizeRet d))
      refine MSim.bind (dProd_vs_pure hs hks bks.lt53 pks) fun M' S' C' r r' h => ?_
      obtain ⟨⟨e, hv, hsr, g⟩, hl⟩ := h
      subst hl
      refine fin r _ g hv hsr ?_
      rw [← e, numRet_sizeRet]
    | none =>
      -- both through the layer
      have hany' : nd'.shape.any isSym = true := by
        rw [hsh'] at hn' ⊢; exact natsOfDims_none_symM hks bks.lt53 hn'
      rw [callSym_stuck (call_size_none y hsym hnd' hn'), symShapeCall_size y hsym hnd' hany', hsh']
      refine MSim.bind (dProd_simV hs hks bks.lt53 pks) fun M' S' C' r r' h => ?_
      obtain ⟨e, hv, hsr, g⟩ := h
      subst e
      exact fin r _ g hv hsr (numRet_sizeRet _)

end

end Host.Ts.Sim.G

namespace Host.Ts.Sim.Full
open Host.Ts Host.Ts.Sim Host.Load.Layers
open Host.Mlx.Ffi.FullKeep (Keep AllX KRes)
open Host.Mlx.Ffi.SymShape (callSym symShapeCall)

/-- **Lift** of the size call to the load world. -/
theorem mlx_liftSize {P : LoadP} {NB : Nat} {M : Map} {ν : Nat → F64} {S : SSrv} {C : CSrv} {x y : Host.Load.LSt}
    {name : Name} {args args' : List Arg} (A : Nat → Prop) (hr : G.LoadR P NB M S.tab.length x y)
    (h : MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ G.SizeRM P NB M' S'.tab.length r r') S C
      (callSym x.mlx name args) (callSym y.mlx name args')) :
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧
      Disp.SizeR (F := Host.Load.ffi) (G.LoadR P NB) M' S'.tab.length A r r') S C
      (loadCallSym x name args) (loadCallSym y name args') := by
  unfold loadCallSym
  refine MSim.bind h fun M' S' C' a b hab => ?_
  obtain ⟨hg, hc⟩ := hab
  cases a with
  | none =>
    cases b with
    | none => exact MSim.pure ⟨hg, trivial⟩
    | some q => obtain ⟨_, _, _⟩ := q; exact MSim.pure ⟨hg, trivial⟩
  | some p =>
    obtain ⟨m, r, ws⟩ := p
    cases b with
    | none => exact hc.elim
    | some q =>
      obtain ⟨m', r', ws'⟩ := q
      obtain ⟨hmr, h1, h2, v, hv, hv', hsv⟩ := hc
      refine MSim.pure ⟨hg, ⟨?_, h1, h2, v, hv, hv', hsv A⟩⟩
      exact ⟨hr.host, fun k hk => by rw [hg.ext.region]; exact hr.hostReg k hk, hr.hostLt,
        fun a => by rw [hg.ext.region, hg.ext.a]; exact hr.cbr a, hmr⟩

/-- The layers after a size call. -/
theorem full_size_post {P : LoadP} {NB : Nat} {M M' : Map} {ν : Nat → F64} {S S' : SSrv} {C C' : CSrv}
    {x y : FF.S} {name : Name} {args : List Arg} {l l' : Host.Load.LSt} {r r' : Ret} {A : Nat → Prop}
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    (hr : FullR P NB M S.tab.length x y) (hgr : Grow M ν S C M' S' C')
    (hcr : Disp.SizeR (F := Host.Load.ffi) (G.LoadR P NB) M' S'.tab.length A (some (l, r, [])) (some (l', r', [])))
    (kx : Keep (mlxOf x) l.mlx) (ky : Keep (mlxOf y) l'.mlx) (hsupp : ∀ a ∈ args, Supp.arg (fun _ => True) S.tab.length a) :
    MSim (fun M'' S'' C'' r r' => Grow M ν S C M'' S'' C'' ∧
      Disp.SizeR (F := FF) (FullR P NB) M'' S''.tab.length A r r') S' C'
      (Host.Ts.M.pure (liftF x name args (some (⟨l, bridgeOf x⟩, r, []))))
      (Host.Ts.M.pure (liftF y name (args.map M.arg) (some (⟨l', bridgeOf y⟩, r', [])))) := by
  obtain ⟨hlr, -, -, v, hv, hv', hsv⟩ := hcr
  have hob : ObsPost P NB M M' S.tab.length S'.tab.length (mlxOf x) (mlxOf y) l.mlx l'.mlx :=
    ⟨hr.load.mlx, hlr.mlx, hgr.ext, hgr.len, kx, ky⟩
  have hobs : obsOk (mlxOf x) name args = true := by
    unfold obsOk; rw [hsym]; rcases args with _ | ⟨a, _ | ⟨b, rest⟩⟩ <;> rfl
  have hka : KernAcc P (mlxOf x) name args := by
    intro s hs; rw [hsym] at hs; cases hs
    exact ⟨(fun h => nomatch h), (fun h => by rcases h with h | h | h <;> cases h)⟩
  have hk := kern_step (r := r) hr.kern hob hsupp hka (fun hs => by rw [hsym] at hs; cases hs)
    (fun hs => by rw [hsym] at hs; cases hs)
  have ko : ∀ (e : KRec) (m : Host.Mlx.Ffi.St) (as : List Arg) (q : Ret), kernCall e m name as q = some e :=
    fun e m as q => kernCall_other e m name as q hsym (by decide) (by decide) (by decide) (by decide) (by decide)
  simp only [ko] at hk
  rw [liftF_some, liftF_some]
  refine MSim.pure ⟨hgr, ⟨hlr, ⟨hr.bridge.1, hr.bridge.2⟩, ?_, ?_, hr.pend.step hr.load.mlx hlr.mlx hgr.ext kx⟩, rfl, rfl, v, hv, hv', hsv⟩
  · exact live_step hr.live hob hobs (fun hs => by rw [hsym] at hs; cases hs)
  · simp only [ko]; exact hk

/-- The premise of the full world's size call: a node handle whose shape's dimensions have small
values, and products below `2 ^ 53`. -/
def SizePre (ν : Nat → F64) (S : SSrv) (x : FF.S) (as : List Arg) : Prop :=
  ∃ a nd, as = [a] ∧ nodeOk (mlxOf x) a = true ∧ (Host.Mlx.Ffi.argNat a).bind (mlxOf x).node? = some nd ∧
    nd.shape.all dimOkV = true ∧ G.prodBnd nd.shape < 2 ^ 53 ∧ ∀ j ∈ nd.shape.flatMap dimRefs, RefSmall ν S j

/-- **B-size's native side for the full world.** -/
theorem fullSizeCallSim (P : LoadP) (NB : Nat) {name : Name} (hsym : Host.Mlx.Ffi.symOf name = some .arraySize)
    (hm : Host.Load.isMlx name = true) (hp : nameEq name Host.Mlx.FfiAne.payloadName = false) (A : Nat → Prop) :
    Disp.SizeCallSim FF (FullR P NB) name A SizePre := by
  intro M ν S C x y as hsrv hr hsupp hpre
  obtain ⟨a, nd, rfl, ha, hnd, vo, po, hsm⟩ := hpre
  have hact : (bridgeOf x).active = false := hr.bridge.2
  have hacty : (bridgeOf y).active = false := by rw [hr.bridge.1]; exact hact
  rw [full_call_sym x name [a] hm hp hact, full_call_sym y name _ hm hp hacty]
  have hg := mlx_liftSize A hr.load (G.sim_arraySizeS hsrv hr.load.mlx hsym ha hnd vo po hsm)
  have hg2 := MSim.both hg (loadCallSym_l _ _ _) (loadCallSym_l _ _ _)
  refine MSim.bind hg2 fun M' S' C' o o' hab => ?_
  obtain ⟨⟨hgr, hcr⟩, hra, hrb⟩ := hab
  rcases o with _ | ⟨l, r, ws⟩
  · exact MSim.pure ⟨hgr, trivial⟩
  · rcases o' with _ | ⟨l', r', ws'⟩
    · exact hcr.elim
    · obtain ⟨hl1, rfl, rfl, hv4⟩ := hcr
      exact full_size_post hsym hr hgr ⟨hl1, rfl, rfl, hv4⟩ (keepS_of_run hra) (keepS_of_runC hrb)
        (fun b hb => Supp.arg_mono (fun _ _ => trivial) (Nat.le_refl _) (hsupp b hb))

/-- `SizePre` decided, the valuations within `VB`. -/
def sizePreB (VB : Nat → Nat) (S : SSrv) (x : FF.S) (as : List Arg) : Bool :=
  match as with
  | [a] => nodeOk (mlxOf x) a && match (Host.Mlx.Ffi.argNat a).bind (mlxOf x).node? with
    | some nd => nd.shape.all dimOkV && decide (G.prodBnd nd.shape < 2 ^ 53) &&
        (nd.shape.flatMap dimRefs).all (refSmallB VB S)
    | none => false
  | _ => false

theorem sizePreB_sound {VB : Nat → Nat} {ν : Nat → F64} {S : SSrv} {x : FF.S} {as : List Arg}
    (h : sizePreB VB S x as = true) (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) : SizePre ν S x as := by
  unfold sizePreB at h
  split at h
  · rename_i a
    simp only [Bool.and_eq_true] at h
    obtain ⟨ha, h⟩ := h
    split at h
    · rename_i nd hnd
      simp only [Bool.and_eq_true, decide_eq_true_eq] at h
      obtain ⟨⟨vo, po⟩, hs⟩ := h
      exact ⟨a, nd, rfl, ha, hnd, vo, po, fun j hj => refSmallB_sound (List.all_eq_true.mp hs j hj) hν⟩
    · cases h
  · cases h

/-- The premise from the template's decoding run and the decider. -/
theorem sizePre_of {VB : Nat → Nat} {ν : Nat → F64} {S S0 : SSrv} {s : St FF.S} {tys args : List Val}
    {as0 : List Arg} (hdec : interpS (decodeArgs FF s tys args).run S = some (some as0, S0))
    (hb : sizePreB VB S0 s.ffi as0 = true) (hν : ∀ v, ∃ k ≤ VB v, ν v = F64.ofNat k) :
    ∀ asR S1, interpS (decodeArgs FF s tys args).run S = some (some asR, S1) → SizePre ν S1 s.ffi asR := by
  intro asR S1 h
  rw [hdec] at h
  simp only [Option.some.injEq, Prod.mk.injEq] at h
  obtain ⟨rfl, rfl⟩ := h
  exact sizePreB_sound hb hν

/-- **B-size in the full world**: at the call state of `Number(C.mlx_array_size(h))`, the template's
and the target's blocks end related. -/
theorem fullBridgeSize {P : LoadP} {NB : Nat} {W : Nat → Option WFrame} {stk : List Frame} {M : Map}
    {ν : Nat → F64} {K : Ctx} {s t : St FF.S} {S : SSrv} {C : CSrv}
    (h : RelB FF (FullR P NB) W stk M ν K s S t C)
    {fsym ta nf : Nat} {name rt : Name} {tys args : List Val}
    (hp : Disp.sizeParts s = some (fsym, ta, nf, name, rt, tys, args)) (hargs : Disp.sizeArgsOk s = true)
    (hsym : Host.Mlx.Ffi.symOf name = some .arraySize) (hm : Host.Load.isMlx name = true)
    (hpay : nameEq name Host.Mlx.FfiAne.payloadName = false) (hfr : K.fr ta = none)
    (hpre : ∀ asR S1, interpS (decodeArgs FF s tys args).run S = some (some asR, S1) → SizePre ν S1 s.ffi asR) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB FF (FullR P NB) W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret asR' ret' v, s1.trace = ⟨name, asR, ret⟩ :: s.trace ∧ t1.trace = ⟨name, asR', ret'⟩ :: t.trace ∧
        Disp.numRet ret = some v ∧ Disp.numRet ret' = some (M'.val v)) S C
      (Disp.sizeS FF s) (Disp.sizeS FF t) :=
  Disp.bridge_size_at h (fullR_laws bridgeI_stable P NB) (fullFfiSim P NB) hp hargs hfr hpre
    (fullSizeCallSim P NB hsym hm hpay (Present s))

end Host.Ts.Sim.Full
