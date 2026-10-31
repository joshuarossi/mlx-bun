import host.load.link.l2micro.Same
namespace Host.Load.Link
set_option maxRecDepth 1000000 in
theorem L.l2 : Host.Ts.linkRun L.cx 40 20 L.x2 = some L.x3 := L2Micro.same
end Host.Load.Link
