# Portfolio Website Requirements & Architecture

## Requirements (Spelling Corrected)

1. Add a recommendation section in the `random.md` section where a person can recommend a person (me).
   - First, they have to provide their: name, company name, position, and then recommendation text.
   - The recommendation section contains an admin section to handle the responses to accept or decline a response.
   - The recommendation submission is handled in a modal popup with a highlighted button.
   - The responses are reflected on the frontend only after approval.
   - The approved recommendation cards are displayed in a random order on the frontend.

2. Delete the certification section.

3. Make the experience section interactive: after clicking the card, it should toggle and display the detailed description.

4. Add the admin login button at the bottom of the website, bringing up a login modal. All security features should be handled securely (SHA-256 hashed password, rate limiting/lockout, session timeout) so it cannot be hacked.

5. Use password `kaivalya@2005` via a `.env` section for handling all private/sensitive configuration.

---

## Code & File Structure

Here is a map of the project files and directory structure:

```
portfolio/
├── .env                          # [NEW] Stores private configurations (e.g., ADMIN_PASSWORD="kaivalya@2005")
├── .gitignore                    # Specifies ignored files (ignores .env and .venv)
├── package.json                  # Node.js build dependencies and dev commands
├── pyproject.toml                # Python package dependencies (Jinja2, BeautifulSoup4, etc.)
├── build.ps1                     # Windows build script (runs Tailwind CSS and python src/build.py)
├── public/                       # Static public assets, copied directly to dist/
│   ├── assets/                   # Optimized images and icons
│   └── random/                   # Random sub-pages (travel.html, lore.html, etc.)
├── src/
│   ├── build.py                  # Static site generator entry point (loads .env, hashes password, renders Jinja)
│   ├── dev-server.py             # Flask development server serving dist/ locally on port 8000
│   ├── index.css                 # Tailwind CSS entry file
│   └── templates/                # Jinja templates used by the build generator
│       ├── layout.html           # Base HTML layout (contains global modals, script triggers, and Tailwind styling)
│       ├── index.html            # Main landing page (contains portfolio sections, inline admin console, experience toggle)
│       ├── components/           # Reusable Jinja macros
│       │   ├── button.html       # Macro for styling link buttons
│       │   └── fieldset.html     # Macro for fieldset frames
│       └── posts/
│           └── projects/         # Templates for displaying markdown project posts
├── dist/                         # Compiled site output directory served to visitors
```

---

## Custom Feature Implementations

### 1. Hardened Admin Panel Login & Moderation
- **Cryptographic Gate**: The password (`kaivalya@2005` in `.env`) is hashed using standard SHA-256 during the site build. The browser checks logins against this SHA-256 hash using the Web Crypto API, meaning the plaintext password is never stored or sent in browser JS.
- **Attempts Rate-Limiting**: 5 failed login attempts triggers a 60-second cooldown timeout stored in `sessionStorage` to prevent brute forcing.
- **Inactivity Session Timeout**: Logs out the admin after 15 minutes of inactivity (resets sliding session timer on user click, mouse move, scroll, or key down).
- **Inline Console**: Renders directly inside the homepage at the bottom of the page upon login. Standalone `/admin.html` page has been completely deleted.

### 2. Collapsible Experience Cards
- The InfoSpeed Services card is default collapsed (`max-h-0`). Clicking anywhere on the card toggles its height smooth transition utilizing `scrollHeight`, rotating the toggle arrow indicator `▶` to `▼`.

### 3. Dynamic Recommendations
- Submitting recommendations stores them as `pending` items in `localStorage`. Once accepted via the moderation console, they move to `approved` and appear on the homepage. They are shuffled randomly using the Fisher-Yates algorithm on page load.