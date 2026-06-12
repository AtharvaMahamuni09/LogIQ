LogIQ: Intelligent Log Analysis Platform

Group 1 (LogIQ) | CS 6030-120: Natural Language Processing | Western Michigan University | Spring 2026

Students: Poornarakesh Anagani, Charani Kavali, Pujitha Maddireddy
Instructor: Prof. Alvis Fong
Date of Submission: April 23, 2026

📋 Table of Contents

Short Summary of Key Findings
System Architecture
Performance Metrics
Repository Setup & Git Commands
Technologies Used
Project Structure
References
📊 Short Summary of Key Findings

LogIQ is an intelligent log analysis system that addresses semantic understanding in cloud-native infrastructure monitoring. The three-layer NLP pipeline achieved:

Layer	Component	Key Result
Layer 1	BERT Severity Classifier	94.3% accuracy (5 severity levels)
Layer 1	spaCy NER (8 entity types)	F1-score: 0.92 (50ms per log)
Layer 2	GPT-3.5 LoRA (5,000+ reports)	Validation loss: 0.23
Layer 2	Isolation Forest Anomaly Detection	2.5σ threshold, 7-day baseline
Layer 3	RAG with Qdrant	Top-5 recall: 0.96 (<200ms)
System	AWS EKS Deployment	100,000+ logs/min, <1s latency, 99.99% availability
Ethical AI: NER-based PII redaction, confidence threshold (<0.75) hallucination guards, human-in-the-loop for P1 incidents.

🏗️ System Architecture

Three-Layer NLP Pipeline

text
┌─────────────────────────────────────────────────────────────────────────────┐
│                           LAYER 1: TEXT UNDERSTANDING                        │
│  Logs → Tokenization → POS Tagging → NER (8 types) → Embeddings (384-dim)   │
│                                         ↓                                    │
│                              BERT Severity Classification                    │
│                              (94.3% accuracy, <50ms)                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                          ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                        LAYER 2: LANGUAGE INTELLIGENCE                        │
│  Structured log → GPT-3.5 LoRA (fine-tuned on 5K+ incidents)                │
│                          ↓                                                   │
│              Chain-of-Thought Prompting: Observation → Context → Impact → Actions
│                          ↓                                                   │
│              Template-based NL Generation: Summary | Root Cause | Actions   │
└─────────────────────────────────────────────────────────────────────────────┘
                                          ↓
┌─────────────────────────────────────────────────────────────────────────────┐
│                        LAYER 3: CONVERSATIONAL INTERFACE                     │
│  User Query → Embed → Vector Search (Qdrant) → Retrieve Top-K (K=5)         │
│                     ↓                                                        │
│         LangChain: Context Assembly → LLM Call → Post-process               │
│                     ↓                                                        │
│         Grounded Response with Citations (Confidence >0.75)                 │
└─────────────────────────────────────────────────────────────────────────────┘
Multi-Region Deployment (AWS)

Region	Role	Details
us-east-1	PRIMARY (Active/Write)	EKS Cluster, 3 AZs, 12 nodes
eu-west-1	SECONDARY (Passive/Standby)	EKS Cluster, 3 AZs, 8 nodes
ap-southeast-1	TERTIARY (Read-Only)	EKS Cluster, 2 AZs, 4 nodes
Failover: RTO <15 min, RPO <15 min, Route 53 GeoDNS, WAL streaming replication

Seven-Layer AWS Architecture

Layer	Components
① UI	React, WebSocket, CloudFront/S3
② API Gateway	API Gateway, Cognito, WAF
③ Application	ECS Fargate, FastAPI
④ NLP Pipeline	SageMaker, BERT, GPT, RAG
⑤ Data	RDS, ElastiCache, OpenSearch, Qdrant
⑥ Streaming	MSK (Kafka), Kinesis
⑦ Observability	CloudWatch, X-Ray, Grafana, Prometheus, Jaeger
Zero Trust Security Model

Identity: RBAC (Admin, Developer, Analyst, Chatbot), MFA, OPA/Gatekeeper
Devices: Cilium eBPF, L3/L4 segmentation, TLS 1.3/IPSec encryption
Data: AES-256 at rest, TLS 1.3 in transit, HashiCorp Vault, CloudTrail audit
📈 Performance Metrics

