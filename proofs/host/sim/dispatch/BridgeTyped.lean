import host.sim.dispatch.BridgeSpread
import host.sim.dispatch.BridgeSlice
namespace Host.Ts.Sim.Disp
open Host.Ts Host.Ts.Sim

/-! # Bridges B-typed and B-ptr: the chunk's `Int32Array` and its pointer

`ops.fromInt32(chunk, [1, chunk.length])` (`generation/prefill.ts:24`) runs
`MlxArray.fromInt32(new Int32Array(data), shape)` (`packages/mlx/src/ops.ts:731-733`), whose body
(`packages/mlx/src/array.ts:177-182`) is `const sb = shapeBuf(shape)` (`array.ts:21-23`:
`new Int32Array(shape)`, a two-element array with a symbolic cell, accepted) and
`new MlxArray(C.mlx_array_new_data(ptr(data), ptr(sb), shape.length, Dtype.int32))`.

* **B-typed** is the step `.construct Int32Array [.obj chunk]` (`constructNative` →
  `bufN .typedCtor` → `typedCtor`, `Builtins.lean`) on the framed chunk (template `[]`, target
  `ys`): both sides allocate a buffer and an `Int32Array` (`newTyped`). The template is patched
  to allocate two ordinary placeholders instead (`typedSP`), and the two new addresses get a
  buffer frame (target bytes `cellBytes .i32`) and a typed-array frame (target length `|ys|`).
* **B-ptr** is the step `.call ptr undefined [.obj data]` (`ffiN .ptr`, `Control.lean`): the
  template's placeholder is no view, so the template is patched to return the pointer
  `ptr (.js buffer) offset`, the image of the target's.

The steps between them (the rest of `fromInt32`, `shapeBuf`) run with these frames live. -/

theorem M_pure_bind {α β : Type} (a : α) (f : α → Host.Ts.M β) :
    Host.Ts.M.bind (Host.Ts.M.pure a) f = f a := rfl

/-- A number literal. -/
def litV (y : F64) : Val := .num (.lit y)

/-- The cell `Int32Array` stores for a literal (`numCell .i32`). -/
def i32Cell (y : F64) : Cell := .num (.lit (F64.un .int32 y))

theorem cellsOf_lits : ∀ ys : List F64, cellsOf .i32 (ys.map litV) = Host.Ts.M.pure (some (ys.map i32Cell))
  | [] => rfl
  | y :: ys => by
    show Host.Ts.M.bind (toCell .i32 (litV y)) (fun
      | some c => Host.Ts.M.bind (cellsOf .i32 (ys.map litV)) fun r => Host.Ts.M.pure (r.map (c :: ·))
      | none => Host.Ts.M.pure none) = _
    rw [cellsOf_lits ys]
    rfl

/-- A natural number is the literal of its binary64 value. -/
theorem natV_litV (n : Nat) : natV n = litV (F64.ofNat n) := rfl

theorem natV_map_litV (ks : List Nat) : ks.map natV = (ks.map F64.ofNat).map litV := by
  simp [List.map_map, Function.comp_def, natV_litV]

/-- A token below `2 ^ 31` is stored as itself: the target's cells are the tokens. -/
theorem i32Cell_ofNat {k : Nat} (h : k < 2 ^ 31) : i32Cell (F64.ofNat k) = .num (.lit (F64.ofNat k)) := by
  have ht : F64.truncInt (F64.ofNat k) = some (k : Int) := truncInt_ofNat (by omega)
  have hu : F64.toUint32 (F64.ofNat k) = k := by
    simp only [F64.toUint32, ht, F64.modNat]
    rw [Int.emod_eq_of_lt (by omega) (by omega)]
    rfl
  have hi : F64.toInt32 (F64.ofNat k) = (k : Int) := by
    simp only [F64.toInt32, hu]
    rw [show Nat.blt k (2 ^ 31) = true from Nat.blt_eq.mpr h, Bool.cond_true]
  show Cell.num (.lit (F64.ofInt (F64.toInt32 (F64.ofNat k)))) = _
  rw [hi]
  rfl

