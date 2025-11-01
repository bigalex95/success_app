-- Supabase Database Setup Script
-- Run this in your Supabase SQL Editor to create the required tables

-- Create habits table
CREATE TABLE IF NOT EXISTS habits (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create progress table
CREATE TABLE IF NOT EXISTS progress (
  id BIGSERIAL PRIMARY KEY,
  habit_id BIGINT NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  completed INTEGER NOT NULL DEFAULT 0 CHECK (completed IN (0, 1)),
  notes TEXT,
  UNIQUE(habit_id, date)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_progress_habit_id ON progress(habit_id);
CREATE INDEX IF NOT EXISTS idx_progress_date ON progress(date);
CREATE INDEX IF NOT EXISTS idx_progress_completed ON progress(completed);
CREATE INDEX IF NOT EXISTS idx_habits_created_at ON habits(created_at);

-- Enable Row Level Security (RLS) - optional but recommended
-- For now, we'll allow all operations. You can customize this later for user-specific data
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress ENABLE ROW LEVEL SECURITY;

-- Create policies to allow all operations (for single-user app)
-- For multi-user app, you'd want to add user_id column and restrict access
CREATE POLICY "Allow all operations on habits" ON habits
  FOR ALL USING (true) WITH CHECK (true);

CREATE POLICY "Allow all operations on progress" ON progress
  FOR ALL USING (true) WITH CHECK (true);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at on habits table
CREATE TRIGGER update_habits_updated_at
  BEFORE UPDATE ON habits
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

