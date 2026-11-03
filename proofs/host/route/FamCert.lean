import host.route.CertStep
import host.simgraph.mach.Agree
import host.route.PrefGraph
import host.load.run.full.InitialLayout
import host.simgraph.family.FoldedData
set_option maxRecDepth 1000000
set_option autoImplicit false
namespace Host.Route.PrefGraph
open Host.Load Host.Load.Extract Host.Load.Program Host.Load.Run.Full
open Host.Mlx Host.Mlx.GlueStep Host.Mlx.FfiEval Host.Mlx.SimGraph Host.Ts
open Inference Inference.Contracts.Mlx Inference.Models.Qwen
open Host.Mlx.SimGraph.Iter
open Host.Ts.Sim (LoadP Map)
open Host.Mlx.SimGraph.Mach (CacheValuesV routeVal GrR)
open Host.Mlx.SimGraph.Ref (refRows refNu rowSem rowIds stepEnv handlesOf)

/-! # A first forward's certificate

`FamCert`: a row family's expected graph at the cold layout, checked against a first forward's end template. It names no
chain: a generated module instantiates it from `simgraph_choose_route` and `simgraph_check_segment`.

* `ffiGraphR_key`: the route's graph at prompt keys is its graph at input keys, keyed.
* `FamCert.emb`: the end template embeds in the route's graph, from the native relation.
* `FamCert.plain`: the kernels are plain at the carriers, because the domain excludes replayed ones.
* `FamCert.inputs`: the carriers of the family's inputs hold them.
* `FamCert.values`: **the forward's handles at their carriers.** -/

/-! ## Keys -/

section
variable {δ κ κ' : Type} (f : κ → κ')