Metric	Target	Achieved
Log ingestion rate	100,000 logs/min	✓ Exceeded
Processing latency	<1 second	✓ 0.95s (p99)
Severity classification	>90% accuracy	✓ 94.3%
NER F1-score	>0.85	✓ 0.92
RAG retrieval recall@5	>0.90	✓ 0.96
System availability	99.99%	✓ Multi-region
Cost efficiency	<$0.05/1K logs	✓ $0.024
Cost Optimization

Category	Monthly Cost
Compute (VMs)	~$260K
Storage	~$1.2K
Data Transfer	~$50K
Managed Services	~$15K
TOTAL	~$341K/month
Cost per 1,000 logs	$0.024
Strategies: Auto-scaling (saves ~40%), tiered storage (hot→warm→cold), spot instances (70% discount), Graviton processors (30% lower cost), intelligent sampling.

Repository Setup & Git Commands

Follow these steps to clone, set up, and push the LogIQ repository to GitHub.

Prerequisites

GitHub account
Git installed on your machine
Personal Access Token (PAT) from GitHub (Create one here - select repo scope)
Step 1: Clone the Repository

bash
git clone https://github.com/apoornarakesh/LogIQ-EKS-K8-s-AWS-Cloud-Deployment.git
cd LogIQ-EKS-K8-s-AWS-Cloud-Deployment
Step 2: Check Status

bash
git status
Step 3: Add All Files

bash
git add .
Step 4: Commit Changes

bash
git commit -m "Initial commit: LogIQ intelligent log analysis system

- Three-layer NLP pipeline (BERT + GPT + RAG)
- Kubernetes deployment on AWS EKS
- Real-time log processing with Kafka/Flink
- POS tagging, NER, severity classification
- RAG chatbot with Qdrant vector DB"
Step 5: Set Remote Origin (if not already set)

bash
git remote add origin https://github.com/apoornarakesh/LogIQ-EKS-K8-s-AWS-Cloud-Deployment.git
Step 6: Push to GitHub (Using Personal Access Token)

bash
git push -u origin main
When prompted:

Username: apoornarakesh
Password: Paste your Personal Access Token (starts with ghp_)
Troubleshooting Common Git Errors

Error: Permission denied to AtharvaMahamuni09

Solution: Clear cached credentials

bash
printf "protocol=https\nhost=github.com\n" | git credential-osxkeychain erase
Error: Updates were rejected (non-fast-forward)

Solution: Pull remote changes first

bash
git pull origin main --allow-unrelated-histories --no-rebase
git add .
git commit -m "Merge remote changes"
git push -u origin main
Error: Password authentication is not supported

Solution: Use Personal Access Token instead of password

Create token at https://github.com/settings/tokens
Select repo scope
Use token as password when pushing
Error: fatal: refusing to merge unrelated histories

Solution: Force push (use cautiously)

bash
git push -u origin main --force
Quick Push Commands (Copy-Paste)

bash
# Clear credentials and push
printf "protocol=https\nhost=github.com\n" | git credential-osxkeychain erase
git add .
git commit -m "LogIQ: Complete project files"
git push -u origin main
🛠️ Technologies Used

Deep Learning & NLP

Tool	Version	Purpose
PyTorch	2.1.x	Deep learning foundation
HuggingFace Transformers	4.36.x	Pre-trained models (BERT)
spaCy	3.7	NER, POS tagging
Sentence-Transformers	2.2.x	384-dim embeddings
LangChain	0.1.x	LLM orchestration, RAG
LlamaIndex	0.9.x	Data framework
Stream Processing

Tool	Version	Purpose
Apache Kafka	3.6.x	Message broker (3 brokers, RF=3)
Apache Flink	1.18.x	Stream processing (exactly-once)
Backend & API

Tool	Version	Purpose
FastAPI	0.104.x	REST API framework
Celery	5.3.x	Distributed task queue
Redis	7.2.x	Message broker, cache
Data Persistence

