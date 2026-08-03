# DevOps & SRE Technical Interview Preparation Guide

This guide contains **60 interview questions** (20 Beginner, 20 Intermediate, 20 Advanced) designed to prepare you for technical rounds, explaining the architectural decisions implemented in this portfolio.

---

## 🟢 Part 1: Beginner Level (Questions 1 - 20)

### Q1: What is a multi-stage Docker build, and why is it used in your Laravel projects?
**Answer**: A multi-stage Docker build uses multiple `FROM` instructions in a single Dockerfile. The first stage builds the dependencies (installing Composer packages, compiling assets), and the second stage copies only the compiled output into a clean, minimal runtime image (like `php:alpine`). This reduces the final container size, minimizes security vulnerabilities by omitting compilers, and optimizes build caches.

### Q2: What is the difference between a Liveness probe and a Readiness probe in Kubernetes?
**Answer**: 
- **Liveness Probe**: Determines if a container needs to be restarted. If it fails, Kubernetes kills the container and restarts it according to its restart policy.
- **Readiness Probe**: Determines if a container is ready to accept incoming traffic. If it fails, the pod is removed from the Endpoint IP pool of the associated Service, preventing requests from routing to it.

### Q3: Why do you run containers as a non-root user?
**Answer**: By default, containers run as `root`. If a hacker exploits a container breakout vulnerability, they gain root access on the host system. Running container processes as a non-root system user (e.g. `www-data` in PHP/Nginx) isolates permissions and blocks host takeovers.

### Q4: What does the `set -e` option do at the beginning of your Bash scripts?
**Answer**: It instructs the shell to exit immediately if any command returns a non-zero exit status (i.e. if a command fails). This prevents the script from executing subsequent lines when a critical step, like directory creation or remote transfer, fails.

### Q5: What is the purpose of an Internet Gateway (IGW) in AWS?
**Answer**: An Internet Gateway is a horizontally scaled, redundant VPC component that allows communication between instances in public subnets and the internet.

### Q6: Why do we place database servers in private subnets?
**Answer**: Private subnets do not route traffic to the internet. Putting databases in private subnets prevents external hackers from targeting database connection ports directly, securing sensitive assets.

### Q7: What is the purpose of a NAT Gateway in AWS VPC?
**Answer**: A NAT Gateway allows instances inside private subnets to send outbound requests to the internet (e.g., to download OS updates or package dependencies) while preventing the internet from establishing inbound connections to those instances.

### Q8: What does the `--force` flag do when running Laravel migrations in production?
**Answer**: By default, Laravel prompts for confirmation before running migrations in a production environment. The `--force` flag overrides this prompt, allowing automated pipelines to execute migrations without human intervention.

