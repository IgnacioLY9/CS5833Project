# Ignacio Yockers CS 5833 Project <a href="#"><img align="right" src=".github/assets/logo.svg" height="80px" /></a>

This codebase updates the open-source project Blobscan. Blobscan is a block explorer that focuses on Ethereum blobs.

The Blobscan website can be found [here](https://blobscan.com/). The original Blobscan github repository can be found [here](https://github.com/Blobscan/blobscan).

# Objective of this repository

This repositry is for the final project of OU's Spring 2026 CS 5833 Blockchains and Cryptocurrencies class. 

# Video showcase of this project

[Demonstration video](https://youtu.be/9WzsHFktUIU)

# Features/Improvements added by this project

- **New API Endpoint** - Returns a 5 number summary of blob gas prices

- **New API Endpoint** - Query blob gas price for custom time interval.

- **New API Endpoint** - Query information about transactions contained in a blob.

- **New API Endpoint** - Query blob gas price for a specific blob.

- **New Tests** - Tests matching the original tests were added for the new API endpoints added in this project.

- **Updated Official Installation Guide** - When I originally tried following the [installation guide](https://docs.blobscan.com/docs/installation), I experiend a lot of trouble. Using docker was not good for development of this repository. Additionally, the guide for running the project locally is confusing, spread across multiple pages on the documentation page, and did not work.

- **Updated API documentation** - The original API documentation does not contain a lot of detail. I improved the descriptions of the API endpoints I am familiar with.

Code for the added API endpoints can be found in `/packages/api/src/routers`.

Code for the added tests can be found in `/packages/api/test`.


# Installation/Build

Requirements:

Node.js 20

pnpm

psql

docker compose

Clone the repo:

```bash
git clone https://github.com/IgnacioLY9/CS5833Project.git
cd blobscan
```

Set env file:

```bash
cp .env.example .env
```

For the purposes of this guide, you need to update:

SECRET_KEY, BEACON_NODE_ENDPOINT, EXECUTION_NODE_ENDPOINT

DATABASE_URL=postgresql://blobscan:s3cr3t@localhost:5432/blobscan_dev?schema=public

DIRECT_URL=postgresql://blobscan:s3cr3t@localhost:5432/blobscan_dev?schema=public

Install dependencies:

```bash
pnpm fetch -r
pnpm install -r
NODE_ENV=production SKIP_ENV_VALIDATION=true npm run build
```

If this does not work due to a lack of space on the stack, you may need to run a command like this:

```bash
NODE_OPTIONS="--max-old-space-size=4096" NODE_ENV=production SKIP_ENV_VALIDATION=true npm run build
```

# Run

Launch Docker for postgres and redis:

```bash
docker compose -f docker-compose.local.yml up -d postgres redis
```

Run:

```bash
pnpm dev
```

Update the database:

Move to a separate terminal and run
```bash
sudo -u postgres psql
```

Inside psql run

```bash
CREATE DATABASE blobscan_dev OWNER blobscan;
ALTER USER blobscan WITH PASSWORD 's3cr3t';
GRANT CREATE ON SCHEMA public TO blobscan;
\q
```

Back in the normal terminal, we need to initialize the database:


```bash
cd packages/db
pnpm db:migrate
pnpm db:seed
```

For the purposes of this project, the most important thing is the API page which can be found at localhost port 3001.

# Test

Testing is done automatically by GitHub Actions everytime the main branch of this repository is updated.