theorem resolvePrim_key (N : Nums δ) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim) (dtype : Nat) :
    ∀ p : Ffi.Prim, (resolvePrim (κ := κ) N kn shape dtype p).map (keyP f) = resolvePrim (κ := κ') N kn shape dtype p := by
  intro p
  induction p with
  | replayed c p ih =>
    simp only [resolvePrim, Option.map_map]
    rw [← ih, Option.map_map]
    rfl
  | data b =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases b.mapM N.byte <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases shape.mapM N.d <;> rfl
  | zeros =>
    simp only [resolvePrim]
    cases shape.mapM N.d <;> rfl
  | reshape l =>
    simp only [resolvePrim]
    cases l.mapM N.d <;> rfl
  | slice a b c =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases a.mapM N.d <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases b.mapM N.d <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases c.mapM N.d <;> rfl
  | sliceUpdate a b c =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases a.mapM N.d <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases b.mapM N.d <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases c.mapM N.d <;> rfl
  | sliceDynamic _ l =>
    simp only [resolvePrim]
    cases l.mapM N.d <;> rfl
  | rmsNorm e =>
    simp only [resolvePrim]
    cases N.word e <;> rfl
  | rope _ _ b s o =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases Ffi.argNat b <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases N.word s <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases N.dim o <;> rfl
  | sdpa s _ =>
    simp only [resolvePrim]
    cases N.word s <;> rfl
  | kernel k c _ =>
    simp only [resolvePrim, Option.bind_eq_bind, Option.pure_def]
    cases kn k <;> simp only [Option.bind_none, Option.bind_some, Option.map_none]
    cases resolveCfg N c <;> rfl
  | _ => rfl

end

theorem resolvePrimP_key {κ κ' : Type} (f : κ → κ') (N : Nums Int) (kn : Nat → Option (List Char)) (shape : List Ffi.Dim)
    (dtype : Nat) : ∀ p : Ffi.Prim,
      (resolvePrimP (κ := κ) N kn shape dtype p).map (keyP f) = resolvePrimP (κ := κ') N kn shape dtype p
  | .arange a b c => by
    simp only [resolvePrimP, Option.bind_eq_bind]
    cases N.dim a with
    | none => rfl
    | some x =>
      simp only [Option.bind_some]
      cases N.dim c with
      | none => rfl
      | some y =>
        simp only [Option.bind_some]
        cases shape.mapM N.d with
        | none => rfl
        | some l =>
          simp only [Option.bind_some]
          match l with
          | [] => rfl
          | [n] =>
            dsimp only
            split <;> rfl
          | _ :: _ :: _ => rfl
  | .replayed c p => by
    simp only [resolvePrimP, Option.map_map]
    rw [← resolvePrimP_key f N kn shape dtype p, Option.map_map]
    rfl
  | .data _ | .load _ _ | .tracer _ | .zeros | .reshape _ | .transpose _ | .slice _ _ _ | .sliceUpdate _ _ _
  | .sliceDynamic _ _ | .concat _ | .unary _ | .binary _ | .astype _ | .contiguous | .rmsNorm _ | .rope _ _ _ _ _
  | .sdpa _ _ | .qmm _ _ _ _ | .dequantize _ _ _ _ | .take _ | .conv1d _ _ _ _ | .logsumexp _ _ | .kernel _ _ _ =>
    resolvePrim_key f N kn shape dtype _

theorem ffiGraphR_key {κ κ' : Type} (f : κ → κ') (N : Nums Int) (S : KernelSources) (s : Ffi.St) :
    keyG f (ffiGraphR (κ := κ) N S s) = ffiGraphR (κ := κ') N S s := by
  funext i
  simp only [keyG, ffiGraphR]
  cases s.nodes.get i with
  | none => rfl
  | some nd =>
    simp only [Option.bind_some, resolveNodeP, Option.map_map]
    rw [← resolvePrimP_key f N (routeKernelName? S s) nd.shape nd.dtype nd.prim, Option.map_map]
    rfl

/-! ## The checks -/

theorem sameNum_eq {a b : NumV} (h : sameNum a b = true) : a = b := by
  cases a <;> cases b <;> simp_all [sameNum]

theorem cellAt_eq {i : Nat} {b : Byte} {a : NumV} (h : cellAt i b = some a) : b = .part .i32 (.num a) i := by
  unfold cellAt at h
  split at h
  · rename_i a' j
    split at h
    · rename_i hj
      cases h
      rw [hj]
    · cases h
  · cases h

theorem cellsNums_eq : ∀ (b : List Byte) (xs : List NumV), cellsNums b = some xs → b = cellsHostBytes xs
  | [], xs, h => by
    simp only [cellsNums, Option.some.injEq] at h
    subst h
    rfl
  | [_], _, h => by simp [cellsNums] at h
  | [_, _], _, h => by simp [cellsNums] at h
  | [_, _, _], _, h => by simp [cellsNums] at h
  | b0 :: b1 :: b2 :: b3 :: r, xs, h => by
    unfold cellsNums at h
    cases h0 : cellAt 0 b0 with
    | none => simp [h0] at h
    | some a =>
    cases h1 : cellAt 1 b1 with
    | none => simp [h0, h1] at h
    | some a1 =>
    cases h2 : cellAt 2 b2 with
    | none => simp [h0, h1, h2] at h
    | some a2 =>
    cases h3 : cellAt 3 b3 with
    | none => simp [h0, h1, h2, h3] at h
    | some a3 =>
    simp only [h0, h1, h2, h3] at h
    split at h
    · rename_i hs
      simp only [Bool.and_eq_true] at hs
      obtain ⟨⟨e1, e2⟩, e3⟩ := hs
      obtain ⟨xs', hr, rfl⟩ := Option.map_eq_some_iff.mp h
      have e1' := sameNum_eq e1
      have e2' := sameNum_eq e2
      have e3' := sameNum_eq e3
      subst e1' e2' e3'
      rw [cellAt_eq h0, cellAt_eq h1, cellAt_eq h2, cellAt_eq h3, cellsNums_eq r xs' hr]
      rfl
    · cases h

theorem cellsNumsL_eq : ∀ (b : List Byte) (xs : List NumV), cellsNumsL b = some xs → b = cellsHostBytes xs
  | [], xs, h => by
    simp only [cellsNumsL, Option.some.injEq] at h
    subst h
    rfl
  | [_], _, h => by simp [cellsNumsL] at h
  | [_, _], _, h => by simp [cellsNumsL] at h
  | [_, _, _], _, h => by simp [cellsNumsL] at h
  | b0 :: b1 :: b2 :: b3 :: r, xs, h => by
    unfold cellsNumsL at h
    cases h0 : cellAt 0 b0 with
    | none => simp [h0] at h
    | some a =>
    cases h1 : cellAt 1 b1 with
    | none => simp [h0, h1] at h
    | some a1 =>
    cases h2 : cellAt 2 b2 with
    | none => simp [h0, h1, h2] at h
    | some a2 =>
    cases h3 : cellAt 3 b3 with
    | none => simp [h0, h1, h2, h3] at h
    | some a3 =>
    simp only [h0, h1, h2, h3] at h
    split at h
    · rename_i hs
      simp only [Bool.and_eq_true] at hs
      obtain ⟨⟨e1, e2⟩, e3⟩ := hs
      obtain ⟨xs', hr, rfl⟩ := Option.map_eq_some_iff.mp h
      have e1' : a = a1 := of_decide_eq_true e1
      have e2' : a = a2 := of_decide_eq_true e2
      have e3' : a = a3 := of_decide_eq_true e3
      subst e1' e2' e3'
      rw [cellAt_eq h0, cellAt_eq h1, cellAt_eq h2, cellAt_eq h3, cellsNumsL_eq r xs' hr]
      rfl
    · cases h

/-- An attention layout before any step. -/
def coldLayout : StageLayout → Bool
  | .delta _ => true
  | .attention a => a.kcap.isNone && a.vcap.isNone

kernel_rfl stages_cold : Expected.stages.all coldLayout = true

theorem kvSigP_cold {n₀ n : Nat} (h0 : 0 < n₀ ∧ n₀ < 256) (h : 0 < n ∧ n < 256) : kvSigP none 0 n₀ = kvSigP none 0 n := by
  have e0 : (n₀ + 255) / 256 = 1 := by omega
  have e1 : (n + 255) / 256 = 1 := by omega
  simp only [kvSigP, kvCapP, e0, e1, Option.map_none]
  congr 1
  rw [decide_eq_false (by omega), decide_eq_false (by omega)]

theorem sig_cold {n₀ n : Nat} (h0 : 0 < n₀ ∧ n₀ < 256) (h : 0 < n ∧ n < 256) :
    ∀ l : List StageLayout, l.all coldLayout = true → List.Forall₂ (SigRelR kvSigP 0 n₀ 0 n) l l
  | [], _ => .nil
  | s :: l, hl => by
    simp only [List.all_cons, Bool.and_eq_true] at hl
    refine .cons ?_ (sig_cold h0 h l hl.2)
    cases s with
    | delta d => rfl
    | attention a =>
      simp only [coldLayout, Bool.and_eq_true, Option.isNone_iff_eq_none] at hl
      obtain ⟨⟨hk, hv⟩, -⟩ := hl
      refine ⟨rfl, rfl, rfl, rfl, rfl, ?_, ?_⟩
      · rw [hk]; exact kvSigP_cold h0 h
      · rw [hv]; exact kvSigP_cold h0 h

theorem mapP_input {δ δ' κ : Type} {f : δ → δ'} {p : RPrim δ κ} {key : κ} (h : mapP f p = .input key) : p = .input key := by
  cases p <;> simp_all [mapP]

theorem mapP_kernel {δ δ' κ : Type} {f : δ → δ'} {p : RPrim δ κ} {name : List Char} {c : RCfg δ'} {out : Nat}
    (h : mapP f p = .kernel name c out) : ∃ c', p = .kernel name c' out := by
  cases p with
  | kernel n c' o =>
    simp only [mapP, RPrim.kernel.injEq] at h
    exact ⟨c', by rw [h.1, h.2.2]⟩
  | _ => simp [mapP] at h

theorem insOf_base (promptN : Nat) (cells : List ((Nat × Nat) × Nat)) {b : InKey} (hb : b ≠ .tokenIds) :
    insOf promptN cells (.base b) = inputNode parameterChoice parameterChoice.model.finalNorm b := by
  cases b <;> first | rfl | contradiction

theorem stepInputs_initial (value : TensorValues) {b : InKey} (hb : b ≠ .tokenIds) :
    stepInputs (weights value) 0 initialHandles b = (parameterInput parameterChoice b).map value := by
  have h := initial_input_values value (tokenIds 0) b hb
  cases b <;> first | contradiction | exact h

theorem parameterInput_noncache {b : InKey} {t : Tensor} (h : parameterInput parameterChoice b = some t) :
    isCacheKey b = false := by
  cases hc : isCacheKey b with
  | false => rfl
  | true =>
    obtain ⟨p, i, rfl⟩ := (isCacheKey_iff b).mp hc
    simp only [parameterInput] at h
    obtain ⟨st, -, hs⟩ := Option.bind_eq_some_iff.mp h
    cases st <;> simp [stageParameter] at hs

theorem handlesOf_length : ∀ (ws : List StageWeights) (cs : List (Value × Value)) (hs : List Handles),
    handlesOf ws cs = some hs → hs.length = ws.length
  | [], [], hs, e => by
    simp only [handlesOf, Option.some.injEq] at e
    subst e
    rfl
  | .delta w :: ws, (a, b) :: cs, hs, e => by
    simp only [handlesOf, Option.map_eq_some_iff] at e
    obtain ⟨hs', e', rfl⟩ := e
    simp [handlesOf_length ws cs hs' e']
  | .attention w :: ws, (a, b) :: cs, hs, e => by
    simp only [handlesOf, Option.map_eq_some_iff] at e
    obtain ⟨hs', e', rfl⟩ := e
    simp [handlesOf_length ws cs hs' e']
  | [], _ :: _, _, e => by simp [handlesOf] at e
  | _ :: _, [], _, e => by cases ‹StageWeights› <;> simp [handlesOf] at e

/-! ## A forward's certificate -/

/-- **A first forward's certificate**: the family's graph at the cold layout, as the chain reads it at its rows' variable
`x`, on the template `s` at the forward's return. Generated, kernel-checked. -/
structure FamCert (pk : ProjKind) (mk : MlpKind) (rd : Read) (ss : List StageLayout) where
  n₀ : Nat
  r : PDim → PDim
  s : Ffi.St
  S : SSrv
  B : Box
  fixed : List Int
  cert : List Nat
  kinds : List (Nat × Compiled)
  cells : List ((Nat × Nat) × Nat)
  E : List (RNode PDim SimGraph.PKey)
  Ec : List (RNode PDim SimGraph.PKey)
  tok : Nat
  outs : List (Nat × Nat)
  family : familyGraph (rowTpl refRows pk mk rd).ops id 0 n₀ ss = (E, tok, outs)
  hEc : E.map (Host.Mlx.SimGraph.mapN r) = Ec
  hn₀ : 0 < n₀ ∧ n₀ < 256
  fixedHi : ∀ i ∈ fixed, (131072 : Int) ≤ i ∧ i < 2 ^ 56
  hdown : (List.range s.nnext).all (downB (routeDom 15235 15235 fixed s) s) = true
  hlen : E.length ≤ cert.length
  hm : MatchesSeg .promptIds (kindOf kinds) (famGs s S B fixed) Ec cert 0 Ec.length = true
  inputs : InputsSeg Ec cert (insOf 15235 cells) 0 Ec.length = true
  extra : checkNodesD (extraOkR (famGs s S B fixed) cert r S B fixed s (insOf 15235 cells)) 0 Ec = true
  kindsPresent : ∀ e ∈ kinds, (s.objs.get e.1).isSome = true
  outsLt : ∀ q ∈ outs, q.1 < cert.length ∧ q.2 < cert.length ∧ certAt cert q.1 < s.nnext ∧ certAt cert q.2 < s.nnext
  outs64 : outs.length = 64

/-- The handles' carriers on the template. -/
def FamCert.carriers {pk : ProjKind} {mk : MlpKind} {rd : Read} {ss : List StageLayout} (c : FamCert pk mk rd ss) : List (Option Nat × Option Nat) :=
  c.outs.map fun q => (some (certAt c.cert q.1), some (certAt c.cert q.2))

theorem inputs_at {E : List (RNode PDim SimGraph.PKey)} {cert : List Nat} {ins : SimGraph.PKey → Option Nat}
    (h : InputsSeg E cert ins 0 E.length = true) {k : Nat} {e : RNode PDim SimGraph.PKey} {key : SimGraph.PKey}
    (he : E[k]? = some e) (hp : e.prim = .input key) : ins key = some (certAt cert k) := by
  have hk : k < E.length := (List.getElem?_eq_some_iff.mp he).1
  have := List.all_eq_true.mp h k (List.mem_range.mpr hk)
  rw [he] at this
  simp only [Nat.zero_le, decide_true, hk, Bool.and_self, Bool.not_true, Bool.false_or, inputNodeOkD, hp,
    decide_eq_true_eq] at this
  exact this

section
variable {C : M1Max.Contract} (P : MlxPrefillContract C) (KR : RouteKernelContract C) (env : FfiEval.Env InKey)
  (kind : Nat → Option Compiled)

theorem keyed_of_routeVal (tab : List F64) (y : Ffi.St) (envP : FfiEval.Env SimGraph.PKey) (hw : envP.weights = env.weights)
    (i : Nat) (v : Value) (h : routeVal P KR env kind (fun _ => none) tab y i = some v) :
    evalRR P KR envP kind (GrK tab y) i = some v := by
  rw [evalRR_keyG SimGraph.PKey.base P KR envP env kind (GrR tab y) hw
    (fun j nd hj => ffiGraphR_keyAgree SimGraph.PKey.base envP env _ _ y j nd hj)]
  exact (Host.Mlx.SimGraph.Mach.routeVals_empty P KR env kind tab y i).symm.trans h

/-- **The certificate's embedding** into the route's graph, from the native relation at the forward's return. -/
theorem FamCert.emb {pk : ProjKind} {mk : MlpKind} {rd : Read} {ss : List StageLayout} (c : FamCert pk mk rd ss) {Pm : LoadP} {NB : Nat} {M : Map}
    {m : Nat} {y : Ffi.St} (tab : List F64) (hmr : Host.Ts.Sim.G.MR Pm NB M m c.s y) (hband : Pm.NL = Pm.N0) (hE : (Pm.E : Int) ≤ 131072)
    (ρ : Nat → F64) (ν : Nat → Int)
    (hnum : ∀ i e, nth? c.S.tab i = some e → CSrv.val ⟨tab⟩ (M.nv (.ref i)) = some (e.eval ρ))
    (hB : InBox c.B ν) (hρ : ∀ x l h, c.B.get x = some (l, h) → ρ x = F64.ofInt (ν x)) :
    Embeds (κ := SimGraph.PKey) M.node M.handle (mapG (PDim.eval ν) (famGs c.s c.S c.B c.fixed)) (GrK tab y) := by
  have hfix : ∀ i ∈ c.fixed, M.big i = i := fun i hi =>
    hmr.bigFixHi i (by have := (c.fixedHi i hi).1; omega) (c.fixedHi i hi).2
  have himg : NativeImage M.node (loadImg M) (routeDom 15235 15235 c.fixed c.s) c.s y :=
    nativeImage_of_GMR hmr _
      (fun i _ => by rcases Nat.lt_or_ge i Pm.NL with h | h; exacts [.inl h, .inr (hband ▸ h)])
      (fun _ _ hi hn => exactTplDom_exact (routeDom_exact hi) hn) (down_of_all c.hdown hmr.nlt)
  have h := embeds_of_runR (κ := SimGraph.PKey) c.S c.B SourceKernels.sources c.s y (routeDom 15235 15235 c.fixed c.s) ν ρ
    hB hρ (CSrv.val ⟨tab⟩) M.nv M.big M.arg M.handle M.node (nv_lit M) (fun _ => rfl) hnum
    (fun a => okArg c.fixed a = true) (arg_fixed M c.fixed hfix)
    (fun i nd hi hn => exactTplDom_args (routeDom_exact hi) hn) (fun i nd hi hn => routeDom_arange hi hn)
    (routeKernels_of_GMR hmr _) himg
  have hGr : GrK tab y = ffiGraphR (κ := SimGraph.PKey) (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources y :=
    ffiGraphR_key _ _ _ _
  rw [hGr]
  exact h

/-- **The forward's handles at their carriers**, from the certificate, the native relation at the forward's return, the
prompt's ids and the checkpoint's parameters. -/
theorem FamCert.values {pk : ProjKind} {mk : MlpKind} {rd : Read} {ss : List StageLayout} (c : FamCert pk mk rd ss) {Pm : LoadP} {NB : Nat} {M : Map}
    {m : Nat} {y : Ffi.St} (tab : List F64) (hmr : Host.Ts.Sim.G.MR Pm NB M m c.s y) (hband : Pm.NL = Pm.N0)
    (hE : (Pm.E : Int) ≤ 131072) (ρ : Nat → F64) (ν : Nat → Int) (n : Nat) (π : List Nat)
    (hnum : ∀ i e, nth? c.S.tab i = some e → CSrv.val ⟨tab⟩ (M.nv (.ref i)) = some (e.eval ρ))
    (hB : InBox c.B ν) (hρ : ∀ x l h, c.B.get x = some (l, h) → ρ x = F64.ofInt (ν x)) (hr : ∀ d, (c.r d).eval ν = d.eval (refNu 0 n))
    (hn : 0 < n ∧ n < 256)
    (hk : ∀ c' k, kindOf c.kinds c' = some k → kind (M.handle c') = some k)
    (hip : HostInt32 (concrete (CSrv.val ⟨tab⟩)) y (M.node 15235) ((π.take n).map Int.ofNat) [1, n])
    (hpar : ∀ p ∈ parameterTensors parameterChoice, routeVal P KR env kind (fun _ => none) tab y (M.node p.node) =
      some (firstValues P.toMlxContract KR.toKernelContract env tab p))
    (hlay : chainLayout (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) initialHandles = ss)
    (hsig : List.Forall₂ (SigRelR kvSigP 0 c.n₀ 0 n) ss ss)
    (hs' : List Handles)
    (hv : rowSem P KR env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) π
      (rowTpl refRows pk mk rd) 0 n initialHandles = some hs') :
    CacheValuesV (routeVal P KR env kind (fun _ => none) tab y) (cachesAt M.node c.carriers) hs' := by
  have emb := c.emb tab hmr hband hE ρ ν hnum hB hρ
  have hGr : GrK tab y = ffiGraphR (κ := SimGraph.PKey) (concrete (CSrv.val ⟨tab⟩)) SourceKernels.sources y :=
    ffiGraphR_key _ _ _ _
  have hfe := family_eval (rowFamily refRows pk mk rd) 0 c.n₀ ss (refNu 0 n) 0 n ss hsig
  have hE1 : (familyGraph (rowFamily refRows pk mk rd).ops id 0 c.n₀ ss).1 = c.E := congrArg Prod.fst c.family
  have hE2 : (familyGraph (rowFamily refRows pk mk rd).ops id 0 c.n₀ ss).2.2 = c.outs :=
    congrArg (fun r => r.2.2) c.family
  have hmatch : MatchesED kind (GrK tab y)
      (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu 0 n)) 0 n ss).1 (c.cert.map M.node) = true :=
    cert_route (rowFamily refRows pk mk rd) .promptIds 0 c.n₀ ss ν c.r n hr ss hsig
      (famGs c.s c.S c.B c.fixed) (kindOf c.kinds) c.cert (by rw [hE1]; exact c.hlen)
      (by rw [hE1, c.hEc]; exact c.hm) (GrK tab y) emb kind hk
  -- the graph at the reference's valuation is the chain's reading of `Ec`
  have hEv : c.Ec.map (Host.Mlx.SimGraph.mapN (PDim.eval ν)) =
      (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu 0 n)) 0 n ss).1 := by
    rw [← c.hEc, graph_rows _ ν c.r n hr, ← hE1]
    exact congrArg Prod.fst hfe
  have hEv2 : (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu 0 n)) 0 n ss).2.2 = c.outs := by
    rw [← hE2]
    exact (congrArg (fun r => r.2.2) hfe).symm
  have hEc_len : c.Ec.length = c.E.length := by rw [← c.hEc, List.length_map]
  have hpick : ∀ {k : Nat} {e : RNode Int SimGraph.PKey},
      (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu 0 n)) 0 n ss).1[k]? = some e →
      ∃ e0, c.Ec[k]? = some e0 ∧ Host.Mlx.SimGraph.mapN (PDim.eval ν) e0 = e ∧ k < c.cert.length := by
    intro k e he
    rw [← hEv, List.getElem?_map] at he
    obtain ⟨e0, he0, rfl⟩ := Option.map_eq_some_iff.mp he
    refine ⟨e0, he0, rfl, ?_⟩
    have := (List.getElem?_eq_some_iff.mp he0).1
    have := c.hlen
    omega
  -- the inputs
  have hin : ∀ ids, rowIds π 0 n = some ids → InputsHeldR P KR
      (stepEnv env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) 0 n ids initialHandles) kind
      (GrK tab y) (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu 0 n)) 0 n ss).1
      (c.cert.map M.node) := by
    intro ids hids k e key v he hp hv'
    obtain ⟨e0, he0, rfl, hlt⟩ := hpick he
    have hp0 : e0.prim = .input key := mapP_input hp
    have hins := inputs_at c.inputs he0 hp0
    rw [certAt_map _ _ _ hlt]
    cases key with
    | promptIds =>
      have hc : certAt c.cert k = 15235 := by
        have : some 15235 = some (certAt c.cert k) := hins
        exact (Option.some.inj this).symm
      rw [hc, hGr, hostInt32_eval P KR _ kind _ _ _ _ _ _ hip]
      have hv2 : some ids = some v := hv'
      cases hv2
      simpa [rowIds] using hids
    | base b =>
      have hbn : b ≠ .tokenIds := by
        rintro rfl
        cases hins
      rw [insOf_base _ _ hbn] at hins
      have hv2 : stepInputs (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) 0 initialHandles b = some v := hv'
      rw [stepInputs_initial _ hbn] at hv2
      obtain ⟨t, ht, rfl⟩ := Option.map_eq_some_iff.mp hv2
      have hnode := inputNode_parameter parameterChoice parameterChoice.model.finalNorm b _ hbn (parameterInput_noncache ht) hins
      rw [ht] at hnode
      have hne : t.node = certAt c.cert k := Option.some.inj hnode
      rw [← hne]
      exact keyed_of_routeVal P KR env kind tab y _ rfl _ _ (hpar t (parameterInput_mem _ _ ht))
    | cells p j vals shape =>
      have hok := (Bool.and_eq_true _ _ ▸ checkNodesD_get _ _ 0 c.extra he0 : _ ∧ _).2
      simp only [cellNodeOkR, hp0, cellKeyOkR, hins, Bool.and_eq_true] at hok
      obtain ⟨hD, hok⟩ := hok
      cases hnd : c.s.nodes.get (certAt c.cert k) with
      | none => rw [hnd] at hok; cases hok
      | some nd =>
        rw [hnd] at hok
        obtain ⟨prim, ins, sh, dt⟩ := nd
        cases prim with
        | data b =>
          dsimp only at hok
          cases hxs : cellsNumsL b with
          | none => rw [hxs] at hok; cases hok
          | some xs =>
            rw [hxs] at hok
            simp only [Bool.and_eq_true, decide_eq_true_eq, List.isEmpty_iff] at hok
            obtain ⟨⟨⟨hi, hdt⟩, hds⟩, hsh⟩ := hok
            subst hi hdt
            rw [cellsNumsL_eq b xs hxs] at hnd
            have hcar := cells_carrier (M := P.toMlxContract) (K := KR.toKernelContract) (env := env) (clsOfX c.S c.B) PDim.lit
              (PDim.eval ν) (fun _ => rfl) SourceKernels.sources c.s y (routeDom 15235 15235 c.fixed c.s) (νsOf c.S ρ)
              (CSrv.val ⟨tab⟩) M.nv M.big M.arg M.handle M.node (nv_lit M) (fun _ => rfl)
              (numbers_agree c.S ρ M.nv _ (nv_lit M) (fun _ => rfl) hnum) (clsOfX_sound c.S c.B ν ρ hB hρ)
              (nativeImage_of_GMR hmr _
                (fun i _ => by rcases Nat.lt_or_ge i Pm.NL with h | h; exacts [.inl h, .inr (hband ▸ h)])
                (fun _ _ hi hn => exactTplDom_exact (routeDom_exact hi) hn) (down_of_all c.hdown hmr.nlt))
              _ hD xs sh hnd _ _ hds hsh
            have hm1 : (vals.map c.r).map (PDim.eval ν) = vals.map (PDim.eval (refNu 0 n)) := by
              rw [List.map_map]
              exact List.map_congr_left fun d _ => hr d
            have hm2 : (shape.map c.r).map (PDim.eval ν) = shape.map (PDim.eval (refNu 0 n)) := by
              rw [List.map_map]
              exact List.map_congr_left fun d _ => hr d
            rw [hm1, hm2] at hcar
            have hv2 : cellsValue (vals.map (PDim.eval (refNu 0 n))) (shape.map (PDim.eval (refNu 0 n))) = some v := hv'
            rw [hv2] at hcar
            exact keyed_of_routeVal P KR env kind tab y _ rfl _ _
              (Host.Mlx.SimGraph.Mach.evalR_routeVal P KR env kind (fun _ => none) tab y _ _ hcar)
        | _ => cases hok
    | iota p j count =>
      have hok := (Bool.and_eq_true _ _ ▸ checkNodesD_get _ _ 0 c.extra he0 : _ ∧ _).2
      simp only [cellNodeOkR, hp0, cellKeyOkR, hins] at hok
      cases hrc : c.r count with
      | lit N =>
        rw [hrc] at hok
        simp only [Bool.and_eq_true] at hok
        obtain ⟨hD, hok⟩ := hok
        cases hnd : c.s.nodes.get (certAt c.cert k) with
        | none => rw [hnd] at hok; cases hok
        | some nd =>
          rw [hnd] at hok
          obtain ⟨prim, ins, sh, dt⟩ := nd
          cases prim with
          | data b =>
            dsimp only at hok
            cases hxs : cellsNumsL b with
            | none => rw [hxs] at hok; cases hok
            | some xs =>
              rw [hxs] at hok
              simp only [Bool.and_eq_true, decide_eq_true_eq, List.isEmpty_iff] at hok
              obtain ⟨⟨⟨hi, hdt⟩, hds⟩, hsh⟩ := hok
              subst hi hdt
              rw [cellsNumsL_eq b xs hxs] at hnd
              have hcar := cells_carrier (M := P.toMlxContract) (K := KR.toKernelContract) (env := env) (clsOfX c.S c.B) PDim.lit
                (PDim.eval ν) (fun _ => rfl) SourceKernels.sources c.s y (routeDom 15235 15235 c.fixed c.s) (νsOf c.S ρ)
                (CSrv.val ⟨tab⟩) M.nv M.big M.arg M.handle M.node (nv_lit M) (fun _ => rfl)
                (numbers_agree c.S ρ M.nv _ (nv_lit M) (fun _ => rfl) hnum) (clsOfX_sound c.S c.B ν ρ hB hρ)
                (nativeImage_of_GMR hmr _
                  (fun i _ => by rcases Nat.lt_or_ge i Pm.NL with h | h; exacts [.inl h, .inr (hband ▸ h)])
                  (fun _ _ hi hn => exactTplDom_exact (routeDom_exact hi) hn) (down_of_all c.hdown hmr.nlt))
                _ hD xs sh hnd _ _ hds hsh
              have hN : N = PDim.eval (refNu 0 n) count := by
                have := hr count
                rw [hrc] at this
                exact this
              have e1 : ((List.range N.toNat).map fun (k : Nat) => PDim.lit (Int.ofNat k)).map (PDim.eval ν) = (List.range N.toNat).map Int.ofNat := by
                rw [List.map_map]
                rfl
              have e2 : [PDim.lit N].map (PDim.eval ν) = [N] := rfl
              rw [e1, e2] at hcar
              have hv2 : cellsValue ((List.range (PDim.eval (refNu 0 n) count).toNat).map Int.ofNat) [PDim.eval (refNu 0 n) count] =
                  some v := hv'
              rw [← hN] at hv2
              rw [hv2] at hcar
              exact keyed_of_routeVal P KR env kind tab y _ rfl _ _
                (Host.Mlx.SimGraph.Mach.evalR_routeVal P KR env kind (fun _ => none) tab y _ _ hcar)
          | _ => cases hok
      | _ => rw [hrc] at hok; cases hok
  -- the plain kernels
  have hG : ∀ k e, (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu 0 n)) 0 n ss).1[k]? = some e →
      ∀ nd name cf out, e.prim = .kernel name cf out → GrK tab y (certAt (c.cert.map M.node) k) = some nd → nd.prim = e.prim := by
    intro k e he nd name cf out hp hnd
    obtain ⟨e0, he0, rfl, hlt⟩ := hpick he
    obtain ⟨cf0, hp0⟩ := mapP_kernel hp
    have hok := (Bool.and_eq_true _ _ ▸ checkNodesD_get _ _ 0 c.extra he0 : _ ∧ _).1
    simp only [plainKOk, hp0, Nat.zero_add] at hok
    cases hr : famGs c.s c.S c.B c.fixed (certAt c.cert k) with
    | none => rw [hr] at hok; cases hok
    | some r =>
      rw [hr] at hok
      have hprim : r.prim = .kernel name cf0 out := of_decide_eq_true hok
      have hnode := emb.node (certAt c.cert k) (Host.Mlx.SimGraph.mapN (PDim.eval ν) r) (by simp [mapG, hr])
      rw [certAt_map _ _ _ hlt, hnode] at hnd
      cases hnd
      show renameCls _ (mapP _ r.prim) = mapP _ e0.prim
      rw [hprim, hp0]
      rfl
  -- the outputs
  have hout : (cachesAt M.node c.carriers).map (fun t => (t.first.map Tensor.node, t.second.map Tensor.node)) =
      (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu 0 n)) 0 n ss).2.2.map
        (fun (a, b) => (some (certAt (c.cert.map M.node) a), some (certAt (c.cert.map M.node) b))) := by
    have h := cachesAt_nodes M.node c.carriers
    rw [hEv2]
    refine h.trans ?_
    simp only [FamCert.carriers, List.map_map]
    refine List.map_congr_left fun q hq => ?_
    obtain ⟨h1, h2, -, -⟩ := c.outsLt q hq
    simp only [Function.comp, Option.map_some]
    rw [certAt_map _ _ _ h1, certAt_map _ _ _ h2]
  have hlenO : (familyGraph (rowTpl refRows pk mk rd).ops (PDim.eval (refNu 0 n)) 0 n ss).2.2.length = hs'.length := by
    rw [hEv2, c.outs64]
    unfold rowSem at hv
    cases hids : rowIds π 0 n with
    | none => rw [hids] at hv; cases hv
    | some ids =>
      rw [hids] at hv
      dsimp only [bind, Option.bind] at hv
      cases hr : forwardT (rowTpl refRows pk mk rd) (valueB P KR.toKernelContract
          (stepEnv env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) 0 n ids initialHandles)
          (ksR P KR (stepEnv env.weights (weights (firstValues P.toMlxContract KR.toKernelContract env tab)) 0 n ids initialHandles)))
          (PDim.eval (refNu 0 n)) 0 n
          (chainLayout (stageWeights (weights (firstValues P.toMlxContract KR.toKernelContract env tab))) initialHandles) with
      | none => rw [hr] at hv; cases hv
      | some r =>
        rw [hr] at hv
        exact (handlesOf_length _ _ _ hv).symm
  refine rowStep_of_matches P KR env kind (fun _ => none) tab y _ π pk mk rd 0 n initialHandles hs' hv (c.cert.map M.node)
    (by rw [hlay]; exact hmatch) (fun ids h => by rw [hlay]; exact hin ids h) (by rw [hlay]; exact hG) _ (by rw [hlay]; exact hout)
    (by rw [hlay]; exact hlenO)

end

end Host.Route.PrefGraph
