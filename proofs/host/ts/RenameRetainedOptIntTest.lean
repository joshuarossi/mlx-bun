import host.ts.RenameRetainedOptIntFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Ts.Owned.Annotated.OptIntTest
open Parametric

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,1000,.ret .undef,[.e (.binR .add (.big 7))],⟨[],(),[],[]⟩⟩
noncomputable def function : Obj := ⟨.fn (.closure optIntFunction [] false .undef),.null,[],[],true⟩
def bigintFunction : Obj := ⟨.fn (.native (.num .bigint) []),.null,[],[],true⟩
def global : Obj := ⟨.ordinary,.null,[(.str chars!"BigInt",.data (.obj 60) true true)],[],true⟩
noncomputable def input (value : Val) : St Unit :=
  (((base.setObj 50 function).setObj 60 bigintFunction).setObj aGlobal global).go (.call (.obj 50) (.obj 71) [value])
noncomputable def numeric (n : Nat) : St Unit := input (.num (.lit (F64.ofNat n)))
noncomputable def output (n : Nat) : St Unit := optIntCallResult (numeric n) [] (.obj 71) n

host_retained_optInt ffi, numeric 64 using server to output 64 using server as SixtyFour
host_retained_optInt ffi, numeric 4 using server to output 4 using server as Four
host_retained_optInt ffi, numeric 0 using server to output 0 using server as PresentZero
host_retained_optInt ffi, numeric 4294967295 using server to output 4294967295 using server as MaxUint32

theorem present_zero_has_flag : (output 0).ctl = .ret (.big 4294967296) := by host_kernel_rfl
theorem upper_bound_has_flag : (output 4294967295).ctl = .ret (.big 8589934591) := by host_kernel_rfl
theorem preserves_callers : (output 64).stack = base.stack := rfl
theorem allocates_only_receiver_and_parameter : (output 64).next = base.next+2 := rfl

/-- The null path has no global object or BigInt builtin in its heap. -/
noncomputable def nullInput : St Unit := (base.setObj 50 function).go (.call (.obj 50) .undef [.null])
noncomputable def nullOutput : St Unit := optIntNullCallResult nullInput [] .undef
host_retained_optInt ffi, nullInput using server to nullOutput using server as Absent

theorem null_is_absent : nullOutput.ctl = .ret (.big 0) := rfl
theorem null_never_needs_bigint : nullInput.heap.get aGlobal = none := by host_kernel_rfl

noncomputable def referenceInput : St Unit := input (.num (.ref 0))
/-- error: host_retained_optInt: expected literal numeric argument -/
#guard_msgs (error, substring := true) in
host_retained_optInt ffi, referenceInput using server to output 64 using server as RejectReference

/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ←Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_optInt ffi, numeric 64 using server to numeric 64 using server as RejectEndpoint"
  finally Lean.setEnv saved

noncomputable def missingFlag : St Unit := (output 64).ret (.big 64)
/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ←Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_optInt ffi, numeric 64 using server to missingFlag using server as RejectMissingFlag"
  finally Lean.setEnv saved

/-- Same name and parameter list, with a different body. -/
def mutatedFunction : Func := .mk (some chars!"optInt") [.id chars!"value"] none (.block []) false false []
noncomputable def mutatedInput : St Unit := (numeric 64).setObj 50
  ⟨.fn (.closure mutatedFunction [] false .undef),.null,[],[],true⟩
/-- error: (kernel) declaration type mismatch -/
#guard_msgs (error, substring := true) in
run_cmd do
  let saved ←Lean.getEnv
  try
    Host.Ts.Owned.Parametric.Driver.emit "host_retained_optInt ffi, mutatedInput using server to output 64 using server as RejectMutatedBody"
  finally Lean.setEnv saved

run_cmd Lean.Elab.Command.liftTermElabM do
  let info ←Lean.getConstInfo ``SixtyFour.retained_transport
  Lean.Meta.forallTelescopeReducing info.type fun binders _ => do
    let mut names : Array Lean.Name := #[]
    for binder in binders do names := names.push (←Lean.Meta.getFVarLocalDecl binder).userName
    for forbidden in [`targetValue,`targetParameter,`targetGlobal,`targetBigint,`targetRun,`postInventory] do
      if names.contains forbidden then throwError "optInt: future target premise remained"
end Host.Ts.Owned.Annotated.OptIntTest
