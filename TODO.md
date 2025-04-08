# Kamegor MVP - TODO List

**Product:** A cross-platform mobile app (iOS/Android) enabling users to become "Sellers" whose profile marker appears on a map at their location when online. Other users ("Buyers") can view Seller profiles and, if the Seller is actively streaming, pay per-minute with virtual currency ("Credits") to watch a live P2P (WebRTC) video feed from the Seller's location.

**Target Audience (for this doc):** AI Coding Agents, Senior Developer overseeing the project.

**Core Technologies:**
*   Frontend: React Native / Flutter (Decision needed) - *Assuming React Native for specificity, adjust if Flutter is chosen.*
*   Backend: Elixir / Phoenix Framework
*   Database: PostgreSQL w/ PostGIS extension
*   Real-time: Phoenix Channels (WebSockets), Phoenix Presence
*   P2P Streaming: WebRTC
*   Infrastructure: Cloud Hosting (AWS/GCP/Azure), STUN/TURN Server (e.g., Coturn or Managed Service)

---

## Phase 0: Project Setup & Foundational Design (Est. 1-2 Weeks)

*Goal: Establish project structure, finalize core tech choices, detailed design.*

*   **TODO:**
    *   [ ] **Project Management:**
        *   [x] Setup Git repository (e.g., GitHub, GitLab).
        *   [ ] Setup project board (e.g., Jira, Trello, GitHub Projects).
        *   [ ] Define branching strategy (e.g., Gitflow).
    *   [ ] **Tech Stack Decisions:**
        *   [ ] **Finalize Frontend Framework:** Confirm React Native or Flutter. *Decision needed.*
        *   [ ] **Finalize Mapping Library:** Choose Mapbox SDK / Google Maps SDK for React Native. Consider API usage costs & features.
        *   [ ] **Finalize Payment Gateway for Credits:** Choose Stripe/Braintree/Paddle.
        *   [ ] **Decide on TURN Server Strategy:** Self-hosted Coturn vs. Managed Service (e.g., Twilio). Allocate budget/infra planning.
    *   [ ] **Design & Architecture:**
        *   [ ] Finalize UI/UX mockups & prototypes for all MVP screens (Map, Profile, Streamer View, Viewer View, Auth, Settings).
        *   [ ] Create detailed Database Schema design (Users, Profiles, Streams, Transactions, Ratings, CreditLedger).
        *   [ ] Define detailed Backend API Specification (REST/GraphQL endpoints, WebSocket message formats for Signaling & Presence).
        *   [ ] Design WebRTC Signaling flow precisely (Offer/Answer/ICE Candidate exchange steps).
        *   [ ] Design User Presence tracking logic (states: offline, online, streaming; handling transitions).
        *   [ ] Define core data models/structs for Elixir backend.
        *   [ ] Define core state management strategy for Frontend (e.g., Redux, Zustand, Context API).
    *   [ ] **Environment Setup:**
        *   [ ] Setup local development environments for Frontend (React Native) & Backend (Elixir/Phoenix).
        *   [ ] Setup initial cloud infrastructure project/account (AWS/GCP/Azure).
        *   [ ] Provision initial PostgreSQL database instance.
        *   [x] Create basic project skeletons (React Native `init`, Phoenix `mix phx.new`).

---

## Phase 1: Backend Foundation & Authentication (Est. 2-3 Weeks)

*Goal: Implement secure user accounts and the basic API structure.*

*   **TODO:**
    *   [ ] **Backend (Elixir/Phoenix):**
        *   [x] Implement Database Schema using Ecto migrations (Users table: email, password_hash, id, timestamps; Profiles table: user_id, username, description, is_seller, rating_avg, presence_status, location_geom).
        *   [x] Implement User Registration API endpoint (`POST /api/users`): Hash password, create User & Profile records.
        *   [x] Implement User Login API endpoint (`POST /api/sessions`): Verify credentials, issue JWT or Session Token.
        *   [ ] Implement Authentication Middleware/Plug for securing API endpoints.
        *   [ ] Implement basic User Profile fetch endpoint (`GET /api/profiles/me`).
        *   [ ] Implement User Profile update endpoint (`PUT /api/profiles/me`): Allow updating username, description.
        *   [x] Setup basic API routing (`lib/kamegor_web/router.ex`).
        *   [ ] Add basic CORS handling.
    *   [ ] **Frontend (React Native):**
        *   [x] Implement Signup Screen UI.
        *   [x] Implement Login Screen UI.
        *   [x] Implement API client module to interact with backend auth endpoints.
        *   [x] Implement secure token storage (e.g., react-native-keychain).
        *   [x] Implement basic authenticated routing (navigate to main app view after login).
        *   [ ] Implement basic Profile Settings screen (view basic info).

