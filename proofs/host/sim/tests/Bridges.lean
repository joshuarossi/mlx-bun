import host.ts.Harness
import host.sim.dispatch.BridgeNewData
import host.sim.dispatch.BridgeLen

/-! # Tests: symbolic `Number.isSafeInteger`, `setImmediate`, `Number(ptr)`, and the prompt bridges

Kernel-checked runs of the interpreter changes (their agreement with the previous interpreter is
`Sim/InterpAgree.lean`), the interpreter steps each bridge relies on (on small concrete states,
with the template's unpatched step alongside), and the bridge lemmas at a concrete prompt. -/

namespace Host.Ts.Sim.Tests.Bridges
open Host.Ts Host.Ts.Sim Host.Ts.Sim.Disp

/-! ## `Number.isSafeInteger`: literals as before -/

namespace SafeLiteral
def source : String := "const out = [Number.isSafeInteger(5), Number.isSafeInteger(-9007199254740991), Number.isSafeInteger(9007199254740991), Number.isSafeInteger(9007199254740992), Number.isSafeInteger(2.5), Number.isSafeInteger(NaN), Number.isSafeInteger(Infinity), Number.isSafeInteger(-0), Number.isSafeInteger(\"5\"), Number.isSafeInteger()];"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.bool true, .bool true, .bool true, .bool false,
  .bool false, .bool false, .bool false, .bool true, .bool false, .bool false])) = some true
end SafeLiteral

/-! ## `Number.isSafeInteger` of a reference: the three server tests -/

/-- The answers the tests ask for at a safe integer, in order (the oracle shape of
`host/sim/tests/LinGood.lean`, `safeInt`). -/
def safeAnswers (v : SymE) (r : Bool) : List Ans :=
  [⟨.eq, .un .trunc v, v, true⟩, ⟨.le, v, .lit (.fin false 9007199254740991 0), true⟩,
   ⟨.le, .lit (.fin true 9007199254740991 0), v, r⟩]

theorem safe_ref_tests (s : St nullFfi.S) :
    interpS (numN nullFfi s .undef [.num (.ref 0)] .isSafeInteger).run ⟨[.var 1], safeAnswers (.var 1) true⟩ =
      some (s.ret (.bool true), ⟨[.var 1, .un .trunc (.var 1)], []⟩) := rfl

/-- A non-integer stops after the first test. -/
theorem safe_ref_fraction (s : St nullFfi.S) :
    interpS (numN nullFfi s .undef [.num (.ref 0)] .isSafeInteger).run
        ⟨[.var 1], [⟨.eq, .un .trunc (.var 1), .var 1, false⟩]⟩ =
      some (s.ret (.bool false), ⟨[.var 1, .un .trunc (.var 1)], []⟩) := rfl

/-- The tests decide `isSafeInt` on literals (`safeB_lit`), e.g. at `2^53` and `-(2^53-1)`. -/
example : safeB (.lit (F64.ofNat (2 ^ 53))) = Host.Ts.M.pure false := by rw [safeB_lit]; rfl
example : safeB (.lit (F64.neg (F64.ofNat (2 ^ 53 - 1)))) = Host.Ts.M.pure true := by rw [safeB_lit]; rfl

/-! ## `Number(ptr)` and `setImmediate` -/

theorem number_ptr (s : St nullFfi.S) :
    numN nullFfi s .undef [.ptr (.ext 3) 16] .number = retS nullFfi s (.ptr (.ext 3) 16) := rfl

/- A macrotask runs once no microtask is queued, also microtasks queued after it. -/
namespace Immediate
def source : String := "const out = []; setImmediate(() => out.push(3)); Promise.resolve().then(() => { out.push(1); Promise.resolve().then(() => out.push(2)); }); out.push(0);"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 0, .num 1, .num 2, .num 3])) = some true
end Immediate

/- The drain loop's yield (`generation/autoregressive.ts:512`): the awaiting function resumes
after the pending microtasks; two macrotasks run in order, with the first's microtasks between. -/
namespace ImmediateAwait
def source : String := "const out = []; async function f() { out.push(1); await new Promise((r) => setImmediate(r)); out.push(4); } f(); Promise.resolve().then(() => out.push(2)); setImmediate(() => { out.push(5); Promise.resolve().then(() => out.push(6)); }); setImmediate(() => out.push(7)); out.push(3);"
source_parse source
source_ast
kernel_rfl runs : ((snippetJ ast).map fun j => J.beq j (.arr [.num 1, .num 3, .num 2, .num 4, .num 5, .num 6, .num 7])) = some true
end ImmediateAwait

