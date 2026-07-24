-- =====================================================================
--  Adds a per-user token version so a logout can invalidate every
--  outstanding access/refresh JWT for that user (stateless revocation).
--  Existing tokens carry no "tv" claim and are treated as version 0 by
--  the application, so this migration does not force a global logout.
-- =====================================================================
ALTER TABLE users ADD COLUMN token_version INT NOT NULL DEFAULT 0;
