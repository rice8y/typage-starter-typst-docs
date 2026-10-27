(function () {
  const base = document.querySelector('meta[name="typage-base-url"]')?.content || "";
  const asset = (path) => `${base}${path}`;
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  function setupSearch() {
    const root = document.querySelector("[data-doc-search]");
    if (!root) return;

    const input = root.querySelector("[data-doc-search-input]");
    const results = root.querySelector("[data-doc-search-results]");
    const status = root.querySelector("[data-doc-search-status]");
    if (!input || !results || !status) return;

    let pages = [];
    let loadPromise;
    let renderedItems = [];
    let activeIndex = -1;
    let searchRequest = 0;

    function setStatus(message) {
      status.textContent = message;
    }

    function openResults() {
      results.hidden = false;
      input.setAttribute("aria-expanded", "true");
    }

    function closeResults() {
      searchRequest += 1;
      results.hidden = true;
      input.setAttribute("aria-expanded", "false");
      input.removeAttribute("aria-activedescendant");
      activeIndex = -1;
    }

    async function loadIndex() {
      if (loadPromise) return loadPromise;

      root.dataset.state = "loading";
      loadPromise = fetch(asset("/search_index.json"))
        .then((response) => {
          if (!response.ok) throw new Error(`Search index returned ${response.status}`);
          return response.json();
        })
        .then((index) => {
          pages = Array.isArray(index.pages) ? index.pages : [];
          root.dataset.state = "ready";
        })
        .catch(() => {
          pages = [];
          root.dataset.state = "error";
        });

      return loadPromise;
    }

    function score(page, terms) {
      const title = (page.title || "").toLowerCase();
      const description = (page.description || "").toLowerCase();
      const tokens = Array.isArray(page.tokens) ? page.tokens.join(" ").toLowerCase() : "";
      const haystack = `${title} ${description} ${tokens}`;
      let value = 0;

      for (const term of terms) {
        if (!haystack.includes(term)) return 0;
        if (title === term) value += 24;
        else if (title.startsWith(term)) value += 14;
        else if (title.includes(term)) value += 8;
        if (description.includes(term)) value += 3;
        value += 1;
      }

      return value;
    }

    function resultKind(page) {
      if ((page.section || "").startsWith("api/")) return "Symbol";
      if (page.url === "/" || page.url === "/api/") return "Package";
      return "Page";
    }

    function setActive(index) {
      const links = results.querySelectorAll("[data-doc-search-result]");
      if (!links.length) return;

      activeIndex = Math.max(0, Math.min(index, links.length - 1));
      links.forEach((link, current) => {
        const selected = current === activeIndex;
        link.setAttribute("aria-selected", String(selected));
        if (selected) {
          input.setAttribute("aria-activedescendant", link.id);
          link.scrollIntoView({ block: "nearest" });
        }
      });
    }

    function renderMessage(message) {
      results.replaceChildren();
      const empty = document.createElement("div");
      empty.className = "doc-search-empty";
      empty.setAttribute("role", "status");
      empty.textContent = message;
      results.append(empty);
      renderedItems = [];
      activeIndex = -1;
      input.removeAttribute("aria-activedescendant");
      openResults();
    }

    function render(items, query) {
      results.replaceChildren();
      renderedItems = items.slice(0, 8);
      activeIndex = -1;
      input.removeAttribute("aria-activedescendant");

      if (!renderedItems.length) {
        renderMessage(`No results for "${query}".`);
        setStatus(`No results for ${query}.`);
        return;
      }

      const summary = document.createElement("div");
      summary.className = "doc-search-results__summary";
      summary.textContent = `${renderedItems.length} result${renderedItems.length === 1 ? "" : "s"}`;
      results.append(summary);

      renderedItems.forEach((item, index) => {
        const link = document.createElement("a");
        link.id = `doc-search-result-${index}`;
        link.className = "doc-search-result";
        link.href = asset(item.url);
        link.setAttribute("role", "option");
        link.setAttribute("aria-selected", "false");
        link.dataset.docSearchResult = "";

        const row = document.createElement("span");
        row.className = "doc-search-result__row";

        const title = document.createElement("span");
        title.className = "doc-search-result__title";
        title.textContent = item.title || item.url;
        row.append(title);

        const kind = document.createElement("span");
        kind.className = "doc-search-result__kind";
        kind.textContent = resultKind(item);
        row.append(kind);
        link.append(row);

        if (item.excerpt || item.description) {
          const text = document.createElement("span");
          text.className = "doc-search-result__text";
          text.textContent = item.excerpt || item.description;
          link.append(text);
        }

        link.addEventListener("pointermove", () => setActive(index));
        results.append(link);
      });

      openResults();
      setStatus(`${renderedItems.length} results available.`);
    }

    async function search() {
      const request = ++searchRequest;
      const query = input.value.trim().toLowerCase();
      const terms = query.split(/\s+/).filter(Boolean);
      if (!terms.length) {
        results.replaceChildren();
        setStatus("");
        closeResults();
        return;
      }

      if (!loadPromise || root.dataset.state === "loading") renderMessage("Searching...");
      await loadIndex();
      if (request !== searchRequest || document.activeElement !== input) return;

      if (root.dataset.state === "error") {
        renderMessage("Search is unavailable.");
        setStatus("Search is unavailable.");
        return;
      }

      const matches = pages
        .map((page) => ({ page, score: score(page, terms) }))
        .filter((entry) => entry.score > 0)
        .sort((a, b) => b.score - a.score || a.page.title.localeCompare(b.page.title))
        .map((entry) => entry.page);
      render(matches, query);
    }

    root.addEventListener("submit", (event) => {
      event.preventDefault();
      const target = renderedItems[activeIndex >= 0 ? activeIndex : 0];
      if (target) window.location.assign(asset(target.url));
    });

    input.addEventListener("focus", () => {
      loadIndex();
      if (input.value.trim()) search();
    });
    input.addEventListener("input", search);
    input.addEventListener("keydown", (event) => {
      if (event.key === "ArrowDown" && renderedItems.length) {
        event.preventDefault();
        setActive(activeIndex < 0 ? 0 : activeIndex + 1);
      } else if (event.key === "ArrowUp" && renderedItems.length) {
        event.preventDefault();
        setActive(activeIndex < 0 ? renderedItems.length - 1 : activeIndex - 1);
      } else if (event.key === "Escape" && !results.hidden) {
        event.preventDefault();
        event.stopPropagation();
        closeResults();
      }
    });

    document.addEventListener("pointerdown", (event) => {
      if (!root.contains(event.target)) closeResults();
    });
  }

  function setupNavigation() {
    const nav = document.querySelector("[data-doc-nav]");
    const toggle = document.querySelector("[data-doc-nav-toggle]");
    const close = document.querySelector("[data-doc-nav-close]");
    const scrim = document.querySelector("[data-doc-nav-scrim]");
    if (!nav || !toggle || !close || !scrim) return;

    const mobile = window.matchMedia("(max-width: 800px)");
    let open = false;
    let previousFocus;
    let motionTimer;

    function setMotion(animate) {
      window.clearTimeout(motionTimer);
      if (!animate || reducedMotion.matches) {
        document.body.removeAttribute("data-nav-animate");
        return;
      }
      document.body.dataset.navAnimate = "";
      nav.getBoundingClientRect();
      motionTimer = window.setTimeout(() => {
        document.body.removeAttribute("data-nav-animate");
      }, 240);
    }

    function setOpen(next, options = {}) {
      if (!mobile.matches && next) return;
      setMotion(!options.immediate);
      open = next;
      document.body.toggleAttribute("data-nav-open", open);
      toggle.setAttribute("aria-expanded", String(open));
      nav.setAttribute("aria-hidden", String(mobile.matches && !open));

      if (open) {
        previousFocus = document.activeElement;
        close.focus({ preventScroll: true });
      } else if (options.restoreFocus && previousFocus instanceof HTMLElement) {
        previousFocus.focus({ preventScroll: true });
      }
    }

    function syncBreakpoint() {
      window.clearTimeout(motionTimer);
      document.body.removeAttribute("data-nav-animate");
      if (!mobile.matches) {
        open = false;
        document.body.removeAttribute("data-nav-open");
        toggle.setAttribute("aria-expanded", "false");
        nav.removeAttribute("aria-hidden");
      } else if (!open) {
        nav.setAttribute("aria-hidden", "true");
      }
    }

    toggle.addEventListener("click", (event) => {
      setOpen(!open, { immediate: event.detail === 0, restoreFocus: open });
    });
    close.addEventListener("click", (event) => {
      setOpen(false, { immediate: event.detail === 0, restoreFocus: true });
    });
    scrim.addEventListener("click", () => setOpen(false, { restoreFocus: true }));

    nav.addEventListener("click", (event) => {
      if (mobile.matches && event.target.closest("a")) setOpen(false);
    });

    document.addEventListener("keydown", (event) => {
      if (!open || !mobile.matches) return;
      if (event.key === "Escape") {
        event.preventDefault();
        setOpen(false, { immediate: true, restoreFocus: true });
        return;
      }
      if (event.key !== "Tab") return;

      const focusable = Array.from(
        nav.querySelectorAll('a[href], button:not([disabled]), input:not([disabled])'),
      ).filter((element) => !element.hasAttribute("hidden"));
      if (!focusable.length) return;
      const first = focusable[0];
      const last = focusable[focusable.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    });

    mobile.addEventListener("change", syncBreakpoint);
    window.addEventListener("resize", syncBreakpoint, { passive: true });
    syncBreakpoint();
  }

  function fallbackCopy(text) {
    const previousFocus = document.activeElement;
    const textarea = document.createElement("textarea");
    textarea.value = text;
    textarea.setAttribute("readonly", "");
    textarea.setAttribute("aria-hidden", "true");
    textarea.style.position = "fixed";
    textarea.style.top = "0";
    textarea.style.left = "-9999px";
    textarea.style.width = "1px";
    textarea.style.height = "1px";
    textarea.style.padding = "0";
    textarea.style.border = "0";
    textarea.style.opacity = "0";
    document.body.append(textarea);
    try {
      textarea.focus({ preventScroll: true });
      textarea.select();
      textarea.setSelectionRange(0, textarea.value.length);
      return document.execCommand("copy");
    } finally {
      textarea.remove();
      if (previousFocus instanceof HTMLElement) previousFocus.focus({ preventScroll: true });
    }
  }

  function copyIcon(name, className) {
    const icon = document.createElement("img");
    icon.className = className;
    icon.src = asset(`/icons/${name}.svg`);
    icon.alt = "";
    icon.width = 15;
    icon.height = 15;
    return icon;
  }

  function createCopyButton() {
    const button = document.createElement("button");
    button.className = "copy-button";
    button.type = "button";
    button.title = "Copy code";
    button.setAttribute("aria-label", "Copy code");
    button.dataset.copyButton = "";
    button.append(
      copyIcon("copy", "copy-button__icon copy-button__icon--copy"),
      copyIcon("check", "copy-button__icon copy-button__icon--check"),
    );

    const label = document.createElement("span");
    label.className = "visually-hidden";
    label.setAttribute("aria-live", "polite");
    label.dataset.copyLabel = "";
    label.textContent = "Copy";
    button.append(label);
    return button;
  }

  function setupProseCodeBlocks() {
    document.querySelectorAll(".docs-article pre > code").forEach((code) => {
      const pre = code.parentElement;
      if (!pre || pre.closest("[data-code-block]")) return;

      const block = document.createElement("div");
      block.className = "code-block prose-code-block";
      block.dataset.codeBlock = "";
      pre.replaceWith(block);
      pre.classList.add("code-definition");
      pre.tabIndex = 0;
      pre.setAttribute("aria-label", "Code");
      block.append(pre, createCopyButton());
    });
  }

  function setupCopyButtons() {
    document.querySelectorAll("[data-copy-button]").forEach((button) => {
      let resetTimer;
      button.addEventListener("click", async (event) => {
        const block = button.closest("[data-code-block]");
        const code = block?.querySelector("code")?.textContent;
        if (!code) return;

        if (event.detail === 0) button.dataset.instant = "";
        window.clearTimeout(resetTimer);

        try {
          let copied = fallbackCopy(code);
          if (!copied && navigator.clipboard?.writeText) {
            await Promise.race([
              navigator.clipboard.writeText(code),
              new Promise((_, reject) =>
                window.setTimeout(() => reject(new Error("Clipboard timed out")), 500),
              ),
            ]);
            copied = true;
          }
          if (!copied) throw new Error("Copy failed");
          button.dataset.state = "copied";
          button.setAttribute("aria-label", "Copied");
          button.title = "Copied";
          button.querySelector("[data-copy-label]").textContent = "Copied";
        } catch (_error) {
          button.dataset.state = "error";
          button.setAttribute("aria-label", "Copy failed");
          button.title = "Copy failed. Try again.";
          button.querySelector("[data-copy-label]").textContent = "Failed";
        }

        delete button.dataset.instant;
        resetTimer = window.setTimeout(() => {
          delete button.dataset.state;
          button.setAttribute("aria-label", "Copy code");
          button.title = "Copy code";
          button.querySelector("[data-copy-label]").textContent = "Copy";
        }, 1800);
      });
    });
  }

  function setupDeclarations() {
    document.querySelectorAll("[data-declaration]").forEach((declaration) => {
      const toggle = declaration.querySelector("[data-declaration-toggle]");
      if (!toggle) return;
      toggle.hidden = false;
      toggle.addEventListener("click", () => {
        const expanded = declaration.classList.toggle("is-expanded");
        toggle.setAttribute("aria-expanded", String(expanded));
        toggle.textContent = expanded ? "Show less" : "Show full declaration";
        if (!expanded) toggle.scrollIntoView({ block: "nearest" });
      });
    });

    const anchor = document.querySelector(".docs-article #parameters");
    const heading = anchor?.matches("h2, h3") ? anchor : anchor?.parentElement.nextElementSibling;
    const list = heading?.nextElementSibling;
    if (list?.tagName === "UL") list.classList.add("parameter-list");
  }

  function setupOverview() {
    const overview = document.querySelector("#page-overview");
    if (!overview) return;

    const entries = Array.from(overview.querySelectorAll('a[href^="#"]'))
      .map((link) => ({ link, target: document.querySelector(link.getAttribute("href")) }))
      .filter((entry) => entry.target);
    if (!entries.length) return;

    let scheduled = false;
    function update() {
      scheduled = false;
      let current = entries[0];
      for (const entry of entries) {
        if (entry.target.getBoundingClientRect().top <= 144) current = entry;
        else break;
      }
      entries.forEach((entry) => {
        if (entry === current) entry.link.setAttribute("aria-current", "location");
        else entry.link.removeAttribute("aria-current");
      });
    }

    function schedule() {
      if (scheduled) return;
      scheduled = true;
      requestAnimationFrame(update);
    }

    window.addEventListener("scroll", schedule, { passive: true });
    window.addEventListener("hashchange", schedule);
    update();
  }

  setupSearch();
  setupNavigation();
  setupProseCodeBlocks();
  setupCopyButtons();
  setupDeclarations();
  setupOverview();
})();
