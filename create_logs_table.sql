-- Create logs table in PostgreSQL
CREATE TABLE IF NOT EXISTS logs (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    level VARCHAR(20),
    source VARCHAR(100),
    message TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster queries
CREATE INDEX idx_logs_timestamp ON logs(timestamp DESC);
CREATE INDEX idx_logs_level ON logs(level);
CREATE INDEX idx_logs_source ON logs(source);

-- Insert sample data if table is empty
INSERT INTO logs (level, source, message, metadata)
SELECT * FROM (
    VALUES 
        ('INFO', 'api', 'Server started on port 8000', '{"host": "localhost"}'::jsonb),
        ('ERROR', 'database', 'Connection timeout after 30s', '{"retries": 3}'::jsonb),
        ('WARNING', 'auth', 'Failed login attempt from 192.168.1.100', '{"attempts": 2}'::jsonb),
        ('INFO', 'payment', 'Payment processed for order #12345', '{"amount": 99.99}'::jsonb)
) AS sample(level, source, message, metadata)
WHERE NOT EXISTS (SELECT 1 FROM logs LIMIT 1);
