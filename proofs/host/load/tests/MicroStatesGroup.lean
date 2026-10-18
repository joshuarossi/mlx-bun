import host.load.Micro
import host.load.Compose

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Tests.MicroStatesGroup
open Host.Ts Host.Load

def source : String := "export let out = 0; let i = 0; while (i < 4) { out += i; i++; }"
source_parse source
source_ast

def world : LSt := ⟨Host.Mlx.Ffi.init [] [] [] [],HostSt.init [] [] [] 0 [] []⟩
def initial : Option (St LSt) := boot world [⟨chars!"main.ts",ast⟩] [] chars!"main.ts"
host_chain G : Host.Load.ffi, initial, (⟨[],[]⟩ : SSrv), [20,20,40]
host_micro_states_group G 0, 3, 7
host_chunk G.micro0 0
host_chunk G.micro0 1
host_chunk G.micro0 2
host_micro_run G 0
host_chunk G.micro1 0
host_chunk G.micro1 1
host_chunk G.micro1 2
host_micro_run G 1
host_chunk G.micro2 0
host_chunk G.micro2 1
host_chunk G.micro2 2
host_chunk G.micro2 3
host_chunk G.micro2 4
host_chunk G.micro2 5
host_micro_run G 2
host_chain_run_staged G

theorem grouped : runS G.F 80 G.s0 G.S0 = some (G.s3,G.S3) := G.run
theorem ordered_join : G.micro0.s3 = G.micro1.s0 ∧ G.micro0.S3 = G.micro1.S0 := ⟨rfl,rfl⟩

/-- error: host_micro_states_group: expected 1 to 8 consecutive chunks and positive width -/
#guard_msgs in
host_micro_states_group G 0, 0, 7

/-- error: host_micro_states_group: selected chunks are outside the original chain -/
#guard_msgs in
host_micro_states_group G 2, 2, 7

/-- error: host_micro_states_group: expected 1 to 8 consecutive chunks and positive width -/
#guard_msgs in
host_micro_states_group G 0, 1, 0

namespace WrongEndpoint
noncomputable def F := G.F
def ks : List Nat := [20]
noncomputable def s0 := G.s0
noncomputable def S0 := G.S0
noncomputable def s1 := G.s2
noncomputable def S1 := G.S2
end WrongEndpoint
host_micro_states_group WrongEndpoint 0, 1, 7
host_chunk WrongEndpoint.micro0 0
host_chunk WrongEndpoint.micro0 1

namespace WrongOrder
noncomputable def F := G.F
def ks : List Nat := [20,20]
noncomputable def s0 := G.s0
noncomputable def S0 := G.S0
noncomputable def s1 := G.s1
noncomputable def S1 := G.S1
noncomputable def s2 := G.s0
noncomputable def S2 := G.S0
end WrongOrder
host_micro_states_group WrongOrder 0, 2, 7
host_chunk WrongOrder.micro0 0
host_chunk WrongOrder.micro0 1
host_chunk WrongOrder.micro0 2
host_micro_run WrongOrder 0
host_chunk WrongOrder.micro1 0
host_chunk WrongOrder.micro1 1

/- Rejected kernel declarations must not remain as placeholder axioms in the
environment audited after this test. Preserve the complete command state. -/
open Lean Elab Command in
run_cmd do
  for chain in ["WrongEndpoint.micro0","WrongOrder.micro1"] do
    let saved : Command.State ← get
    let mut rejected := false
    try
      let stx ← match Parser.runParserCategory (← getEnv) `command s!"host_chunk {chain} 2" with
        | .ok stx => pure stx
        | .error message => throwError "{message}"
      withScope (fun scope => {scope with opts := scope.opts.setBool `Elab.async false}) (elabCommand stx)
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "incorrect grouped endpoint/order was not rejected by the kernel"

namespace TooMany
def ks : List Nat := [1025]
end TooMany
/-- error: host_micro_states_group: at most 1024 small boundaries may be chosen -/
#guard_msgs in
host_micro_states_group TooMany 0, 1, 1

end Host.Load.Tests.MicroStatesGroup
