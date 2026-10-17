import kernels.trellis.DownHostSelection
namespace Inference.Kernels.Trellis.DownBuiltinSource
open Copy.ScalarCopySyntax (Parser accept nameToken)
open DownFoldSyntax
set_option maxRecDepth 10000

-- A native Metal invocation supplies this environment. The parser/evaluator
-- proves which builtin each source variable reads; it does not prove the
-- hardware's builtin values or SIMD width.
abbrev Environment := String → Option Nat

def declarationTokens : Parser (String × String) := fun ts => do
  let ts ←accept "uint" (←accept "const" ts)
  let (target,ts) ←nameToken ts
  let ts ←accept "=" ts
  let (builtin,ts) ←match ts with | name::rest => some (name,rest) | [] => none
  let ts ←accept ";" ts
  pure ((target,builtin),ts)

def laneSource : String := "const uint lane = thread_index_in_simdgroup;"
def simdSource : String := "const uint sg = simdgroup_index_in_threadgroup;"
def groupSource : String := "const uint ty = threadgroup_position_in_grid.y;"

theorem parsed_lane : parse declarationTokens laneSource=some ("lane","thread_index_in_simdgroup") := rfl
theorem parsed_simd : parse declarationTokens simdSource=some ("sg","simdgroup_index_in_threadgroup") := rfl
theorem parsed_group : parse declarationTokens groupSource=some ("ty","threadgroup_position_in_grid.y") := rfl

def invocation (groupY localThread : Nat) : Environment := fun name =>
  if name="thread_index_in_simdgroup" then some (localThread%32)
  else if name="simdgroup_index_in_threadgroup" then some (localThread/32)
  else if name="threadgroup_position_in_grid.y" then some groupY else none

def read (env : Environment) (source target : String) : Option Nat :=
  (parse declarationTokens source).bind (fun code => if code.1=target then env code.2 else none)

def coordinates (env : Environment) : Option (Nat × Nat × Nat) :=
  (read env groupSource "ty").bind (fun ty =>
    (read env simdSource "sg").bind (fun sg =>
      (read env laneSource "lane").map (fun lane => (ty,sg,lane))))

theorem coordinates_selected (groupY localThread : Nat) :
    coordinates (invocation groupY localThread)=some (groupY,localThread/32,localThread%32) := by
  simp only [coordinates,read,parsed_group,parsed_simd,parsed_lane,Option.bind_some]
  simp [invocation]


-- The selected host launch supplies 160 groups and 256 threads/group.
-- This model fixes the native invocation mapping explicitly.
theorem selected_bounds (groupY localThread : Nat) (hg : groupY<160) (ht : localThread<256) :
    groupY<160 ∧ localThread/32<8 ∧ localThread%32<32 := by omega

def dispatch (width : Nat) (env : Environment) : Option (BitVec 32 × BitVec 32 × BitVec 32) :=
  (coordinates env).bind (fun point => DownDispatchSource.dispatch width point.1 point.2.1 point.2.2)

theorem dispatch_selected (width groupY localThread : Nat)
    (valid : width=2 ∨ width=3 ∨ width=4) (hg : groupY<160) (ht : localThread<256) :
    dispatch width (invocation groupY localThread)=
      some (BitVec.ofNat 32 (groupY%32+32*((localThread/32)%4)),
        BitVec.ofNat 32 ((2*(groupY/32)+(localThread/32)/4)*2+(localThread%32)/16),
        BitVec.ofNat 32 ((groupY%32+32*((localThread/32)%4))*136)) := by
  rw [dispatch,coordinates_selected,Option.bind_some]
  exact DownDispatchSource.dispatch_selected width groupY (localThread/32) (localThread%32) valid hg (by omega) (by omega)

end Inference.Kernels.Trellis.DownBuiltinSource
