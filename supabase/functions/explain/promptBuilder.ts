// promptBuilder.ts - Build prompts for different explanation modes

import { ExplainRequest } from "./types.ts";

const SYSTEM_PROMPT = `You are a helpful assistant that explains complex topics simply. 
Rules:
- Do not invent details; if unclear, say what's missing.
- Be concise and accurate.
- Follow the requested format strictly.
- Output must be valid JSON with: summary, bullets (array), actionItems (array), questions (array).
- Keep bullets to 5-8 items, actionItems to 3-5 items, questions to 2-4 items.`;

export function buildPrompt(req: ExplainRequest): string {
  let userPrompt = "";
  
  switch (req.mode) {
    case "simple":
      userPrompt = `Explain the following in plain English with no jargon: ${req.text}\n\nProvide: 1) One sentence summary, 2) 5-8 key points, 3) 3-5 action items, 4) 2-4 questions to ask next.`;
      break;
    case "bullets":
      userPrompt = `Convert the following into clear bullet points: ${req.text}\n\nProvide: 1) One sentence summary, 2) 5-8 bullet points, 3) 3-5 action items, 4) 2-4 questions to ask next.`;
      break;
    case "actions":
      userPrompt = `Extract actionable steps from: ${req.text}\n\nProvide: 1) One sentence summary, 2) 5-8 key points, 3) 3-5 action items, 4) 2-4 questions to ask next.`;
      break;
    case "eli12":
      userPrompt = `Explain this like the user is 12 years old: ${req.text}\n\nUse friendly, short sentences. Provide: 1) One sentence summary, 2) 5-8 key points, 3) 3-5 action items, 4) 2-4 questions to ask next.`;
      break;
  }
  
  if (req.safetyContextToggle) {
    userPrompt += "\n\nIMPORTANT: This content is legal/medical/financial. Include a warning that this isn't professional advice.";
  }
  
  userPrompt += "\n\nRespond ONLY with valid JSON in this exact format:\n{\"summary\": \"...\", \"bullets\": [\"...\"], \"actionItems\": [\"...\"], \"questions\": [\"...\"]}";
  
  return userPrompt;
}

export function getSystemPrompt(): string {
  return SYSTEM_PROMPT;
}
