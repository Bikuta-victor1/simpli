// validation.ts - Request validation logic

import { ExplainRequest } from "./types.ts";

const MAX_TEXT_LENGTH = 4000;
const MIN_TEXT_LENGTH = 10;

export function validateRequest(req: ExplainRequest): { valid: boolean; error?: string; field?: string } {
  if (!req.text || typeof req.text !== "string") {
    return { valid: false, error: "Text is required", field: "text" };
  }
  
  if (req.text.length < MIN_TEXT_LENGTH) {
    return { valid: false, error: `Text must be at least ${MIN_TEXT_LENGTH} characters`, field: "text" };
  }
  
  if (req.text.length > MAX_TEXT_LENGTH) {
    return { valid: false, error: `Text exceeds maximum length of ${MAX_TEXT_LENGTH} characters`, field: "text" };
  }
  
  const validModes = ["simple", "bullets", "actions", "eli12"];
  if (!validModes.includes(req.mode)) {
    return { valid: false, error: "Invalid mode", field: "mode" };
  }
  
  if (!req.clientId || typeof req.clientId !== "string") {
    return { valid: false, error: "clientId is required", field: "clientId" };
  }
  
  return { valid: true };
}