---

## Phase 2: User Presence, Seller Opt-in & Map Display Basics (Est. 3-4 Weeks)

*Goal: Get online Sellers appearing correctly on the map based on real-time presence.*

*   **TODO:**
    *   [ ] **Backend (Elixir/Phoenix):**
        *   [x] Implement "Become a Seller" API endpoint (`PUT /api/profiles/me/seller`): Toggle `is_seller` boolean, update `seller_description`.
        *   [ ] **Integrate Phoenix Presence:**
            *   [x] Setup Presence Channel (`lib/kamegor_web/channels/presence_channel.ex`).
            *   [x] Track user connections via `Presence.track/3`. Store user ID, device ID, initial status (`online`).
            *   [x] Handle user disconnects (`Presence.untrack/2`) to set status `offline`.
        *   [x] Implement API endpoint to fetch Sellers within map viewport (`GET /api/map/sellers?lat=...&lon=...&radius=...`): Use PostGIS spatial query (`ST_DWithin`), filter by `is_seller=true` and presence status (`online` or `streaming`). Return necessary profile info (id, username, pic_url, rating, status, location).
        *   [x] Implement WebSocket endpoint/channel for map clients to subscribe to real-time Seller presence/location updates within their viewport. Broadcast updates when tracked presence changes (join, leave, status update) or location changes.
        *   [x] Implement API endpoint for Sellers to update their current location (`POST /api/location`): Update Profile's location_geom (PostGIS point). Broadcast this change via WebSocket.
        *   [x] Update Profile model to include `presence_status` (offline, online, streaming). Update this based on Presence tracking.
    *   [ ] **Frontend (React Native):**
        *   [ ] Implement Profile Settings screen section for Seller Opt-in (toggle, description input), calling the backend endpoint.
        *   [ ] **Implement Map Screen:**
            *   [ ] Integrate chosen Map library (Mapbox/Google Maps).
            *   [ ] Request location permissions from the user.
            *   [ ] Display user's current location on the map.
            *   [ ] Connect to the map update WebSocket endpoint.
            *   [ ] Fetch initial Sellers within viewport via API.
            *   [ ] Render Seller profile picture markers on the map based on received data (API + WebSocket).
            *   [ ] Update marker appearance based on Seller status (`online` vs. `streaming` - basic distinction for now).
            *   [ ] Handle map panning/zooming: Fetch new Sellers for the updated viewport.
            *   [ ] Implement basic map marker clustering.
            *   [ ] Implement logic to periodically send Seller's current location to backend (`POST /api/location`) *only* if `is_seller` is true and app is foregrounded. (Use `react-native-geolocation-service` or similar).
        *   [ ] Implement tapping a map marker to show basic Seller info popup (username, status).

---

## Phase 3: Seller Profile View & Stream Initiation Flow (Est. 2 Weeks)

*Goal: Allow users to view detailed Seller profiles from the map and see the conditional "Watch Live" button.*

*   **TODO:**
    *   [ ] **Backend (Elixir/Phoenix):**
        *   [ ] Implement detailed Seller Profile fetch endpoint (`GET /api/profiles/:id`): Return all necessary public info (username, pic_url, description, rating_avg, status, simplified transaction history - empty list for now). Ensure real-time status is fetched from Presence or Profile model.
    *   [ ] **Frontend (React Native):**
        *   [ ] Implement Seller Profile Screen UI (Modal or separate screen).
        *   [ ] Fetch and display Seller data from `GET /api/profiles/:id` when navigating from map marker popup.
        *   [ ] Display real-time Seller status (`Online`, `Streaming`, `Offline`) - potentially update via WebSocket if viewing the profile.
        *   [ ] Display simplified Transaction History section (placeholder text for now).
        *   [ ] Implement **conditional "Watch Live" button:**
            *   Button is active ONLY if Seller status is `streaming`.
            *   Display per-minute Credit cost near the button (hardcoded for now).
            *   Button press should eventually trigger the WebRTC connection flow (placeholder action for now).