/-- The template after `new Int32Array(chunk)` over its empty chunk. -/
def typedS (F : Ffi) (s : St F.S) (proto : Nat) : St F.S :=
  (newTyped F s .i32 proto [] 0).2.ret (.obj (newTyped F s .i32 proto [] 0).1)

/-- The patched template: ordinary placeholders for the buffer (at `s.next`) and the typed array
(at `s.next + 1`), whose target images the frames `typedWF` give. -/
def typedSP (F : Ffi) (s : St F.S) (proto : Nat) : St F.S :=
  ((s.allocObj .ordinary (.obj aArrayBufferProto) []).2.allocObj .ordinary (.obj proto) []).2.ret
    (.obj (s.next + 1))

/-- The target after `new Int32Array(chunk)` over `ys`. -/
def typedT (F : Ffi) (t : St F.S) (proto : Nat) (ys : List F64) : St F.S :=
  (newTyped F t .i32 proto (cellBytes .i32 (ys.map i32Cell)) ys.length).2.ret
    (.obj (newTyped F t .i32 proto (cellBytes .i32 (ys.map i32Cell)) ys.length).1)

/-- The frames B-typed adds: the buffer at `a` (target bytes the cells of `ys`) and the typed
array at `a + 1` (over the buffer at `a`, target length `|ys|`). -/
def typedWF (W : Nat → Option WFrame) (a : Nat) (ys : List F64) : Nat → Option WFrame :=
  wAt (wAt W a (.buf (cellBytes .i32 (ys.map i32Cell)))) (a + 1) (.typed .i32 a 0 ys.length)

