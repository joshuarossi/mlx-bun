import host.sim.template.a4pre_d1_post.Origin
-- revision: literal chunk length
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Tpl
set_option interpreter.prefer_native true in
tpl_chain D1PostSplit from D1Post.s3, D1Post.S3 : "{\"stop\":\"steps:4981\",\"stuckStop\":false,\"cap\":4981,\"stages\":[],\"compact\":false,\"isolate\":false,\"frames\":[2665,2673479,2673484,2673485],\"wide\":[[4910,\".memo []\"]],\"lens\":[[2665,9],[2673479,9]],\"baseVals\":[[9,1]],\"vars\":[[0,\"T\"],[9,\"L\"]],\"bridges\":[],\"accept\":\"jsjxs\",\"D0\":4096,\"loadP\":[18151,131072,1099511627776,15235,15235]}" («world» := full)
end Host.Load.Run.Tpl
