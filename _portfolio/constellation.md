---
title: "Constellation: Milestone 1"
subtitle: "A personal database with semantic search"
layout: section
date: 2025-04-02
updated: null
tags:
  - portfolio
  - docker-compose
  - constellation
  - weaviate
---
![Detailed anatomical illustration of the human brain and nervous system, highlighting neural pathways and blood vessels in vibrant colors.](/assets/images/brain.png)
# 🔭 Constellation Milestone 1: Debugging, Refactoring, and Overengineering

At work, I am a data analyst and primarily develop and implement buisness logic that is embedded in complex data pipelines. But I wanted a toy version of what I am only a small part of at work. Soething I could fully own, build from scratch, and do *"right"* (sorry to my colleagues for my naïveté 🫶). So I started building **Constellation**: a self-hosted, AI-powered journaling and search system designed to explore how personal knowledge evolves over time.

This week, I wrapped up **Milestone 1**, and I wanted to share a bit of the process, the bugs, the structure, and a tiny demo.


## 🛠️ What I Built

The architecture:

- **Second Brain**: Ingests and stores journal entries via a FastAPI service + Postgres
- **Constellation**: Handles search and AI logic, powered by Weaviate and OpenAI embeddings
- **CLI**: A simple interface using the Typer python module for adding, retrieving, and semantically searching entries using cosine similarity 

![Mermaid.js diagram of semantic search architecture](/assets/images/constellation-architecture-1.jpeg "Early mermaid.js architecture diagram that needs updating.")

## 🪡 Using Weaviate in the Stack

Here's a quick example of how I’m sending entries to Weaviate:

```python
def index_journal_entry(entry_id: str, content: str):
    url = f"{WEAVIATE_URL}/v1/objects"
    payload = {
        "class": "JournalEntry",
        "id": str(entry_id),
        "properties": {
            "content": content
        }
    }
    requests.post(url, json=payload)
```

Right now I'm using the **`text2vec-openai`** module. It’s hosted, lightweight, and lets me focus on wiring everything together before I explore alternatives like SentenceTransformers or Cohere.

## 🤕 What Broke 

### 🔄 Persistent Volumes Aren’t Persisting
Every time I reinitialize Weaviate, I lose my vector index—despite having a persistent volume configured in Docker. Something in the mount path or volume handling is off, and it's on my list to fully debug during the next refactor.

### 🫥 My Reindexing Script Ghosted Me
I wrote a full reindexing flow to repopulate Weaviate from Second Brain. It doesn’t error... but it doesn’t work either. No logs. No entries. Just the illusion that something is working. 

For now, I can keep things working in a single session, and that’s good enough to call Milestone 1 **done** (especially since I plan to restructure the entire thing anyway).


## 🎉 What *Did* Work

This was my first completely solo Python project and wow, it’s been satisfying to see it all come together.

I’ve used RESTful APIs and HTTP requests plenty at work, but mostly inside massive, tangled Jupyter notebooks meant for data analysis. This time, I built:

- A modular FastAPI backend
- A clean journal service
- Docker containers with (mostly) sane networking
- A CLI tool to interact with the whole stack
- And a semantic search pipeline using Weaviate + OpenAI embeddings

It feels **artisanal**. And I love it.


##  CLI Demo: Journaling + Semantic Search in Action
Here’s a quick look at how Constellation works when running locally inside the container. The CLI is my little testbench—it hits the FastAPI routes in second-brain and triggers search through constellation.

### 🗂️ Step 1: Check for existing entries
```bash
$ python cli.py get-entries
📡 Fetching entries from http://second-brain:8000/entries/
No journal entries found.
```

### 📝 Step 2: Add some journal entries
```bash
$ python cli.py add-entry "My Cat" "My cat is named Bonnie"
📡 Sending entry to http://second-brain:8000/add_entry/
✅ Entry added successfully!
```
```bash
$ python cli.py add-entry "Origin" "I was born in California"
📡 Sending entry to http://second-brain:8000/add_entry/
✅ Entry added successfully!
```
```bash
$ python cli.py add-entry "Park" "Today Ashwin squeegeed all the play equipment like he was a mini parks and rec employee"
📡 Sending entry to http://second-brain:8000/add_entry/
✅ Entry added successfully!
```

