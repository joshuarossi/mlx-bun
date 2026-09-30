export interface ApiEnvelope { ok?: boolean; error?: string; message?: string; [key: string]: unknown }
export interface PanelConnection { readonly apiBase: string; readonly eventsUrl: string }
