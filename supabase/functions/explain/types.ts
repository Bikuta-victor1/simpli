// types.ts - Type definitions for the explain Edge Function

export interface ExplainRequest {
  text: string;
  mode: "simple" | "bullets" | "actions" | "eli12";
  safetyContextToggle: boolean;
  clientId: string;
  appVersion: string;
}

export interface ExplainResponse {
  summary: string;
  bullets: string[];
  actionItems: string[];
  questions: string[];
  warnings?: string[];
}

export interface ErrorResponse {
  error: string;
  message: string;
  field?: string;
  retryAfter?: number;
}
