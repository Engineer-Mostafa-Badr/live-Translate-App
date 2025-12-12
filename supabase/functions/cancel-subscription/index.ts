// ========================================
// Cancel Subscription - Edge Function
// ========================================
// This function cancels a Stripe subscription
// Deploy: supabase functions deploy cancel-subscription

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.5.0?target=deno'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') || 'sk_test_placeholder', {
  apiVersion: '2023-10-16',
  httpClient: Stripe.createFetchHttpClient(),
})

const supabaseUrl = Deno.env.get('SUPABASE_URL') || 'https://your-project.supabase.co'
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || 'service_role_key_placeholder'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { userId, immediately } = await req.json()

    if (!userId) {
      throw new Error('Missing required parameter: userId')
    }

    // Initialize Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Get user subscription
    const { data: subscription, error } = await supabase
      .from('user_subscriptions')
      .select('stripe_subscription_id')
      .eq('user_id', userId)
      .single()

    if (error || !subscription?.stripe_subscription_id) {
      throw new Error('No active subscription found')
    }

    // Cancel subscription in Stripe
    const canceledSubscription = immediately
      ? await stripe.subscriptions.cancel(subscription.stripe_subscription_id)
      : await stripe.subscriptions.update(subscription.stripe_subscription_id, {
          cancel_at_period_end: true,
        })

    // Update subscription status in Supabase
    await supabase
      .from('user_subscriptions')
      .update({
        subscription_status: immediately ? 'cancelled' : 'active',
        cancelled_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('user_id', userId)

    return new Response(
      JSON.stringify({
        success: true,
        message: immediately
          ? 'Subscription cancelled immediately'
          : 'Subscription will be cancelled at period end',
        cancelAt: canceledSubscription.cancel_at
          ? new Date(canceledSubscription.cancel_at * 1000).toISOString()
          : null,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error cancelling subscription:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