/-! ## The interpreter steps the bridges cover, on small states -/

/-- A state with the given heap entries (`nullFfi`). -/
def st (hp : List (Nat × HObj)) (next : Nat) (c : Ctl) (stk : List Frame) : St Unit :=
  ⟨hp.foldl (fun h p => h.set p.1 p.2) PTrie.nil, next, c, stk, ⟨[], (), [], []⟩⟩

def arr (es : List Val) : HObj := .obj ⟨.array es, .obj aArrayProto, [], [], true⟩
def fnH (n : Native) (data : List Val) : HObj := .obj ⟨.fn (.native n data), .null, [], [], true⟩
def prompt : List Val := [natV 5, natV 6, natV 7, natV 8]

/-- The control after one step. -/
def ctlAfter (t : St Unit) : Option Ctl := (interpC (step nullFfi t).run ⟨[]⟩).map fun p => p.1.ctl

/- B-len: the target's own length; the template's empty prefix gives `0` (hence the patch). -/
kernel_rfl len_target : ctlAfter (st [(50, arr prompt)] 51 (.ret (.obj 50)) [.e (.member kLength false)]) =
  some (.ret (natV 4))
kernel_rfl len_template : ctlAfter (st [(50, arr [])] 51 (.ret (.obj 50)) [.e (.member kLength false)]) =
  some (.ret (natV 0))

/- B-slice: `prompt.slice(1, 3)` on the target; the template's symbolic bounds are stuck. -/
kernel_rfl slice_target : (interpC (step nullFfi (st [(50, arr prompt), (51, fnH (.arr .slice) [])] 52
    (.call (.obj 51) (.obj 50) [natV 1, natV 3]) [])).run ⟨[]⟩).bind (fun p => natsOf p.1 (.obj 52)) = some [6, 7]
kernel_rfl slice_template : (interpS (step nullFfi (st [(50, arr []), (51, fnH (.arr .slice) [])] 52
    (.call (.obj 51) (.obj 50) [.num (.ref 0), .num (.ref 1)]) [])).run ⟨[.var 2, .var 3], []⟩).isSome = false
theorem slice_prompt : sliceL ([5, 6, 7, 8].map natV) (F64.ofNat 1) (F64.ofNat 3) = [6, 7].map natV :=
  sliceL_ofNat (by decide) (by decide) (by decide)

/- B-spread: the first spread accumulates the prompt (reversed), the last allocates
`prompt ++ forwarded`. -/
kernel_rfl spread_open : (interpC (step nullFfi (st [(50, arr [natV 5, natV 6])] 51 (.ret (.obj 50))
    [.l (.spread [] [.spread (.id ['f'])] [])])).run ⟨[]⟩).bind (fun p => match p.1.stack with
      | [.l (.spread acc [] [])] => acc.mapM natOf
      | _ => none) = some [6, 5]
kernel_rfl spread_close : (interpC (step nullFfi (st [(50, arr [natV 9])] 51 (.ret (.obj 50))
    [.l (.spread [natV 6, natV 5] [] [])])).run ⟨[]⟩).bind (fun p => natsOf p.1 (.obj 51)) = some [5, 6, 9]

/-- The `Int32Array` constructor (`typedCtor .i32`, prototype 22) at 51. -/
def i32Ctor : HObj := fnH (.buf .typedCtor) [natV 4, natV 22]

def typedLen (t : St Unit) (a : Nat) : Option Nat :=
  match t.obj? a with
  | some ⟨.typed .i32 _ 0 n, _, _, _, _⟩ => some n
  | _ => none

/- B-typed: the target's typed array has the chunk's length over 8 bytes; the template's has length 0. -/
kernel_rfl typed_target : (interpC (step nullFfi (st [(50, arr [natV 6, natV 7]), (51, i32Ctor)] 52
    (.construct (.obj 51) [.obj 50] (.obj 51)) [])).run ⟨[]⟩).map (fun p => (typedLen p.1 53, byteLen nullFfi p.1 52)) =
  some (some 2, 8)
kernel_rfl typed_template : (interpC (step nullFfi (st [(50, arr []), (51, i32Ctor)] 52
    (.construct (.obj 51) [.obj 50] (.obj 51)) [])).run ⟨[]⟩).map (fun p => (typedLen p.1 53, byteLen nullFfi p.1 52)) =
  some (some 0, 0)

