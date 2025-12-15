import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Apple receipt validation URLs
const APPLE_PRODUCTION_URL = 'https://buy.itunes.apple.com/verifyReceipt'
const APPLE_SANDBOX_URL = 'https://sandbox.itunes.apple.com/verifyReceipt'

// Your app's shared secret from App Store Connect
const APPLE_SHARED_SECRET = Deno.env.get('APPLE_SHARED_SECRET') ?? ''

interface AppleReceiptResponse {
  status: number
  environment: string
  receipt: {
    bundle_id: string
    application_version: string
    in_app: any[]
    original_purchase_date_ms: string
  }
  latest_receipt_info?: any[]
  pending_renewal_info?: any[]
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { receipt_data, user_id } = await req.json()

    if (!receipt_data) {
      console.error('validate-receipt: missing receipt_data payload', { user_id })
      return new Response(
        JSON.stringify({ error: 'Missing receipt_data' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Validate with Apple - try production first
    let appleResponse = await validateWithApple(receipt_data, APPLE_PRODUCTION_URL)

    // If status 21007, receipt is from sandbox, validate with sandbox URL
    if (appleResponse.status === 21007) {
      appleResponse = await validateWithApple(receipt_data, APPLE_SANDBOX_URL)
    }

    // Check validation status
    if (appleResponse.status !== 0) {
      console.error('validate-receipt: Apple validation failed', {
        status: appleResponse.status,
        environment: appleResponse.environment,
        body: appleResponse,
      })
      return new Response(
        JSON.stringify({
          error: 'Invalid receipt',
          apple_status: appleResponse.status
        }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get the latest receipt info (for auto-renewable subscriptions)
    const latestReceiptInfo = appleResponse.latest_receipt_info?.[0]

    if (!latestReceiptInfo) {
      console.error('validate-receipt: no subscription info returned by Apple', {
        receipt: appleResponse.receipt,
        pending_renewal_info: appleResponse.pending_renewal_info,
      })
      return new Response(
        JSON.stringify({ error: 'No subscription found in receipt' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Extract subscription details
    const subscriptionData = {
      user_id: user_id,
      product_id: latestReceiptInfo.product_id,
      purchase_date: new Date(parseInt(latestReceiptInfo.purchase_date_ms)),
      expires_date: new Date(parseInt(latestReceiptInfo.expires_date_ms)),
      original_transaction_id: latestReceiptInfo.original_transaction_id,
      latest_receipt_data: receipt_data,
      status: 'active',
      environment: appleResponse.environment,
    }

    // Check if subscription already exists
    const { data: existingSubscription, error: lookupError } = await supabase
      .from('subscriptions')
      .select('id')
      .eq('original_transaction_id', subscriptionData.original_transaction_id)
      .single()

    if (lookupError && lookupError.code !== 'PGRST116') {
      console.error('validate-receipt: failed to lookup existing subscription', {
        error: lookupError,
        original_transaction_id: subscriptionData.original_transaction_id,
      })
      throw lookupError
    }

    let subscription
    if (existingSubscription) {
      // Update existing subscription
      const { data, error } = await supabase
        .from('subscriptions')
        .update({
          ...subscriptionData,
          updated_at: new Date().toISOString()
        })
        .eq('id', existingSubscription.id)
        .select()
        .single()

      if (error) throw error
      subscription = data
    } else {
      // Insert new subscription
      const { data, error } = await supabase
        .from('subscriptions')
        .insert(subscriptionData)
        .select()
        .single()

      if (error) throw error
      subscription = data
    }

    // Check if subscription is expired
    const isExpired = new Date(subscription.expires_date) < new Date()
    if (isExpired) {
      await supabase
        .from('subscriptions')
        .update({ status: 'expired' })
        .eq('id', subscription.id)

      subscription.status = 'expired'
    }

    return new Response(
      JSON.stringify({
        success: true,
        subscription: {
          id: subscription.id,
          product_id: subscription.product_id,
          status: subscription.status,
          expires_date: subscription.expires_date,
          is_active: subscription.status === 'active' && !isExpired
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('validate-receipt: unhandled error', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

async function validateWithApple(receiptData: string, url: string): Promise<AppleReceiptResponse> {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      'receipt-data': receiptData,
      'password': APPLE_SHARED_SECRET,
      'exclude-old-transactions': true
    })
  })

  return await response.json()
}
