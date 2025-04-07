**Revised Sections of Kamegor Project Plan**

**(Adding Seller Activation & Profile Interaction Flow)**

**1. App Description (Refined):**

Kamegor is a cross-platform mobile application creating a marketplace for live, peer-to-peer (P2P) video streams broadcast from users' locations. Registered users can **opt-in to become "Sellers" via their profile.** Once activated, a **Seller's profile picture appears as an interactive marker on the main map at their current location whenever they are online.** Other users ("Buyers") can tap these markers to **view the Seller's detailed profile**, which includes their description, rating, reputation tier, potentially pre-recorded intro videos (future feature), and a **history of their past stream transactions** (logged transparently, potentially using blockchain concepts later for enhanced trust). From the Seller's profile, if the Seller is **currently broadcasting live**, Buyers can initiate a **paid viewing session (charged per-minute in "Credits")**, connecting via P2P WebRTC video. Elixir/Phoenix powers the real-time map updates, user status (online/streaming), P2P signaling, and transaction backend.

*   **Core Functionality Changes:**
    *   **Seller Role:** Clear distinction; users opt-in.
    *   **Persistent Map Markers:** Online Sellers are visible on the map (represented by profile pic marker), not just active streams. *Privacy considerations are paramount here.*
    *   **Profile as Hub:** Interaction point for checking Seller info, history, *and* initiating a live stream purchase *if available*.

---

**2. Scope (MVP - Refined):**

*   **In-Scope (MVP):**
    *   User Authentication & Profile (Includes `is_seller` toggle, Seller description field).
    *   **Map Interface:** Displays markers for *online* users who have enabled "Seller" mode. Markers use profile pictures. Basic clustering if dense. **Visual distinction** for Sellers *currently streaming*.
    *   **Seller Profile Screen:** Accessible from map marker. Displays: Profile Pic, Username, Rating/Score, Seller Description, **Current Status (Online / Streaming / Offline)**, Simplified Transaction History (e.g., date, duration, rating received), **Conditional "Watch Live" button.**
    *   Streamer Functionality: "Go Live" initiates streaming state change, broadcasts stream availability.
    *   Viewer Functionality: Browse map, Tap Seller marker -> View Profile. If Seller status is "Streaming", "Watch Live" button is active.
    *   P2P Connection (WebRTC 1-to-1 via Signaling).
    *   Per-Minute Billing Logic & Virtual Currency System (Credits).
    *   Post-Stream Rating System.
    *   Basic Reputation Score display.
    *   Elixir Backend: API, Signaling, **User Presence Tracking (Online/Offline/Streaming)**, Billing, DB.
    *   Essential Admin Tools (incl. Moderation).
*   **Out-of-Scope (MVP):**
    *   Pre-recorded Profile Videos (Upload/Hosting).
    *   Detailed Blockchain transaction view on profile (use DB log).
    *   Displaying buyer ratings *given by* the seller or transaction comments.
    *   Requesting a stream / "Notify Me When Live" features.
    *   Multi-viewer streams, In-stream chat.

---

**3. Key Features (MVP Detailed Breakdown - Revised):**

*   **FE1: User Authentication & Profile:**
    *   Add `is_seller` (boolean) to user data model.
    *   Add `seller_description` (text) field.
    *   In Profile Settings: Add "Become a Seller" section with a toggle switch. Add field to edit `seller_description`.
*   **FE2: Map Interface:**
    *   Fetch and display markers for users where `is_seller` is true AND user presence is `online` OR `streaming`.
    *   Marker displays user profile picture.
    *   Apply visual distinction to marker if user presence is `streaming` (e.g., pulsing border, 'LIVE' badge).
    *   Implement map marker clustering for performance/UX in dense areas.
    *   Marker tap -> Show small preview popup (Pic, Username, Rating, Status: Online/Streaming) -> Button to "View Full Profile".
*   **FE3: Seller Experience:**
    *   Includes profile setup ("Become a Seller" toggle, description).
    *   "Go Live" button (available if `is_seller` is true and status is `online`). Tapping this:
        *   Changes user status to `streaming`.
        *   Broadcasts this status update (backend handles notifying relevant map clients).
        *   Navigates to Active Stream Screen (showing camera feed, stats, stop button).
    *   Stopping stream changes status back to `online`. Going offline changes status to `offline`.
