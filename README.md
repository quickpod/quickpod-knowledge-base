# QuickPod Knowledge Base

This repository stores the public knowledge base used by QuickPod Assistant.

## Purpose

- Product and feature documentation for retrieval-augmented answers.
- FAQ, onboarding, billing, and workflow guidance.
- Curated training pairs for optional supervised fine-tuning.

## Repository Layout

- `docs/product/`: product overviews, feature specs, pricing behavior, limits.
- `docs/guides/`: step-by-step user workflows.
- `docs/faq/`: common user questions and short answers.
- `docs/policies/`: safety, privacy, billing, and support policy docs.
- `qa/`: curated JSONL training pairs for optional LoRA/SFT.

## Assistant Integration

Point the QuickPod assistant service at this repository during deployment:

```bash
KNOWLEDGE_BASE_BOOTSTRAP_MODE=git
KNOWLEDGE_BASE_GIT_URL=https://github.com/<owner>/quickpod-knowledge-base.git
KNOWLEDGE_BASE_GIT_REF=main
KNOWLEDGE_BASE_GIT_SUBDIR=
KB_BOOTSTRAP_ON_START=true
KB_BOOTSTRAP_REQUIRED=true
```

The assistant container will sync this repository into `/workspace/knowledge-base` on startup and index it for retrieval.

## Publish To GitHub

This local repository includes `publish-github.sh` for creating a public GitHub repository and pushing this content once a token is available.

Example:

```bash
cd /home/ubuntu/quickpod-knowledge-base
GITHUB_TOKEN=... ./publish-github.sh dosvak quickpod-knowledge-base
```

## Content Rules

- Store only public or user-safe content here.
- Do not include admin-only procedures, secrets, tokens, internal dashboards, or private user data.
- Keep docs factual, concise, and versioned.
- Prefer Markdown for human-authored content.

## Optional Fine-Tuning Data

Use `qa/training-pairs.example.jsonl` as the schema reference for supervised fine-tuning pairs.

Each line should look like:

```json
{"question":"How do I deploy a pod cluster?","answer":"Open Clusters, choose a template, select an offer, and create the cluster.","contexts":["Clusters let you run one or more replicas from a selected template."]}
```