/-- B-ptr: `ptr(view)` into the target's buffer; the template's empty view throws. -/
def viewHeap (n : Nat) : List (Nat × HObj) :=
  [(52, .obj ⟨.buf (cellBytes .i32 ((List.replicate n (F64.ofNat 6)).map i32Cell)), .obj aArrayBufferProto, [], [], true⟩),
   (53, .obj ⟨.typed .i32 52 0 n, .obj 22, [], [], true⟩), (54, fnH (.ffi .ptr) [])]
kernel_rfl ptr_target : ctlAfter (st (viewHeap 2) 55 (.call (.obj 54) .undef [.obj 53]) []) = some (.ret (.ptr (.js 52) 0))
kernel_rfl ptr_template : (ctlAfter (st (viewHeap 0) 55 (.call (.obj 54) .undef [.obj 53]) [])).map
  (fun | .abr (.throw _) => true | _ => false) = some true

/-- B-newdata: a native model recording its calls; the call receives the buffer's bytes. -/
def recFfi : Ffi :=
  ⟨List (List Char × List Arg), fun x name as => .pure (some ((name, as) :: x, .big 7, [])),
    fun _ _ _ _ => none, fun _ => 0, fun _ _ => .pure none⟩

def dataSt : St recFfi.S :=
  ⟨((viewHeap 2).foldl (fun h p => h.set p.1 p.2) PTrie.nil).set 55 (arr [.str ['p', 't', 'r'], .str ['i', '3', '2']])
    |>.set 56 (fnH (.ffi .symbol) [.str (chars!"mlx_array_new_data"), .obj 55, .str ['p', 't', 'r']]),
   57, .call (.obj 56) .undef [.ptr (.js 52) 0, natV 2], [], ⟨[], [], [], []⟩⟩

def firstArg (t : St recFfi.S) : Option (Nat × Nat) :=
  match t.trace with
  | ⟨_, .jsPtr b off bs :: _, .big 7⟩ :: _ => some (b, off + len bs)
  | _ => none

kernel_rfl newdata_target : (interpC (step recFfi dataSt).run ⟨[]⟩).map (fun p => (firstArg p.1, p.1.ffi.length)) =
  some (some (52, 8), 1)

/-! ## The bridges at a concrete prompt -/

section
variable {F : Ffi} {FR : Map → Nat → F.S → F.S → Prop} {M : Map} {ν : Nat → F64} {K : Ctx}
  {s t : St F.S} {S : SSrv} {C : CSrv}

/-- B-len on the prompt `[5, 6, 7, 8]` (template prefix `[]`): the target returns `4`. -/
theorem len_prompt (h : Rel F FR M ν K s S t C) (hFR : FRLaws FR) {a : Nat} {fs : List Frame} {o : Obj}
    (hc : s.ctl = .ret (.obj a)) (hst : s.stack = .e (.member kLength false) :: fs)
    (hfr : K.fr a = some ([], [5, 6, 7, 8].map natV)) (ho : s.obj? a = some o) (hk : o.kind = .array [])
    (e : SymE) (he : e.eval ν = F64.ofNat 4) :
    interpC (step F t).run C = some ({ t with stack := fs.map M.frame ++ [] }.ret (natV 4), C) :=
  (bridge_len h hFR (xs := []) hc hst hfr ho hk e he).1

/-- B-slice's frame is B-typed's precondition: the chunk's target prefix is the literals of
`π[o, e)`. -/
theorem slice_typed_pre {π : List Nat} {o e : Nat} (hoe : o ≤ e) (he : e ≤ π.length) (h53 : π.length < 2 ^ 53) :
    sliceL (π.map natV) (F64.ofNat o) (F64.ofNat e) = (((π.drop o).take (e - o)).map F64.ofNat).map litV := by
  rw [sliceL_ofNat hoe he h53, natV_map_litV]

/-- The target bytes B-newdata exports are the `int32` cells of the tokens themselves. -/
theorem newdata_bytes {ks : List Nat} (hk : ∀ k ∈ ks, k < 2 ^ 31) :
    cellBytes .i32 ((ks.map F64.ofNat).map i32Cell) = cellBytes .i32 (ks.map fun k => .num (.lit (F64.ofNat k))) := by
  congr 1
  simp only [List.map_map]
  exact List.map_congr_left fun k hm => i32Cell_ofNat (hk k hm)

end

end Host.Ts.Sim.Tests.Bridges
