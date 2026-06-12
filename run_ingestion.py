"""
Main log ingestion script
Run this to start producing and consuming logs
"""
import sys
import threading
import time
from app.services.kafka_producer import LogProducer
from app.services.kafka_consumer import LogConsumer
from app.services.log_preprocessor import LogPreprocessor
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def run_producer():
    """Run the log producer"""
    producer = LogProducer()
    try:
        logger.info("Starting log producer...")
        producer.produce_logs(logs_per_minute=10000)  # 10K logs/min
    except KeyboardInterrupt:
        logger.info("Stopping producer...")
        producer.stop()
    except Exception as e:
        logger.error(f"Producer error: {e}")
        producer.stop()

def run_consumer():
    """Run the log consumer with preprocessing"""
    consumer = LogConsumer()
    preprocessor = LogPreprocessor()
    
    def process_with_preprocessing(log_entry):
        processed = preprocessor.preprocess(log_entry)
        logger.debug(f"Processed log: {processed.get('level')} - {len(processed.get('tokens', []))} tokens")
        return True
    
    try:
        logger.info("Starting log consumer...")
        consumer.consume_with_exactly_once(callback=process_with_preprocessing)
    except KeyboardInterrupt:
        logger.info("Stopping consumer...")
        consumer.close()
    except Exception as e:
        logger.error(f"Consumer error: {e}")
        consumer.close()

def main():
    """Run both producer and consumer in separate threads"""
    logger.info("=" * 50)
    logger.info("LogIQ Ingestion Pipeline Starting...")
    logger.info("=" * 50)
    
    # Create and start threads
    producer_thread = threading.Thread(target=run_producer, daemon=True)
    consumer_thread = threading.Thread(target=run_consumer, daemon=True)
    
    producer_thread.start()
    consumer_thread.start()
    
    logger.info("✅ Producer thread started")
    logger.info("✅ Consumer thread started")
    logger.info("📊 Processing 10,000 logs per minute...")
    logger.info("Press Ctrl+C to stop")
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("\n🛑 Shutting down...")
        sys.exit(0)

if __name__ == "__main__":
    main()
