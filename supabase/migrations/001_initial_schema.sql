-- ========================================
-- Live Translate App - Supabase Database Schema
-- ========================================
-- This file contains all table definitions for the app
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ========================================
-- 1. User Subscriptions Table
-- ========================================
CREATE TABLE IF NOT EXISTS user_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Subscription Details
    subscription_tier VARCHAR(50) NOT NULL CHECK (subscription_tier IN ('free', 'basic', 'pro', 'premium')),
    subscription_status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (subscription_status IN ('active', 'cancelled', 'expired', 'paused')),
    
    -- Stripe Integration
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    stripe_price_id VARCHAR(255),
    
    -- Billing Period
    billing_period VARCHAR(20) CHECK (billing_period IN ('monthly', 'yearly')),
    current_period_start TIMESTAMP WITH TIME ZONE,
    current_period_end TIMESTAMP WITH TIME ZONE,
    
    -- Trial Information
    trial_start TIMESTAMP WITH TIME ZONE,
    trial_end TIMESTAMP WITH TIME ZONE,
    is_trial BOOLEAN DEFAULT false,
    
    -- Usage Limits
    daily_translation_limit INTEGER DEFAULT 10,
    daily_ocr_limit INTEGER DEFAULT 5,
    daily_voice_limit INTEGER DEFAULT 5,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    cancelled_at TIMESTAMP WITH TIME ZONE,
    
    -- Indexes
    UNIQUE(user_id),
    UNIQUE(stripe_customer_id),
    UNIQUE(stripe_subscription_id)
);

-- Create index for faster queries
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(subscription_status);
CREATE INDEX idx_user_subscriptions_tier ON user_subscriptions(subscription_tier);

-- ========================================
-- 2. Subscription Transactions Table
-- ========================================
CREATE TABLE IF NOT EXISTS subscription_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    subscription_id UUID REFERENCES user_subscriptions(id) ON DELETE SET NULL,
    
    -- Transaction Details
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('subscription', 'upgrade', 'downgrade', 'renewal', 'cancellation', 'refund')),
    transaction_status VARCHAR(50) NOT NULL CHECK (transaction_status IN ('pending', 'completed', 'failed', 'refunded')),
    
    -- Stripe Details
    stripe_payment_intent_id VARCHAR(255),
    stripe_invoice_id VARCHAR(255),
    
    -- Amount
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    
    -- Metadata
    description TEXT,
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Indexes
    UNIQUE(stripe_payment_intent_id)
);

CREATE INDEX idx_transactions_user_id ON subscription_transactions(user_id);
CREATE INDEX idx_transactions_status ON subscription_transactions(transaction_status);
CREATE INDEX idx_transactions_created_at ON subscription_transactions(created_at DESC);

-- ========================================
-- 3. Usage Tracking Table
-- ========================================
CREATE TABLE IF NOT EXISTS usage_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Usage Type
    usage_type VARCHAR(50) NOT NULL CHECK (usage_type IN ('translation', 'ocr', 'voice', 'camera')),
    
    -- Usage Details
    source_language VARCHAR(10),
    target_language VARCHAR(10),
    character_count INTEGER,
    
    -- Metadata
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    date DATE DEFAULT CURRENT_DATE
);

CREATE INDEX idx_usage_tracking_user_id ON usage_tracking(user_id);
CREATE INDEX idx_usage_tracking_date ON usage_tracking(date DESC);
CREATE INDEX idx_usage_tracking_type ON usage_tracking(usage_type);
CREATE INDEX idx_usage_tracking_user_date ON usage_tracking(user_id, date);

-- ========================================
-- 4. Bookmarks Table
-- ========================================
CREATE TABLE IF NOT EXISTS bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Translation Content
    source_text TEXT NOT NULL,
    translated_text TEXT NOT NULL,
    source_language VARCHAR(10) NOT NULL,
    target_language VARCHAR(10) NOT NULL,
    
    -- Bookmark Details
    title VARCHAR(255),
    notes TEXT,
    tags TEXT[],
    is_favorite BOOLEAN DEFAULT false,
    
    -- Metadata
    translation_type VARCHAR(50) CHECK (translation_type IN ('text', 'ocr', 'voice', 'camera')),
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_bookmarks_user_id ON bookmarks(user_id);
CREATE INDEX idx_bookmarks_created_at ON bookmarks(created_at DESC);
CREATE INDEX idx_bookmarks_favorite ON bookmarks(is_favorite);
CREATE INDEX idx_bookmarks_tags ON bookmarks USING GIN(tags);

-- ========================================
-- 5. Browsing History Table
-- ========================================
CREATE TABLE IF NOT EXISTS browsing_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Translation Content
    source_text TEXT NOT NULL,
    translated_text TEXT,
    source_language VARCHAR(10) NOT NULL,
    target_language VARCHAR(10) NOT NULL,
    
    -- History Details
    translation_type VARCHAR(50) CHECK (translation_type IN ('text', 'ocr', 'voice', 'camera')),
    
    -- Metadata
    metadata JSONB,
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_history_user_id ON browsing_history(user_id);
CREATE INDEX idx_history_created_at ON browsing_history(created_at DESC);
CREATE INDEX idx_history_user_created ON browsing_history(user_id, created_at DESC);

