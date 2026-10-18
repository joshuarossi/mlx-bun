import host.mlx.NativeCachedFrontend

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.CachedCases

host_retained_cached P.F, P.RestStream.micro0.micro23.s82 using P.RestStream.micro0.micro23.S82
  to P.RestStream.micro0.micro23.s83 using P.RestStream.micro0.micro23.S83 as Source2382

/-- error: host_retained_cached: expected source call -/
#guard_msgs in
host_retained_cached P.F, Source2382.output using P.RestStream.micro0.micro23.S83
  to Source2382.output using P.RestStream.micro0.micro23.S83 as RejectReturn

end Host.Load.Run.Full.Ordinary.CachedCases
