-- Clean 1.2 Subscription Functions - NO BRIDGING, NO NULL RETURNS
-- This completely replaces all previous subscription functions

-- Drop old functions if they exist
DROP FUNCTION IF EXISTS has_active_pro(UUID);
DROP FUNCTION IF EXISTS has_active_mega(UUID);
DROP FUNCTION IF EXISTS upsert_subscription(UUID, TEXT, TEXT, TIMESTAMPTZ);

-- Clean table structure for subscriptions
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  subscription_type TEXT NOT NULL CHECK (subscription_type IN ('pro', 'mega')),
  expires_at TIMESTAMPTZ NOT NULL,
  transaction_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, subscription_type)
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_type ON public.subscriptions(user_id, subscription_type);
CREATE INDEX IF NOT EXISTS idx_subscriptions_expires ON public.subscriptions(expires_at);

-- Enable RLS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can view their own subscriptions
CREATE POLICY "Users view own subscriptions" ON public.subscriptions
  FOR SELECT USING (auth.uid() = user_id);

-- Service role manages subscriptions
CREATE POLICY "Service role manages subscriptions" ON public.subscriptions
  FOR ALL USING (auth.role() = 'service_role');

-- Function to check Pro subscription - ALWAYS returns true/false
CREATE OR REPLACE FUNCTION has_active_pro(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.subscriptions
    WHERE user_id = p_user_id
      AND subscription_type = 'pro'
      AND expires_at > NOW()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check Mega subscription - ALWAYS returns true/false
CREATE OR REPLACE FUNCTION has_active_mega(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.subscriptions
    WHERE user_id = p_user_id
      AND subscription_type = 'mega'
      AND expires_at > NOW()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Upsert subscription - handles both insert and update
CREATE OR REPLACE FUNCTION upsert_subscription(
  p_user_id UUID,
  p_product_id TEXT,
  p_subscription_type TEXT,
  p_expires_at TIMESTAMPTZ
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO public.subscriptions (
    user_id,
    product_id,
    subscription_type,
    expires_at,
    transaction_id,
    updated_at
  ) VALUES (
    p_user_id,
    p_product_id,
    p_subscription_type,
    p_expires_at,
    gen_random_uuid()::TEXT,
    NOW()
  )
  ON CONFLICT (user_id, subscription_type)
  DO UPDATE SET
    product_id = EXCLUDED.product_id,
    expires_at = EXCLUDED.expires_at,
    updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get all active subscriptions for a user
CREATE OR REPLACE FUNCTION get_user_subscriptions(p_user_id UUID)
RETURNS TABLE (
  subscription_type TEXT,
  product_id TEXT,
  expires_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.subscription_type,
    s.product_id,
    s.expires_at
  FROM public.subscriptions s
  WHERE s.user_id = p_user_id
    AND s.expires_at > NOW()
  ORDER BY s.expires_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;