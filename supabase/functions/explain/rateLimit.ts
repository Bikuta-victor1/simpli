// rateLimit.ts - Simple in-memory rate limiting (for MVP)
// In production, use Redis or Supabase database

const rateLimitStore = new Map<string, { count: number; resetAt: number }>();
const RATE_LIMIT = 10; // requests per day
const RATE_LIMIT_WINDOW = 24 * 60 * 60 * 1000; // 24 hours in ms

export function checkRateLimit(clientId: string): { allowed: boolean; retryAfter?: number } {
  const now = Date.now();
  const record = rateLimitStore.get(clientId);
  
  if (!record) {
    rateLimitStore.set(clientId, { count: 1, resetAt: now + RATE_LIMIT_WINDOW });
    return { allowed: true };
  }
  
  // Reset if window expired
  if (now > record.resetAt) {
    rateLimitStore.set(clientId, { count: 1, resetAt: now + RATE_LIMIT_WINDOW });
    return { allowed: true };
  }
  
  // Check if limit exceeded
  if (record.count >= RATE_LIMIT) {
    const retryAfter = Math.ceil((record.resetAt - now) / 1000);
    return { allowed: false, retryAfter };
  }
  
  // Increment count
  record.count++;
  return { allowed: true };
}
