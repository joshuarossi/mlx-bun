import host.load.boundary.SeekStates
namespace Host.Load.Run.Full
open Host.Ts
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

host_chunk BoundarySeek.micro0 0
host_chunk BoundarySeek.micro0 1
host_chunk BoundarySeek.micro0 2

namespace BoundarySeek
theorem first_two : runS F 2000 micro0.s0 micro0.S0 = some (micro0.s2,micro0.S2) :=
  runS_trans F (m := 1000) (n := 1000) micro0.c0 micro0.c1

theorem seek_run : runS F 2056 micro0.s0 micro0.S0 = some (micro0.s3,micro0.S3) :=
  runS_trans F (m := 2000) (n := 56) first_two micro0.c2

theorem source_template : micro0.s3 = Growth64.template := rfl
theorem same_template : Growth64.template = Fill64.template := rfl

/-- The unmodified method entry is reached from the authoritative source
state. Future cache-position specializations retain separate reachability
and incoming-content obligations. -/
theorem template_reached :
    runS Host.Load.ffi 2056 P.s3273 P.S3273 = some (Growth64.template,micro0.S3) := by
  exact seek_run.trans (congrArg (fun s => some (s,micro0.S3)) source_template)

end BoundarySeek
end Host.Load.Run.Full