/-- The context B-typed leaves: both new addresses framed. -/
def typedK (K : Ctx) (a : Nat) : Ctx :=
  Ctx.frameAt (Ctx.frameAt K a ([], [])) (a + 1) ([], [])

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {W : Nat → Option WFrame} {stk : List Frame} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- **B-typed.** `new Int32Array(chunk)` over a framed empty chunk whose target holds the
literals `ys`: the template's own step allocates an empty buffer and view (`typedS`); the
patched template `typedSP` (ordinary placeholders at the two new addresses) is related to the
target under the frames `typedWF` and the context `typedK`. -/
theorem bridge_typed (h : RelB F FR W stk M ν K s S t C) {fa ch proto : Nat} {args : List Val} {nt : Val}
    {fo oc : Obj} {cF pF : F64} {ys : List F64}
    (hc : s.ctl = .construct (.obj fa) args nt) (hfo : s.obj? fa = some fo)
    (hk : fo.kind = .fn (.native (.buf .typedCtor) [.num (.lit cF), .num (.lit pF)]))
    (hcode : F64.toIndex? cF = some 4) (hpr : F64.toIndex? pF = some proto) (hpI : proto < aFirst)
    (harg : arg args 0 = .obj ch) (hfr : K.fr ch = some ([], ys.map litV)) (hch : s.obj? ch = some oc)
    (hkc : oc.kind = .array []) (hn : s.next + margin < Sim.bound) (hpB : Present s aArrayBufferProto)
    (hpP : Present s proto) :
    step F s = Host.Ts.M.pure (typedS F s proto) ∧
      interpC (step F t).run C = some (typedT F t proto ys, C) ∧
      RelB F FR (typedWF W s.next ys) stk M ν (typedK K s.next) (typedSP F s proto) S (typedT F t proto ys) C := by
  have hI := h.intr
  have hIB : M.a aArrayBufferProto = aArrayBufferProto := hI _ (by decide)
  have hIP : M.a proto = proto := hI _ hpI
  have hwch : W ch = none := by
    cases hw : W ch with
    | none => rfl
    | some w =>
      obtain ⟨_, _, hwk, _⟩ := h.wide_obj (obj?_iff.1 hch) hfr hw
      rw [hkc] at hwk
      exact hwk.elim
  obtain ⟨o', ho', xs, hk', rfl⟩ := h.obj?_framed hch hfr hwch
  have hxs : xs = [] := by
    rw [hkc] at hk'
    injection hk' with hk'
    exact (List.append_eq_nil_iff.1 hk'.symm).2
  subst hxs
  obtain ⟨kd, pr, ps, pv, ex⟩ := oc
  simp only at hkc
  subst hkc
  -- the template's step
  have e1 : step F s = Host.Ts.M.pure (typedS F s proto) := by
    rw [BufSim.step_construct_native hc hfo hk]
    simp only [constructNative, bufN, hcode, hpr, eltOfCode, bufN.typedCtor, harg, hch, elemsOf]
    rfl
  -- the target's step
  have hto : t.obj? (M.a ch) = some ⟨.array (ys.map litV), M.val pr, M.props ps, M.privs pv, ex⟩ := by
    rw [ho']; simp [Map.obj, Map.kind, Map.vals, Map.privs]
  have e2 : step F t = Host.Ts.M.pure (typedT F t proto ys) := by
    rw [BufSim.step_construct_native_t h hc hfo hk]
    have hd : M.vals [Val.num (.lit cF), .num (.lit pF)] = [.num (.lit cF), .num (.lit pF)] := rfl
    have ha : arg (M.vals args) 0 = .obj (M.a ch) := by rw [BufSim.arg_vals, harg]; rfl
    simp only [hd, constructNative, bufN, hcode, hpr, eltOfCode, bufN.typedCtor, ha, hto, elemsOf, M_pure_bind,
      cellsOf_lits]
    rw [show len (ys.map i32Cell) = ys.length by rw [bi_len, List.length_map]]
    rfl
  refine ⟨e1, by rw [e2]; rfl, ?_⟩
  -- the two placeholders and their frames
  have hn' : s.next < Sim.bound := Nat.lt_of_le_of_lt (Nat.le_add_right _ _) hn
  have hs64 : s.next < 2 ^ 64 := by have : Sim.bound = 2 ^ 61 := rfl; omega
  have hat0 : M.a s.next = t.next := by simpa using h.next 0
  have hat1 : M.a (s.next + 1) = t.next + 1 := h.next 1
  have hmg : 2 ≤ margin := by decide
  have hn1 : s.next + 1 < Sim.bound := by omega
  have hs1_64 : s.next + 1 < 2 ^ 64 := by have : Sim.bound = 2 ^ 61 := rfl; omega
  obtain ⟨-, r1⟩ := RelB.allocWide h ⟨.ordinary, .obj aArrayBufferProto, [], [], true⟩
    ⟨.buf (cellBytes .i32 (ys.map i32Cell)), .obj aArrayBufferProto, [], [], true⟩
    (.buf (cellBytes .i32 (ys.map i32Cell))) ([], []) hn'
    ⟨trivial, Present.alloc _ hs64 hpB, fun _ hx => by simp at hx, fun _ hx => by simp at hx⟩
    ⟨rfl, by simp [Map.obj, Map.val, Map.kind, Map.props, Map.privs, hIB]⟩
  have hP1 : ∀ x, Present s x →
      Present (s.alloc (.obj ⟨.ordinary, .obj aArrayBufferProto, [], [], true⟩)).2 x :=
    fun x hx => Present.alloc _ hs64 hx
  obtain ⟨-, r2⟩ := RelB.allocWide r1 ⟨.ordinary, .obj proto, [], [], true⟩
    ⟨.typed .i32 t.next 0 ys.length, .obj proto, [], [], true⟩ (.typed .i32 s.next 0 ys.length) ([], []) hn1
    ⟨trivial, Present.alloc _ hs1_64 (hP1 _ hpP), fun _ hx => by simp at hx, fun _ hx => by simp at hx⟩
    ⟨rfl, by simp [Map.obj, Map.val, Map.kind, Map.props, Map.privs, hIP, hat0]⟩
  have hv : Supp.val (Present ((s.alloc (.obj ⟨.ordinary, .obj aArrayBufferProto, [], [], true⟩)).2.alloc
      (.obj ⟨.ordinary, .obj proto, [], [], true⟩)).2) S.tab.length (.obj (s.next + 1)) :=
    Present.alloc_next (s.alloc (.obj ⟨.ordinary, .obj aArrayBufferProto, [], [], true⟩)).2 _ hs1_64
  have r3 := r2.ret (.obj (s.next + 1)) hv
  simp only [Map.val, hat1] at r3
  exact r3

/-- **B-ptr.** `ptr(view)` of a placeholder under a typed-array frame (target length `n' ≠ 0`)
over a buffer-framed placeholder: the target returns the pointer into its buffer at the view's
offset; the template, patched to return the source pointer, stays related. -/
theorem bridge_ptr (h : RelB F FR W stk M ν K s S t C) {fp ta b off n' : Nat} {k : EltK}
    {this : Val} {args : List Val} {fo o : Obj} {data : List Val} {bs' : List Byte}
    {p q : List Val × List Val}
    (hc : s.ctl = .call (.obj fp) this args) (hfo : s.obj? fp = some fo)
    (hk : fo.kind = .fn (.native (.ffi .ptr) data))
    (harg0 : arg args 0 = .obj ta) (harg1 : arg args 1 = .undef)
    (hfta : K.fr ta = some p) (hwta : W ta = some (.typed k b off n')) (hn0 : n' ≠ 0)
    (hts : s.obj? ta = some o) (hfb : K.fr b = some q) (hwb : W b = some (.buf bs')) :
    interpC (step F t).run C = some (t.ret (.ptr (.js (M.a b)) off), C) ∧
      RelB F FR W stk M ν K (s.ret (.ptr (.js b) off)) S (t.ret (.ptr (.js (M.a b)) off)) C := by
  have hfr : K.fr fp = none :=
    h.bi_fr hfo (by rw [hk]; intro es he; cases he) (by rw [hk]; exact fun hw => hw)
  have hto : t.obj? (M.a fp) = some (M.obj fo) := h.obj? hfo hfr
  have htk : (M.obj fo).kind = .fn (.native (.ffi .ptr) (M.vals data)) := by
    show M.kind fo.kind = _; rw [hk]; rfl
  have htc : t.ctl = .call (.obj (M.a fp)) (M.val this) (M.vals args) := by
    rw [show t.ctl = _ from h.ctl, hc]; rfl
  -- the target's view and buffer
  have hwt := (SlotW.of_wide hfta hwta).1 (h.heap ta _ (obj?_iff.1 hts))
  have hview : t.obj? (M.a ta) = some { M.obj o with kind := .typed k (M.a b) off n' } := by
    revert hwt
    cases htg : t.heap.get (M.a ta) with
    | none => intro hw'; exact hw'.elim
    | some x =>
      cases x with
      | cell _ => intro hw'; exact hw'.elim
      | obj o' =>
        rintro ⟨-, rfl⟩
        exact obj?_iff.2 htg
  obtain ⟨hb0, hgb⟩ := Present.get (h.framedPresent b q hfb)
  have hwb' := (SlotW.of_wide hfb hwb).1 (h.heap b _ hgb)
  have hbuf : ∃ o', t.obj? (M.a b) = some o' ∧ o'.kind = .buf bs' := by
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
          exact ⟨_, obj?_iff.2 hbg, rfl⟩
  obtain ⟨ob, hob, hobk⟩ := hbuf
  obtain ⟨kb, prb, psb, pvb, exb⟩ := ob
  simp only at hobk
  subst hobk
  have hstep : step F t = Host.Ts.M.pure (t.ret (.ptr (.js (M.a b)) off)) := by
    have ha0 : arg (M.vals args) 0 = .obj (M.a ta) := by rw [BufSim.arg_vals, harg0]; rfl
    have ha1 : arg (M.vals args) 1 = .undef := by rw [BufSim.arg_vals, harg1]; rfl
    have hz : Nat.beq n' 0 = false := by
      cases hz' : Nat.beq n' 0
      · rfl
      · exact absurd (Nat.eq_of_beq_eq_true hz') hn0
    simp only [step, htc, callStep, hto, htk, callNative, ffiN, ha0, ha1, offsetArg, hview, hz, hob,
      M_pure_bind, Bool.cond_false]
    rfl
  exact ⟨by rw [hstep]; rfl, h.ret (.ptr (.js b) off) (Present.of_get hgb)⟩

end
end Host.Ts.Sim.Disp
