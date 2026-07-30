/**
 * Stored-procedure call layer. (Security rules: RULES.md S1–S5.)
 *
 * Every conversation with the IBM i goes through callProcedure(): an HTTP POST
 * to /api/<path>, where Apache on the IBM i routes it to the CGI dispatcher
 * (APLLIB/APIDSP), which calls the routed SQL stored procedure — see
 * BACKEND.md. The signed-on user's IBM i profile and password are sent as
 * HTTP Basic auth on each request — Apache authenticates against the real
 * user profile and runs the request AS that user (UserID %%CLIENT%%), so
 * authority is enforced by the operating system, not by this app.
 *
 * Credentials live only in this module's memory (set at sign-on, cleared at
 * sign-off). They are never written to localStorage, sessionStorage, or
 * cookies, which means a browser refresh requires signing on again (RULES.md
 * S4).
 *
 * MOCK mode: until the back end is reachable, MOCK = true simulates sign-on
 * (any non-blank credentials pass; profile NOAUTH exercises the
 * authority-denied path) and makes callProcedure() fail loudly so a screen
 * can't silently believe it talked to the system.
 */

export const MOCK = false

export interface Credentials {
  user: string
  password: string
}

export type SignOnResult = 'ok' | 'bad-credentials' | 'not-authorized'

let credentials: Credentials | null = null

export function setCredentials(c: Credentials): void {
  credentials = c
}

export function clearCredentials(): void {
  credentials = null
}

function authHeader(): string {
  if (!credentials) {
    throw new Error('Not signed on')
  }
  return 'Basic ' + btoa(`${credentials.user}:${credentials.password}`)
}

/**
 * Verify a user profile and password on the IBM i, and check that the
 * profile has *CHANGE authority to the APLLIB library (RULES.md S2).
 *
 * Server contract for POST /api/signon (procedure APLLIB.API_SIGNON):
 *   - HTTP 401/403        → profile or password is wrong (from Apache,
 *                           before any program runs)
 *   - HTTP 200 + JSON     → { "authorized": true | false }
 *     where authorized reflects the *CHANGE-to-APLLIB check performed by
 *     the sign-on stored procedure.
 */
export async function verifySignOn(c: Credentials): Promise<SignOnResult> {
  if (MOCK) {
    await new Promise((resolve) => setTimeout(resolve, 500))
    if (c.user.trim() === '' || c.password === '') {
      return 'bad-credentials'
    }
    if (c.user.trim().toUpperCase() === 'NOAUTH') {
      return 'not-authorized'
    }
    return 'ok'
  }

  const response = await fetch('/api/signon', {
    method: 'POST',
    headers: {
      Authorization: 'Basic ' + btoa(`${c.user}:${c.password}`),
      'Content-Type': 'application/json',
    },
    body: '{}',
  })
  if (response.status === 401 || response.status === 403) {
    return 'bad-credentials'
  }
  if (!response.ok) {
    throw new Error(`Sign-on check failed (HTTP ${response.status})`)
  }
  const body = (await response.json()) as { authorized: boolean }
  return body.authorized ? 'ok' : 'not-authorized'
}

/**
 * Call a stored procedure by its /api/ endpoint path.
 * Parameters go as a JSON body; the result set comes back as parsed JSON.
 * Every call is an independent, stateless request made as the signed-on
 * user (RULES.md S3, C3).
 */
export async function callProcedure<T>(
  procedure: string,
  params: Record<string, unknown> = {},
): Promise<T> {
  if (MOCK) {
    throw new Error(`MOCK mode: back end not connected — cannot call procedure "${procedure}"`)
  }

  const response = await fetch(`/api/${procedure}`, {
    method: 'POST',
    headers: {
      Authorization: authHeader(),
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(params),
  })
  if (response.status === 401) {
    throw new Error('The IBM i rejected the sign-on credentials')
  }
  if (!response.ok) {
    // The dispatcher returns {"error":"<message>"} for business errors
    // (SIGNAL from a procedure) and failures — surface that message.
    let message = `Procedure "${procedure}" failed (HTTP ${response.status})`
    try {
      const body = (await response.json()) as { error?: string }
      if (body.error) {
        message = body.error
      }
    } catch {
      // non-JSON error body — keep the generic message
    }
    throw new Error(message)
  }
  return (await response.json()) as T
}
