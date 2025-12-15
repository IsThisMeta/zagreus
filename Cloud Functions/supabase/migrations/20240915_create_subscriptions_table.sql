-- Create subscriptions table
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  apple_user_id TEXT, -- Apple's user identifier
  product_id TEXT NOT NULL, -- com.zagreus.pro.monthly
  purchase_date TIMESTAMPTZ NOT NULL,
  expires_date TIMESTAMPTZ NOT NULL,
  original_transaction_id TEXT UNIQUE NOT NULL, -- Apple's transaction ID
  latest_receipt_data TEXT, -- Store the receipt for re-validation
  status TEXT NOT NULL DEFAULT 'active', -- active, expired, cancelled, refunded
  environment TEXT, -- Production or Sandbox
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON public.subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_expires_date ON public.subscriptions(expires_date);
CREATE INDEX IF NOT EXISTS idx_subscriptions_original_transaction_id ON public.subscriptions(original_transaction_id);

-- RLS policies
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

-- Users can only see their own subscriptions
DO $$
BEGIN
  CREATE POLICY "Users can view own subscriptions" ON public.subscriptions
    FOR SELECT USING (auth.uid() = user_id);
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$;

-- Only server/service role can insert/update
DO $$
BEGIN
  CREATE POLICY "Service role can manage subscriptions" ON public.subscriptions
    FOR ALL USING (auth.role() = 'service_role');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END;
$$;

-- Function to get active subscription for a user
CREATE OR REPLACE FUNCTION get_active_subscription(p_user_id UUID)
RETURNS TABLE (
  subscription_id UUID,
  product_id TEXT,
  expires_date TIMESTAMPTZ,
  status TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    id as subscription_id,
    subscriptions.product_id,
    subscriptions.expires_date,
    subscriptions.status
  FROM public.subscriptions
  WHERE user_id = p_user_id
    AND status = 'active'
    AND expires_date > NOW()
  ORDER BY expires_date DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user has active Pro
CREATE OR REPLACE FUNCTION has_active_pro(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM public.subscriptions
    WHERE user_id = p_user_id
      AND status = 'active'
      AND expires_date > NOW()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;