// ========================================
// Stripe Webhook Handler - Edge Function
// ========================================
// This function handles Stripe webhook events
// Deploy: supabase functions deploy stripe-webhook

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@14.5.0?target=deno'

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') || 'sk_test_placeholder', {
  apiVersion: '2023-10-16',
  httpClient: Stripe.createFetchHttpClient(),
})

const supabaseUrl = Deno.env.get('SUPABASE_URL') || 'https://your-project.supabase.co'
const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || 'service_role_key_placeholder'
const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') || 'whsec_placeholder'

serve(async (req) => {
  const signature = req.headers.get('stripe-signature')
  
  if (!signature) {
    return new Response(
      JSON.stringify({ error: 'No signature found' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }

  try {
    const body = await req.text()
    const event = stripe.webhooks.constructEvent(body, signature, webhookSecret)

    console.log('Webhook event received:', event.type)

    // Initialize Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Handle different event types
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object, supabase)
        break

      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionUpdate(event.data.object, supabase)
        break

      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object, supabase)
        break

      case 'invoice.paid':
        await handleInvoicePaid(event.data.object, supabase)
        break

      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object, supabase)
        break

      default:
        console.log(`Unhandled event type: ${event.type}`)
    }

    return new Response(
      JSON.stringify({ received: true }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    console.error('Webhook error:', err.message)
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})

// ========================================
// Event Handlers
// ========================================

async function handleCheckoutCompleted(session: any, supabase: any) {
  console.log('Processing checkout.session.completed')
  
  const customerId = session.customer
  const subscriptionId = session.subscription
  const userId = session.metadata?.user_id

  if (!userId) {
    console.error('No user_id in session metadata')
    return
  }

  // Get subscription details from Stripe
  const subscription = await stripe.subscriptions.retrieve(subscriptionId)
  
  // Determine subscription tier based on price
  const tier = getSubscriptionTier(subscription.items.data[0].price.id)
  const limits = getSubscriptionLimits(tier)

  // Update user subscription in Supabase
  const { error } = await supabase
    .from('user_subscriptions')
    .upsert({
      user_id: userId,
      stripe_customer_id: customerId,
      stripe_subscription_id: subscriptionId,
      stripe_price_id: subscription.items.data[0].price.id,
      subscription_tier: tier,
      subscription_status: 'active',
      billing_period: subscription.items.data[0].price.recurring?.interval || 'monthly',
      current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
      daily_translation_limit: limits.translation,
      daily_ocr_limit: limits.ocr,
      daily_voice_limit: limits.voice,
      updated_at: new Date().toISOString(),
    })

  if (error) {
    console.error('Error updating subscription:', error)
    throw error
  }

  // Create transaction record
  await createTransaction(supabase, userId, {
    transaction_type: 'subscription',
    transaction_status: 'completed',
    stripe_payment_intent_id: session.payment_intent,
    amount: session.amount_total / 100,
    currency: session.currency,
    description: `Subscription to ${tier} plan`,
  })

  console.log('Checkout completed successfully')
}

async function handleSubscriptionUpdate(subscription: any, supabase: any) {
  console.log('Processing subscription update')

  const { error } = await supabase
    .from('user_subscriptions')
    .update({
      subscription_status: subscription.status,
      current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscription.id)

  if (error) {
    console.error('Error updating subscription:', error)
    throw error
  }

  console.log('Subscription updated successfully')
}

async function handleSubscriptionDeleted(subscription: any, supabase: any) {
  console.log('Processing subscription deletion')

  // Get user_id from subscription
  const { data: subData } = await supabase
    .from('user_subscriptions')
    .select('user_id')
    .eq('stripe_subscription_id', subscription.id)
    .single()

  if (!subData) {
    console.error('Subscription not found')
    return
  }

  // Downgrade to free tier
  const { error } = await supabase
    .from('user_subscriptions')
    .update({
      subscription_tier: 'free',
      subscription_status: 'cancelled',
      cancelled_at: new Date().toISOString(),
      daily_translation_limit: 10,
      daily_ocr_limit: 5,
      daily_voice_limit: 5,
      updated_at: new Date().toISOString(),
    })
    .eq('stripe_subscription_id', subscription.id)

  if (error) {
    console.error('Error cancelling subscription:', error)
    throw error
  }

  // Create transaction record
  await createTransaction(supabase, subData.user_id, {
    transaction_type: 'cancellation',
    transaction_status: 'completed',
    amount: 0,
    currency: 'USD',
    description: 'Subscription cancelled',
  })

  console.log('Subscription cancelled successfully')
}

async function handleInvoicePaid(invoice: any, supabase: any) {
  console.log('Processing invoice.paid')

  const { data: subData } = await supabase
    .from('user_subscriptions')
    .select('user_id')
    .eq('stripe_subscription_id', invoice.subscription)
    .single()

  if (!subData) {
    console.error('Subscription not found')
    return
  }

  // Create transaction record
  await createTransaction(supabase, subData.user_id, {
    transaction_type: 'renewal',
    transaction_status: 'completed',
    stripe_payment_intent_id: invoice.payment_intent,
    stripe_invoice_id: invoice.id,
    amount: invoice.amount_paid / 100,
    currency: invoice.currency,
    description: 'Subscription renewal',
  })

  console.log('Invoice paid successfully')
}

async function handlePaymentFailed(invoice: any, supabase: any) {
  console.log('Processing invoice.payment_failed')

  const { data: subData } = await supabase
    .from('user_subscriptions')
    .select('user_id')
    .eq('stripe_subscription_id', invoice.subscription)
    .single()

  if (!subData) {
    console.error('Subscription not found')
    return
  }

  // Create transaction record
  await createTransaction(supabase, subData.user_id, {
    transaction_type: 'renewal',
    transaction_status: 'failed',
    stripe_invoice_id: invoice.id,
    amount: invoice.amount_due / 100,
    currency: invoice.currency,
    description: 'Payment failed',
  })

  console.log('Payment failed recorded')
}

// ========================================
// Helper Functions
// ========================================

function getSubscriptionTier(priceId: string): string {
  // Map price IDs to tiers
  // Replace with your actual Stripe price IDs
  const tierMap: Record<string, string> = {
    'price_basic_monthly_placeholder': 'basic',
    'price_basic_yearly_placeholder': 'basic',
    'price_pro_monthly_placeholder': 'pro',
    'price_pro_yearly_placeholder': 'pro',
    'price_premium_monthly_placeholder': 'premium',
    'price_premium_yearly_placeholder': 'premium',
  }

  return tierMap[priceId] || 'free'
}

function getSubscriptionLimits(tier: string) {
  const limits: Record<string, any> = {
    free: { translation: 10, ocr: 5, voice: 5 },
    basic: { translation: 100, ocr: 50, voice: 50 },
    pro: { translation: 500, ocr: 200, voice: 200 },
    premium: { translation: -1, ocr: -1, voice: -1 }, // -1 = unlimited
  }

  return limits[tier] || limits.free
}

async function createTransaction(supabase: any, userId: string, data: any) {
  const { error } = await supabase
    .from('subscription_transactions')
    .insert({
      user_id: userId,
      ...data,
      created_at: new Date().toISOString(),
      completed_at: data.transaction_status === 'completed' ? new Date().toISOString() : null,
    })

  if (error) {
    console.error('Error creating transaction:', error)
  }
}
