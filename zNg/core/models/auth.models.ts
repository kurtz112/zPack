// Modelli dell'autenticazione verso zServer.
// Il login e il rinnovo li gestisce TMVCJWTRefreshMiddleware di zServer:
// POST /api/auth/login, /api/auth/refresh, /api/auth/logout.

export interface LoginRequest {
  jwtusername: string;
  jwtpassword: string;
}

/** Risposta del middleware TMVCJWTRefreshMiddleware al login. */
export interface LoginResponse {
  token: string;
  refresh_token: string;
}

/** Risposta del middleware al rinnovo del token. */
export interface RefreshResponse {
  token: string;
  refresh_token: string;
}

/** Contenuto del token JWT emesso da zServer. */
export interface JwtPayload {
  sub: string;
  username: string;
  displayname: string;
  role: string;
  exp: number;
  iat: number;
  iss: string;
  [key: string]: unknown;
}