-- ========================================
-- 6. Translations Cache Table
-- ========================================
CREATE TABLE IF NOT EXISTS translations_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Cache Key (hash of source text + languages)
    cache_key VARCHAR(255) NOT NULL UNIQUE,
    
    -- Translation Content
    source_text TEXT NOT NULL,
    translated_text TEXT NOT NULL,
    source_language VARCHAR(10) NOT NULL,
    target_language VARCHAR(10) NOT NULL,
    
    -- Cache Metadata
    hit_count INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '30 days')
);

CREATE INDEX idx_cache_key ON translations_cache(cache_key);
CREATE INDEX idx_cache_expires_at ON translations_cache(expires_at);

-- ========================================
-- 7. OCR Results Cache Table
-- ========================================
CREATE TABLE IF NOT EXISTS ocr_cache (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Cache Key (hash of image)
    image_hash VARCHAR(255) NOT NULL UNIQUE,
    
    -- OCR Results
    extracted_text TEXT NOT NULL,
    confidence_score DECIMAL(5, 2),
    language VARCHAR(10),
    
    -- Cache Metadata
    hit_count INTEGER DEFAULT 0,
    last_accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT (NOW() + INTERVAL '7 days')
);

CREATE INDEX idx_ocr_cache_hash ON ocr_cache(image_hash);
CREATE INDEX idx_ocr_cache_expires_at ON ocr_cache(expires_at);

-- ========================================
-- Row Level Security (RLS) Policies
-- ========================================

-- Enable RLS on all tables
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_tracking ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE browsing_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE translations_cache ENABLE ROW LEVEL SECURITY;
ALTER TABLE ocr_cache ENABLE ROW LEVEL SECURITY;

-- User Subscriptions Policies
CREATE POLICY "Users can view their own subscription"
    ON user_subscriptions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own subscription"
    ON user_subscriptions FOR UPDATE
    USING (auth.uid() = user_id);

-- Subscription Transactions Policies
CREATE POLICY "Users can view their own transactions"
    ON subscription_transactions FOR SELECT
    USING (auth.uid() = user_id);

-- Usage Tracking Policies
CREATE POLICY "Users can view their own usage"
    ON usage_tracking FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own usage"
    ON usage_tracking FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Bookmarks Policies
CREATE POLICY "Users can manage their own bookmarks"
    ON bookmarks FOR ALL
    USING (auth.uid() = user_id);

-- Browsing History Policies
CREATE POLICY "Users can manage their own history"
    ON browsing_history FOR ALL
    USING (auth.uid() = user_id);

-- Cache Policies (Public read for efficiency)
CREATE POLICY "Anyone can read cache"
    ON translations_cache FOR SELECT
    USING (true);

CREATE POLICY "Anyone can read OCR cache"
    ON ocr_cache FOR SELECT
    USING (true);

-- ========================================
-- Functions and Triggers
-- ========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for user_subscriptions
CREATE TRIGGER update_user_subscriptions_updated_at
    BEFORE UPDATE ON user_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for bookmarks
CREATE TRIGGER update_bookmarks_updated_at
    BEFORE UPDATE ON bookmarks
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to clean expired cache
CREATE OR REPLACE FUNCTION clean_expired_cache()
RETURNS void AS $$
BEGIN
    DELETE FROM translations_cache WHERE expires_at < NOW();
    DELETE FROM ocr_cache WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to get daily usage count
CREATE OR REPLACE FUNCTION get_daily_usage_count(
    p_user_id UUID,
    p_usage_type VARCHAR
)
RETURNS INTEGER AS $$
DECLARE
    usage_count INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO usage_count
    FROM usage_tracking
    WHERE user_id = p_user_id
        AND usage_type = p_usage_type
        AND date = CURRENT_DATE;
    
    RETURN COALESCE(usage_count, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to check if user has active subscription
CREATE OR REPLACE FUNCTION has_active_subscription(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    is_active BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1
        FROM user_subscriptions
        WHERE user_id = p_user_id
            AND subscription_status = 'active'
            AND (current_period_end IS NULL OR current_period_end > NOW())
    ) INTO is_active;
    
    RETURN COALESCE(is_active, false);
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- Initial Data / Seed
-- ========================================

-- Insert default free tier for new users (via trigger)
CREATE OR REPLACE FUNCTION create_default_subscription()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO user_subscriptions (
        user_id,
        subscription_tier,
        subscription_status,
        daily_translation_limit,
        daily_ocr_limit,
        daily_voice_limit
    ) VALUES (
        NEW.id,
        'free',
        'active',
        10,
        5,
        5
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION create_default_subscription();

-- ========================================
-- Indexes for Performance
-- ========================================

-- Composite indexes for common queries
CREATE INDEX idx_subscriptions_user_status ON user_subscriptions(user_id, subscription_status);
CREATE INDEX idx_usage_user_type_date ON usage_tracking(user_id, usage_type, date);
CREATE INDEX idx_bookmarks_user_created ON bookmarks(user_id, created_at DESC);

-- ========================================
-- Comments for Documentation
-- ========================================

COMMENT ON TABLE user_subscriptions IS 'Stores user subscription information and limits';
COMMENT ON TABLE subscription_transactions IS 'Tracks all subscription-related transactions';
COMMENT ON TABLE usage_tracking IS 'Tracks daily usage for rate limiting';
COMMENT ON TABLE bookmarks IS 'Stores user bookmarked translations';
COMMENT ON TABLE browsing_history IS 'Stores translation history';
COMMENT ON TABLE translations_cache IS 'Caches translations for performance';
COMMENT ON TABLE ocr_cache IS 'Caches OCR results for performance';
