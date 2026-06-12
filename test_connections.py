#!/usr/bin/env python
"""
Test script to verify all services are running
"""
import sys
import psycopg2
import redis
from kafka import KafkaProducer, KafkaConsumer
from qdrant_client import QdrantClient
from elasticsearch import Elasticsearch

def test_postgres():
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="logiq",
            user="logiq",
            password="logiq123"
        )
        conn.close()
        print("✓ PostgreSQL: Connected")
        return True
    except Exception as e:
        print(f"✗ PostgreSQL: {e}")
        return False

def test_redis():
    try:
        r = redis.Redis(host="localhost", port=6379)
        r.ping()
        print("✓ Redis: Connected")
        return True
    except Exception as e:
        print(f"✗ Redis: {e}")
        return False

def test_kafka():
    try:
        producer = KafkaProducer(bootstrap_servers="localhost:9092")
        producer.close()
        print("✓ Kafka: Connected")
        return True
    except Exception as e:
        print(f"✗ Kafka: {e}")
        return False

def test_qdrant():
    try:
        client = QdrantClient(host="localhost", port=6333)
        client.get_collections()
        print("✓ Qdrant: Connected")
        return True
    except Exception as e:
        print(f"✗ Qdrant: {e}")
        return False

def test_elasticsearch():
    try:
        es = Elasticsearch(["http://localhost:9200"])
        es.ping()
        print("✓ Elasticsearch: Connected")
        return True
    except Exception as e:
        print(f"✗ Elasticsearch: {e}")
        return False

if __name__ == "__main__":
    print("Testing service connections...\n")
    
    tests = [
        test_postgres,
        test_redis,
        test_kafka,
        test_qdrant,
        test_elasticsearch
    ]
    
    results = [test() for test in tests]
    
    print(f"\nSummary: {sum(results)}/{len(results)} services connected")
    
    sys.exit(0 if all(results) else 1)
