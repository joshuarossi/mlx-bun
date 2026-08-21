export type AuxiliaryRoute =
  | "memory-status"
  | "memory-list"
  | "memory-search"
  | "memory-article"
  | "memory-links"
  | "memory-history"
  | "memory-diff"
  | "memory-init"
  | "hub-local"
  | "hub-search"
  | "hub-download"
  | "hub-serve"
  | "sessions-search"
  | "sessions-export";

/** Match request-only routes that do not depend on the loaded model or
 * createServer's live generation state. */
export function matchAuxiliaryRoute(method: string, pathname: string): AuxiliaryRoute | null {
  switch (`${method} ${pathname}`) {
    case "GET /api/memory/status": return "memory-status";
    case "GET /api/memory/list": return "memory-list";
    case "GET /api/memory/search": return "memory-search";
    case "GET /api/memory/article": return "memory-article";
    case "GET /api/memory/links": return "memory-links";
    case "GET /api/memory/history": return "memory-history";
    case "GET /api/memory/diff": return "memory-diff";
    case "POST /api/memory/init": return "memory-init";
    case "GET /api/hub/local": return "hub-local";
    case "GET /api/hub/search": return "hub-search";
    case "POST /api/hub/download": return "hub-download";
    case "POST /api/hub/serve": return "hub-serve";
    case "GET /api/sessions/search": return "sessions-search";
    case "GET /api/sessions/export": return "sessions-export";
    default: return null;
  }
}

export async function handleAuxiliaryRoute(
  url: URL,
  request: Request,
): Promise<Response | null> {
  switch (matchAuxiliaryRoute(request.method, url.pathname)) {
    case "memory-status": {
      const { handleMemoryStatus } = await import("../memory/rest");
      return handleMemoryStatus();
    }
    case "memory-list": {
      const { handleMemoryList } = await import("../memory/rest");
      return handleMemoryList();
    }
    case "memory-search": {
      const { handleMemorySearch } = await import("../memory/rest");
      return handleMemorySearch(url);
    }
    case "memory-article": {
      const { handleMemoryArticle } = await import("../memory/rest");
      return handleMemoryArticle(url);
    }
    case "memory-links": {
      const { handleMemoryLinks } = await import("../memory/rest");
      return handleMemoryLinks(url);
    }
    case "memory-history": {
      const { handleMemoryHistory } = await import("../memory/rest");
      return handleMemoryHistory(url);
    }
    case "memory-diff": {
      const { handleMemoryDiff } = await import("../memory/rest");
      return handleMemoryDiff(url);
    }
    case "memory-init": {
      const { handleMemoryInit } = await import("../memory/rest");
      return handleMemoryInit(request);
    }
    case "hub-local": {
      const { handleHubLocal } = await import("../hub-rest");
      return handleHubLocal();
    }
    case "hub-search": {
      const { handleHubSearch } = await import("../hub-rest");
      return handleHubSearch(url);
    }
    case "hub-download": {
      const { handleHubDownload } = await import("../hub-rest");
      return handleHubDownload(request);
    }
    case "hub-serve": {
      const { handleHubServe } = await import("../hub-rest");
      return handleHubServe(request);
    }
    case "sessions-search": {
      const { handleSessionsSearch } = await import("./session-search");
      return handleSessionsSearch(url);
    }
    case "sessions-export": {
      const { handleSessionsExport } = await import("./session-search");
      return handleSessionsExport(url);
    }
    default:
      return null;
  }
}
