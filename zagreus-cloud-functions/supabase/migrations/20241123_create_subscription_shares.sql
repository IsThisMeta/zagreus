-- Subscription sharing system
-- Mega gets 1 share, Ultra gets 5 shares

CREATE TABLE IF NOT EXISTS public.subscription_shares (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Owner info
  owner_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  owner_product_id TEXT NOT NULL, -- mega.monthly, ultra.yearly, etc
  owner_expires_at TIMESTAMPTZ NOT NULL, -- Synced from RevenueCat by master device

  -- Shared with
  shared_with_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  shared_with_email TEXT, -- For display purposes

  -- Status
  status TEXT NOT NULL DEFAULT 'active', -- active, revoked

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Prevent duplicate shares
  UNIQUE(owner_user_id, shared_with_user_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_shares_owner ON public.subscription_shares(owner_user_id);
CREATE INDEX IF NOT EXISTS idx_shares_recipient ON public.subscription_shares(shared_with_user_id);
CREATE INDEX IF NOT EXISTS idx_shares_status ON public.subscription_shares(status);

-- RLS
ALTER TABLE public.subscription_shares ENABLE ROW LEVEL SECURITY;

-- Owners can see their granted shares
CREATE POLICY "Owners can view their shares"
  ON public.subscription_shares
  FOR SELECT
  USING (auth.uid() = owner_user_id);

-- Recipients can see shares granted to them
CREATE POLICY "Recipients can view their shares"
  ON public.subscription_shares
  FOR SELECT
  USING (auth.uid() = shared_with_user_id);

-- Only owners can grant shares (with quota check)
CREATE POLICY "Owners can grant shares"
  ON public.subscription_shares
  FOR INSERT
  WITH CHECK (auth.uid() = owner_user_id);

-- Only owners can revoke shares
CREATE POLICY "Owners can revoke shares"
  ON public.subscription_shares
  FOR UPDATE
  USING (auth.uid() = owner_user_id);

-- Function to check share quota
CREATE OR REPLACE FUNCTION get_share_quota(p_product_id TEXT)
RETURNS INTEGER AS $$
BEGIN
  -- Ultra gets 5, Mega gets 1
  IF p_product_id ILIKE '%ultra%' THEN
    RETURN 5;
  ELSIF p_product_id ILIKE '%mega%' THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to get remaining shares
CREATE OR REPLACE FUNCTION get_remaining_shares(p_user_id UUID, p_product_id TEXT)
RETURNS INTEGER AS $$
DECLARE
  v_quota INTEGER;
  v_used INTEGER;
BEGIN
  v_quota := get_share_quota(p_product_id);

  SELECT COUNT(*)
  INTO v_used
  FROM public.subscription_shares
  WHERE owner_user_id = p_user_id
    AND status = 'active';

  RETURN GREATEST(0, v_quota - v_used);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user has Pro access (direct OR shared)
CREATE OR REPLACE FUNCTION has_pro_access(p_user_id UUID)
RETURNS TABLE (
  has_access BOOLEAN,
  access_type TEXT, -- 'direct', 'shared', or NULL
  expires_at TIMESTAMPTZ,
  product_id TEXT
) AS $$
BEGIN
  -- Check direct subscription first
  RETURN QUERY
  SELECT
    TRUE as has_access,
    'direct'::TEXT as access_type,
    s.expires_date as expires_at,
    s.product_id
  FROM public.subscriptions s
  WHERE s.user_id = p_user_id
    AND s.status = 'active'
    AND s.expires_date > NOW()
  ORDER BY s.expires_date DESC
  LIMIT 1;

  -- If no direct subscription, check shared access
  IF NOT FOUND THEN
    RETURN QUERY
    SELECT
      TRUE as has_access,
      'shared'::TEXT as access_type,
      sh.owner_expires_at as expires_at,
      sh.owner_product_id as product_id
    FROM public.subscription_shares sh
    WHERE sh.shared_with_user_id = p_user_id
      AND sh.status = 'active'
      AND sh.owner_expires_at > NOW()
    ORDER BY sh.owner_expires_at DESC
    LIMIT 1;
  END IF;

  -- No access
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, NULL::TEXT, NULL::TIMESTAMPTZ, NULL::TEXT;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to grant a share (with quota validation)
CREATE OR REPLACE FUNCTION grant_share(
  p_owner_user_id UUID,
  p_shared_with_email TEXT,
  p_owner_product_id TEXT,
  p_owner_expires_at TIMESTAMPTZ
)
RETURNS JSON AS $$
DECLARE
  v_remaining INTEGER;
  v_recipient_user_id UUID;
  v_share_id UUID;
BEGIN
  -- Check quota
  v_remaining := get_remaining_shares(p_owner_user_id, p_owner_product_id);
  IF v_remaining <= 0 THEN
    RETURN json_build_object('success', false, 'error', 'No shares remaining');
  END IF;

  -- Find recipient user
  SELECT id INTO v_recipient_user_id
  FROM auth.users
  WHERE email = p_shared_with_email;

  IF v_recipient_user_id IS NULL THEN
    RETURN json_build_object('success', false, 'error', 'User not found');
  END IF;

  -- Can't share with yourself
  IF v_recipient_user_id = p_owner_user_id THEN
    RETURN json_build_object('success', false, 'error', 'Cannot share with yourself');
  END IF;

  -- Insert or update share
  INSERT INTO public.subscription_shares (
    owner_user_id,
    owner_product_id,
    owner_expires_at,
    shared_with_user_id,
    shared_with_email,
    status
  ) VALUES (
    p_owner_user_id,
    p_owner_product_id,
    p_owner_expires_at,
    v_recipient_user_id,
    p_shared_with_email,
    'active'
  )
  ON CONFLICT (owner_user_id, shared_with_user_id)
  DO UPDATE SET
    status = 'active',
    owner_product_id = EXCLUDED.owner_product_id,
    owner_expires_at = EXCLUDED.owner_expires_at,
    updated_at = NOW()
  RETURNING id INTO v_share_id;

  RETURN json_build_object('success', true, 'share_id', v_share_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to revoke a share
CREATE OR REPLACE FUNCTION revoke_share(
  p_owner_user_id UUID,
  p_share_id UUID
)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE public.subscription_shares
  SET status = 'revoked',
      updated_at = NOW()
  WHERE id = p_share_id
    AND owner_user_id = p_owner_user_id;

  RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