### 📖 Step 3: List all entries
```bash
$ python cli.py get-entries
📡 Fetching entries from http://second-brain:8000/entries/
📖 Journal Entries:
📝 ID: 50ea3333-6e3f-4ce0-87ad-0273179b20b9 | Title: My Cat
    → Content: My cat is named Bonnie
    → Created At: 2025-03-17T05:19:14.332641

📝 ID: dac149d7-c6eb-4ca5-af4d-fd025334d334 | Title: Origin
    → Content: I was born in California
    → Created At: 2025-03-17T05:19:56.059977

📝 ID: 7089cf18-5c92-4151-9ea5-b489c3cbec26 | Title: Park
    → Content: Today Ashwin squeegeed all the play equipment like he was a mini parks and rec employee
    → Created At: 2025-03-17T05:21:56.239169
```

### 🔍 Step 4: Semantic Search — “pet”
```bash
$ python cli.py search "pet"
🔍 Searching for 'pet' using Weaviate at http://weaviate:8080/v1/graphql
✅ Found entry with ID: 50ea3333-6e3f-4ce0-87ad-0273179b20b9 (certainty: 0.638)
📡 Fetching entry details from Second Brain at http://second-brain:8000/entries/50ea3333-6e3f-4ce0-87ad-0273179b20b9/
📖 Journal Entry Details:
📝 ID: 50ea3333-6e3f-4ce0-87ad-0273179b20b9
📝 Title: My Cat
📝 Content: My cat is named Bonnie
📝 Created At: 2025-03-17T05:19:14.332641
```

### 🔍 Step 5: Semantic Search — “toddler”
```bash
$ python cli.py search "toddler"
🔍 Searching for 'toddler' using Weaviate at http://weaviate:8080/v1/graphql
✅ Found entry with ID: 7089cf18-5c92-4151-9ea5-b489c3cbec26 (certainty: 0.547)
📡 Fetching entry details from Second Brain at http://second-brain:8000/entries/7089cf18-5c92-4151-9ea5-b489c3cbec26/
📖 Journal Entry Details:
📝 ID: 7089cf18-5c92-4151-9ea5-b489c3cbec26
📝 Title: Park
📝 Content: Today Ashwin squeegeed all the play equipment like he was a mini parks and rec employee
📝 Created At: 2025-03-17T05:21:56.239169
```
The search isn’t keyword-based—it’s **semantic**, powered by `text2vec-openai`. So even though “pet” and “toddler” aren’t in the journal text directly, the system gets it. That’s the magic.


## 💍 Milestone 2: One Repo to Rule Them All

I started with two repos—one for Second Brain, one for Constellation—but context-switching between them became a pain. Two `main.py`s, two `endpoints.py`s, and constant mental overhead.

So for Milestone 2, I’m merging everything into a **single monorepo** with clean service boundaries. Still microservice-ish, just without the branching chaos.

I’m hoping the restructure will also:
- Reveal why my Weaviate volume isn’t persisting
- Help debug the broken reindexing logic
- Let me move faster without sacrificing clarity


## 🪞 Reflections

I’ve spent way too much time cosplaying as a product manager, writing user stories and drawing architecture diagrams I’ll immediately break. I’ve also realized I have no idea how to balance **big-picture ideas** with the **tedium of debugging Python path hell**.

But I'm learning. And it’s deeply satisfying to make something that works, sort of.


## ...Coming Soon

- Better error handling + observability
- Reindexing that actually… reindexes
- Persistent volumes that persist
- A mind-mapping UI on top of the API
- Integration with external data (YNAB, calendar, etc.)


If you're also working on personal infrastructure, AI search, or data architecture experiments, I’d love to trade notes. And if you know how to make VS Code act more like IntelliJ when moving files... *please* send help 🙏