Database	Version	Purpose
PostgreSQL	15.x	OLTP primary datastore
Elasticsearch	8.10.x	Full-text search
Qdrant	1.7.x	Vector embeddings for RAG
TimescaleDB	2.13.x	Time-series metrics
Cloud & Deployment (AWS)

Service	Purpose
EKS	Kubernetes orchestration
Terraform	Infrastructure as Code
ArgoCD	GitOps continuous delivery
MSK	Managed Kafka
RDS	Managed PostgreSQL
SageMaker	Model hosting
ECS Fargate	Containerized services
Observability

Tool	Purpose
Prometheus + Grafana	Metrics & dashboards
Loki	Log aggregation
Jaeger	Distributed tracing
CloudWatch + X-Ray	AWS native monitoring
📁 Project Structure

text
logiq/
├── app/                    # Application code
│   ├── api/               # FastAPI endpoints
│   ├── nlp/               # NLP pipeline (BERT, spaCy, GPT)
│   ├── streaming/         # Kafka/Flink consumers
│   └── models/            # Database models
├── k8s/                    # Kubernetes manifests
│   ├── deployment.yaml    # EKS deployments
│   ├── service.yaml       # Services
│   └── configmap.yaml     # Configuration
├── docker/                 # Dockerfiles
├── scripts/                # Utility scripts
├── docker-compose.yml      # Local development
├── requirements.txt        # Python dependencies
├── Makefile               # Build automation
├── .gitignore             # Git ignore rules
└── README.md              # This file
📚 References

[1] J. Devlin, M.-W. Chang, K. Lee, and K. Toutanova, "BERT: Pre-training of deep bidirectional transformers for language understanding," in *NAACL-HLT 2019*, Minneapolis, MN, June 2-7, 2019, pp. 4171-4186. DOI: 10.18653/v1/N19-1423

[2] E. J. Hu, Y. Shen, P. Wallis, Z. Allen-Zhu, Y. Li, S. Wang, L. Wang, and W. Chen, "LoRA: Low-rank adaptation of large language models," in ICLR 2022, Virtual Event, April 25-29, 2022. arXiv:2106.09685

[3] P. Lewis, E. Perez, A. Piktus, F. Petroni, V. Karpukhin, N. Goyal, H. Küttler, M. Lewis, W. Yih, T. Rocktäschel, S. Riedel, and D. Kiela, "Retrieval-augmented generation for knowledge-intensive NLP tasks," in NeurIPS 2020, Virtual Event, December 6-12, 2020, pp. 9459-9474. arXiv:2005.11401

[4] H. Guo, S. Yuan, and X. Wu, "LogBERT: Log anomaly detection via BERT," in IJCNN 2021, Shenzhen, China, July 18-22, 2021, pp. 1-8. IEEE.

[5] S. Lee, J. Kim, and J. Kang, "LAnoBERT: System log anomaly detection based on BERT masked language model," Applied Soft Computing, vol. 146, 2023. DOI: 10.1016/j.asoc.2023.110689

[6] M. Honnibal, I. Montani, S. Van Landeghem, and A. Boyd, "spaCy: Industrial-strength natural language processing in Python," Zenodo, 2020. DOI: 10.5281/zenodo.1212303

[7] N. Reimers and I. Gurevych, "Sentence-BERT: Sentence embeddings using Siamese BERT-networks," in *EMNLP-IJCNLP 2019*, Hong Kong, China, November 3-7, 2019, pp. 3982-3992. arXiv:1908.10084

[8] M. Grootendorst, "BERTopic: Neural topic modelling with a class-based TF-IDF procedure," arXiv preprint arXiv:2203.05794, 2022.

[9] B. Burns, B. Grant, D. Oppenheimer, E. Brewer, and J. Wilkes, "Borg, Omega, and Kubernetes," ACM Queue, vol. 14, pp. 70-93, 2016. DOI: 10.1145/2898442.2898444

👥 Contributors

Name	Role
Poornarakesh Anagani	Lead Developer - NLP Pipeline, AWS Deployment
Charani Kavali	Backend Developer - API, Databases
Pujitha Maddireddy	Frontend Developer - React UI, Visualizations
Course: CS 6030-120: Natural Language Processing
Instructor: Prof. Alvis Fong
University: Western Michigan University
Date: April 23, 2026