---

## Phase 4: WebRTC Core Implementation (P2P Video) (Est. 4-6 Weeks - High Complexity)

*Goal: Establish a basic 1-to-1 P2P video stream between Seller and Buyer.*

*   **TODO:**
    *   [ ] **Infrastructure:**
        *   [ ] Setup and configure STUN server (e.g., public Google STUN).
        *   [ ] Setup and configure TURN server (e.g., self-hosted Coturn or managed service). Ensure credentials/access control.
    *   [ ] **Backend (Elixir/Phoenix):**
        *   [ ] **Implement WebRTC Signaling Channel:** (`lib/kamegor_web/channels/signaling_channel.ex`).
            *   [ ] Handle user joining/leaving the channel (e.g., Buyer joining a Seller's "stream room").
            *   [ ] Relay SDP Offers/Answers between peers securely.
            *   [ ] Relay ICE Candidates between peers securely.
            *   [ ] Define message formats (`offer`, `answer`, `ice_candidate`, `join`, `leave`).
            *   [ ] Implement logic to change Seller's presence status to `streaming` when they initiate "Go Live". Broadcast this update.
            *   [ ] Implement logic to change Seller's status back to `online` when they stop streaming. Broadcast update.
    *   [ ] **Frontend (React Native):**
        *   [ ] **Integrate WebRTC library:** (`react-native-webrtc`).
        *   [ ] **Seller Side ("Go Live"):**
            *   [ ] Implement "Go Live" button logic: Connect to Signaling Channel, get local camera/mic stream (`getUserMedia`), create `RTCPeerConnection`.
            *   [ ] Implement logic to create SDP Offer and send via Signaling Channel.
            *   [ ] Handle receiving SDP Answer via Signaling Channel, set remote description.
            *   [ ] Handle generating ICE Candidates and sending via Signaling Channel.
            *   [ ] Handle receiving remote ICE Candidates and adding them.
            *   [ ] Implement Active Streamer UI: Display local camera preview, basic stats (timer), "Stop Streaming" button.
            *   [ ] "Stop Streaming" logic: Close `RTCPeerConnection`, release media, notify backend/channel to update status.
        *   [ ] **Buyer Side ("Watch Live"):**
            *   [ ] Implement "Watch Live" button logic: Connect to Signaling Channel for the specific Seller.
            *   [ ] Handle receiving SDP Offer via Signaling Channel, create `RTCPeerConnection`, set remote description.
            *   [ ] Get dummy local media (required by some WebRTC setups) or handle offer directionality.
            *   [ ] Create SDP Answer and send via Signaling Channel.
            *   [ ] Handle receiving remote ICE Candidates and adding them.
            *   [ ] Handle generating local ICE Candidates and sending via Signaling Channel.
            *   [ ] Implement Active Viewer UI: Display remote video stream (`<RTCView />`), show Seller info, show "Leave Stream" button.
            *   [ ] "Leave Stream" logic: Close `RTCPeerConnection`, notify backend/channel.
        *   [ ] Configure `RTCPeerConnection` to use configured STUN/TURN servers.
        *   [ ] Handle basic WebRTC connection state changes (connecting, connected, failed, disconnected) in UI.
        *   [ ] Request Camera & Microphone permissions.

---

## Phase 5: Virtual Currency & Per-Minute Billing (Est. 3-4 Weeks)

*Goal: Implement the Credits system and charge Buyers per minute for viewing streams.*

*   **TODO:**
    *   [ ] **Backend (Elixir/Phoenix):**
        *   [ ] Implement `CreditLedger` DB table (user_id, transaction_type [purchase, stream_spend, stream_earn], amount, related_stream_id, timestamp).
        *   [ ] Implement `User` model field/association for current Credit balance.
        *   [ ] Implement internal function/service to add/deduct Credits atomically and log to ledger.
        *   [ ] **Integrate Billing Logic:**
            *   [ ] When Buyer successfully connects to stream (WebRTC `connected` state, signaled via Channel), log stream start time.
            *   [ ] Implement periodic check (e.g., GenServer, Oban job scheduled every minute) for active viewing sessions.
            *   [ ] For each active minute, deduct X Credits from Buyer, add Y Credits (X - platform cut) to Seller, log both to CreditLedger.
            *   [ ] Handle disconnections gracefully: Calculate final partial minute cost upon disconnect event, perform final deduction/credit. Ensure robustness against duplicate billing.
        *   [ ] Implement API endpoint to fetch current Credit balance (`GET /api/credits/balance`).
        *   [ ] Implement basic Credit purchase endpoint (`POST /api/credits/purchase`): Integrate with chosen Payment Gateway (Stripe/etc.) to handle payment intent, verification, and credit awarding upon success. (MVP might just have an admin endpoint to grant Credits).
    *   [ ] **Frontend (React Native):**
        *   [ ] Display User's Credit balance in UI (e.g., Profile/Settings).
        *   [ ] Implement basic Credit Purchase screen (if not doing admin grant for MVP). Connect to payment gateway SDK / backend endpoint.
        *   [ ] Display cost per minute clearly on Seller Profile and Viewer Screen.
        *   [ ] (Optional) Display running cost/duration on Viewer Screen.
        *   [ ] Ensure Buyer has sufficient Credits before allowing "Watch Live" connection attempt.

---

## Phase 6: Rating System & Transaction History (Est. 2 Weeks)

*Goal: Allow Buyers to rate streams and display basic history on Seller profiles.*

*   **TODO:**
    *   [ ] **Backend (Elixir/Phoenix):**
        *   [ ] Add `Ratings` DB table (stream_session_id, buyer_id, seller_id, score, comment[optional], timestamp).
        *   [ ] Add `StreamSessions` DB table (seller_id, start_time, end_time, total_billed_credits). Log session details upon stream end. Link to `CreditLedger` entries.
        *   [ ] Implement API endpoint for Buyer to submit rating post-stream (`POST /api/ratings`): Validate user viewed the stream session, store rating.
        *   [ ] Implement logic (e.g., async task via Oban) to update Seller's average rating (`rating_avg` on Profile) after a new rating is submitted.
        *   [ ] Update Seller Profile fetch endpoint (`GET /api/profiles/:id`) to include simplified transaction/stream history (query `StreamSessions` and associated `Ratings` for that seller, limit N results).
    *   [ ] **Frontend (React Native):**
        *   [ ] Implement post-stream Rating prompt/modal for Buyer (e.g., 1-5 stars). Call rating submission API.
        *   [ ] Display Seller's average rating clearly on Map Popup and Profile Screen.
        *   [ ] Display simplified transaction history list on Seller Profile Screen based on API data.

---

## Phase 7: Admin Panel & Moderation Basics (Est. 2-3 Weeks)

*Goal: Provide essential tools for managing users and monitoring activity.*

*   **TODO:**
    *   [ ] **Backend (Elixir/Phoenix):**
        *   [ ] Choose Admin Panel framework (e.g., Phoenix LiveDashboard extensions, separate admin app).
        *   [ ] Implement Admin authentication.
        *   [ ] Implement User lookup/view/edit functionality (view details, toggle `is_seller`, ban user).
        *   [ ] Implement view of active streams (get from Presence/State).
        *   [ ] Implement functionality for Admin to forcefully terminate a specific stream (requires signaling mechanism).
        *   [ ] Implement basic CreditLedger viewer/search.
        *   [ ] Implement system for user reporting/flagging (API endpoint, DB table for flags).
    *   [ ] **Frontend (React Native):**
        *   [ ] Implement basic "Report User/Stream" button/flow in relevant UI locations (Profile, Viewer Screen). Call reporting API endpoint.
    *   [ ] **Admin Panel UI:**
        *   [ ] Build UI for the backend admin functionalities listed above.
        *   [ ] Implement review queue for user flags/reports.

---

## Phase 8: Testing, Polish & Security Review (Est. 3-4 Weeks)

*Goal: Ensure MVP stability, performance, security, and usability.*

*   **TODO:**
    *   [ ] **Testing:**
        *   [ ] Write backend unit & integration tests (Ecto, Channel tests, API tests).
        *   [ ] Write frontend unit & component tests (Jest, React Testing Library).
        *   [ ] **Perform extensive manual QA:** Focus on cross-device compatibility, various network conditions (WiFi, 4G, 3G), WebRTC connection success rates, billing accuracy, presence state accuracy, app crashes, UI glitches.
        *   [ ] Test STUN/TURN server effectiveness across different network types (especially symmetric NATs).
        *   [ ] Perform basic load testing on signaling server and API endpoints.
    *   [ ] **Polish:**
        *   [ ] Refine UI/UX based on testing feedback (loading states, error handling, transitions).
        *   [ ] Optimize map performance (rendering, data fetching).
        *   [ ] Optimize frontend app performance (bundle size, render performance).
        *   [ ] Optimize backend query performance.
        *   [ ] Review and improve battery consumption (location updates, streaming).
    *   [ ] **Security:**
        *   [ ] Perform security review: Check auth logic, API authorization, WebSocket security, WebRTC signaling security (prevent spoofing), data validation, potential DoS vectors.
        *   [ ] Ensure sensitive data is handled appropriately (PII, location).
        *   [ ] Review payment gateway integration security.
        *   [ ] Implement basic rate limiting on sensitive endpoints.
    *   [ ] **Content & Legal:**
        *   [ ] Finalize Community Guidelines & Terms of Service.
        *   [ ] Implement links to Privacy Policy, T&S within the app.

---

## Phase 9: Deployment & Infrastructure Setup (Est. 1-2 Weeks)

*Goal: Prepare and deploy the application to staging and production environments.*

*   **TODO:**
    *   [ ] **Infrastructure:**
        *   [ ] Configure cloud environments (Staging, Production): VPC, Subnets, Security Groups.
        *   [ ] Setup managed PostgreSQL instances (Staging, Prod) with backups.
        *   [ ] Setup Elixir/Phoenix application servers (e.g., EC2 instances with systemd, Gigalixir, Render, Fly.io). Configure clustering if needed.
        *   [ ] Deploy and configure STUN/TURN server(s) for production use.
        *   [ ] Setup Load Balancer for API/WebSocket traffic.
        *   [ ] Configure DNS records.
        *   [ ] Setup CDN for static assets (if applicable).
    *   [ ] **Deployment (CI/CD):**
        *   [ ] Setup CI/CD pipelines (e.g., GitHub Actions, GitLab CI) for backend (build, test, deploy Elixir releases).
        *   [ ] Setup CI/CD pipelines for frontend (build, test, deploy JS bundles - e.g., CodePush; or build native binaries).
        *   [ ] Configure environment variables securely for different environments.
    *   [ ] **App Stores:**
        *   [ ] Setup Apple Developer Account & Google Play Console Account.
        *   [ ] Configure App Store Connect listing (metadata, screenshots, privacy info).
        *   [ ] Configure Google Play Console listing.
        *   [ ] Build signed release versions of the React Native app (IPA, AAB/APK).

---

## Phase 10: Launch & Initial Monitoring (Est. 1 Week)

*Goal: Release the MVP to the public and monitor its initial performance.*

*   **TODO:**
    *   [ ] Perform final pre-launch checks on production environment.
    *   [ ] Submit apps to Apple App Store and Google Play Store for review.
    *   [ ] Respond to any reviewer feedback.
    *   [ ] Release apps upon approval.
    *   [ ] **Monitoring:**
        *   [ ] Setup application performance monitoring (APM) for backend (e.g., AppSignal, Datadog, New Relic).
        *   [ ] Setup frontend error tracking (e.g., Sentry, Bugsnag).
        *   [ ] Setup infrastructure monitoring (CPU, Memory, Network, Disk) on cloud provider.
        *   [ ] Setup log aggregation and monitoring (e.g., ELK stack, Datadog Logs, CloudWatch Logs).
        *   [ ] Monitor key metrics: User signups, active sellers, active streams, billing transactions, WebRTC connection success rate, server errors, app crashes.
    *   [ ] Prepare basic user support channel.

---

This TODO list provides a detailed breakdown for building the Kamegor MVP. The Senior Developer should use this to assign tasks and manage progress, while AI agents can use the specific technical TODOs within each phase to generate code snippets or initial implementations. Remember that WebRTC implementation (Phase 4) is the most complex and might require significant iteration and testing. Good luck!
