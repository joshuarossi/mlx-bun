// The parts of the host library that load no model and no native code, for a
// process that owns app state but no engine (the persistent state, the
// isolated parent): module activation, route mounting, storage entries, the event bus,
// the model host's failure type and the image host's stage rules (the isolated parent decides an
// image worker's staging by them). The package index adds the companion model hosts (Whisper, image).
export { activateModules, runVerb } from "./activation";
export { createEventHub } from "./events";
export { createExecutionLock } from "./execution-lock";
export type { EventHub, EventHubOptions, EventHubStats, SubscriberStats } from "./events";
export { createRegistryCatalog } from "./catalog";
export type { CatalogHub, RegistryCatalogOptions } from "./catalog";
export { CatalogFailure, ModelHostFailure } from "./failure";
export { defaultStageBudgetBytes, fixedStageRule, pipelineComponentBytes, stageBudgetRule, stageResidency } from "./image-stages";
export type { StageResidency, StageRule } from "./image-stages";
export { createModuleRoutes } from "./routes";
export type { ModuleRoutes } from "./routes";
export { createModuleSockets } from "./sockets";
export type { ModuleSocketData, ModuleSockets, Upgrader } from "./sockets";
export { MODEL_LAYOUT, mlxBunHome } from "./home";
export { createStorage } from "./storage";