### Q9: Why is Prometheus considered a "Pull-based" monitoring system?
**Answer**: Instead of targets sending metrics to a central monitoring server, Prometheus periodically scrapes metrics endpoints (like `/metrics` or Node Exporter's `9100` port) at configured intervals.

### Q10: What is Grafana used for in your monitoring stack?
**Answer**: Grafana is a visualization tool. It connects to Prometheus as a datasource to query time-series data and display it in graphical dashboards, charts, and metrics tables.

### Q11: What is Infrastructure as Code (IaC)?
**Answer**: IaC is the management and provisioning of infrastructure through machine-readable definition files (like Terraform `.tf` or CloudFormation `.yaml`), rather than manual hardware configuration or interactive cloud consoles.

### Q12: What is the function of the `.gitignore` file?
**Answer**: It specifies files and directories that Git should ignore and not track, preventing private credentials (`.env`), build directories (`vendor/`, `node_modules/`), and local caches from being committed to public source control.

### Q13: What are conventional commits, and why are they used?
**Answer**: Conventional commits are a specification for commit messages that add human and machine-readable meaning to commit histories (e.g. `feat:`, `fix:`, `docs:`). They facilitate changelog generation and version tracking.

### Q14: What is GitOps?
**Answer**: GitOps is an operational framework that takes DevOps best practices (such as version control, collaboration, compliance, and CI/CD) and applies them to infrastructure automation, treating Git as the single source of truth for the desired state of the system.

### Q15: Why is caching configuration files in Laravel (`php artisan config:cache`) critical for production?
**Answer**: It combines all of Laravel's config files into a single, pre-compiled file, reducing filesystem read operations and accelerating response times.

### Q16: What is a sidecar container in Kubernetes?
**Answer**: A sidecar is a container that runs alongside the primary application container in the same Pod. It shares the pod's network namespaces and volume mounts to assist the main container (e.g., Nginx sidecar proxying requests to PHP-FPM).

### Q17: What does the `ports` section do in a docker-compose.yml file?
**Answer**: It maps ports between the host machine and the container, allowing host network ports to direct traffic to internal container services.

### Q18: What is a Webhook?
**Answer**: A webhook is a user-defined HTTP callback that triggers automatically when a specific event occurs, delivering real-time payloads to target URLs (like posting alert logs to a Discord channel).

### Q19: What is the difference between AWS Security Groups and Network Access Control Lists (NACLs)?
**Answer**:
- **Security Groups**: Stateful firewall rules associated with specific instances (operates at the instance level).
- **NACLs**: Stateless firewall rules associated with subnets (operates at the subnet level).

### Q20: What is an IAM role?
**Answer**: An IAM role is an AWS identity with permission policies that determine what the identity can and cannot do in AWS. Unlike users, roles do not have credentials associated with them; they are dynamically assumed by trusted resources.

---

## 🟡 Part 2: Intermediate Level (Questions 21 - 40)

### Q21: How do you achieve zero-downtime deployments using symlink switching in your VPS deploy script?
**Answer**: The deployment script clones the new codebase version into a unique directory under `releases/TIMESTAMP`. It runs package installations, configurations optimization, and database migrations in this isolated directory. Once the release is ready, it updates a symbolic link:
`ln -nfs /var/www/app/releases/TIMESTAMP /var/www/app/current`
Because modifying a symlink is atomic at the OS level, incoming traffic switches immediately to the new release directory. reloading Nginx and PHP-FPM updates the active file descriptors without dropping active socket connections.

### Q22: What is the purpose of the `terraform.tfstate` file, and why is remote state locking crucial?
**Answer**: The state file maps your Terraform configurations to real-world cloud resources. If multiple developers execute `terraform apply` concurrently without locking, they can overwrite changes, cause resource conflicts, or corrupt state files. Storing state files in S3 and using DynamoDB for state locking ensures only one execution runs at a time.

### Q23: Why do we use Node Exporter and cAdvisor together in the monitoring stack?
**Answer**:
- **Node Exporter**: Accesses `/proc` and `/sys` to gather host operating system metrics (CPU load, memory allocation, disk I/O). It has no visibility into docker container details.
- **cAdvisor**: Connects to the Docker daemon to gather container-level metrics (CPU throttling, RAM limits, container status). Combining them provides visibility into both the physical servers and the applications running on them.

### Q24: How does a Horizontal Pod Autoscaler (HPA) determine when to scale replicas in Kubernetes?
**Answer**: The HPA controller queries metrics APIs at set intervals (usually 15 seconds) to compare resource utilization (e.g. CPU or Memory usage) against target metrics configured in `hpa.yaml`. If the average utilization exceeds the target percentage (e.g., 70% CPU), the HPA calculates the required replicas:
`DesiredReplicas = ceil[CurrentReplicas * (CurrentMetricValue / TargetMetricValue)]`
It then scales up the deployment.

### Q25: Explain the flow of GitOps reconciliation when using ArgoCD.
**Answer**: ArgoCD continuously compares the live state of resources in the Kubernetes cluster against the target configurations managed in Git. If it detects a difference (e.g. replica count modified manually in the cluster), it marks the resource status as `OutOfSync`. Depending on configuration rules, it either sends alerts or triggers self-healing to redeploy the Git-approved configuration state.

### Q26: What is a Multi-AZ deployment in AWS RDS, and how does it provide high availability?
**Answer**: Multi-AZ provisions a synchronous standby replica of your database in a different Availability Zone (AZ) under the same subnet group. If the primary AZ suffers an outage, AWS dynamically modifies the DNS endpoint to fail over to the standby instance without manual reconfiguration or connection string updates in your application.

### Q27: How does Fail2ban protect SSH services on Linux?
**Answer**: Fail2ban scans authentication log files (e.g., `/var/log/auth.log`) for failed SSH login attempts. If it matches patterns (like repeatedly inputting wrong passwords from a single IP), it updates local netfilter or IPTables rules to reject connection requests from that source IP for a configured duration.

### Q28: How do you secure credentials inside a public GitHub repository?
**Answer**:
- Use GitHub Secrets or environment variables to inject sensitive data during pipeline executions.
- Never commit `.env` or variable configuration files containing real passwords.
- Use tools like Gitguardian or Trufflehog to scan commit histories for accidental credential leaks.

### Q29: What is the purpose of Helm in Kubernetes development?
**Answer**: Helm is a package manager for Kubernetes. It allows you to package multiple related manifests (deployments, services, ingress, configuration maps) into a reusable template directory (a Chart), parameters of which can be injected dynamically using `values.yaml` files.

### Q30: How does Nginx communicate with PHP-FPM, and what is the difference between Unix sockets and TCP ports?
**Answer**: Nginx communicates with PHP-FPM using the FastCGI protocol.
- **Unix Sockets (`unix:/var/run/php-fpm.sock`)**: Communicates via file system structures on the same host. It has lower overhead because it bypasses the network stack.
- **TCP Ports (`127.0.0.1:9000` or `app:9000`)**: Communicates over IP addresses. It is slower due to network packet encapsulation but necessary if Nginx and PHP-FPM run on separate hosts.

### Q31: How do you verify the integrity of local database backups?
**Answer**: The automated backup pipeline should periodically mount the GPG-encrypted dump, decrypt it, and restore the schema into an ephemeral database container, executing validation tests to confirm database records are readable and not corrupted.

### Q32: What is the role of an IAM Instance Profile in AWS EC2?
**Answer**: An Instance Profile acts as a container for an IAM Role. Attaching it to an EC2 instance allows applications running on that server to automatically fetch temporary AWS access credentials via the EC2 Instance Metadata Service (IMDS).

### Q33: How does the LimitRange manifest prevent resource starvation in Kubernetes?
**Answer**: Without LimitRanges, developers can deploy pods without resource configurations. If a container suffers a memory leak, it can consume all resources on a node, crashing other pods. LimitRanges enforce minimum, maximum, and default memory/CPU limits on all containers inside a namespace.

### Q34: What is the difference between blue-green and rolling updates in Kubernetes?
**Answer**:
- **Rolling Update**: Replaces pods of the old version with the new version one-by-one, maintaining service availability throughout the deploy phase.
- **Blue-Green**: Provisions a complete duplicate pod environment (Green) alongside the active environment (Blue). Traffic is switched over at the load balancer level once the Green environment is verified.

### Q35: What is the purpose of the `unattended-upgrades` package in Linux servers?
**Answer**: It automates the installation of security upgrades and package patches on Debian/Ubuntu systems, keeping host dependencies secure without manual admin intervention.

### Q36: How does Redis handle memory eviction when it reaches maximum storage limits?
**Answer**: It uses eviction policies configured in `redis.conf` (like `allkeys-lru` or `volatile-lru`) to identify and delete keys that have expired or haven't been requested recently, preventing out-of-memory errors.

### Q37: How do you implement database indexing in Laravel database migrations?
**Answer**: Use `$table->index('column_name')` in migration files. Indexing speeds up SELECT queries by creating lookup indexes, but it can slow down INSERT and UPDATE operations because the index must be recalculated.

### Q38: What does the `depends_on` flag do in a docker-compose.yml file?
**Answer**: It configures execution start order dependencies. For example, `depends_on: - db` ensures the database container starts booting before the application container. It does not wait for the database service to be fully ready to accept connections.

### Q39: What is DNS caching, and why is it important?
**Answer**: It stores active DNS query results locally, reducing network lookups and accelerating response times for external services.

### Q40: What is the function of the `outputs.tf` file in Terraform?
**Answer**: It defines the values to return from a Terraform run (such as database endpoints or public IP addresses), making them accessible for post-provisioning scripts or other Terraform states.

---

## 🔴 Part 3: Advanced Level (Questions 41 - 60)

### Q41: How do you prevent connection drops during Nginx reloads in high-traffic production environments?
**Answer**: When Nginx reloads (`nginx -s reload` or `systemctl reload nginx`), the master process validates the new configuration. If valid, it spawns new worker processes utilizing the new configurations. The old worker processes stop accepting new incoming connections but continue processing active requests until they are finished. Once all active connections on old workers drop, the master process terminates them, enabling seamless updates without dropped requests.

### Q42: What is the difference between TCP and HTTP health checks, and why are HTTP checks preferred for web servers?
**Answer**:
- **TCP Checks**: Simply verify if a port (like `80`) is listening. It does not check if the server is functioning. A server can return 500 errors but still pass TCP checks because the port is open.
- **HTTP Checks**: Query a specific endpoint (like `/api/v1/readiness`) and expect a successful status code (like `200 OK`). This verifies that the backend application, database connections, and cache layers are functional.

### Q43: How does a CPU-bound application scale differently from a Memory-bound application in Kubernetes?
**Answer**:
- **CPU-bound apps**: When CPU usage limits are hit, container processes throttle, causing slower response times but not necessarily crashing. They scale effectively based on CPU utilization metrics.
- **Memory-bound apps**: When memory limits are reached, the kernel terminates the container immediately with an Out-Of-Memory (OOM) error (`OOMKilled`). They must be scaled based on memory thresholds, with sufficient buffer limits to accommodate memory spikes.

### Q44: Explain the security implications of utilizing `docker.sock` mounts inside docker containers.
**Answer**: Mounting `/var/run/docker.sock` inside a container (e.g., in cAdvisor or Jenkins) allows it to communicate with the host's Docker daemon. Since Docker commands run with root privileges, anyone who gains access to that container can execute command overrides on the host system, creating a significant security risk.

### Q45: How do you design a disaster recovery plan with a low recovery time objective (RTO)?
**Answer**:
- Provision multi-region infrastructure using Terraform.
- Configure active-active failover routing using AWS Route 53 latency or failover routing policies.
- Automate database replication across regions.
- Store backup archives in S3 with cross-region replication.
- Implement automated recovery scripts to quickly restore services.

### Q46: What is a 2-Phase Commit (2PC), and how does it differ from the Saga pattern in microservices?
**Answer**:
- **2-Phase Commit (2PC)**: A synchronous protocol that coordinates a transaction across multiple nodes, locking resources until all nodes agree to commit. It guarantees consistency but can block system execution.
- **Saga Pattern**: An asynchronous model that executes a sequence of local transactions. Each transaction updates database tables within a single service. If a step fails, the Saga runs compensating transactions to roll back changes, prioritizing availability.

### Q47: How do you configure Alertmanager to prevent alert fatigue?
**Answer**:
- **Grouping**: Group similar alerts (like multiple instances of the same alert) into a single notification.
- **Inhibition**: Suppress alerts if a related, higher-priority alert is already active (e.g. suppress target CPU alerts if the host is down).
- **Muting**: Silence alerts during planned maintenance windows.

### Q48: What is the difference between stateful and stateless containers?
**Answer**:
- **Stateless**: Containers do not store state locally. Any replica can handle requests, and containers can be destroyed and recreated without data loss.
- **Stateful**: Containers require persistent state (like databases). They need stable network identities and persistent volume mappings (e.g. Kubernetes StatefulSets).

### Q49: How do you implement rate limiting in a distributed microservices architecture?
**Answer**: Use a shared cache layer (like Redis) or an API Gateway (like Kong or AWS API Gateway) to manage token buckets globally. This prevents requests from exceeding limits when routed across different server instances.

### Q50: How do you optimize database query performance under heavy read loads?
**Answer**:
- Implement read replicas for select queries, routing write operations to the primary instance.
- Cache frequent query results in Redis.
- Optimize database indexes and review queries using `EXPLAIN`.

### Q51: What is container escape, and how do you protect against it?
**Answer**: Container escape is a vulnerability where an attacker breaks out of container isolation to access the host system. Protect against it by running containers as non-root users, disabling privileged execution flags, and keeping Docker engines updated.

### Q52: What is the function of the `LimitRange` manifest in Kubernetes?
**Answer**: It enforces minimum, maximum, and default resource allocations (CPU and Memory) for all containers inside a namespace, preventing resource starvation.

### Q53: How do you secure data in transit between microservices?
**Answer**: Enforce Mutual TLS (mTLS) configurations using a service mesh (like Istio or Linkerd) or manage certificate authorities to encrypt internal traffic.

### Q54: What is the role of a bastion host?
**Answer**: A bastion host is a secure, hardened gateway server positioned in a public subnet. It acts as a single proxy point to access instances in private subnets, minimizing exposure.

### Q55: How do you implement load balancing for WebSockets?
**Answer**: WS connections are persistent. Configure the load balancer to support sticky sessions (session affinity) or use a reverse proxy (like Nginx) with configurations allowing protocol upgrades.

### Q56: How does Nginx process request routing?
**Answer**: Nginx matches requests based on Server Blocks (`server_name`) and Location Blocks (`location`), using regular expressions or prefix matches to route traffic.

### Q57: What is the benefit of database partitioning?
**Answer**: It splits tables into smaller, manageable chunks (partitions), accelerating queries that target specific partition keys.

### Q58: How do you secure S3 buckets?
**Answer**: Enable default encryption (SSE-S3 or SSE-KMS), block public access, restrict bucket policies using IAM, and enable versioning to prevent accidental deletions.

### Q59: What is the purpose of the `unattended-upgrades` package on Debian/Ubuntu systems?
**Answer**: It automates the installation of security upgrades and package patches, keeping host systems secure.

### Q60: Why is the Saga pattern preferred over 2PC in modern microservices?
**Answer**: The Saga pattern is asynchronous and does not lock database resources for long periods. This improves system throughput and availability, aligning with the CAP theorem.
