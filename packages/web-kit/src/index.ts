// @mlx-bun/web-kit: the browser kit mlx-bun panels and shells build with. Browser code with no workspace
// dependencies and no DOM access at import time, so a server-side inventory can import a panel entry that imports
// this. The design tokens and base styles are one copy of the visual system; the API, event-stream and socket
// clients are the one transport layer; the fakes for tests live behind `./testing`.
export { TOKENS_CSS, TOKEN_NAMES } from "./tokens";
export { BASE_CSS } from "./base";
export { $, el, h, esc, injectStyles, shadowStyles, listen, createDisposer, deepActiveElement, trapFocus, type Child, type Disposer, type FocusTrap } from "./dom";
export { createApi, requestJson, errorOf, UNREACHABLE, type Api, type ApiEnvelope, type ApiRequest } from "./api";
export { openEventStream, byType, type EventStream, type EventStreamHandlers, type EventStreamOptions } from "./stream";
export { createSocket, type SocketClient, type SocketOptions, type SocketStatus } from "./socket";
export { num, gb, mb, bytes, ms, uptime, rate, percent, tokens, relativeTime, shortName } from "./format";
export { HOST_EVENTS, emitHostEvent, onHostEvent, type HostEventMap, type ServerStatusDetail, type PanelUi } from "./host";
