document.addEventListener("DOMContentLoaded", () => {
  let deleteTargetId = null;

  const modal = document.getElementById("deleteModal");
  const confirmBtn = document.getElementById("confirmDeleteBtn");
  const cancelBtn = document.getElementById("cancelDeleteBtn");
  const form = document.getElementById("newPostForm");
  const discussionList = document.getElementById("discussionList");
  const params = new URLSearchParams(window.location.search);
  const userIdFromQuery = params.get("userId");
  const userIdFromStorage = localStorage.getItem("userId");
  const userId = userIdFromQuery || userIdFromStorage;

  if (userIdFromQuery && userIdFromQuery !== userIdFromStorage) {
    localStorage.setItem("userId", userIdFromQuery);
  }

  if (!userId) {
    window.location.href = "/Sprint2Alberto/CustomerSingInPage.html";
    return;
  }

  function safe(str) {
    return String(str || "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
  }

  function renderEmpty(message) {
    discussionList.innerHTML = `<p style="color:rgba(175,200,245,0.72);">${safe(message)}</p>`;
  }

  function renderPost(post) {
    const div = document.createElement("div");
    div.className = "content-box";
    div.style.marginTop = "12px";

    const isOwner = String(post.UserID) === String(userId);

    div.innerHTML = `
      <h3 style="margin-bottom:8px;">${safe(post.Title)}</h3>
      <p style="margin-bottom:8px;">${safe(post.Content)}</p>
      <small style="color:rgba(175,200,245,0.72);">By ${safe(post.UserName)}</small>
      <div style="margin-top:12px; display:flex; gap:8px; flex-wrap:wrap;">
        ${isOwner ? `<button onclick="deletePost(${post.DiscussionID})">Delete</button>` : ""}
        <button onclick="bookmark(${post.DiscussionID})">Bookmark</button>
      </div>
      <div id="replies-${post.DiscussionID}" style="margin-top:12px;"></div>
      <div class="reply-box" style="margin-top:10px; display:flex; gap:8px; flex-wrap:wrap;">
        <input
          type="text"
          id="reply-input-${post.DiscussionID}"
          placeholder="Write a reply..."
          class="reply-input"
          style="flex:1; min-width:220px;"
        />
        <button onclick="submitReply(${post.DiscussionID})">Reply</button>
      </div>
    `;

    discussionList.appendChild(div);
    loadReplies(post.DiscussionID);
  }

  async function loadReplies(id) {
    try {
      const res = await fetch(`/discussions/${id}/replies`);
      const replies = await res.json();
      const container = document.getElementById(`replies-${id}`);
      container.innerHTML = "";

      (replies || []).forEach((r) => {
        const p = document.createElement("p");
        p.style.marginBottom = "6px";
        p.innerHTML = `<strong>${safe(r.UserName)}:</strong> ↳ ${safe(r.Content)}`;
        container.appendChild(p);
      });
    } catch {
      const container = document.getElementById(`replies-${id}`);
      if (container) container.innerHTML = "<p>Could not load replies.</p>";
    }
  }

  window.loadDiscussions = async function () {
    try {
      const res = await fetch("/discussions");
      const data = await res.json();
      discussionList.innerHTML = "";

      if (!Array.isArray(data) || data.length === 0) {
        renderEmpty("No discussions yet. Start one above.");
        return;
      }

      data.forEach((post) => renderPost(post));
    } catch {
      renderEmpty("Could not load discussions right now.");
    }
  };

  window.loadBookmarks = async function () {
    try {
      const res = await fetch(`/bookmarks/${userId}`);
      const data = await res.json();
      discussionList.innerHTML = "";

      if (!Array.isArray(data) || data.length === 0) {
        renderEmpty("No bookmarked discussions yet.");
        return;
      }

      data.forEach((post) => renderPost(post));
    } catch {
      renderEmpty("Could not load bookmarks right now.");
    }
  };

  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const title = document.getElementById("postTitle").value.trim();
    const content = document.getElementById("postContent").value.trim();
    if (!title || !content) return;

    const res = await fetch("/discussions", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId: Number(userId), title, content })
    });

    if (!res.ok) {
      alert("Failed to create discussion.");
      return;
    }

    form.reset();
    window.loadDiscussions();
  });

  window.submitReply = async (id) => {
    const input = document.getElementById(`reply-input-${id}`);
    const content = input.value.trim();
    if (!content) return;

    const res = await fetch(`/discussions/${id}/replies`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId: Number(userId), content })
    });

    if (!res.ok) {
      alert("Failed to post reply.");
      return;
    }

    input.value = "";
    window.loadDiscussions();
  };

  window.deletePost = (id) => {
    deleteTargetId = id;
    modal.classList.remove("hidden");
  };

  window.bookmark = async (id) => {
    const res = await fetch("/bookmarks", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId: Number(userId), discussionId: id })
    });

    if (!res.ok) {
      alert("Failed to update bookmark.");
      return;
    }

    window.loadDiscussions();
  };

  confirmBtn.addEventListener("click", async () => {
    if (!deleteTargetId) return;

    const res = await fetch(`/discussions/${deleteTargetId}`, {
      method: "DELETE",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ userId: Number(userId) })
    });

    if (!res.ok) {
      const data = await res.json().catch(() => ({}));
      alert(data.error || "Could not delete this post.");
      modal.classList.add("hidden");
      deleteTargetId = null;
      return;
    }

    modal.classList.add("hidden");
    deleteTargetId = null;
    window.loadDiscussions();
  });

  cancelBtn.addEventListener("click", () => {
    modal.classList.add("hidden");
    deleteTargetId = null;
  });

  window.loadDiscussions();
});