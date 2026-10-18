import host.mlx.NativeEvalRetained

set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.EvalRetainedTest
open Host.Ts Host.Ts.Owned Host.Mlx.Ffi

theorem original_call_no_write (kind : EvalHost.Mode) (s : Host.Mlx.Ffi.St) (handle : Nat)
    (current : kind.Input s handle) :
    Host.Mlx.Ffi.call s kind.name [.big (Int.ofNat handle)] = ok s status0 := kind.call s handle current

theorem original_host_no_write (kind : EvalHost.Mode) (s : LSt) (handle : Nat)
    (current : kind.Input s.mlx handle) :
    Host.Load.call s kind.name [.big (Int.ofNat handle)] = M.pure (some (s,status0,[])) := kind.load_call s handle current

theorem distinct_input_kinds (s : Host.Mlx.Ffi.St) (handle : Nat) :
    EvalHost.Mode.arrayEval.Input s handle = (∃ node, s.node? handle = some node) ∧
    EvalHost.Mode.asyncVector.Input s handle = (∃ nodes, s.obj? handle = some (.vec nodes)) := ⟨rfl,rfl⟩
end Host.Load.Run.Full.Ordinary.EvalRetainedTest