*   **FE4: Viewer Experience:**
    *   Tapping map marker -> View Profile (modal/screen).
    *   **Seller Profile Screen:**
        *   Displays: Pic, Username, Rating, Score, Seller Description.
        *   **Real-time Status Indicator:** "Status: Streaming Now" or "Status: Online" or "Status: Offline".
        *   **Simplified Transaction History:** List view showing past streams (e.g., "Streamed for X mins on [Date] - Rated Y stars").
        *   **Conditional Action Button:**
            *   If Status is "Streaming Now": Show "**Watch Live (X Credits/min)**" button. -> Triggers WebRTC purchase flow.
            *   If Status is "Online": Show disabled button or text like "Not currently streaming".
            *   If Status is "Offline": Show disabled button or text like "Offline".
*   **FE5: Post-Stream Interaction:** (Unchanged - rating after viewing).
*   **FE6: Real-time Billing & Ledger:** (Unchanged logic - triggered by "Watch Live").
*   **FE7: Reputation System:** Seller Profile displays overall score/rating. Transaction history provides context.
*   **FE8: Virtual Currency ("Credits"):** (Unchanged).
*   **BE1: Backend API (Elixir/Phoenix):**
    *   Endpoints for: Setting `is_seller`, updating `seller_description`. Fetching Seller profile data (incl. simplified transaction history).
    *   Endpoint/Channel for map clients to get Seller locations/statuses within viewport. Needs filtering (`is_seller=true`, `status=online` or `streaming`).
*   **BE2: Real-time Services (Elixir - CRITICAL UPDATES):**
    *   **Robust User Presence System:** Track user state (`offline`, `online`, `streaming`). Phoenix Presence is ideal for this. Needs to handle app backgrounding/foregrounding, network loss gracefully.
    *   Broadcast presence changes (`online`, `offline`, `start_streaming`, `stop_streaming`) to:
        *   Relevant map clients (to update markers).
        *   Any client currently viewing that specific Seller's profile (to update Status indicator and button state).
    *   WebRTC Signaling Server (as before).
    *   Billing Engine (as before).
*   **BE3: Trust Layer (Initial):** DB log of stream sessions (as before).
*   **BE4: Admin Panel:** Needs ability to view/manage `is_seller` flag and `seller_description`. Monitor presence states.

---

**4. Technology Stack:**

*   Consider **Phoenix Presence** explicitly for managing the `online`/`offline`/`streaming` state efficiently.
*   Potential need for background location tracking on mobile (if Sellers should remain visible on map even when app is backgrounded, though this has major battery/privacy implications - **recommend requiring app foreground for MVP**).

---

**8. Risks & Mitigation (Refined):**

*   **Privacy (Seller Location Exposure):** Showing *all* online Sellers' locations persistently is a significant risk.
    *   **Mitigation:**
        *   **Require App in Foreground:** Only show Sellers on the map when they actively have the app open (MVP approach). Status becomes `online` only then.
        *   **Location Obfuscation:** Show markers in generalized areas (e.g., S2 cell level, geohash) when status is `online`. Only show a precise marker when status is `streaming`. *This seems like a good balance.*
        *   **Explicit Consent:** Clear opt-in screen explaining exactly when and how their location will be shown.
        *   **Visibility Controls (V2):** Allow sellers to temporarily hide their map marker even when online.
*   **Map Performance/Clutter:** Many online sellers could slow down map.
    *   **Mitigation:** Efficient backend queries (geospatial indexing), use map marker clustering, limit data sent to clients (only send updates for viewport).
*   **State Management Complexity:** Tracking `offline`/`online`/`streaming` reliably across network changes and app states.
    *   **Mitigation:** Leverage Phoenix Presence, careful client-side state handling, design for graceful failure/reconnection.

---

This refined flow makes the app feel more like a persistent marketplace where Buyers browse potential Sellers on the map and then engage when a Seller decides to go live. It centers the interaction around the Seller's profile. The privacy implications of showing online (but not streaming) Sellers need careful handling through obfuscation and user consent.
