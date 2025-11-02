-- Enable Real-time Replication for Success App
-- Run this in your Supabase SQL Editor to enable real-time synchronization

-- Enable realtime for habits table
alter publication supabase_realtime add table habits;

-- Enable realtime for progress table
alter publication supabase_realtime add table progress;

-- Enable realtime for assistant_conversations table
alter publication supabase_realtime add table assistant_conversations;

-- Verify real-time is enabled
SELECT schemaname, tablename 
FROM pg_publication_tables 
WHERE pubname = 'supabase_realtime';
