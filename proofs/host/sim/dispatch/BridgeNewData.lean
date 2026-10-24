import host.sim.dispatch.BridgeTyped
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim BufSim

/-! # Bridge B-newdata: `mlx_array_new_data` on the chunk's buffer

`C.mlx_array_new_data(ptr(data), ptr(sb), shape.length, Dtype.int32)` (`packages/mlx/src/array.ts:179-181`)
is one step, `.call symbol this [ptr data, ptr sb, 2, int32]` (`ffiN .symbol`, `Control.lean`):
decode the arguments (the first reads the framed buffer: the target's bytes `bs'`; the template's
buffer is a placeholder, so the patched template `newDataS` supplies bytes `bsT`), call the
native model, record the event, return the handle. The native side is the interface
`DataCallSim` (the native relation must relate a template node with shape `[1, n]` and no
bytes to the target's node holding `bs'`, design §3.6 item 2) under a premise `Pre` on the
template's decoded arguments (for the load relation: `dataOk`, `RefSmall` of the shape's
references, `SBs bsT`), which the template's run discharges. The JavaScript side is
`bridge_newdata`: the frames stay, the event bases restart at the call (the two events differ in
their first argument's bytes), and the target's event is exported: the call received `bs'`. -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- Restart the event bases at the current traces. -/
theorem _root_.Host.Ts.Sim.RelB.setTraceBase (h : RelB F FR W stk M ν K s S t C) (es es' : List Event) :
    RelB F FR W stk M ν ⟨K.fr, es, es', K.D, K.lo, K.hi⟩ (s.setTrace es) S (t.setTrace es') C :=
  { srv := h.srv, heap := h.heap, next := h.next, offset := h.offset, room := h.room, bigFixed := h.bigFixed,
    bigExt := h.bigExt, band := h.band, intr := h.intr, bound := h.bound, inj := h.inj,
    presentBound := h.presentBound, framedPresent := h.framedPresent, ctl := h.ctl, stack := h.stack,
    jobs := h.jobs, stores := h.stores, ffi := h.ffi, trace := ⟨[], rfl, rfl⟩, heapSupp := h.heapSupp,
    ctlSupp := h.ctlSupp, stackSupp := h.stackSupp, jobsSupp := h.jobsSupp, storesSupp := h.storesSupp,
    traceSupp := ⟨[], rfl, fun _ h => nomatch h⟩ }

theorem retVal_map (M : Map) (r : Ret) (hr : ∀ f cs, r ≠ .callback f cs) : M.val (retVal r) = retVal (M.ret r) := by
  cases r with
  | callback f cs => exact absurd rfl (hr f cs)
  | _ => rfl

theorem ret_nocb (M : Map) {ret : Ret} (h : ∀ f cs, ret ≠ .callback f cs) : ∀ f cs, M.ret ret ≠ .callback f cs := by
  cases ret with
  | callback f cs => exact absurd rfl (h f cs)
  | _ => intro f cs he; simp [Map.ret] at he

/-- The continuation of `ffiN .symbol` once the arguments are decoded. -/
def symK (F : Ffi) (x : St F.S) (name rt : Name) : Option (List Arg) → RS F
  | some as => let _ := rt; .bind (F.call x.ffi name as) (ffiDone F x name as)
  | none => .fail ("FFI argument decoding: " ++ String.ofList name)

theorem ffiN_symbol_eq {x : St F.S} {this : Val} {args : List Val} {name rt : Name} {ta : Nat} {tys : List Val}
    {pr : Val} {ps : Props} {pv : List ((Nat × Name) × PropV)} {ex : Bool}
    (h : x.obj? ta = some ⟨.array tys, pr, ps, pv, ex⟩) :
    ffiN F x this args [.str name, .obj ta, .str rt] .symbol =
      Host.Ts.M.bind (decodeArgs F x tys args) (symK F x name rt) := by
  simp only [ffiN, elemsOf, h, M_pure_bind]
  rfl

/-- The continuation of `decodeArgs` after its first argument. -/
def consK (F : Ffi) (x : St F.S) (ts vs : List Val) : Option Arg → Host.Ts.M (Option (List Arg))
  | some a => .bind (decodeArgs F x ts vs) fun r => .pure (r.map (a :: ·))
  | none => .pure none

theorem decodeArgs_cons_eq {x : St F.S} {ty : List Char} {ts : List Val} {v : Val} {vs : List Val} :
    decodeArgs F x (.str ty :: ts) (v :: vs) = Host.Ts.M.bind (decodeArg F x ty v) (consK F x ts vs) := rfl

/-- A native call's completion without writes or `JSCallback`. -/
theorem ffiDone_nocb {x : St F.S} {name : Name} {as : List Arg} {st : F.S} {ret : Ret}
    (h : ∀ f cs, ret ≠ .callback f cs) :
    ffiDone F x name as (some (st, ret, [])) =
      retS F ((x.setFfi st).setTrace (⟨name, as, ret⟩ :: x.trace)) (retVal ret) := by
  cases ret with
  | callback f cs => exact absurd rfl (h f cs)
  | _ => rfl

end

/-- The results of a data call: related native states, the image of the return value, no
buffer writes, no `JSCallback`, and a return supported by `A`. -/
def DataR {F : Ffi} (FR : Map → Nat → F.S → F.S → Prop) (M : Map) (n : Nat) (A : Nat → Prop) :
    Option (F.S × Ret × List (Nat × Nat × List Byte)) → Option (F.S × Ret × List (Nat × Nat × List Byte)) → Prop
  | none, _ => True
  | some (x, ret, ws), some (y, ret', ws') =>
    FR M n x y ∧ ret' = M.ret ret ∧ ws = [] ∧ ws' = [] ∧ (∀ f cs, ret ≠ .callback f cs) ∧ Supp.ret A n ret
  | some _, none => False

/-- The native side of B-newdata (to be supplied by the native relation): calling `name` with
a first argument carrying the template's bytes `bsT` and the target's own bytes `bs'` (the
remaining arguments `asR` images) gives related results, under the premise `Pre ν S x asR` the
template's run discharges (`bridge_newdata`, `hpre`). -/
def DataCallSim (F : Ffi) (FR : Map → Nat → F.S → F.S → Prop) (name : Name) (b : Nat) (bsT bs' : List Byte)
    (A : Nat → Prop) (Pre : (Nat → F64) → SSrv → F.S → List Arg → Prop) : Prop :=
  ∀ M ν S C x y (asR : List Arg), Srv M ν S C → FR M S.tab.length x y → (∀ a ∈ asR, Supp.arg A S.tab.length a) →
    Pre ν S x asR →
    MSim (fun M' S' C' r r' => Grow M ν S C M' S' C' ∧ DataR FR M' S'.tab.length A r r') S C
      (F.call x name (.jsPtr b 0 bsT :: asR)) (F.call y name (.jsPtr (M.a b) 0 bs' :: asR.map M.arg))

/-- The patched template's B-newdata step: its buffer is a placeholder, so the template's call
receives the bytes `bsT` for it; the remaining arguments decode as in `ffiN .symbol`. -/
def newDataS (F : Ffi) (s : St F.S) (name rt : Name) (tys rest : List Val) (b : Nat) (bsT : List Byte) : RS F :=
  Host.Ts.M.bind (Host.Ts.M.bind (decodeArgs F s tys rest) fun r => Host.Ts.M.pure (r.map (Arg.jsPtr b 0 bsT :: ·)))
    (symK F s name rt)

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv} {okCall : F.S → Name → List Arg → Bool} {okBack : F.S → Arg → Bool}

/-- **B-newdata.** A `dlopen` symbol called with a pointer into a buffer-framed placeholder
first: the target's call receives the target's bytes `bs'`, the patched template's call the
bytes `bsT` (`newDataS`); the frames stay, and the event bases restart at the call. -/
theorem bridge_newdata (h : RelB F FR W stk M ν K s S t C) (hFR : FRLaws FR)
    (hF : FfiSim F FR okCall okBack) {fsym ta b : Nat} {this : Val} {rest : List Val} {fo oa : Obj}
    {name rt ty0 : Name} {tys : List Val} {bsT bs' : List Byte} {q : List Val × List Val}
    {Pre : (Nat → F64) → SSrv → F.S → List Arg → Prop}
    (hc : s.ctl = .call (.obj fsym) this (.ptr (.js b) 0 :: rest)) (hfo : s.obj? fsym = some fo)
    (hk : fo.kind = .fn (.native (.ffi .symbol) [.str name, .obj ta, .str rt]))
    (hta : s.obj? ta = some oa) (htk : oa.kind = .array (.str ty0 :: tys)) (hty0 : nameEq ty0 (chars!"ptr") = true)
    (hfr : K.fr ta = none) (hfb : K.fr b = some q) (hwb : W b = some (.buf bs'))
    (hbuf : ∀ v ∈ rest, ArgBufOK F K W s S.tab.length v) (hbool : ∀ ty v, Val.str ty ∈ tys → v ∈ rest → BoolOK K ty v)
    (hpre : ∀ asR S1, interpS (decodeArgs F s tys rest).run S = some (some asR, S1) → Pre ν S1 s.ffi asR)
    (hcall : DataCallSim F FR name b bsT bs' (Present s) Pre) :
    MSim (fun M' S' C' s1 t1 => Grow M ν S C M' S' C' ∧
      RelB F FR W stk M' ν ⟨K.fr, s1.trace, t1.trace, K.D, K.lo, K.hi⟩ s1 S' t1 C' ∧
      ∃ asR ret, t1.trace = ⟨name, .jsPtr (M.a b) 0 bs' :: asR, ret⟩ :: t.trace) S C
      (newDataS F s name rt tys rest b bsT) (step F t) := by
  -- the callee and its signature, unframed
  have hfrS : K.fr fsym = none :=
    h.bi_fr hfo (by rw [hk]; intro es he; cases he) (by rw [hk]; exact fun hw => hw)
  have hto : t.obj? (M.a fsym) = some (M.obj fo) := h.obj? hfo hfrS
  have htk' : (M.obj fo).kind = .fn (.native (.ffi .symbol) (M.vals [.str name, .obj ta, .str rt])) := by
    show M.kind fo.kind = _; rw [hk]; rfl
  have htc : t.ctl = .call (.obj (M.a fsym)) (M.val this) (M.vals (.ptr (.js b) 0 :: rest)) := by
    rw [show t.ctl = _ from h.ctl, hc]; rfl
  have htt : t.obj? (M.a ta) = some (M.obj oa) := h.obj? hta hfr
  have hso : Supp.vals (Present s) S.tab.length (.str ty0 :: tys) := by
    have := (h.obj?_supp hta).1; rw [htk] at this; exact this
  have hsoT : Supp.vals (Present s) S.tab.length tys := fun v hv => hso v (List.mem_cons_of_mem _ hv)
  have hargs := (call_supp h hc).2
  have hrestS : Supp.vals (Present s) S.tab.length rest := fun v hv => hargs v (List.mem_cons_of_mem _ hv)
  -- the target's buffer
  obtain ⟨hb0, hgb⟩ := Present.get (h.framedPresent b q hfb)
  have hwb' := (SlotW.of_wide hfb hwb).1 (h.heap b _ hgb)
  have hbufT : bufBytes F t (M.a b) = some bs' := by
    revert hwb'
    cases hbg : t.heap.get (M.a b) with
    | none => cases hb0 <;> intro hw' <;> exact hw'.elim
    | some x =>
      cases x with
      | cell _ => cases hb0 <;> intro hw' <;> exact hw'.elim
      | obj o' =>
        cases hb0 with
        | cell _ => intro hw'; exact hw'.elim
        | obj o0 =>
          rintro ⟨-, rfl⟩
          unfold bufBytes; rw [obj?_iff.2 hbg]
  -- the target's step, down to the decoding of the remaining arguments
  obtain ⟨kd, pr, ps, pv, ex⟩ := oa
  simp only at htk
  subst htk
  have htA : t.obj? (M.a ta) = some ⟨.array (.str ty0 :: M.vals tys), M.val pr, M.props ps, M.privs pv, ex⟩ := by
    rw [htt]; rfl
  have hdec0' : decodeArg F t ty0 (.ptr (.js (M.a b)) 0) = Host.Ts.M.pure (some (.jsPtr (M.a b) 0 bs')) := by
    simp only [decodeArg, hty0, Bool.true_or, Bool.cond_true, hbufT, Option.map_some, List.drop_zero]
  have e2 : step F t = Host.Ts.M.bind (Host.Ts.M.bind
      (decodeArgs F t (M.vals tys) (M.vals rest)) fun r =>
      Host.Ts.M.pure (r.map (Arg.jsPtr (M.a b) 0 bs' :: ·))) (symK F t name rt) := by
    have hct : step F t = callNative F t (.ffi .symbol) (M.vals [.str name, .obj ta, .str rt]) (M.val this)
        (M.vals (.ptr (.js b) 0 :: rest)) := by
      simp only [step, htc, callStep, hto, htk']
    rw [hct]
    show ffiN F t (M.val this) (.ptr (.js (M.a b)) 0 :: M.vals rest) [.str name, .obj (M.a ta), .str rt] .symbol = _
    rw [ffiN_symbol_eq htA, decodeArgs_cons_eq, hdec0']
    rfl
  rw [e2]
  -- decode the remaining arguments
  show MSim _ S C (Host.Ts.M.bind (decodeArgs F s tys rest) fun r =>
      Host.Ts.M.bind (Host.Ts.M.pure (r.map (Arg.jsPtr b 0 bsT :: ·))) (symK F s name rt))
    (Host.Ts.M.bind (decodeArgs F t (M.vals tys) (M.vals rest)) fun r =>
      Host.Ts.M.bind (Host.Ts.M.pure (r.map (Arg.jsPtr (M.a b) 0 bs' :: ·))) (symK F t name rt))
  refine MSim.bind (MSim.withRun (decodeArgs_sim hFR hF tys rest h hsoT hrestS hbuf hbool)
    (decodeArgs_lawful _ _ _ _) (decodeArgs_lawful _ _ _ _)) ?_
  rintro M1 S1 C1 r r' ⟨⟨rfl, g1, hs1⟩, hrun⟩
  cases r with
  | none => exact MSim.fail _ _
  | some asR =>
    -- the native call
    have h1 := h.grow hFR g1
    have hsuppR : ∀ a ∈ asR, Supp.arg (Present s) S1.tab.length a := hs1 asR rfl
    have hc1 := hcall M1 ν S1 C1 s.ffi t.ffi asR h1.srv h1.ffi hsuppR (hpre asR S1 hrun)
    rw [g1.ext.a] at hc1
    show MSim _ S1 C1 (symK F s name rt (some (.jsPtr b 0 bsT :: asR)))
      (symK F t name rt (some (.jsPtr (M.a b) 0 bs' :: asR.map M1.arg)))
    simp only [symK]
    refine MSim.bind hc1 ?_
    rintro M2 S2 C2 cr cr' ⟨g2, hd⟩
    cases cr with
    | none => exact MSim.fail _ _
    | some p =>
      obtain ⟨x, ret, ws⟩ := p
      cases cr' with
      | none => exact hd.elim
      | some p' =>
        obtain ⟨y, ret', ws'⟩ := p'
        obtain ⟨hxy, rfl, rfl, rfl, hnc, hret⟩ := hd
        rw [ffiDone_nocb hnc, ffiDone_nocb (ret_nocb M2 hnc)]
        have g := g1.trans g2
        have h2 := ((h.grow hFR g).setFfi x y hxy).setTraceBase
          (⟨name, .jsPtr b 0 bsT :: asR, ret⟩ :: s.trace) (⟨name, .jsPtr (M.a b) 0 bs' :: asR.map M1.arg, M2.ret ret⟩ :: t.trace)
        have h3 := h2.ret (retVal ret) (retVal_supp hret)
        rw [retVal_map M2 ret hnc] at h3
        exact MSim.pure ⟨g, h3, _, _, rfl⟩

end
end Host.Ts.Sim.Disp
