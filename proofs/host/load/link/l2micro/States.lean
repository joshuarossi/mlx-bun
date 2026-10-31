import host.load.link.States
namespace Host.Load.Link
set_option maxRecDepth 1000000 in
set_option maxHeartbeats 0 in
set_option interpreter.prefer_native true in
link_chain L2Micro : Route.cx, Route.world, [40, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1] fixed_ffi
end Host.Load.Link
