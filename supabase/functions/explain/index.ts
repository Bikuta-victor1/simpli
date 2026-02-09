// index.ts - Main Edge Function handler

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { ExplainRequest, ExplainResponse, ErrorResponse } from "./types.ts";
import { validateRequest } from "./validation.ts";
import { checkRateLimit } from "./rateLimit.ts";
import { buildPrompt, getSystemPrompt } from "./promptBuilder.ts";

const AI_PROVIDER = Deno.env.get("AI_PROVIDER") || "openai";
const AI_API_KEY = Deno.env.get("AI_API_KEY");
const MAX_OUTPUT_TOKENS = 500;

serve(async (req) => {
  // CORS headers
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };
  
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  
  try {
    // Parse request
    const body: ExplainRequest = await req.json();
    
    // Validate
    const validation = validateRequest(body);
    if (!validation.valid) {
      const errorResponse: ErrorResponse = {
        error: "validation_error",
        message: validation.error || "Validation failed",
        field: validation.field,
      };
      return new Response(JSON.stringify(errorResponse), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    
    // Rate limiting
    const rateLimit = checkRateLimit(body.clientId);
    if (!rateLimit.allowed) {
      const errorResponse: ErrorResponse = {
        error: "rate_limited",
        message: "Rate limit exceeded. Try again later.",
        retryAfter: rateLimit.retryAfter,
      };
      return new Response(JSON.stringify(errorResponse), {
        status: 429,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    
    // Check API key
    if (!AI_API_KEY) {
      console.error("AI_API_KEY not set");
      const errorResponse: ErrorResponse = {
        error: "server_error",
        message: "Server configuration error",
      };
      return new Response(JSON.stringify(errorResponse), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
    
    // Build prompt
    const systemPrompt = getSystemPrompt();
    const userPrompt = buildPrompt(body);
    
    // Call AI provider
    let aiResponse: any;
    if (AI_PROVIDER === "openai") {
      aiResponse = await callOpenAI(systemPrompt, userPrompt);
    } else if (AI_PROVIDER === "anthropic") {
      aiResponse = await callAnthropic(systemPrompt, userPrompt);
    } else {
      throw new Error(`Unsupported AI provider: ${AI_PROVIDER}`);
    }
    
    // Parse AI response
    const explanation = parseAIResponse(aiResponse);
    
    // Add warnings if needed
    const warnings: string[] = [];
    if (body.safetyContextToggle) {
      warnings.push("This isn't professional advice. Consult a qualified professional.");
    }
    
    const response: ExplainResponse = {
      ...explanation,
      warnings: warnings.length > 0 ? warnings : undefined,
    };
    
    return new Response(JSON.stringify(response), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error:", error);
    const errorResponse: ErrorResponse = {
      error: "server_error",
      message: error instanceof Error ? error.message : "Internal server error",
    };
    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});

async function callOpenAI(systemPrompt: string, userPrompt: string): Promise<any> {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${AI_API_KEY}`,
    },
    body: JSON.stringify({
      model: "gpt-4o-mini", // or gpt-3.5-turbo for cost savings
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
      max_tokens: MAX_OUTPUT_TOKENS,
      temperature: 0.7,
    }),
  });
  
  if (!response.ok) {
    const error = await response.text();
    throw new Error(`OpenAI API error: ${error}`);
  }
  
  const data = await response.json();
  return data.choices[0].message.content;
}

async function callAnthropic(systemPrompt: string, userPrompt: string): Promise<any> {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-api-key": AI_API_KEY!,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model: "claude-3-haiku-20240307", // or claude-3-sonnet for better quality
      system: systemPrompt,
      messages: [{ role: "user", content: userPrompt }],
      max_tokens: MAX_OUTPUT_TOKENS,
    }),
  });
  
  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Anthropic API error: ${error}`);
  }
  
  const data = await response.json();
  return data.content[0].text;
}

function parseAIResponse(content: string): Omit<ExplainResponse, "warnings"> {
  // Try to extract JSON from response
  const jsonMatch = content.match(/\{[\s\S]*\}/);
  if (jsonMatch) {
    try {
      const parsed = JSON.parse(jsonMatch[0]);
      return {
        summary: parsed.summary || "Summary not available",
        bullets: Array.isArray(parsed.bullets) ? parsed.bullets : [],
        actionItems: Array.isArray(parsed.actionItems) ? parsed.actionItems : [],
        questions: Array.isArray(parsed.questions) ? parsed.questions : [],
      };
    } catch (e) {
      console.error("Failed to parse JSON from AI response:", e);
    }
  }
  
  // Fallback: return structured response with content
  return {
    summary: content.split("\n")[0] || "Summary not available",
    bullets: content.split("\n").slice(1, 9).filter(Boolean),
    actionItems: [],
    questions: [],
  };
}
