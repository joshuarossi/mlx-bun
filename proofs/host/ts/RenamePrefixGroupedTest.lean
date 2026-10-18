import host.ts.RenamePrefixTest
namespace Host.Ts.PrefixFrameTest.Grouped
noncomputable def F := P.F
def ks := P.ks
noncomputable def s0 := P.s0
noncomputable def s1 := P.s1
noncomputable def s2 := P.s2
noncomputable def s3 := P.s3
noncomputable def S0 := P.S0
noncomputable def S1 := P.S1
noncomputable def S2 := P.S2
noncomputable def S3 := P.S3
end Host.Ts.PrefixFrameTest.Grouped
namespace Host.Ts.PrefixFrameTest
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
host_read_tail Grouped 0, 0 keep 1
host_prefix_frames Grouped 0, 0 arrays initialPair.1
host_read_tail Grouped 1, 1 keep 0
host_prefix_frames Grouped 1, 1 arrays initialPair.1
host_read_tail Grouped 2, 3 keep 0
host_prefix_frames Grouped 2, 3 arrays initialPair.1
host_chunk_prefix_frames Grouped 0
host_chunk_prefix_frames Grouped 1
host_chunk_prefix_frames Grouped 2
host_chain_prefix_frames Grouped 0, 3

/-- error: host_read_tail: the shared unread suffix changed -/
#guard_msgs in
host_read_tail Grouped 0, 0 keep 0

/-- error: host_prefix_frames: the shared framed addresses changed -/
#guard_msgs in
host_prefix_frames Grouped 0, 0 arrays [0]

theorem grouped_suffix (fw : List Val) (tail : List NumV) :
    (arrayOf Host.Mlx.Ffi.ffi (Grouped.pfa3 fw tail) Grouped.prefixAddresses[0]!).map Prod.snd =
      some (fw ++ [.num (.ref 0)]) ∧ (Grouped.pfa3 fw tail).ffi.tokens = tail := by exact ⟨rfl,rfl⟩
end Host.Ts.PrefixFrameTest
