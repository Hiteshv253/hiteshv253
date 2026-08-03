# System Design Blueprints & Architectural Notes

This directory houses conceptual system design blueprints, scalability strategies, and architectural notes for high-performance enterprise applications.

---

## 🛡️ 1. API Rate Limiting (Token Bucket Pattern)

Rate limiters protect server resources from exhaustion, denial of service (DoS) attacks, and brute force requests.

```mermaid
sequenceDiagram
    actor Client
    participant RateLimiter as API Gateway (Rate Limiter)
    participant Redis as Redis Cache (Token Storage)
    participant Server as Application Backend

    Client->>RateLimiter: HTTP GET /api/v1/resource
    RateLimiter->>Redis: Check token balance (Key: IP/User)
    alt Tokens Available (>0)
        Redis-->>RateLimiter: Token count (Deduct 1)
        RateLimiter->>Server: Forward HTTP request
        Server-->>Client: HTTP 200 OK
    else Tokens Exhausted (<=0)
        Redis-->>RateLimiter: 0 Tokens
        RateLimiter-->>Client: HTTP 429 Too Many Requests
    end
```

### Core Concepts:
- **Refill Rate**: Tokens are continuously added to the bucket at a constant rate (e.g. 10 tokens per minute).
- **Burst Capacity**: If the bucket is full, the client can make a burst of requests equal to the maximum bucket size instantly.
- **Storage Layer**: Utilizes Redis for high-speed counter operations with Time-To-Live (TTL) keys.

---

## 🗄️ 2. Database Sharding & Partitioning

Sharding distributes data horizontally across multiple independent database engines (shards) based on a partition key to scale storage write throughput.

```mermaid
graph TD
    A[Incoming Database Write] --> B[Hashing / Sharding Logic]
    B -->|hashUserId % 3 == 0| C[Database Shard 1: Users A-G]
    B -->|hashUserId % 3 == 1| D[Database Shard 2: Users H-N]
    B -->|hashUserId % 3 == 2| E[Database Shard 3: Users O-Z]
```

### Scaling Strategies:
- **Horizontal Partitioning**: Splitting database tables row-wise across multiple servers.
- **Vertical Partitioning**: Splitting columns (e.g. separating user profile blobs from credentials fields).
- **Reconciliation**: Transactions that span multiple shards require complex coordinates like 2-Phase Commits (2PC) or Sagas.

---

## ⚖️ 3. Horizontal Scaling & Load Balancing

Horizontal scaling adds more application servers to a resource pool instead of increasing the CPU/RAM of a single host.

```mermaid
graph LR
    User[Clients] --> LoadBalancer[Application Load Balancer]
    LoadBalancer --> App1[App Instance 1]
    LoadBalancer --> App2[App Instance 2]
    LoadBalancer --> App3[App Instance 3]
    App1 --> SharedState[(Shared Redis Session DB)]
    App2 --> SharedState
    App3 --> SharedState
```

### Key Considerations:
- **Stateless Backend**: Session information must not be stored inside local container memory. It is externalized to Redis or Memcached to make servers interchangeable.
- **Health Verification**: Load balancers verify servers' readiness endpoints dynamically to drop failing hosts from active routing.

---

## ✉️ 4. Event-Driven Architecture (Message Queues)

Decoupling synchronous API calls via asynchronous messaging queues prevents slow dependencies from clogging client threads.

```mermaid
graph LR
    Client[Client UI] -->|1. HTTP Submit Order| WebAPI[Web API Gateway]
    WebAPI -->|2. HTTP 202 Accepted| Client
    WebAPI -->|3. Publish Event: OrderCreated| MessageQueue[RabbitMQ / Apache Kafka]
    MessageQueue -->|4. Pull Job| Worker1[Invoice Worker Service]
    MessageQueue -->|5. Pull Job| Worker2[Shipping Worker Service]
    Worker1 -->|Database Update| DB[(Production DB)]
    Worker2 -->|Notification API| Email[Email Gateway]
```

### Advantages:
- **Asynchronous Execution**: The API returns an immediate response (`202 Accepted`) to the client, handling resource-heavy tasks like invoice generation or shipping assignments in the background.
- **Traffic Spikes Defusal (Throttling)**: Workers pull jobs at their own pace, preventing database connection limits from crashing during high-sales events.
